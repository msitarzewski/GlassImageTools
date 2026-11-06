import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import PhotosUI
import CoreTransferable
import UniformTypeIdentifiers
import VisionSnipCore

struct ImportedPhoto: Transferable, Sendable {
    let copy: OwnedImageImport
    let name: String
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .image) { received in
            ImportedPhoto(copy: try ImageImportService.copyOwnedForImport(received.file),
                          name: received.file.lastPathComponent)
        }
    }
}

enum EditorMode: String, CaseIterable { case crop = "Crop", annotate = "Annotate" }
enum CanvasTool: Hashable {
    case select, pan, annotation(AnnotationKind)
}

@Observable @MainActor
final class EditorModel {
    init(source: ImageSource? = nil) { if let source { accept(source) } }
    var source: ImageSource?
    var edit = EditState(crop: .zero)
    var mode: EditorMode = .crop
    var tool: CanvasTool = .select
    var preset: CropPreset { edit.preset }
    var selectedAnnotation: UUID?
    var strokeColor: Color = .red
    var strokeWidth: CGFloat = 8
    var fillColor: Color = .red
    var fillsShapes = false
    var textLabel = "Label"
    var fontName = "System"
    var fontSize: CGFloat = 48
    var bold = false
    var italic = false
    var underline = false
    var textAlignment: AnnotationTextAlignment = .leading
    var lastShape: AnnotationKind = .rectangle
    var textEditingRequest = UUID()
    var selectionRevealRequest = UUID()
    var zoom: CGFloat = 1
    var pan: CGSize = .zero
    var busy = false
    /// Copy renders a snapshot in the background; editing continues and only Copy waits.
    var copying = false
    var error: String?
    var status: String?
    var history = EditHistory(EditState(crop: .zero))
    private var generation = UUID()
    private var inspectorTransaction = false
    private var canvasGestureActive = false
    var annotationInspectorPresented = false
    private var savedEdit = EditState(crop: .zero)

    var outputCrop: CGRect { source.map { CropGeometry.pixelAligned(edit.crop, in: $0.bounds) } ?? .zero }
    var displayCrop: CGRect { displayRect(outputCrop) }
    var outputSize: CGSize { edit.rotation.size(for: outputCrop.size) }
    var cropRatio: CGFloat? { preset.ratio.map { edit.rotation.swapsAxes ? 1 / $0 : $0 } }
    var selected: Annotation? { edit.annotations.first { $0.id == selectedAnnotation } }
    var selectedDisplayBounds: CGRect? { selected.map { displayRect($0.bounds) } }
    var hasUnsavedChanges: Bool { source != nil && edit != savedEdit }
    /// An open inspector session commits before Undo, so its pending change is already undoable.
    var canUndo: Bool { history.canUndo || hasPendingInspectorEdit }
    /// Committing a pending inspector change clears Redo, so Redo is unavailable until it ends.
    var canRedo: Bool { history.canRedo && !hasPendingInspectorEdit }
    private var hasPendingInspectorEdit: Bool { inspectorTransaction && edit != history.current }

    /// Fields, accessibility values and labels use the visible rotated axes; edits stay in upright source pixels.
    func displayRect(_ rect: CGRect) -> CGRect {
        source.map { rect.applying(edit.rotation.transform(in: $0.bounds)) } ?? .zero
    }
    func displayPoint(_ point: CGPoint) -> CGPoint {
        source.map { point.applying(edit.rotation.transform(in: $0.bounds)) } ?? .zero
    }
    private var displayBounds: CGRect {
        CGRect(origin: .zero, size: source.map { edit.rotation.size(for: $0.size) } ?? .zero)
    }
    /// Bounds a visible-axis value inside the rotated image, then maps it back to source pixels.
    private func sourceRect(fromDisplay rect: CGRect) -> CGRect {
        guard let source else { return .zero }
        return boundedRect(rect, in: displayBounds).applying(edit.rotation.transform(in: source.bounds).inverted())
    }
    var effectiveAnnotationKind: AnnotationKind {
        if let selected { return selected.kind }
        if case .annotation(let kind) = tool { return kind }
        return lastShape
    }
    /// This is the renderer's target source-pixel block size, not a visible stroke.
    var pixelationSize: CGFloat {
        let width = selected?.lineWidth ?? strokeWidth
        guard width.isFinite else { return 32 }
        return max(16, min(Annotation.maximumDimension, max(1, width)) * 4)
    }

    func selectAnnotation(_ id: UUID?) {
        guard id != selectedAnnotation else { return }
        finishInspectorTransaction()
        selectedAnnotation = id
    }
    /// Canvas geometry consumes this request; reveal never changes source edits or history.
    func revealSelection() {
        guard selected != nil else { return }
        tool = .select
        selectionRevealRequest = UUID()
    }
    func requestTextEditing() {
        guard selected?.kind == .text else { return }
        textEditingRequest = UUID()
    }
    func chooseTool(_ kind: AnnotationKind) {
        finishInspectorTransaction()
        tool = .annotation(kind); selectedAnnotation = nil
        if kind.isShape { lastShape = kind }
    }
    /// Toolbar entry point. Text and pixelation are placed immediately at the crop center, selected
    /// and ready to edit; shapes and freehand wait for a drag on the canvas.
    func useTool(_ kind: AnnotationKind) {
        chooseTool(kind)
        if kind == .text || kind == .pixelate { insertAnnotationAtCenter() }
    }
    func makeAnnotation(kind: AnnotationKind, points: [CGPoint]) -> Annotation {
        Annotation(kind: kind, points: points, color: rgba, lineWidth: strokeWidth, text: textLabel,
                   fontSize: fontSize, fillColor: kind.supportsFill && fillsShapes ? Self.rgba(fillColor) : nil,
                   fontName: fontName, bold: bold, italic: italic, underline: underline,
                   textAlignment: textAlignment)
    }

    /// A native action provides the same retained objects without requiring a canvas drag.
    func insertAnnotationAtCenter() {
        guard source != nil, !busy else { return }
        let kind: AnnotationKind
        if case .annotation(let chosen) = tool { kind = chosen } else { kind = lastShape }
        guard kind != .freehand else { return }
        finishInspectorTransaction()
        let crop = outputCrop
        guard !crop.isEmpty else { return }
        let width = max(1, crop.width * (kind == .text ? 0.6 : 0.4))
        let height = max(1, crop.height * (kind == .text ? 0.2 : 0.3))
        let frame = CGRect(x: crop.midX - width / 2, y: crop.midY - height / 2, width: width, height: height)
        let annotation = makeAnnotation(kind: kind, points: [frame.origin, CGPoint(x: frame.maxX, y: frame.maxY)])
        var state = edit
        state.crop = crop
        state.annotations.append(annotation)
        commit(state)
        mode = .annotate; tool = .select; selectedAnnotation = annotation.id
        if kind == .text { requestTextEditing() }
    }

    /// Only an actual durable save of the still-current document makes its edits clean.
    @discardableResult func markSaved(source savedSource: ImageSource, edits snapshot: EditState) -> Bool {
        guard source === savedSource, edit == snapshot else { return false }
        savedEdit = snapshot
        return true
    }

    func closeImage() {
        generation = UUID()
        source = nil; edit = EditState(crop: .zero); savedEdit = edit; history = EditHistory(edit)
        inspectorTransaction = false; canvasGestureActive = false; annotationInspectorPresented = false
        selectedAnnotation = nil; tool = .select; mode = .crop
        busy = false; copying = false; error = nil; status = nil; fit()
    }

    func commit(_ state: EditState) {
        edit = state
        if !inspectorTransaction { history.commit(state) }
        status = nil
    }
    /// Live form edits end before a canvas gesture changes geometry.
    func beginCanvasGesture() {
        finishInspectorTransaction()
        canvasGestureActive = true
    }
    func finishGesture() {
        inspectorTransaction = false
        commit(edit)
        canvasGestureActive = false
        if annotationInspectorPresented { beginInspectorTransaction() }
    }

    // A live form editing session is one operation; canvas gestures keep their own Undo steps.
    func beginInspectorTransaction() {
        guard !canvasGestureActive else { return }
        inspectorTransaction = true
    }
    func finishInspectorTransaction() {
        guard inspectorTransaction else { return }
        inspectorTransaction = false
        history.commit(edit)
    }
    func undo() {
        finishInspectorTransaction(); history.undo(); restoreHistoryState()
        if annotationInspectorPresented { beginInspectorTransaction() }
    }
    func redo() {
        finishInspectorTransaction(); history.redo(); restoreHistoryState()
        if annotationInspectorPresented { beginInspectorTransaction() }
    }
    private func restoreHistoryState() {
        let oldRotation = edit.rotation
        edit = history.current
        if edit.rotation != oldRotation { fit() }
        if !edit.annotations.contains(where: { $0.id == selectedAnnotation }) { selectedAnnotation = nil }
        status = nil
    }
    func fit() { zoom = 1; pan = .zero }
    /// Keeps the view point at `offset` from the canvas center fixed while magnifying.
    /// The default zooms around the visible center; only the viewport changes.
    func setZoom(_ value: CGFloat, around offset: CGSize = .zero) {
        guard value.isFinite, zoom.isFinite, zoom > 0, offset.width.isFinite, offset.height.isFinite else { return }
        let next = min(8, max(1, value))
        let ratio = next / zoom
        pan = CGSize(width: offset.width * (1 - ratio) + pan.width * ratio,
                     height: offset.height * (1 - ratio) + pan.height * ratio)
        zoom = next
    }

    func changeMode(_ newMode: EditorMode) {
        // Snap the crop before annotation so the canvas and the export use exactly the same bounds.
        if newMode == .annotate {
            var state = edit; state.crop = outputCrop; commit(state)
        }
        finishInspectorTransaction()
        mode = newMode; tool = .select
    }

    func setPreset(_ value: CropPreset) {
        guard let source else { return }
        var state = edit
        state.preset = value
        state.crop = CropGeometry.preset(value, inside: source.bounds, rotation: edit.rotation)
        commit(state)
    }

    func rotateLeft() {
        guard source != nil, !busy else { return }
        finishInspectorTransaction()
        var state = edit
        state.rotation = state.rotation.turnedLeft
        if state.preset != .square { state.preset = .freeform }
        commit(state)
        fit()
    }

    func resetCrop() {
        guard let source else { return }
        var state = edit; state.crop = source.bounds; state.preset = .freeform; commit(state); fit()
    }

    func updateSelected(_ update: (inout Annotation) -> Void) {
        guard let index = edit.annotations.firstIndex(where: { $0.id == selectedAnnotation }) else { return }
        var state = edit; update(&state.annotations[index]); commit(state)
    }

    func deleteSelection() {
        finishInspectorTransaction()
        var state = edit; state.annotations.removeAll { $0.id == selectedAnnotation }
        selectedAnnotation = nil; commit(state)
        if annotationInspectorPresented { beginInspectorTransaction() }
    }

    func duplicateSelection() {
        guard let selected, let source else { return }
        finishInspectorTransaction()
        var duplicate = Annotation(kind: selected.kind, points: selected.points, color: selected.color,
            lineWidth: selected.lineWidth, text: selected.text, fontSize: selected.fontSize,
            fillColor: selected.fillColor, fontName: selected.fontName, bold: selected.bold,
            italic: selected.italic, underline: selected.underline, textAlignment: selected.textAlignment)
        let offset = min(24, max(0, source.bounds.maxX - duplicate.bounds.maxX),
                         max(0, source.bounds.maxY - duplicate.bounds.maxY))
        duplicate = duplicate.moved(by: CGSize(width: offset, height: offset))
        var state = edit; state.annotations.append(duplicate); commit(state); selectedAnnotation = duplicate.id
        if annotationInspectorPresented { beginInspectorTransaction() }
    }

    func bringSelectionToFront() { reorderSelection(toFront: true) }
    func sendSelectionToBack() { reorderSelection(toFront: false) }
    private func reorderSelection(toFront: Bool) {
        guard let index = edit.annotations.firstIndex(where: { $0.id == selectedAnnotation }) else { return }
        finishInspectorTransaction()
        var state = edit; let annotation = state.annotations.remove(at: index)
        state.annotations.insert(annotation, at: toFront ? state.annotations.endIndex : 0)
        commit(state)
        if annotationInspectorPresented { beginInspectorTransaction() }
    }

    func setStrokeColor(_ value: Color) {
        guard let color = Self.rgba(value) else { return }
        strokeColor = value
        updateSelected { $0.color = color }
    }
    func setStrokeWidth(_ value: CGFloat) {
        strokeWidth = max(1, min(80, value))
        updateSelected { $0.lineWidth = strokeWidth }
    }
    func setPixelationSize(_ value: CGFloat) {
        guard value.isFinite else { return }
        setStrokeWidth(min(320, max(16, value)) / 4)
    }
    func setFillEnabled(_ enabled: Bool) {
        fillsShapes = enabled
        let fill = fillRGBA
        updateSelected { if $0.kind.supportsFill { $0.fillColor = enabled ? fill : nil } }
    }
    func setFillColor(_ value: Color) {
        guard let fill = Self.rgba(value) else { return }
        fillColor = value
        updateSelected { if $0.kind.supportsFill, $0.fillColor != nil { $0.fillColor = fill } }
    }

    /// SwiftUI's sRGB space is extended, so wide-gamut values survive the native color well.
    /// Value equality matters: a new CGColor-backed Color on every read made the ColorPicker
    /// treat its binding as externally changed and intermittently drop palette selections.
    static func color(_ value: StrokeColor) -> Color {
        Color(.sRGB, red: value.red, green: value.green, blue: value.blue, opacity: value.alpha)
    }

    // The setters admit only convertible colors, so these defaults cannot be reached in practice.
    var rgba: StrokeColor { Self.rgba(strokeColor) ?? .red }
    private var fillRGBA: StrokeColor { Self.rgba(fillColor) ?? .red }
    /// The system palette can return Display P3 colors; keep them as extended-range sRGB.
    static func rgba(_ value: Color) -> StrokeColor? {
        #if os(macOS)
        StrokeColor(converting: NSColor(value).cgColor)
        #else
        StrokeColor(converting: UIColor(value).cgColor)
        #endif
    }

    private func accept(_ image: ImageSource) {
        source = image; edit = EditState(crop: image.bounds); history = EditHistory(edit)
        savedEdit = edit
        strokeWidth = max(2, min(24, image.size.width / 400))
        mode = .crop; tool = .select; selectedAnnotation = nil
        inspectorTransaction = false; canvasGestureActive = false
        status = nil; fit()
    }

    private func importImage(_ operation: () async throws -> ImageSource) async {
        let token = UUID()
        generation = token; busy = true; error = nil
        defer { if generation == token { busy = false } }
        do {
            let image = try await operation()
            try Task.checkCancellation()
            guard generation == token else { return }
            accept(image)
        } catch is CancellationError {
            // A replaced or dismissed import must not report an error or change the document.
        } catch {
            if generation == token { self.error = error.localizedDescription }
        }
    }

    func importPhoto(_ item: PhotosPickerItem) async {
        await importImage {
            guard let photo = try await item.loadTransferable(type: ImportedPhoto.self) else { throw ImageError.unreadable }
            return try await ImageImportService.loadOwnedCopy(photo.copy, name: photo.name)
        }
    }

    func importFile(_ url: URL) async {
        await importImage {
            try await ImageImportService.importFileAsync(url)
        }
    }

    /// Providers arrive only after the user invokes the native Paste action.
    func pasteImage(_ providers: [NSItemProvider]) async {
        await importImage {
            try await ImageImportService.importItemProviders(providers, allowsImageLinks: true)
        }
    }

    /// Drops have the same owned-copy, cancellation and decoding boundary as explicit Paste.
    func dropImage(_ providers: [NSItemProvider]) async {
        await importImage {
            try await ImageImportService.importItemProviders(providers, fallbackName: "Dropped Image", emptyError: .noDroppedImage)
        }
    }

    /// Inspector values stay inside finite zero-origin bounds before any integer display conversion.
    private func boundedRect(_ rect: CGRect, in bounds: CGRect) -> CGRect {
        let width = min(bounds.width, max(1, rect.width.isFinite ? rect.width : 1))
        let height = min(bounds.height, max(1, rect.height.isFinite ? rect.height : 1))
        return CGRect(x: min(max(0, rect.minX.isFinite ? rect.minX : 0), bounds.width - width),
                      y: min(max(0, rect.minY.isFinite ? rect.minY : 0), bounds.height - height),
                      width: width, height: height)
    }

    func setCropDimension(_ value: Int, keyPath: WritableKeyPath<CGRect, CGFloat>) {
        guard source != nil else { return }
        var rect = displayCrop
        rect[keyPath: keyPath] = CGFloat(value)
        var state = edit
        state.crop = sourceRect(fromDisplay: rect)
        state.preset = .freeform
        commit(state)
    }

    /// Like crop fields, annotation fields follow the visible rotated axes.
    func setSelectedDimension(_ value: Int, keyPath: WritableKeyPath<CGRect, CGFloat>) {
        guard var rect = selectedDisplayBounds, source != nil else { return }
        rect[keyPath: keyPath] = CGFloat(value)
        let resized = sourceRect(fromDisplay: rect)
        updateSelected { $0 = $0.resized(to: resized) }
    }

    func displayedPixelValue(_ value: CGFloat) -> Int {
        guard value.isFinite else { return 0 }
        let limit = max(source?.size.width ?? 1, source?.size.height ?? 1)
        // Imported sources are bounded; a second bound makes conversion safe even for a forged state.
        let bounded = min(200_000_000, max(-200_000_000, min(limit, max(-limit, value))))
        // Source-pixel transforms can represent an exact typed width as 299.99999999999994.
        // Display the nearest pixel rather than truncating that harmless arithmetic remainder.
        return Int(bounded.rounded())
    }

    /// Font sizes are independent of image dimensions, unlike source-coordinate inspector values.
    func displayedFontSize(_ value: CGFloat) -> Int {
        guard value.isFinite else { return 48 }
        return Int(min(1000, max(8, value)))
    }

    /// Like the system Share › Copy, this does not block the editor: it copies the current snapshot.
    func copy() async {
        guard let source, !busy, !copying else { return }
        copying = true; error = nil; status = "Copying…"
        let snapshot = edit
        let token = generation
        defer { if generation == token { copying = false } }
        do {
            let output = try await ImageExportQueue.shared.export(source, edits: snapshot, format: .png)
            let data = try await Task.detached {
                try Data(contentsOf: output.url, options: .mappedIfSafe)
            }.value
            try Task.checkCancellation()
            guard generation == token, self.source === source else { return }
            guard ClipboardService.copy(data) else { throw CocoaError(.fileWriteUnknown) }
            status = "Copied \(Int(output.size.width)) × \(Int(output.size.height))"
        } catch is CancellationError {
            // The canceled operation must not update the clipboard.
        } catch { if generation == token { status = nil; self.error = error.localizedDescription } }
    }
}
