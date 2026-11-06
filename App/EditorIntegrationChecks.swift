#if DEBUG
import Foundation
import SwiftUI
import UIKit
import ImageIO
import UniformTypeIdentifiers
import VisionSnipCore

/// Explicit simulator smoke checks exercise the same services as the buttons. Never runs in Release.
@MainActor enum EditorIntegrationChecks {
    struct Check: Codable { let name: String; let passed: Bool; let detail: String }
    struct Report: Codable { let timestamp: Date; let checks: [Check] }
    static func run(model: EditorModel, savePhotos: Bool) async {
        var checks: [Check] = []
        guard let source = model.source else { return }
        checks.append(contentsOf: await workspaceChecks(source: source))
        checks.append(contentsOf: editorRegressionChecks(source: source))
        checks.append(contentsOf: await rotationChecks(source: source))
        checks.append(contentsOf: accessibleAnnotationChecks(source: source))
        checks.append(contentsOf: contextualInspectorChecks(source: source))
        checks.append(contentsOf: await directShareChecks(source: source))
        checks.append(contentsOf: await documentLifecycleChecks(source: source))
        checks.append(contentsOf: await imagePasteChecks(source: source))
        checks.append(contentsOf: await asyncImportOwnershipChecks(source: source))
        checks.append(contentsOf: await reviewFixChecks(source: source))
        checks.append(contentsOf: await toolbarActionChecks(source: source))
        let edits = EditState(crop: CGRect(x: 125, y: 100, width: 800, height: 600), annotations: [
            Annotation(kind: .rectangle, points: [CGPoint(x: 200, y: 200), CGPoint(x: 600, y: 400)]),
            Annotation(kind: .ellipse, points: [CGPoint(x: 400, y: 300), CGPoint(x: 700, y: 500)]),
            Annotation(kind: .arrow, points: [CGPoint(x: 250, y: 500), CGPoint(x: 600, y: 250)]),
            Annotation(kind: .freehand, points: [CGPoint(x: 300, y: 400), CGPoint(x: 400, y: 500), CGPoint(x: 500, y: 450)]),
            Annotation(kind: .text, points: [CGPoint(x: 200, y: 150), CGPoint(x: 800, y: 220)], text: "Glass Image Tools integration fixture"),
            Annotation(kind: .pixelate, points: [CGPoint(x: 600, y: 450), CGPoint(x: 800, y: 600)])
        ])
        model.commit(edits); model.changeMode(.annotate)
        for format in ExportFormat.allCases {
            do {
                let output = try await ImageExportQueue.shared.export(source, edits: edits, format: format)
                let document = try ExportFile(url: output.url)
                guard let decoded = CGImageSourceCreateWithData(document.data as CFData, nil),
                      let image = CGImageSourceCreateImageAtIndex(decoded, 0, nil),
                      image.width == 800, image.height == 600,
                      CGImageSourceGetType(decoded) as String? == format.type.identifier else { throw ImageError.encodeFailed }
                checks.append(Check(name: "\(format.rawValue) full-resolution export", passed: true,
                    detail: "Decoded 800 × 600 image; \(output.byteCount) bytes."))
                ClipboardService.copy(document.data, format: format)
                guard let pasted = UIPasteboard.general.data(forPasteboardType: format.type.identifier), pasted == document.data,
                      let pastedSource = CGImageSourceCreateWithData(pasted as CFData, nil),
                      let pastedImage = CGImageSourceCreateImageAtIndex(pastedSource, 0, nil),
                      pastedImage.width == 800, pastedImage.height == 600,
                      let systemImage = UIPasteboard.general.image?.cgImage,
                      systemImage.width == 800, systemImage.height == 600 else { throw ImageError.unreadable }
                checks.append(Check(name: "\(format.rawValue) clipboard round-trip", passed: true,
                    detail: "Read and decoded the actual system pasteboard data and standard UIImage representation."))
                if savePhotos {
                    try await ExportService.saveToPhotos(output)
                    checks.append(Check(name: "\(format.rawValue) Photos save", passed: true,
                        detail: "PHPhotoLibrary.performChanges completed for a new image asset."))
                }
            } catch {
                checks.append(Check(name: "\(format.rawValue) integration", passed: false, detail: error.localizedDescription))
            }
        }
        let report = Report(timestamp: .now, checks: checks)
        do {
            let data = try JSONEncoder().encode(report)
            try data.write(to: URL.documentsDirectory.appendingPathComponent("VisionSnipSmokeResults.json"), options: .atomic)
            model.status = checks.allSatisfy(\.passed) ? "Integration checks passed: \(checks.count)" : "Integration checks failed. See smoke report."
        } catch { model.error = "Could not write smoke report: \(error.localizedDescription)" }
    }

    private static func workspaceChecks(source: ImageSource) async -> [Check] {
        do {
            let workspace = DocumentWorkspace(source: source)
            let first = workspace.documents[0]
            first.model.setCropDimension(800, keyPath: \.size.width)
            first.model.zoom = 3; first.model.pan = CGSize(width: 40, height: 20)
            let edits = first.model.edit
            let second = EditorModel(source: source)
            let secondID = try workspace.add(second)
            let newIsClean = !second.history.canUndo && !second.hasUnsavedChanges
            workspace.select(first.id)
            let retained = workspace.model === first.model && first.model.edit == edits
                && first.model.zoom == 3 && first.model.pan == CGSize(width: 40, height: 20)
            first.model.undo()
            let independent = first.model.outputSize.width == 1600 && second.outputSize.width == 1600 && !second.history.canUndo
            first.model.redo()
            let output = try await ImageExportQueue.shared.export(source, edits: edits, format: .png)
            workspace.recordSave(output, documentID: first.id, source: source, edits: edits)
            let staleSave = !workspace.recordSave(output, documentID: UUID(), source: source, edits: edits)
                && !workspace.recordSave(output, documentID: secondID, source: source, edits: edits)
                && !second.hasUnsavedChanges && workspace.documents[1].savedOutput == nil
            let closeWarning = try await workspace.closeDocument(first.id)
            let flattened = workspace.recents[0].source
            let closed = closeWarning == nil && workspace.documents.count == 1 && workspace.selectedID == secondID && first.model.source == nil
            let recent = workspace.recents[0]
            try workspace.reopen(recent.id)
            let reopened = workspace.model.outputSize.width == 800 && workspace.model.outputSize.height == 1000
                && workspace.model.edit.annotations.isEmpty && !workspace.model.history.canUndo && !workspace.model.hasUnsavedChanges
                && workspace.recents.isEmpty
            let discardID = workspace.selectedID!
            workspace.model.setCropDimension(400, keyPath: \.size.width)
            try workspace.close(discardID, recentSource: flattened)
            try workspace.reopen(workspace.recents[0].id)
            let discarded = workspace.model.outputSize.width == 800 && !workspace.model.hasUnsavedChanges
            try workspace.close(workspace.selectedID!, recentSource: flattened)
            workspace.clearRecents()
            let cleared = workspace.recents.isEmpty && workspace.documents.count == 1 && second.source === source
            let limited = DocumentWorkspace(source: source, maximumDocuments: 1)
            var countRejected = false
            do { try limited.add(EditorModel(source: source)) } catch DocumentWorkspace.LimitError.openLimit { countRejected = true }
            var privateCopy: ImageSource? = try await ImageImportService.importFileAsync(output.url, name: "Private fixture.png")
            weak let weakCopy = privateCopy
            let privateURL = privateCopy!.url!
            let cleanupWorkspace = DocumentWorkspace(source: privateCopy)
            try cleanupWorkspace.close(cleanupWorkspace.selectedID!, recentSource: privateCopy!)
            privateCopy = nil
            let retainedUntilClear = weakCopy != nil && FileManager.default.fileExists(atPath: privateURL.path)
            cleanupWorkspace.clearRecents()
            let deletedOnClear = weakCopy == nil && !FileManager.default.fileExists(atPath: privateURL.path)
            let recovery = DocumentWorkspace(source: source)
            let recoveryID = recovery.selectedID!
            let missingOutput = try await ImageExportQueue.shared.export(source, edits: EditState(crop: source.bounds), format: .png)
            recovery.recordSave(missingOutput, documentID: recoveryID, source: source, edits: recovery.model.edit)
            try FileManager.default.removeItem(at: missingOutput.url)
            let recoveryWarning = try await recovery.closeDocument(recoveryID)
            let recovered = recoveryWarning != nil && recovery.documents.isEmpty && recovery.recents.isEmpty
            let cancelled = DocumentWorkspace(source: source)
            let cancelledID = cancelled.selectedID!
            let cancellation = Task { @MainActor in
                withUnsafeCurrentTask { $0?.cancel() }
                return try await cancelled.closeDocument(cancelledID)
            }
            var cancellationObserved = false
            do { _ = try await cancellation.value } catch is CancellationError { cancellationObserved = true }
            let cancelledOpen = cancellationObserved && cancelled.documents.count == 1 && cancelled.recents.isEmpty
            let rejectedInitial = DocumentWorkspace(source: source, maximumBytes: 1)
            let tiny = DocumentWorkspace(maximumBytes: 1)
            var bytesRejected = false
            do { try tiny.add(EditorModel(source: source)) } catch DocumentWorkspace.LimitError.storageLimit { bytesRejected = true }
            return [
                Check(name: "New document preserves current edits", passed: newIsClean && retained,
                      detail: "New model is clean; switching restores original crop, zoom and pan without replacing the source."),
                Check(name: "Independent document Undo", passed: independent,
                      detail: "Undo/Redo belongs to the selected document; another editor's history remains clean."),
                Check(name: "Close selects surviving document", passed: closed,
                      detail: "Closing releases the old editor source and selects the surviving model."),
                Check(name: "Saved recent reopens flattened", passed: reopened,
                      detail: "Actual PNG encoded/decoded at 800 by 1000; reopening has no vectors, dirty state or Undo history."),
                Check(name: "Discarded recent restores saved pixels", passed: discarded,
                      detail: "Discarding newer edits retains the last saved flattened image."),
                Check(name: "Clear Recents preserves open images", passed: cleared,
                      detail: "Recent ownership is removed while the other open document retains its immutable source."),
                Check(name: "Recent-copy failure cannot trap close", passed: recovered,
                      detail: "A deliberately removed synthetic saved output yields a visible warning and closes without a broken Recent."),
                Check(name: "Cancelled close preserves document", passed: cancelledOpen,
                      detail: "A cancelled actual close task leaves the source/model open and creates no Recent."),
                Check(name: "Stale save cannot affect another document", passed: staleSave,
                      detail: "Wrong identity or changed edit snapshot cannot mark another document saved or retain an unrelated output."),
                Check(name: "Clear Recents removes private copies", passed: retainedUntilClear && deletedOnClear,
                      detail: "Actual owned image file exists while recent, then its source and private file release on Clear Recents."),
                Check(name: "Workspace resource limits preserve documents", passed: countRejected && bytesRejected && limited.documents.count == 1 && tiny.documents.isEmpty && rejectedInitial.documents.isEmpty && rejectedInitial.emptyModel.error != nil,
                      detail: "Injected count and storage limits reject imports without evicting open edits or adding rows.")
            ]
        } catch { return [Check(name: "Document workspace lifecycle", passed: false, detail: error.localizedDescription)] }
    }

    private static func rotationChecks(source: ImageSource) async -> [Check] {
        let model = EditorModel(source: source)
        model.setCropDimension(800, keyPath: \.size.width)
        model.setCropDimension(600, keyPath: \.size.height)
        let original = model.edit
        model.rotateLeft()
        let rotated = model.edit
        let rotation = rotated.rotation == .left && rotated.crop == original.crop
            && model.outputSize == CGSize(width: 600, height: 800) && model.zoom == 1 && model.pan == .zero
        model.undo(); let undone = model.edit == original
        model.redo(); let redone = model.edit == rotated
        model.setCropDimension(250, keyPath: \.size.width)
        model.setCropDimension(400, keyPath: \.size.height)
        let fields = model.outputSize == CGSize(width: 250, height: 400)
            && source.bounds.contains(model.outputCrop)
        await model.copy()
        let copied = UIPasteboard.general.image?.cgImage
        let copy = model.error == nil && copied?.width == 250 && copied?.height == 400
        model.setPreset(.wide)
        let ratio = model.outputSize.width / model.outputSize.height
        return [
            Check(name: "Nondestructive quarter-turn and one-step Undo Redo", passed: rotation && undone && redone,
                  detail: "Rotation changes value state only; crop/source ownership is stable and the viewport fits."),
            Check(name: "Rotated exact crop dimensions and native Copy", passed: fields && copy,
                  detail: "Visible width/height map back to bounded source pixels; actual system image decodes at 250 by 400."),
            Check(name: "Rotated preset follows output axes", passed: abs(ratio - 16.0 / 9.0) < 0.01,
                  detail: "The 16:9 preset follows the visible/exported orientation.")
        ]
    }

    private static func asyncImportOwnershipChecks(source: ImageSource) async -> [Check] {
        do {
            let output = try await ImageExportQueue.shared.export(source, edits: EditState(crop: source.bounds), format: .png)
            let bytes = try Data(contentsOf: output.url)
            let model = EditorModel(source: source)
            model.setCropDimension(800, keyPath: \.size.width)
            await model.importFile(output.url)
            let fileImported = model.source.map {
                $0 !== source && $0.size == source.size && !model.hasUnsavedChanges
                    && !model.history.canUndo && model.error == nil && !model.busy
            } ?? false

            let root = FileManager.default.temporaryDirectory.appendingPathComponent("VisionSnip-Imports")
            let before = Set(try FileManager.default.contentsOfDirectory(atPath: root.path))
            var photo: ImportedPhoto? = ImportedPhoto(copy: try ImageImportService.copyOwnedForImport(output.url),
                                                     name: "Owned photo fixture")
            photo = nil
            let unconsumedCleaned = Set(try FileManager.default.contentsOfDirectory(atPath: root.path)) == before
            photo = ImportedPhoto(copy: try ImageImportService.copyOwnedForImport(output.url), name: "Cancelled photo fixture")
            guard let copy = photo?.copy else { throw ImageError.unreadable }
            let task = Task { try await ImageImportService.loadOwnedCopy(copy, name: "Cancelled photo fixture") }
            task.cancel()
            var cancelled = false
            do { _ = try await task.value }
            catch is CancellationError { cancelled = true }
            photo = nil
            // The local copy above remains an explicit owner until this helper's scope ends.
            // Unconsumed-transfer deletion and cancellation are asserted separately here; core
            // ownership regressions assert deletion after the final cancelled owner is released.
            let originalPreserved = try Data(contentsOf: output.url) == bytes
            return [
                Check(name: "Shared asynchronous file import", passed: fileImported && originalPreserved,
                    detail: "The native model imports through the shared worker, installs an immutable full-resolution source and resets the saved/history baseline."),
                Check(name: "Photo transfer ownership before decoding", passed: unconsumedCleaned && cancelled,
                    detail: "Dropping a real ImportedPhoto before decoding removes its private copy; cancelled shared-worker decoding throws cancellation without accepting a source.")
            ]
        } catch {
            return [Check(name: "Asynchronous import ownership", passed: false, detail: error.localizedDescription)]
        }
    }

    private static func accessibleAnnotationChecks(source: ImageSource) -> [Check] {
        let crop = CGRect(x: 125, y: 100, width: 800, height: 600)
        var geometryAndHistory = true
        var stylingAndSelection = true
        for kind in AnnotationKind.allCases where kind != .freehand {
            let model = EditorModel(source: source)
            model.commit(EditState(crop: crop))
            model.zoom = 3; model.pan = CGSize(width: 50, height: -35)
            model.strokeColor = .blue; model.strokeWidth = 12
            model.fontName = "Georgia"; model.fontSize = 64; model.bold = true
            model.chooseTool(kind)
            let before = model.edit
            let textRequest = model.textEditingRequest
            model.insertAnnotationAtCenter()
            guard let annotation = model.selected else { geometryAndHistory = false; continue }
            geometryAndHistory = geometryAndHistory && crop.contains(annotation.bounds)
                && annotation.bounds.midX == crop.midX && annotation.bounds.midY == crop.midY
                && annotation.kind == kind && model.mode == .annotate && model.tool == .select
                && model.zoom == 3 && model.pan == CGSize(width: 50, height: -35)
            stylingAndSelection = stylingAndSelection && annotation.color == model.rgba && annotation.lineWidth == 12
                && annotation.fontName == "Georgia" && annotation.fontSize == 64 && annotation.bold
                && (kind != .text || textRequest != model.textEditingRequest)
            let inserted = model.edit
            model.undo()
            geometryAndHistory = geometryAndHistory && model.edit == before
            model.redo()
            geometryAndHistory = geometryAndHistory && model.edit == inserted
        }
        let model = EditorModel(source: source)
        model.lastShape = .triangle
        model.insertAnnotationAtCenter()
        let defaultShape = model.selected?.kind == .triangle
        model.chooseTool(.freehand)
        let beforeFreehand = model.edit
        model.insertAnnotationAtCenter()
        let freehandRequiresDrawing = model.edit == beforeFreehand
        return [
            Check(name: "Accessible annotation insertion and Undo", passed: geometryAndHistory,
                detail: "Every supported non-freehand object is inserted in source pixels at the crop center, remains selected/editable, preserves zoom/pan and commits one Undo/Redo operation."),
            Check(name: "Accessible annotation style and text editing", passed: stylingAndSelection && defaultShape && freehandRequiresDrawing,
                detail: "Insertion reuses the current retained style and last shape, requests native text editing for text, and does not invent a freehand path.")
        ]
    }

    private static func contextualInspectorChecks(source: ImageSource) -> [Check] {
        let textModel = EditorModel(source: source)
        let original = textModel.edit
        textModel.lastShape = .triangle
        let lastShapeFallback = textModel.effectiveAnnotationKind == .triangle
        textModel.chooseTool(.text)
        let activeTool = textModel.effectiveAnnotationKind == .text
        textModel.textLabel = "Prepared label"
        textModel.fontName = "Georgia"; textModel.fontSize = 72
        textModel.bold = true; textModel.italic = true; textModel.underline = true
        textModel.textAlignment = .center; textModel.strokeColor = .blue
        textModel.fillsShapes = true
        let defaultsStayClean = textModel.edit == original && !textModel.hasUnsavedChanges
            && !textModel.history.canUndo
        textModel.insertAnnotationAtCenter()
        let insertedText = textModel.selected
        let textDefaultsApplied = insertedText?.kind == .text && insertedText?.text == "Prepared label"
            && insertedText?.fontName == "Georgia" && insertedText?.fontSize == 72
            && insertedText?.bold == true && insertedText?.italic == true && insertedText?.underline == true
            && insertedText?.textAlignment == .center && insertedText?.color == textModel.rgba
            && insertedText?.fillColor == nil
        textModel.tool = .annotation(.arrow)
        let selectionPrecedence = textModel.effectiveAnnotationKind == .text
        let insertedState = textModel.edit
        textModel.undo()
        let creationUndo = textModel.edit == original
        textModel.redo()
        let creationRedo = textModel.edit == insertedState

        let pixelModel = EditorModel(source: source)
        pixelModel.strokeWidth = 1
        pixelModel.chooseTool(.pixelate)
        pixelModel.insertAnnotationAtCenter()
        let pixelOriginal = pixelModel.selected
        let minimumSize = pixelModel.pixelationSize == 16
        pixelModel.beginInspectorTransaction()
        for size in [CGFloat(64), 96, 128] { pixelModel.setPixelationSize(size) }
        let pixelEdited = pixelModel.selected
        let targetSize = pixelModel.pixelationSize == 128 && pixelEdited?.lineWidth == 32
        pixelModel.setPixelationSize(.nan); pixelModel.setPixelationSize(.infinity)
        let invalidPreserved = pixelModel.selected == pixelEdited
        pixelModel.finishInspectorTransaction()
        pixelModel.undo()
        let pixelUndo = pixelModel.selected == pixelOriginal && pixelModel.pixelationSize == 16
        pixelModel.redo()
        let pixelRedo = pixelModel.selected == pixelEdited && pixelModel.pixelationSize == 128

        // Undo of creation clears selection; Redo restores content without reselecting it.
        // Reveal operates on an explicitly selected retained object, just as the native panel does.
        textModel.selectAnnotation(insertedText?.id)
        textModel.zoom = 4; textModel.pan = CGSize(width: 900, height: -600)
        let beforeReveal = textModel.edit
        let historyBeforeReveal = textModel.history.current
        let requestBeforeReveal = textModel.selectionRevealRequest
        textModel.revealSelection()
        let revealPreservesEdits = textModel.selectionRevealRequest != requestBeforeReveal
            && textModel.tool == .select && textModel.selectedAnnotation == insertedText?.id
            && textModel.edit == beforeReveal && textModel.history.current == historyBeforeReveal
            && textModel.zoom == 4 && textModel.pan == CGSize(width: 900, height: -600)
        textModel.undo()
        let revealAddsNoUndo = textModel.edit == original
        let liveModel = EditorModel(source: source)
        liveModel.chooseTool(.rectangle)
        liveModel.insertAnnotationAtCenter()
        let liveOriginal = liveModel.edit
        liveModel.annotationInspectorPresented = true
        liveModel.beginInspectorTransaction()
        liveModel.setStrokeColor(.blue)
        let firstStyle = liveModel.edit
        liveModel.beginCanvasGesture()
        // SwiftUI selection observers can run before the end of a drag; they must not absorb it.
        liveModel.beginInspectorTransaction()
        if let selected = liveModel.selected,
           let index = liveModel.edit.annotations.firstIndex(where: { $0.id == selected.id }) {
            liveModel.edit.annotations[index] = selected.moved(by: CGSize(width: 40, height: 20))
        }
        liveModel.finishGesture()
        let moved = liveModel.edit
        liveModel.setStrokeWidth(18)
        liveModel.finishInspectorTransaction()
        let secondStyle = liveModel.edit
        liveModel.undo()
        let secondStyleUndo = liveModel.edit == moved
        liveModel.undo()
        let movementUndo = liveModel.edit == firstStyle
        liveModel.undo()
        let firstStyleUndo = liveModel.edit == liveOriginal
        liveModel.redo(); liveModel.redo(); liveModel.redo()
        let liveRedo = liveModel.edit == secondStyle
        liveModel.beginInspectorTransaction()
        liveModel.beginCanvasGesture()
        liveModel.pan = CGSize(width: 12, height: 18)
        liveModel.finishGesture()
        liveModel.undo()
        let panAddedNoUndo = liveModel.edit == moved
        liveModel.setStrokeWidth(11); liveModel.setStrokeWidth(13); liveModel.setStrokeColor(.red)
        let styleAfterUndo = liveModel.edit
        liveModel.undo()
        let postUndoStyleGrouped = liveModel.edit == moved
        liveModel.redo()
        let postUndoStyleRedo = liveModel.edit == styleAfterUndo
        liveModel.setStrokeWidth(21); liveModel.setStrokeWidth(25); liveModel.setStrokeColor(.green)
        liveModel.undo()
        let postRedoStyleGrouped = liveModel.edit == styleAfterUndo
        return [
            Check(name: "Contextual annotation kind precedence", passed: lastShapeFallback && activeTool && selectionPrecedence,
                  detail: "The selected object owns inspector controls; an active annotation tool takes precedence over the remembered shape when nothing is selected."),
            Check(name: "Prepared text defaults and creation Undo", passed: defaultsStayClean && textDefaultsApplied && creationUndo && creationRedo,
                  detail: "Text content, font, traits, alignment and color prepared before insertion create the retained text object without irrelevant shape fill; insertion remains one reversible edit."),
            Check(name: "Source-pixel pixelation size and inspector Undo", passed: minimumSize && targetSize && invalidPreserved && pixelUndo && pixelRedo,
                  detail: "Pixelation reports the renderer's 16-pixel minimum and maps a 128-pixel target to its retained rendering parameter. Multiple live changes undo together; non-finite input is rejected."),
            Check(name: "Persistent inspector gesture Undo boundaries", passed: secondStyleUndo && movementUndo && firstStyleUndo && liveRedo && panAddedNoUndo
                    && postUndoStyleGrouped && postUndoStyleRedo && postRedoStyleGrouped,
                  detail: "Style, canvas movement and later style edits undo separately while the inspector stays visible. Multiple style changes after Undo or Redo still form one operation; mid-gesture callbacks do not absorb geometry, and Pan adds no edit."),
            Check(name: "Selection reveal preserves document and history", passed: revealPreservesEdits && revealAddsNoUndo,
                  detail: "Show Selection requests canvas-owned recentering without modifying source edits or adding Undo; actual viewport movement is verified by native canvas interaction separately.")
        ]
    }

    private static func directShareChecks(source: ImageSource) async -> [Check] {
        do {
            let original = try await ImageExportQueue.shared.export(source, edits: EditState(crop: source.bounds), format: .png)
            let originalBytes = try Data(contentsOf: original.url)
            let imported = try await ImageImportService.importFileAsync(original.url, name: "Direct share fixture")
            let crop = CGRect(x: 125, y: 100, width: 800, height: 600)
            let green = StrokeColor(red: 0, green: 1, blue: 0)
            let annotation = Annotation(kind: .rectangle,
                points: [crop.origin, CGPoint(x: crop.maxX, y: crop.maxY)], color: green,
                lineWidth: 8, fillColor: green)
            let bytes = try await EditedImageTransfer(source: imported,
                edits: EditState(crop: crop, annotations: [annotation])).pngData()
            guard let decoded = CGImageSourceCreateWithData(bytes as CFData, nil),
                  CGImageSourceGetCount(decoded) == 1,
                  CGImageSourceGetType(decoded) as String? == UTType.png.identifier,
                  let image = CGImageSourceCreateImageAtIndex(decoded, 0, nil),
                  image.width == 800, image.height == 600,
                  let ownedURL = imported.url else { throw ImageError.unreadable }
            var pixel = [UInt8](repeating: 0, count: 4)
            let renderedGreen = pixel.withUnsafeMutableBytes { buffer -> Bool in
                guard let context = CGContext(data: buffer.baseAddress, width: 1, height: 1,
                    bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
                else { return false }
                context.draw(image, in: CGRect(x: 0, y: 0, width: 1, height: 1))
                return true
            }
            let annotationApplied = renderedGreen && pixel[0] <= 2 && pixel[1] >= 253
                && pixel[2] <= 2 && pixel[3] == 255
            let originalPreserved = try Data(contentsOf: original.url) == originalBytes
                && Data(contentsOf: ownedURL) == originalBytes
            return [Check(name: "Direct native share snapshot bytes", passed: annotationApplied && originalPreserved,
                detail: "The real Transferable produces a single decoded 800×600 PNG with the flattened green annotation; original and private source bytes remain unchanged. No recipient behavior is inferred.")]
        } catch {
            return [Check(name: "Direct native share snapshot bytes", passed: false, detail: error.localizedDescription)]
        }
    }

    private static func imagePasteChecks(source: ImageSource) async -> [Check] {
        var checks: [Check] = []
        for format in ExportFormat.allCases {
            do {
                let output = try await ImageExportQueue.shared.export(source, edits: EditState(crop: source.bounds), format: format)
                let bytes = try Data(contentsOf: output.url)
                let provider = NSItemProvider()
                provider.suggestedName = "Pasted fixture"
                provider.registerDataRepresentation(forTypeIdentifier: format.type.identifier, visibility: .all) {
                    completion in completion(bytes, nil); return nil
                }
                let model = EditorModel(source: source)
                await model.pasteImage([provider])
                guard let pasted = model.source, pasted !== source, let owned = pasted.url,
                      pasted.size == source.size, pasted.typeIdentifier == format.type.identifier,
                      try Data(contentsOf: owned) == bytes, try Data(contentsOf: output.url) == bytes,
                      !model.hasUnsavedChanges, !model.history.canUndo, !model.busy, model.error == nil else {
                    throw ImageError.unreadable
                }
                checks.append(Check(name: "\(format.rawValue) explicit image paste", passed: true,
                    detail: "An actual NSItemProvider imports unchanged encoded bytes through the shared protected source pipeline and resets the editing baseline."))
            } catch {
                checks.append(Check(name: "\(format.rawValue) explicit image paste", passed: false, detail: error.localizedDescription))
            }
        }

        let model = EditorModel(source: source)
        model.setCropDimension(800, keyPath: \.size.width)
        let edit = model.edit
        let historyCanUndo = model.history.canUndo
        let malformed = NSItemProvider()
        malformed.registerDataRepresentation(forTypeIdentifier: UTType.png.identifier, visibility: .all) {
            completion in completion(Data("Malformed synthetic paste".utf8), nil); return nil
        }
        var rejectedAndPreserved = true
        for providers in [[], [NSItemProvider(object: "Copied text" as NSString)], [malformed]] {
            await model.pasteImage(providers)
            rejectedAndPreserved = rejectedAndPreserved && model.source === source && model.edit == edit
                && model.hasUnsavedChanges && model.history.canUndo == historyCanUndo && model.error != nil && !model.busy
        }
        checks.append(Check(name: "Invalid image paste preserves document", passed: rejectedAndPreserved,
            detail: "Empty, text-only and malformed encoded providers report errors while preserving the current source, crop, dirty state and Undo availability."))

        var cancelledAndPreserved = false
        var lateResultRejected = false
        var closeRejectsStalePaste = false
        do {
            let output = try await ImageExportQueue.shared.export(source, edits: EditState(crop: source.bounds), format: .png)
            let progress = Progress(totalUnitCount: 1)
            let (started, signal) = AsyncStream<Bool>.makeStream()
            let provider = NSItemProvider()
            provider.registerFileRepresentation(forTypeIdentifier: UTType.png.identifier, fileOptions: [], visibility: .all) {
                completion in
                signal.yield(true)
                DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(150)) {
                    completion(output.url, false, nil)
                }
                return progress
            }
            let task = Task { await model.pasteImage([provider]) }
            for await _ in started { break }
            task.cancel()
            await task.value
            cancelledAndPreserved = model.source === source && model.edit == edit && model.hasUnsavedChanges
                && model.history.canUndo == historyCanUndo && !model.busy && model.error == nil
            try await Task.sleep(for: .milliseconds(250))
            lateResultRejected = progress.isCancelled && model.source === source && model.edit == edit && !model.busy

            let (nextStarted, nextSignal) = AsyncStream<Bool>.makeStream()
            let nextProvider = NSItemProvider()
            nextProvider.registerFileRepresentation(forTypeIdentifier: UTType.png.identifier, fileOptions: [], visibility: .all) {
                completion in
                nextSignal.yield(true)
                DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(50)) {
                    completion(output.url, false, nil)
                }
                return nil
            }
            let nextTask = Task { await model.pasteImage([nextProvider]) }
            for await _ in nextStarted { break }
            model.closeImage()
            await nextTask.value
            closeRejectsStalePaste = model.source == nil && !model.history.canUndo && !model.busy && model.error == nil
        } catch {
            cancelledAndPreserved = false
        }
        checks.append(Check(name: "Cancelled image paste preserves document", passed: cancelledAndPreserved && lateResultRejected,
            detail: "Cancelling an in-flight provider propagates to its Progress, preserves source/edit/history and ignores a delayed completion."))
        checks.append(Check(name: "Closed document rejects stale image paste", passed: closeRejectsStalePaste,
            detail: "Closing while a provider loads prevents its eventual successful source from reopening or changing the document."))
        return checks
    }

    private static func documentLifecycleChecks(source: ImageSource) async -> [Check] {
        let model = EditorModel(source: source)
        let initial = model.edit
        let startsClean = !model.hasUnsavedChanges
        model.setCropDimension(800, keyPath: \.size.width)
        let changed = model.hasUnsavedChanges
        model.undo()
        let undoIsClean = !model.hasUnsavedChanges && model.history.canRedo
        model.redo()
        let snapshot = model.edit
        let saved = model.markSaved(source: source, edits: snapshot)
        let cleanWithUndo = !model.hasUnsavedChanges && model.history.canUndo
        model.undo()
        let undoAwayIsDirty = model.hasUnsavedChanges
        let staleRejected = !model.markSaved(source: source, edits: snapshot) && model.hasUnsavedChanges
        let replacement = EditorModel(source: source)
        replacement.setCropDimension(800, keyPath: \.size.width)
        let preserved = replacement.edit
        await replacement.importFile(URL.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("png"))
        let failedImportPreserved = replacement.source === source && replacement.edit == preserved
            && replacement.hasUnsavedChanges && replacement.error != nil
        var cancelledImportPreserved = false
        do {
            let output = try await ImageExportQueue.shared.export(source, edits: initial, format: .png)
            let task = Task { await replacement.importFile(output.url) }
            task.cancel()
            await task.value
            cancelledImportPreserved = replacement.source === source && replacement.edit == preserved
                && replacement.hasUnsavedChanges && !replacement.busy
        } catch {
            cancelledImportPreserved = false
        }
        model.closeImage()
        let closeClears = model.source == nil && !model.hasUnsavedChanges && !model.history.canUndo
            && model.edit.annotations.isEmpty && !model.markSaved(source: source, edits: initial)

        let textModel = EditorModel(source: source)
        let annotation = textModel.makeAnnotation(kind: .text,
            points: [CGPoint(x: 100, y: 100), CGPoint(x: 700, y: 300)])
        textModel.commit(EditState(crop: source.bounds, annotations: [annotation]))
        textModel.selectAnnotation(annotation.id)
        let oldRequest = textModel.textEditingRequest
        textModel.requestTextEditing()
        let editingRequested = oldRequest != textModel.textEditingRequest
        let safeFontDisplay = textModel.displayedFontSize(500) == 500
            && textModel.displayedFontSize(.greatestFiniteMagnitude) == 1000
            && textModel.displayedFontSize(-10) == 8
            && textModel.displayedFontSize(.infinity) == 48 && textModel.displayedFontSize(.nan) == 48
        textModel.beginInspectorTransaction()
        for text in ["R", "Review", "Review this region"] { textModel.updateSelected { $0.text = text } }
        textModel.updateSelected {
            $0.fontName = "Georgia"; $0.fontSize = 64; $0.bold = true; $0.italic = true
            $0.underline = true; $0.textAlignment = .center
        }
        textModel.finishInspectorTransaction()
        let styled = textModel.selected
        textModel.undo()
        let oneTextUndo = textModel.selected == annotation
        textModel.redo()
        let textRedo = textModel.selected == styled
        textModel.duplicateSelection()
        let duplicate = textModel.selected
        let duplicateStyle = duplicate?.id != annotation.id && duplicate?.text == styled?.text
            && duplicate?.fontName == styled?.fontName && duplicate?.underline == styled?.underline
        textModel.sendSelectionToBack()
        let sentBack = textModel.edit.annotations.first?.id == duplicate?.id
        textModel.bringSelectionToFront()
        let broughtFront = textModel.edit.annotations.last?.id == duplicate?.id
        textModel.changeMode(.annotate)
        textModel.zoom = 2; textModel.pan = CGSize(width: 15, height: 20)
        let beforeCrop = textModel.edit.annotations
        textModel.changeMode(.crop)
        let modePreserves = textModel.edit.annotations == beforeCrop && textModel.selected?.id == duplicate?.id
            && textModel.zoom == 2 && textModel.pan == CGSize(width: 15, height: 20)

        return [
            Check(name: "Document saved baseline", passed: startsClean && changed && undoIsClean && saved && cleanWithUndo && undoAwayIsDirty,
                  detail: "Dirty state follows the initial/last durable snapshot, including Undo away from or back to that snapshot."),
            Check(name: "Stale save and close ownership", passed: staleRejected && closeClears,
                  detail: "Newer edits and a closed source reject stale save completions; close clears document state and history."),
            Check(name: "Failed and cancelled replacement", passed: failedImportPreserved && cancelledImportPreserved,
                  detail: "Actual failed file decoding and a cancelled import preserve the previous source, edits and dirty state."),
            Check(name: "Live typography undo transaction", passed: editingRequested && safeFontDisplay && oneTextUndo && textRedo,
                  detail: "Text editing is requested on creation; content and typography update as one reversible edit. Font displays are safely bounded independently of image dimensions."),
            Check(name: "Annotation arrangement and mode preservation", passed: duplicateStyle && sentBack && broughtFront && modePreserves,
                  detail: "Duplicates retain typography, front/back ordering changes retained objects, and mode switching preserves objects and viewport.")
        ]
    }

    private static func editorRegressionChecks(source: ImageSource) -> [Check] {
        let model = EditorModel(source: source)
        model.beginInspectorTransaction()
        for value in [8, 80, 800] { model.setCropDimension(value, keyPath: \.size.width) }
        model.finishInspectorTransaction()
        let changed = model.outputCrop.width == 800
        model.undo()
        let cropUndo = changed && model.outputCrop == source.bounds && !model.history.canUndo
        model.redo()
        let cropRedo = model.outputCrop.width == 800

        model.resetCrop()
        model.setPreset(.square)
        model.undo()
        let presetUndo = model.preset == .freeform && model.outputCrop == source.bounds
        model.redo()
        let presetRedo = model.preset == .square && model.outputCrop.width == model.outputCrop.height

        let annotation = Annotation(kind: .rectangle,
            points: [CGPoint(x: 100.2, y: 100.3), CGPoint(x: 500.2, y: 400.3)])
        model.commit(EditState(crop: source.bounds, annotations: [annotation]))
        model.selectedAnnotation = annotation.id
        model.beginInspectorTransaction()
        for value in [3, 30, 300] { model.setSelectedDimension(value, keyPath: \.size.width) }
        model.finishInspectorTransaction()
        let annotationDisplay = model.selected.map {
            abs($0.bounds.width - 300) < 0.000001 && model.displayedPixelValue($0.bounds.width) == 300
        } ?? false
        model.undo()
        let annotationUndo = model.selected == annotation
        model.selectedAnnotation = annotation.id
        model.beginInspectorTransaction()
        let paths: [WritableKeyPath<CGRect, CGFloat>] = [\.origin.x, \.origin.y, \.size.width, \.size.height]
        for value in [Int.max, Int.min] {
            for keyPath in paths {
                model.setSelectedDimension(value, keyPath: keyPath)
            }
        }
        model.finishInspectorTransaction()
        let bounded = model.selected.map { source.bounds.contains($0.bounds) } ?? false
        let safeDisplay = model.displayedPixelValue(.infinity) == 0 && model.displayedPixelValue(.nan) == 0
            && abs(model.displayedPixelValue(CGFloat.greatestFiniteMagnitude)) <= Int(max(source.size.width, source.size.height))
        model.beginInspectorTransaction()
        model.deleteSelection()
        model.finishInspectorTransaction()
        model.undo()
        let deletionUndo = model.edit.annotations.count == 1
        return [
            Check(name: "Inspector crop undo/redo", passed: cropUndo && cropRedo,
                  detail: "Three typed digits commit one source-pixel edit; Undo restores the original and Redo restores 800 px."),
            Check(name: "Crop preset undo/redo", passed: presetUndo && presetRedo,
                  detail: "Crop bounds and preset restore together."),
            Check(name: "Inspector annotation undo/delete", passed: annotationDisplay && annotationUndo && deletionUndo,
                  detail: "A fractionally positioned rectangle resized by typed digits displays 300 px; Undo restores the entire original object. Dimension editing and deletion each commit one reversible operation."),
            Check(name: "Inspector numeric bounds", passed: bounded && safeDisplay,
                  detail: "Int minimum/maximum dimensions remain inside the source; nonfinite and extreme display values convert safely.")
        ]
    }

    private static func reviewFixChecks(source: ImageSource) async -> [Check] {
        // A Display P3 color from the system palette must stay editable, drawable and exportable.
        let colorModel = EditorModel(source: source)
        colorModel.chooseTool(.rectangle)
        colorModel.insertAnnotationAtCenter()
        let wideGreen = Color(.displayP3, red: 0, green: 1, blue: 0)
        colorModel.setStrokeColor(wideGreen)
        colorModel.setFillEnabled(true)
        colorModel.setFillColor(wideGreen)
        var wideColor = false
        var wideDetail = "No selected annotation."
        if let selected = colorModel.selected, let fill = selected.fillColor {
            let roundTrip = EditorModel.rgba(EditorModel.color(selected.color))
            do {
                let output = try await ImageExportQueue.shared.export(source, edits: colorModel.edit, format: .png)
                let decoder = CGImageSourceCreateWithURL(output.url as CFURL, nil)
                let image = decoder.flatMap { CGImageSourceCreateImageAtIndex($0, 0, nil) }
                wideColor = selected.color.isOutsideSRGBGamut && fill.isOutsideSRGBGamut
                    && roundTrip.map { abs($0.green - selected.color.green) < 0.001 && abs($0.red - selected.color.red) < 0.001 } == true
                    && image?.colorSpace?.isWideGamutRGB == true && colorModel.error == nil
                wideDetail = "Stroke green \(selected.color.green), red \(selected.color.red); wide-gamut PNG \(image?.colorSpace?.isWideGamutRGB == true)."
            } catch { wideDetail = error.localizedDescription }
        }

        // Rotated annotation fields use the same visible axes as crop fields.
        let rotated = EditorModel(source: source)
        rotated.rotateLeft()
        rotated.chooseTool(.rectangle)
        rotated.insertAnnotationAtCenter()
        let beforeFields = rotated.edit
        rotated.beginInspectorTransaction()
        rotated.setSelectedDimension(250, keyPath: \.size.width)
        rotated.setSelectedDimension(0, keyPath: \.origin.x)
        rotated.finishInspectorTransaction()
        let display = rotated.selectedDisplayBounds ?? .zero
        let upright = rotated.selected?.bounds ?? .zero
        let rotatedFields = abs(display.width - 250) < 0.001 && abs(upright.height - 250) < 0.001
            && abs(display.minX) < 0.001 && abs(upright.minY) < 0.001 && source.bounds.contains(upright)
        rotated.undo()
        let rotatedUndo = rotated.edit == beforeFields

        // A pending inspector edit is undoable before Done; Redo stays unavailable while it would be cleared.
        let pending = EditorModel(source: source)
        pending.beginInspectorTransaction()
        let startsDisabled = !pending.canUndo && !pending.canRedo
        pending.setCropDimension(800, keyPath: \.size.width)
        let pendingUndo = pending.canUndo && !pending.history.canUndo
        pending.undo()
        let undone = pending.outputCrop == source.bounds && pending.canRedo
        pending.beginInspectorTransaction()
        pending.setCropDimension(700, keyPath: \.size.width)
        let redoBlocked = !pending.canRedo && pending.canUndo
        pending.finishInspectorTransaction()

        // Zoom keeps the pinched point, or the visible center for menu commands, over the same source pixel.
        let zoomModel = EditorModel(source: source)
        let viewport = CGSize(width: 1000, height: 700)
        func sourcePoint(at view: CGPoint) -> CGPoint {
            CanvasTransform(bounds: source.bounds, viewport: viewport, zoom: zoomModel.zoom, pan: zoomModel.pan).sourcePoint(view)
        }
        let pinch = CGPoint(x: 700, y: 450), center = CGPoint(x: 500, y: 350)
        let pinched = sourcePoint(at: pinch)
        zoomModel.setZoom(2.5, around: CGSize(width: pinch.x - center.x, height: pinch.y - center.y))
        let pinchHeld = hypot(sourcePoint(at: pinch).x - pinched.x, sourcePoint(at: pinch).y - pinched.y) < 0.001
        let centered = sourcePoint(at: center)
        zoomModel.setZoom(zoomModel.zoom * 1.5)
        let centerHeld = hypot(sourcePoint(at: center).x - centered.x, sourcePoint(at: center).y - centered.y) < 0.001
        zoomModel.setZoom(100); let clampedHigh = zoomModel.zoom == 8
        zoomModel.setZoom(.nan); let ignoredInvalid = zoomModel.zoom == 8
        zoomModel.setZoom(0.1); let clampedLow = zoomModel.zoom == 1

        return [
            Check(name: "Wide-gamut annotation colors", passed: wideColor,
                  detail: "A Display P3 palette color is retained as extended sRGB, round-trips through the color well and exports as wide-gamut PNG. \(wideDetail)"),
            Check(name: "Rotated annotation fields", passed: rotatedFields && rotatedUndo,
                  detail: "After Rotate Left, typed Width/Left follow the visible axes and map to upright source Height/Top; one Undo restores the object."),
            Check(name: "Pending inspector edit Undo", passed: startsDisabled && pendingUndo && undone && redoBlocked,
                  detail: "Undo is enabled for an uncommitted inspector change and restores it; Redo is disabled while a pending change would clear it."),
            Check(name: "Anchored zoom", passed: pinchHeld && centerHeld && clampedHigh && ignoredInvalid && clampedLow,
                  detail: "Pinch zoom keeps the pinched source pixel fixed; menu zoom keeps the visible center; limits and nonfinite values are bounded.")
        ]
    }

    private static func toolbarActionChecks(source: ImageSource) async -> [Check] {
        // Text and Pixelate are actions: each places one selected object at the crop center as one Undo step.
        var placed = true
        for kind in [AnnotationKind.text, .pixelate] {
            let model = EditorModel(source: source)
            model.changeMode(.annotate)
            let before = model.edit
            model.useTool(kind)
            let crop = model.outputCrop
            placed = placed && model.edit.annotations.count == 1 && model.selected?.kind == kind
                && model.tool == .select && model.mode == .annotate
                && model.selected.map { abs($0.bounds.midX - crop.midX) < 1 && abs($0.bounds.midY - crop.midY) < 1 } == true
            model.undo()
            placed = placed && model.edit == before && model.selected == nil
        }
        let shapeModel = EditorModel(source: source)
        shapeModel.changeMode(.annotate)
        shapeModel.useTool(.rectangle)
        let shapesWait = shapeModel.edit.annotations.isEmpty && shapeModel.tool == .annotation(.rectangle)

        // Copy renders a snapshot without blocking the editor or its import/close lifecycle.
        let copyModel = EditorModel(source: source)
        let copyTask = Task { await copyModel.copy() }
        var observedCopying = false, blockedEditor = false
        for _ in 0..<2_000 where !observedCopying {
            await Task.yield()
            if copyModel.copying { observedCopying = true; blockedEditor = copyModel.busy }
        }
        await copyTask.value
        let copied = observedCopying && !blockedEditor && !copyModel.copying && !copyModel.busy
            && copyModel.status == "Copied 1600 × 1000" && UIPasteboard.general.types.contains(UTType.png.identifier)
        return [
            Check(name: "Text and Pixelate place objects", passed: placed && shapesWait,
                  detail: "Each action inserts one centered, selected object as a single Undo step; shapes still wait for a canvas drag."),
            Check(name: "Copy does not block editing", passed: copied,
                  detail: "Copy sets only its own in-flight state, never the editor-wide busy overlay, and writes a PNG pasteboard item.")
        ]
    }
}
#endif
