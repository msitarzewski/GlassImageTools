import SwiftUI
import VisionSnipCore

struct ImageCanvas: View {
    @Bindable var model: EditorModel
    let source: ImageSource
    @State private var startEdit: EditState?
    @State private var startPan: CGSize?
    @State private var startZoom: CGFloat?
    @State private var startTransform: CanvasTransform?
    @State private var movingID: UUID?
    @State private var drawingID: UUID?
    /// Reserved around the image so edge crop controls keep their full 60-point targets.
    static let contentInset: CGFloat = EditorPlatform.canvasInset

    var body: some View {
        canvas
        #if os(macOS)
        .focusable()
        .focusEffectDisabled()
        #endif
        .padding(Self.contentInset)
        .clipped()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("image-canvas")
        .accessibilityLabel(model.mode == .crop ? "Image crop canvas" : "Annotation canvas")
        .accessibilityValue(canvasAccessibilityValue)
        .accessibilityHint(model.mode == .crop
            ? "Annotations stay visible. Drag crop corners or use Crop Dimensions for exact pixels."
            : "Select an annotation to move it, resize its handles or edit text and style.")
        .accessibilityAction(named: Text("Fit to Window")) { model.fit() }
        .accessibilityAction(named: Text("Zoom In")) { model.setZoom(model.zoom * 1.5) }
        .accessibilityAction(named: Text("Zoom Out")) { model.setZoom(model.zoom / 1.5) }
        .accessibilityAction(named: Text("Pan Left")) { model.pan.width -= 40 }
        .accessibilityAction(named: Text("Pan Right")) { model.pan.width += 40 }
        .accessibilityAction(named: Text("Pan Up")) { model.pan.height -= 40 }
        .accessibilityAction(named: Text("Pan Down")) { model.pan.height += 40 }
        .accessibilityActions {
            if model.mode == .annotate, model.tool != .annotation(.freehand) {
                Button("Add Annotation at Crop Center") { model.insertAnnotationAtCenter() }
            }
            if model.selected != nil {
                Button("Reveal Selection") { model.revealSelection() }
            }
        }
        .onChange(of: ObjectIdentifier(source)) { _, _ in resetGesture() }
        .onChange(of: model.mode) { _, _ in resetGesture() }
        .onChange(of: model.edit.rotation) { _, _ in resetGesture() }
    }

    private var canvas: some View {
        GeometryReader { proxy in
            let bounds = model.mode == .crop ? source.bounds : model.outputCrop
            let transform = CanvasTransform(bounds: bounds, viewport: proxy.size, zoom: model.zoom, pan: model.pan, rotation: model.edit.rotation)
            ZStack(alignment: .topLeading) {
                VectorImageLayer(source: source, edits: model.edit, bounds: bounds, transform: transform) { message in
                    guard model.source === source, model.error != message else { return }
                    model.error = message
                }
                .id(ObjectIdentifier(source))
                .accessibilityHidden(true)
                .contentShape(Rectangle())
                .gesture(drag(transform))
                .simultaneousGesture(SpatialTapGesture(coordinateSpace: .named("image-canvas-space"))
                    .onEnded { tap($0.location, transform: transform) })
                #if DEBUG && os(visionOS)
                if model.mode == .annotate, ProcessInfo.processInfo.arguments.contains("--ui-testing") {
                    EditorCanvasTestTargets(transform: transform, bounds: bounds)
                }
                #endif
                if model.mode == .crop {
                    CropOverlay(model: model, transform: transform, sourceBounds: source.bounds, viewport: proxy.size)
                } else {
                    ForEach(model.edit.annotations) { annotation in
                        annotationTarget(annotation, transform: transform)
                            .allowsHitTesting(model.tool == .select)
                    }
                    if model.tool == .select, drawingID == nil, let selected = model.selected {
                        AnnotationSelectionOverlay(model: model, annotation: selected, transform: transform,
                                                   sourceBounds: source.bounds, viewport: proxy.size)
                            .allowsHitTesting(model.tool == .select)
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
            .coordinateSpace(name: "image-canvas-space")
            .simultaneousGesture(MagnifyGesture().onChanged { value in
                if startZoom == nil { startZoom = model.zoom }
                // Keep the content under the pinch in place, as Photos does, rather than the image center.
                let anchor = CGSize(width: value.startLocation.x - proxy.size.width / 2,
                                    height: value.startLocation.y - proxy.size.height / 2)
                model.setZoom((startZoom ?? model.zoom) * value.magnification, around: anchor)
            }.onEnded { _ in startZoom = nil })
            .onChange(of: model.selectionRevealRequest) { _, _ in
                guard let selected = model.selected else { return }
                let visible = selected.bounds.intersection(model.outputCrop)
                let target = visible.isNull || visible.isEmpty ? selected.bounds : visible
                let delta = transform.centeringDelta(for: target, viewport: proxy.size)
                model.pan.width += delta.width; model.pan.height += delta.height
            }
        }
    }

    private var canvasAccessibilityValue: String {
        return "\(model.displayedPixelValue(model.outputSize.width)) by \(model.displayedPixelValue(model.outputSize.height)) pixels, "
            + "\(Int((model.zoom * 100).rounded())) percent zoom, \(model.edit.annotations.count) editable annotations"
    }

    @ViewBuilder private func annotationTarget(_ annotation: Annotation, transform: CanvasTransform) -> some View {
        let tolerance = EditorPlatform.hitTolerance / transform.scale
        let isBox = annotation.kind == .text || annotation.kind == .pixelate
        let pathBounds = isBox ? annotation.bounds : AnnotationEngine.path(for: annotation).boundingBoxOfPath
        let margin = tolerance + (isBox ? 0 : annotation.lineWidth / 2)
        let region = pathBounds.insetBy(dx: -margin, dy: -margin).intersection(model.outputCrop)
        if !region.isNull, !region.isEmpty {
            let rect = transform.viewRect(region)
            Color.clear
                .frame(width: rect.width, height: rect.height)
                .contentShape(.interaction, AnnotationInteractionShape(annotation: annotation, region: region, tolerance: tolerance, rotation: model.edit.rotation))
                #if os(visionOS)
                .contentShape(.hoverEffect, AnnotationInteractionShape(annotation: annotation, region: region, tolerance: tolerance, rotation: model.edit.rotation))
                #endif
                #if os(visionOS)
                .contentShape(.contextMenuPreview, Rectangle())
                #endif
                .editorHover(isEnabled: model.tool == .select)
                .gesture(drag(transform))
                .onTapGesture { selectObject(annotation, editText: true) }
                .editorContextMenu {
                    if annotation.kind == .text {
                        Button("Edit Text", systemImage: "textformat") { selectObject(annotation, editText: true) }
                    }
                    Button("Reveal Selection", systemImage: "viewfinder") {
                        selectObject(annotation); model.revealSelection()
                    }
                    Button("Duplicate", systemImage: "plus.square.on.square") {
                        selectObject(annotation); model.duplicateSelection()
                    }
                    Button("Bring to Front", systemImage: "square.3.layers.3d.top.filled") {
                        selectObject(annotation); model.bringSelectionToFront()
                    }
                    Button("Send to Back", systemImage: "square.3.layers.3d.bottom.filled") {
                        selectObject(annotation); model.sendSelectionToBack()
                    }
                    Button("Delete Annotation", role: .destructive) {
                        selectObject(annotation); model.deleteSelection()
                    }
                } preview: {
                    annotationMenuPreview(region: region)
                        .onAppear { selectObject(annotation) }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(annotation.kind.rawValue) annotation")
                .accessibilityValue(annotationAccessibilityValue(annotation))
                .accessibilityAddTraits(model.selectedAnnotation == annotation.id ? [.isButton, .isSelected] : .isButton)
                .accessibilityIdentifier("annotation-object-\(annotation.kind.rawValue.lowercased())")
                .accessibilityHint(annotationInteractionHint(annotation))
                .accessibilityAction { selectObject(annotation, editText: true) }
                .accessibilityAction(named: Text("Reveal Selection")) { selectObject(annotation); model.revealSelection() }
                .modifier(PixelMovementActions { moveAnnotation(annotation, by: $0) })
                .accessibilityAction(named: Text("Duplicate")) { selectObject(annotation); model.duplicateSelection() }
                .accessibilityAction(named: Text("Bring to Front")) { selectObject(annotation); model.bringSelectionToFront() }
                .accessibilityAction(named: Text("Send to Back")) { selectObject(annotation); model.sendSelectionToBack() }
                .accessibilityAction(named: Text("Delete Annotation")) { selectObject(annotation); model.deleteSelection() }
                .position(x: rect.midX, y: rect.midY)
        }
    }

    private func selectObject(_ annotation: Annotation, editText: Bool = false) {
        model.selectAnnotation(annotation.id)
        if editText, annotation.kind == .text { model.requestTextEditing() }
    }

    private func annotationAccessibilityValue(_ annotation: Annotation) -> String {
        let rect = model.displayRect(annotation.bounds)
        let geometry = "X \(model.displayedPixelValue(rect.minX)), Y \(model.displayedPixelValue(rect.minY)), "
            + "\(model.displayedPixelValue(rect.width)) by \(model.displayedPixelValue(rect.height)) pixels"
        return annotation.kind == .text ? "\(annotation.text). \(geometry)" : geometry
    }

    private func moveAnnotation(_ annotation: Annotation, by delta: CGSize) {
        selectObject(annotation)
        model.beginCanvasGesture()
        let delta = sourcePixelDelta(delta)
        let rect = CropGeometry.moved(annotation.bounds, by: delta, in: source.bounds)
        model.updateSelected { $0 = $0.moved(by: CGSize(width: rect.minX - annotation.bounds.minX,
                                                      height: rect.minY - annotation.bounds.minY)) }
        model.finishGesture()
    }

    private func sourcePixelDelta(_ delta: CGSize) -> CGSize {
        CanvasTransform(bounds: source.bounds, viewport: model.edit.rotation.size(for: source.size),
                        rotation: model.edit.rotation).sourceDelta(delta)
    }

    private func annotationInteractionHint(_ annotation: Annotation) -> String {
        #if os(macOS)
        annotation.kind == .text ? "Click to edit text. Control-click for actions on this label."
            : "Click to select. Control-click for actions on this annotation."
        #else
        annotation.kind == .text ? "Tap to edit text. Pinch and hold for actions on this label."
            : "Tap to select. Pinch and hold for actions on this annotation."
        #endif
    }
    private func annotationMenuPreview(region: CGRect) -> some View {
        let rotated = model.edit.rotation.size(for: region.size)
        let factor = min(360 / rotated.width, 240 / rotated.height)
        let size = CGSize(width: max(44, rotated.width * factor), height: max(44, rotated.height * factor))
        let transform = CanvasTransform(bounds: region, viewport: size, rotation: model.edit.rotation)
        return VectorImageLayer(source: source, edits: model.edit, bounds: region, transform: transform) { message in
            if model.source === source { model.error = message }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
        .accessibilityLabel("Annotation preview")
    }

    private func hit(_ point: CGPoint, transform: CanvasTransform) -> UUID? {
        model.edit.annotations.reversed().first {
            AnnotationEngine.hitTest($0, at: point, tolerance: EditorPlatform.hitTolerance / transform.scale)
        }?.id
    }

    private func drag(_ transform: CanvasTransform) -> some Gesture {
        DragGesture(minimumDistance: 3, coordinateSpace: .named("image-canvas-space")).onChanged { value in
            if startEdit == nil {
                model.beginCanvasGesture()
                startEdit = model.edit; startPan = model.pan
                startTransform = transform
                let start = transform.sourcePoint(value.startLocation)
                movingID = hit(start, transform: transform)
                    ?? (model.selected?.bounds.contains(start) == true ? model.selectedAnnotation : nil)
                if case .annotation(let kind) = model.tool, model.mode == .annotate, kind != .text {
                    let point = transform.sourcePoint(value.startLocation, clamped: true)
                    guard model.outputCrop.contains(point) else { return }
                    let annotation = model.makeAnnotation(kind: kind, points: [point, point])
                    drawingID = annotation.id
                    model.edit.annotations.append(annotation)
                    model.selectAnnotation(annotation.id)
                }
            }
            let dragTransform = startTransform ?? transform
            let delta = dragTransform.sourceDelta(value.translation)
            if model.tool == .pan {
                model.pan = CGSize(width: (startPan?.width ?? 0) + value.translation.width,
                                   height: (startPan?.height ?? 0) + value.translation.height)
            } else if model.mode == .crop {
                let start = dragTransform.sourcePoint(value.startLocation, clamped: true)
                let end = dragTransform.sourcePoint(value.location, clamped: true)
                model.edit.crop = CGRect(x: min(start.x, end.x), y: min(start.y, end.y),
                                         width: max(1, abs(end.x - start.x)), height: max(1, abs(end.y - start.y)))
                model.edit.preset = .freeform
            } else if case .annotation = model.tool,
                      let index = model.edit.annotations.firstIndex(where: { $0.id == drawingID }) {
                let point = dragTransform.sourcePoint(value.location, clamped: true)
                if model.edit.annotations[index].kind == .freehand {
                    let last = model.edit.annotations[index].points.last ?? point
                    if hypot(last.x - point.x, last.y - point.y) * transform.scale >= 1 {
                        model.edit.annotations[index].points.append(point)
                    }
                } else { model.edit.annotations[index].points[1] = point }
            } else if model.tool == .select, let id = movingID,
                      let original = startEdit?.annotations.first(where: { $0.id == id }),
                      let index = model.edit.annotations.firstIndex(where: { $0.id == id }) {
                model.selectAnnotation(id)
                let moved = CropGeometry.moved(original.bounds, by: delta, in: source.bounds)
                model.edit.annotations[index] = original.moved(by: CGSize(width: moved.minX - original.bounds.minX,
                                                                        height: moved.minY - original.bounds.minY))
            }
        }.onEnded { _ in
            if model.tool != .pan {
                if model.mode == .crop { model.edit.crop = model.outputCrop }
                if let id = drawingID, let annotation = model.edit.annotations.first(where: { $0.id == id }),
                   annotation.kind != .freehand { model.tool = .select }
            }
            model.finishGesture()
            resetGesture(resetZoom: false)
        }
    }

    private func tap(_ location: CGPoint, transform: CanvasTransform) {
        guard model.mode == .annotate else { return }
        let point = transform.sourcePoint(location)
        guard model.outputCrop.contains(point) else { model.selectAnnotation(nil); return }
        // Text is placed by its toolbar action, so a canvas tap only selects.
        if model.tool == .select {
            model.selectAnnotation(hit(point, transform: transform))
            if model.selected?.kind == .text { model.requestTextEditing() }
        }
    }

    private func resetGesture(resetZoom: Bool = true) {
        startEdit = nil; startPan = nil; startTransform = nil; movingID = nil; drawingID = nil
        if resetZoom { startZoom = nil }
    }
}

/// Native object gestures share the renderer's path geometry, with a forgiving display-space margin.
/// Clipping the hit shape prevents an off-crop object from intercepting the empty letterbox.
private struct AnnotationInteractionShape: Shape {
    let annotation: Annotation
    let region: CGRect
    let tolerance: CGFloat
    let rotation: ImageRotation

    func path(in rect: CGRect) -> Path {
        var path = Path()
        if annotation.kind == .text || annotation.kind == .pixelate {
            path.addRect(annotation.bounds.insetBy(dx: -tolerance, dy: -tolerance))
        } else {
            let outline = AnnotationEngine.path(for: annotation)
            if annotation.kind.supportsFill, let fill = annotation.fillColor, fill.alpha > 0 {
                path.addPath(Path(outline))
            }
            path.addPath(Path(outline.copy(strokingWithWidth: annotation.lineWidth + tolerance * 2,
                                          lineCap: .round, lineJoin: .round, miterLimit: 10)))
        }
        let size = rotation.size(for: region.size)
        let mapping = rotation.transform(in: region)
            .concatenating(CGAffineTransform(scaleX: rect.width / size.width, y: rect.height / size.height))
            .concatenating(CGAffineTransform(translationX: rect.minX, y: rect.minY))
        return path.applying(mapping).intersection(Path(rect))
    }
}

/// Geometry and text stay live at the window's display scale. Source and redactions share one
/// ordered drawing context so a transparent redaction cannot reveal a separately drawn original.
private struct VectorImageLayer: View {
    let source: ImageSource
    let edits: EditState
    let bounds: CGRect
    let transform: CanvasTransform
    let onError: @MainActor (String) -> Void
    @State private var cacheOwner = CanvasCacheOwner()

    var body: some View {
        Canvas(opaque: false, rendersAsynchronously: false) { graphics, _ in
            graphics.withCGContext { context in
                context.concatenate(transform.affineTransform)
                do {
                    try ImageRenderer.drawPreview(source, edits: edits, clippingTo: bounds,
                                                  cache: &cacheOwner.pixelations, in: context)
                } catch {
                    let message = error.localizedDescription
                    Task { @MainActor in onError(message) }
                }
            }
        }
        .onDisappear { cacheOwner.pixelations = PreviewPixelationCache() }
    }
}

/// Cache mutations must not publish SwiftUI state while the renderer is drawing.
private final class CanvasCacheOwner {
    var pixelations = PreviewPixelationCache()
}

private struct AnnotationSelectionOverlay: View {
    @Bindable var model: EditorModel
    let annotation: Annotation
    let transform: CanvasTransform
    let sourceBounds: CGRect
    let viewport: CGSize
    @State private var initial: Annotation?
    @State private var initialTransform: CanvasTransform?

    var body: some View {
        let rect = transform.viewRect(annotation.bounds)
        let controls = transform.reachableControlRect(for: annotation.bounds, viewport: viewport)
        ZStack(alignment: .topLeading) {
            Rectangle().stroke(.tint, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)
                .allowsHitTesting(false).accessibilityHidden(true)
            tethers(rect: rect, controls: controls)
                .allowsHitTesting(false).accessibilityHidden(true)
            if annotation.kind.hasEndpoints, let start = annotation.points.first, let end = annotation.points.last {
                let endpoints = transform.endpointControls(start: start, end: end, viewport: viewport)
                endpoint(at: start, index: 0, position: endpoints.start)
                endpoint(at: end, index: annotation.points.count - 1, position: endpoints.end)
            } else {
                ForEach(Array(CropCorner.allCases.enumerated()), id: \.offset) { index, corner in
                    cornerHandle(corner, index: index, rect: rect, controls: controls)
                }
            }
            if annotation.bounds.intersection(model.outputCrop).isEmpty {
                Text("Selection outside crop")
                    .font(.caption).padding(.horizontal, 10).padding(.vertical, 6)
                    .background(.regularMaterial, in: Capsule())
                    .position(x: viewport.width / 2, y: 24)
                    .allowsHitTesting(false)
                    .accessibilityLabel("The selected annotation is outside the crop. Use its position fields or handles to bring it into the crop.")
            }
        }
        .onChange(of: annotation.id) { _, _ in initial = nil; initialTransform = nil }
    }

    @ViewBuilder private func tethers(rect: CGRect, controls: CGRect) -> some View {
        if annotation.kind.hasEndpoints, let start = annotation.points.first, let end = annotation.points.last {
            let endpoints = transform.endpointControls(start: start, end: end, viewport: viewport)
            CanvasControlTether(placement: CanvasControlPlacement(actual: transform.viewPoint(start),
                position: endpoints.start, viewport: viewport))
            CanvasControlTether(placement: CanvasControlPlacement(actual: transform.viewPoint(end),
                position: endpoints.end, viewport: viewport))
        } else {
            ForEach(Array(CropCorner.allCases.enumerated()), id: \.offset) { _, corner in
                CanvasControlTether(placement: CanvasControlPlacement(actual: corner.point(in: rect),
                    position: corner.point(in: controls), viewport: viewport))
            }
        }
    }

    private func cornerHandle(_ corner: CropCorner, index: Int, rect: CGRect, controls: CGRect) -> some View {
        let placement = CanvasControlPlacement(actual: corner.point(in: rect), position: corner.point(in: controls), viewport: viewport)
        let label = ["Top left annotation corner", "Top right annotation corner", "Bottom left annotation corner", "Bottom right annotation corner"][index]
        return handle(placement: placement, label: label, marker: ["↖", "↗", "↙", "↘"][index])
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("image-canvas-space")).onChanged { value in
                beginGesture()
                guard let initial else { return }
                let resized = CropGeometry.resized(initial.bounds, corner: (initialTransform ?? transform).sourceCorner(for: corner),
                    by: (initialTransform ?? transform).sourceDelta(value.translation), in: sourceBounds)
                replace(initial.resized(to: resized))
            }.onEnded { _ in finish() })
            .accessibilityLabel(label)
            .accessibilityIdentifier("annotation-handle-\(index)")
            .accessibilityValue("\(placement.status)\(model.displayedPixelValue(model.displayRect(annotation.bounds).width)) by \(model.displayedPixelValue(model.displayRect(annotation.bounds).height)) pixels")
            .accessibilityAdjustableAction { direction in
                let delta: CGFloat = direction == .increment ? 1 : -1
                resize(corner: corner, by: CGSize(width: corner.left ? -delta : delta, height: corner.top ? -delta : delta))
            }
            .modifier(PixelMovementActions { resize(corner: corner, by: $0) })
            .position(placement.position)
    }

    private func handle(placement: CanvasControlPlacement, label: String, marker: String) -> some View {
        Circle().fill(.white).overlay {
            Circle().stroke(.tint, lineWidth: 2).accessibilityHidden(true)
            if placement.isDisplaced {
                Text(marker).font(.system(size: 11, weight: .bold)).foregroundStyle(.black).accessibilityHidden(true)
            }
        }
        .frame(width: placement.isDisplaced ? 24 : 12, height: placement.isDisplaced ? 24 : 12)
        .frame(width: EditorPlatform.controlTarget, height: EditorPlatform.controlTarget)
        .contentShape(Circle()).editorHover()
        .help(placement.help(for: label))
        .accessibilityElement(children: .ignore)
        .accessibilityHint(placement.help(for: label))
    }

    private func endpoint(at point: CGPoint, index: Int, position: CGPoint) -> some View {
        let placement = CanvasControlPlacement(actual: transform.viewPoint(point), position: position, viewport: viewport)
        let label = index == 0 ? "Start point" : "End point"
        return handle(placement: placement, label: label, marker: index == 0 ? "1" : "2")
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("image-canvas-space")).onChanged { value in
                beginGesture()
                guard var changed = initial, changed.points.indices.contains(index) else { return }
                let original = changed.points[index]
                let delta = (initialTransform ?? transform).sourceDelta(value.translation)
                changed.points[index] = CropGeometry.clamp(CGPoint(x: original.x + delta.width,
                    y: original.y + delta.height), to: sourceBounds)
                replace(changed)
            }.onEnded { _ in finish() })
            .accessibilityLabel(label)
            .accessibilityIdentifier("annotation-endpoint-\(index == 0 ? 0 : 1)")
            .accessibilityValue("\(placement.status)X \(model.displayedPixelValue(model.displayPoint(point).x)), Y \(model.displayedPixelValue(model.displayPoint(point).y)) pixels")
            .accessibilityAdjustableAction { direction in
                let delta: CGFloat = direction == .increment ? 1 : -1
                moveEndpoint(index: index, by: CGSize(width: delta, height: delta))
            }
            .modifier(PixelMovementActions { moveEndpoint(index: index, by: $0) })
            .position(placement.position)
    }


    private func beginGesture() {
        if initial == nil {
            model.beginCanvasGesture()
            initial = annotation; initialTransform = transform
        }
    }

    private func replace(_ changed: Annotation) {
        guard let index = model.edit.annotations.firstIndex(where: { $0.id == changed.id }) else { return }
        model.edit.annotations[index] = changed
    }

    private func resize(corner: CropCorner, by delta: CGSize) {
        model.beginCanvasGesture()
        let pixelTransform = CanvasTransform(bounds: sourceBounds, viewport: model.edit.rotation.size(for: sourceBounds.size), rotation: model.edit.rotation)
        let resized = CropGeometry.resized(annotation.bounds, corner: pixelTransform.sourceCorner(for: corner),
            by: pixelTransform.sourceDelta(delta), in: sourceBounds)
        replace(annotation.resized(to: resized)); finish()
    }

    private func moveEndpoint(index: Int, by delta: CGSize) {
        guard annotation.points.indices.contains(index) else { return }
        model.beginCanvasGesture()
        var changed = annotation
        let point = changed.points[index]
        let delta = CanvasTransform(bounds: sourceBounds, viewport: model.edit.rotation.size(for: sourceBounds.size), rotation: model.edit.rotation).sourceDelta(delta)
        changed.points[index] = CropGeometry.clamp(CGPoint(x: point.x + delta.width, y: point.y + delta.height), to: sourceBounds)
        replace(changed); finish()
    }

    private func finish() { model.finishGesture(); initial = nil; initialTransform = nil }
}

/// Hit regions remain on the window's normal interaction plane. Offset visuals never change edit geometry.
private struct CanvasControlPlacement {
    let actual: CGPoint
    let position: CGPoint
    let viewport: CGSize
    var isDisplaced: Bool { hypot(actual.x - position.x, actual.y - position.y) > 0.5 }
    var isOffscreen: Bool { actual.x < 0 || actual.y < 0 || actual.x > viewport.width || actual.y > viewport.height }
    var status: String { isOffscreen ? "Offscreen control. " : isDisplaced ? "Control offset for spacing. " : "" }
    func help(for label: String) -> String {
        if isOffscreen { return "\(label) is outside the visible canvas. Drag this control to adjust its original position, or use Reveal Selection." }
        if isDisplaced { return "\(label) is displayed away from its actual position for easier selection. Drag to adjust it." }
        return "\(label). Drag to adjust, or use the one-pixel directional actions."
    }
}

private struct CanvasControlTether: View {
    let placement: CanvasControlPlacement
    var body: some View {
        if placement.isDisplaced, !placement.isOffscreen {
            Path { path in path.move(to: placement.actual); path.addLine(to: placement.position) }
                .stroke(.black.opacity(0.85), style: StrokeStyle(lineWidth: 3, dash: [2, 3]))
                .overlay {
                    Path { path in path.move(to: placement.actual); path.addLine(to: placement.position) }
                        .stroke(.white, style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                }
                .allowsHitTesting(false).accessibilityHidden(true)
        }
    }
}

struct CropOverlay: View {
    @Bindable var model: EditorModel
    let transform: CanvasTransform
    let sourceBounds: CGRect
    let viewport: CGSize
    @State private var initialCrop: CGRect?
    @State private var initialTransform: CanvasTransform?
    @State private var initialPan: CGSize?

    var body: some View {
        let rect = transform.viewRect(model.edit.crop)
        let whole = transform.viewRect(sourceBounds)
        let visible = rect.intersection(CGRect(origin: .zero, size: viewport))
        let controls = transform.reachableControlRect(for: model.edit.crop, viewport: viewport)
        ZStack(alignment: .topLeading) {
            Path { path in path.addRect(whole); path.addRect(rect) }
                .fill(.black.opacity(0.65), style: FillStyle(eoFill: true))
                // Match the image Canvas clip without clipping the generous crop controls.
                .frame(width: viewport.width, height: viewport.height).clipped()
                .allowsHitTesting(false).accessibilityHidden(true)
            Rectangle().stroke(.black.opacity(0.85), lineWidth: 4)
                .overlay { Rectangle().stroke(.white, lineWidth: 2).accessibilityHidden(true) }
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)
                .allowsHitTesting(false).accessibilityHidden(true)
            if !visible.isNull, !visible.isEmpty {
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .frame(width: visible.width, height: visible.height)
                    .position(x: visible.midX, y: visible.midY)
                    .gesture(DragGesture(minimumDistance: 3, coordinateSpace: .named("image-canvas-space")).onChanged { value in
                        beginGesture()
                        if model.tool == .pan {
                            model.pan = CGSize(width: (initialPan?.width ?? 0) + value.translation.width,
                                               height: (initialPan?.height ?? 0) + value.translation.height)
                        } else {
                            model.edit.crop = CropGeometry.moved(initialCrop ?? model.edit.crop,
                                by: (initialTransform ?? transform).sourceDelta(value.translation), in: sourceBounds)
                        }
                    }.onEnded { _ in finishGesture(editingCrop: model.tool != .pan) })
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Crop selection")
                    .accessibilityValue(cropAccessibilityValue)
                    .accessibilityIdentifier("crop-selection")
                    .accessibilityHint("Drag to move the crop. With Pan selected, drag to move the image. Corner controls always resize the crop.")
                    .modifier(PixelMovementActions { move(by: $0) })
                axisLabel(model.outputSize.width, id: "crop-width-axis", label: "Crop width")
                    .position(x: max(36, min(viewport.width - 36, visible.midX)),
                              y: max(-18, min(viewport.height + 18, rect.minY - 18)))
                axisLabel(model.outputSize.height, id: "crop-height-axis", label: "Crop height")
                    .rotationEffect(.degrees(-90))
                    .position(x: max(-18, min(viewport.width + 18, rect.minX - 18)),
                              y: max(36, min(viewport.height - 36, visible.midY)))
                ForEach(Array(CropCorner.allCases.enumerated()), id: \.offset) { index, corner in
                    cornerHandle(corner, index: index, rect: rect, controls: controls)
                }
            } else {
                Button("Show Crop", systemImage: "viewfinder") {
                    // Reveal without changing zoom, source geometry or Undo history.
                    model.pan.width += viewport.width / 2 - rect.midX
                    model.pan.height += viewport.height / 2 - rect.midY
                }
                .accessibilityIdentifier("reveal-crop")
                .accessibilityHint("Centers the crop in the visible canvas and keeps the current zoom.")
                .position(x: viewport.width / 2, y: viewport.height / 2)
            }
        }
    }

    private func cornerHandle(_ corner: CropCorner, index: Int, rect: CGRect, controls: CGRect) -> some View {
        let actual = corner.point(in: rect)
        // The reserved 36-point canvas padding contains the whole 60-point target at an edge.
        let position = corner.point(in: controls)
        let displaced = hypot(actual.x - position.x, actual.y - position.y) > 0.5
        let offscreen = actual.x < 0 || actual.y < 0 || actual.x > viewport.width || actual.y > viewport.height
        let label = ["Top left crop corner", "Top right crop corner", "Bottom left crop corner", "Bottom right crop corner"][index]
        return ZStack(alignment: .topLeading) {
            if displaced, !offscreen {
                Path { path in path.move(to: actual); path.addLine(to: position) }
                    .stroke(.white, style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                    .allowsHitTesting(false).accessibilityHidden(true)
            }
            Circle().fill(.white).overlay {
                Circle().stroke(.black.opacity(0.85), lineWidth: 1.5).accessibilityHidden(true)
                if displaced {
                    Image(systemName: ["arrow.up.left", "arrow.up.right", "arrow.down.left", "arrow.down.right"][index])
                        .font(.system(size: 11, weight: .bold)).foregroundStyle(.black)
                }
            }
            .frame(width: displaced ? 24 : 18, height: displaced ? 24 : 18)
            .frame(width: EditorPlatform.controlTarget, height: EditorPlatform.controlTarget).contentShape(Circle())
            .editorHover()
            .help(offscreen
                ? "\(label) is outside the visible canvas. Drag this control to adjust the original crop corner, or use Fit to Window."
                : displaced
                    ? "\(label) is displayed away from the crop boundary for easier selection. Drag to adjust it."
                    : "\(label). Drag to resize the crop.")
            .position(position)
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("image-canvas-space")).onChanged { value in
                beginGesture()
                // The pinned control is only a reachable proxy. Its first drag changes the original
                // source corner by a relative delta; it never snaps the boundary to the viewport edge.
                model.edit.crop = CropGeometry.resized(initialCrop ?? model.edit.crop, corner: (initialTransform ?? transform).sourceCorner(for: corner),
                    by: (initialTransform ?? transform).sourceDelta(value.translation),
                    in: sourceBounds, ratio: model.cropRatio)
            }.onEnded { _ in finishGesture() })
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityIdentifier("crop-handle-\(index)")
            .accessibilityValue("\(offscreen ? "Offscreen corner. " : displaced ? "Control offset for spacing. " : "")\(cropAccessibilityValue)")
            .accessibilityHint(displaced
                ? "This control is offset from the crop boundary. Drag to resize from the original boundary, or use one-pixel actions."
                : "Drag to resize, adjust to grow or shrink, or use one-pixel directional actions.")
            .accessibilityAdjustableAction { direction in
                let delta: CGFloat = direction == .increment ? 1 : -1
                resize(corner: corner, by: CGSize(width: corner.left ? -delta : delta, height: corner.top ? -delta : delta))
            }
            .modifier(PixelMovementActions { resize(corner: corner, by: $0) })
        }
    }

    private var cropAccessibilityValue: String {
        let crop = model.displayCrop
        return "X \(model.displayedPixelValue(crop.minX)), Y \(model.displayedPixelValue(crop.minY)), "
            + "\(model.displayedPixelValue(model.outputSize.width)) by \(model.displayedPixelValue(model.outputSize.height)) pixels"
    }

    private func beginGesture() {
        if initialCrop == nil {
            model.beginCanvasGesture()
            initialCrop = model.edit.crop
            initialTransform = transform
            initialPan = model.pan
        }
    }

    private func finishGesture(editingCrop: Bool = true) {
        if editingCrop {
            model.edit.crop = model.outputCrop
        }
        model.finishGesture()
        initialCrop = nil; initialTransform = nil; initialPan = nil
    }

    private func move(by delta: CGSize) {
        model.beginCanvasGesture()
        var state = model.edit
        let delta = CanvasTransform(bounds: sourceBounds, viewport: model.edit.rotation.size(for: sourceBounds.size), rotation: model.edit.rotation).sourceDelta(delta)
        state.crop = CropGeometry.moved(state.crop, by: delta, in: sourceBounds)
        model.commit(state)
        model.finishGesture()
    }

    private func resize(corner: CropCorner, by delta: CGSize) {
        model.beginCanvasGesture()
        var state = model.edit
        let pixelTransform = CanvasTransform(bounds: sourceBounds, viewport: model.edit.rotation.size(for: sourceBounds.size), rotation: model.edit.rotation)
        state.crop = CropGeometry.pixelAligned(CropGeometry.resized(state.crop, corner: pixelTransform.sourceCorner(for: corner),
            by: pixelTransform.sourceDelta(delta), in: sourceBounds, ratio: model.cropRatio), in: sourceBounds)
        model.commit(state)
        model.finishGesture()
    }

    private func axisLabel(_ value: CGFloat, id: String, label: String) -> some View {
        Text("\(model.displayedPixelValue(value)) px")
            .font(.caption).monospacedDigit().foregroundStyle(.primary)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(.regularMaterial, in: Capsule())
            .fixedSize()
            .accessibilityIdentifier(id)
            .accessibilityValue("\(label) in source pixels")
            .allowsHitTesting(false)
    }
}

/// Source-pixel adjustment is shared by crop corners, annotation bounds and endpoints.
private struct PixelMovementActions: ViewModifier {
    let move: (CGSize) -> Void

    func body(content: Content) -> some View {
        content
            .accessibilityAction(named: Text("Move Left One Pixel")) { move(CGSize(width: -1, height: 0)) }
            .accessibilityAction(named: Text("Move Right One Pixel")) { move(CGSize(width: 1, height: 0)) }
            .accessibilityAction(named: Text("Move Up One Pixel")) { move(CGSize(width: 0, height: -1)) }
            .accessibilityAction(named: Text("Move Down One Pixel")) { move(CGSize(width: 0, height: 1)) }
    }
}
