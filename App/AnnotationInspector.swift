import SwiftUI
import VisionSnipCore

struct AnnotationInspector: View {
    @Bindable var model: EditorModel
    var onDone: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var fontSizeDraft = ""
    @State private var fontDraftAnnotation: UUID?
    @FocusState private var fontSizeFocused: Bool
    /// A selected object, or an active drawing tool's style for the next object.
    private var editedKind: AnnotationKind? {
        if let selected = model.selected { return selected.kind }
        if case .annotation(let kind) = model.tool { return kind }
        return nil
    }
    /// One title per pane: the object being edited, or the next object a tool will draw.
    private var title: String {
        if let selected = model.selected { return selected.kind.displayName }
        if let kind = editedKind { return "New \(kind.displayName)" }
        return "Annotate"
    }
    var body: some View {
        Group {
            if let kind = editedKind {
                form(for: kind)
            } else {
                ContentUnavailableView("No Selection", systemImage: "cursorarrow",
                    description: Text("Select an annotation to edit it, or choose a tool. Text and Pixelate add a new object at the center of the crop."))
                    // Fill the pane so its header stays at the top, as with the Forms.
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityElement(children: .contain)
            }
        }
        .accessibilityIdentifier("annotation-panel")
        // A different object/tool is a different editing context. Start at its relevant controls,
        // while ordinary live edits keep the current native form and keyboard focus.
        .id(model.selectedAnnotation).id(editedKind)
        .safeAreaInset(edge: .top, spacing: 0) {
            InspectorHeader(title: title, doneIdentifier: "annotation-inspector-done", onDone: finish)
        }
        // The pane exists only while shown; its appearance owns one inspector editing session.
        .onAppear {
            model.annotationInspectorPresented = true
            synchronizeFontDraft()
            model.beginInspectorTransaction()
        }
        .onChange(of: fontSizeDraft) { _, draft in
            // Keep incomplete typing (for example 6 on the way to 64) out of the model.
            guard let value = Int(draft), (8...1000).contains(value) else { return }
            applyFontSize(value)
        }
        .onChange(of: fontSizeFocused) { _, focused in if !focused { finishFontSizeEditing() } }
        .onChange(of: model.selectedAnnotation) { _, _ in
            synchronizeFontDraft()
            model.beginInspectorTransaction()
        }
        .onChange(of: model.effectiveAnnotationKind) { _, _ in
            synchronizeFontDraft()
            model.beginInspectorTransaction()
        }
        .onChange(of: model.selected?.fontSize) { _, _ in if !fontSizeFocused { synchronizeFontDraft() } }
        .onChange(of: model.fontSize) { _, _ in if !fontSizeFocused { synchronizeFontDraft() } }
        .onDisappear {
            finishFontSizeEditing()
            model.annotationInspectorPresented = false
            model.finishInspectorTransaction()
        }
    }

    private var textContent: Binding<String> {
        Binding(get: { model.selected?.kind == .text ? model.selected?.text ?? model.textLabel : model.textLabel },
                set: { value in
                    if model.selected?.kind == .text { model.updateSelected { $0.text = value } }
                    else { model.textLabel = value }
                })
    }
    private var fontFamily: Binding<String> { textStyle(\.fontName, default: \.fontName) }
    private var alignment: Binding<AnnotationTextAlignment> { textStyle(\.textAlignment, default: \.textAlignment) }

    /// Content, then style, then geometry and arrangement for a selected object. Each control
    /// appears once, in the group a reader expects, without a second title under the pane title.
    private func form(for kind: AnnotationKind) -> some View {
        Form {
            if kind == .text {
                Section("Content") {
                    TextField("Text", text: textContent, axis: .vertical)
                        .lineLimit(2...5)
                        .accessibilityLabel("Text Label")
                        .accessibilityIdentifier("annotation-text")
                }
                Section { textStyleControls } header: { Text("Style") } footer: { newObjectNote(kind) }
            } else if kind == .pixelate {
                Section {
                    pixelationControl
                } footer: {
                    Text("Block size is in original image pixels; blocks adapt to the region.")
                }
            } else {
                Section { strokeControls(kind) } header: { Text("Style") } footer: { newObjectNote(kind) }
            }
            if model.selected != nil {
                Section("Position and Size") {
                    AdaptiveFieldPair(first: annotationField("Left", keyPath: \.origin.x, id: "annotation-left"),
                                      second: annotationField("Top", keyPath: \.origin.y, id: "annotation-top"))
                    AdaptiveFieldPair(first: annotationField("Width", keyPath: \.size.width, id: "annotation-width"),
                                      second: annotationField("Height", keyPath: \.size.height, id: "annotation-height"))
                }
                Section("Arrange") {
                    Button("Show Selection", systemImage: "viewfinder", action: model.revealSelection)
                        .accessibilityIdentifier("annotation-show-selection")
                    Button("Duplicate", systemImage: "plus.square.on.square", action: model.duplicateSelection)
                    Button("Bring to Front", systemImage: "square.3.layers.3d.top.filled", action: model.bringSelectionToFront)
                    Button("Send to Back", systemImage: "square.3.layers.3d.bottom.filled", action: model.sendSelectionToBack)
                    Button("Delete Annotation", role: .destructive) { model.deleteSelection() }
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .contentMargins(.bottom, EditorPlatform.bottomClearance, for: .scrollContent)
    }
    @ViewBuilder private func newObjectNote(_ kind: AnnotationKind) -> some View {
        if model.selected == nil { Text("Applies to the next \(kind.displayName.lowercased()) you add.") }
    }
    @ViewBuilder private func strokeControls(_ kind: AnnotationKind) -> some View {
        colorControl("Stroke Color", selection: strokeColor, supportsOpacity: false, identifier: "annotation-color")
        VStack(alignment: .leading, spacing: 12) {
            LabeledContent("Stroke Width", value: "\(model.displayedPixelValue(model.selected?.lineWidth ?? model.strokeWidth)) px")
            Slider(value: Binding(get: { model.selected?.lineWidth ?? model.strokeWidth },
                                  set: model.setStrokeWidth), in: 1...80, step: 1) {
                Text("Stroke Width")
            }
            .accessibilityValue("\(model.displayedPixelValue(model.selected?.lineWidth ?? model.strokeWidth)) pixels")
            .accessibilityIdentifier("annotation-stroke-width")
        }
        if kind.supportsFill {
            Toggle("Fill", isOn: Binding(get: { model.selected.map { $0.fillColor != nil } ?? model.fillsShapes },
                                         set: model.setFillEnabled)).accessibilityIdentifier("annotation-fill")
            if model.selected.map({ $0.fillColor != nil }) ?? model.fillsShapes {
                colorControl("Fill Color", selection: Binding(get: {
                    model.selected?.fillColor.map(EditorModel.color) ?? model.fillColor
                }, set: model.setFillColor), supportsOpacity: true, identifier: "annotation-fill-color")
            }
        }
    }
    private var strokeColor: Binding<Color> {
        Binding(get: { model.selected.map { EditorModel.color($0.color) } ?? model.strokeColor },
                set: model.setStrokeColor)
    }
    @ViewBuilder private var textStyleControls: some View {
        Picker("Font", selection: fontFamily) {
            Text("System").tag("System")
            Text("Helvetica").tag("Helvetica")
            Text("Georgia").tag("Georgia")
            Text("Menlo").tag("Menlo")
        }.pickerStyle(.menu).accessibilityIdentifier("annotation-font")
        LabeledContent("Font Size") {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                TextField("Font Size", text: $fontSizeDraft)
                    .editorNumericKeyboard().focused($fontSizeFocused)
                    .multilineTextAlignment(.trailing)
                    .accessibilityLabel("Font Size, pixels")
                    .accessibilityHint("Enter a size from 8 to 1000 pixels.")
                    .accessibilityIdentifier("annotation-font-size")
                    .onSubmit { finishFontSizeEditing() }
                Text("px").foregroundStyle(.secondary).accessibilityHidden(true)
            }
        }
        textTraits
        Picker("Alignment", selection: alignment) {
            Label("Left", systemImage: "text.alignleft").tag(AnnotationTextAlignment.leading)
            Label("Center", systemImage: "text.aligncenter").tag(AnnotationTextAlignment.center)
            Label("Right", systemImage: "text.alignright").tag(AnnotationTextAlignment.trailing)
        }
        .pickerStyle(.menu)
        .accessibilityIdentifier("annotation-alignment")
        colorControl("Text Color", selection: strokeColor, supportsOpacity: false, identifier: "annotation-color")
    }
    @ViewBuilder private var textTraits: some View {
        if dynamicTypeSize.isAccessibilitySize {
            textTraitToggles
        } else {
            ViewThatFits(in: .horizontal) {
                HStack { textTraitToggles }.toggleStyle(.button)
                VStack(alignment: .leading, spacing: 12) { textTraitToggles }
            }
        }
    }
    @ViewBuilder private var textTraitToggles: some View {
        Toggle("Bold", isOn: textStyle(\.bold, default: \.bold)).accessibilityIdentifier("annotation-bold")
        Toggle("Italic", isOn: textStyle(\.italic, default: \.italic)).accessibilityIdentifier("annotation-italic")
        Toggle("Underline", isOn: textStyle(\.underline, default: \.underline)).accessibilityIdentifier("annotation-underline")
    }
    private var pixelationControl: some View {
        VStack(alignment: .leading, spacing: 12) {
            LabeledContent("Block Size", value: "\(Int(model.pixelationSize.rounded())) px")
                .accessibilityIdentifier("annotation-pixelation-size-value")
            Slider(value: Binding(get: { model.pixelationSize }, set: model.setPixelationSize),
                   in: 16...320, step: 4) { Text("Block Size") }
                .accessibilityValue("\(Int(model.pixelationSize.rounded())) source pixels")
                .accessibilityIdentifier("annotation-pixelation-size")
        }
    }
    private func finish() {
        finishFontSizeEditing()
        model.finishInspectorTransaction()
        onDone()
    }
    private func colorControl(_ title: String, selection: Binding<Color>, supportsOpacity: Bool,
                              identifier: String) -> some View {
        LabeledContent {
            // Identity and activation belong to the real native color well, not its surrounding row.
            ColorPicker("", selection: selection, supportsOpacity: supportsOpacity)
                .labelsHidden()
                .fixedSize()
                .frame(minWidth: 60, minHeight: 60)
                .contentShape(Rectangle())
                .accessibilityLabel(title)
                .accessibilityIdentifier(identifier)
                .accessibilityValue(colorDescription(selection.wrappedValue, includesOpacity: supportsOpacity))
                .accessibilityHint("Opens the system color palette.")
        } label: { Text(title) }
    }
    private func colorDescription(_ color: Color, includesOpacity: Bool) -> String {
        guard let rgba = EditorModel.rgba(color) else { return "Unavailable color" }
        // Spoken values use the nearest sRGB components; wider colors say so rather than misreport.
        func component(_ value: Double) -> Int { Int((min(1, max(0, value)) * 255).rounded()) }
        var rgb = "Red \(component(rgba.red)), green \(component(rgba.green)), blue \(component(rgba.blue))"
        if rgba.isOutsideSRGBGamut { rgb += ", wide color" }
        return includesOpacity ? "\(rgb), opacity \(Int((rgba.alpha * 100).rounded())) percent" : rgb
    }
    private func synchronizeFontDraft() {
        fontDraftAnnotation = model.selected?.id
        fontSizeDraft = String(model.displayedFontSize(model.selected?.fontSize ?? model.fontSize))
    }
    private func applyFontSize(_ value: Int) {
        guard model.effectiveAnnotationKind == .text, model.selected?.id == fontDraftAnnotation else { return }
        let size = CGFloat(value)
        model.fontSize = size; model.updateSelected { $0.fontSize = size }
    }
    private func finishFontSizeEditing() {
        guard model.effectiveAnnotationKind == .text, model.selected?.id == fontDraftAnnotation else { return }
        let value = Int(fontSizeDraft).map { max(8, min(1000, $0)) }
            ?? model.displayedFontSize(model.selected?.fontSize ?? model.fontSize)
        applyFontSize(value)
        fontSizeDraft = String(value)
    }
    private func textStyle<Value>(_ path: WritableKeyPath<Annotation, Value>,
                                   default defaults: ReferenceWritableKeyPath<EditorModel, Value>) -> Binding<Value> {
        Binding(get: { model.selected?[keyPath: path] ?? model[keyPath: defaults] }, set: { value in
            model[keyPath: defaults] = value
            model.updateSelected { $0[keyPath: path] = value }
        })
    }
    private func annotationField(_ title: String, keyPath: WritableKeyPath<CGRect, CGFloat>, id: String) -> some View {
        PixelField(title: title, value: Binding(
            get: { model.displayedPixelValue(model.selectedDisplayBounds?[keyPath: keyPath] ?? 0) },
            set: { model.setSelectedDimension($0, keyPath: keyPath) }), identifier: id)
    }
}

/// Shared in-pane heading; confirmation stays with the Form instead of joining window actions.
struct InspectorHeader: View {
    let title: String
    let doneIdentifier: String
    let onDone: () -> Void
    var body: some View {
        HStack {
            Text(title).font(.headline).accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("inspector-title")
            Spacer()
            Button("Done", action: onDone)
                .keyboardShortcut(.defaultAction)
                .accessibilityIdentifier(doneIdentifier)
        }
        .padding(16)
    }
}

extension AnnotationKind {
    /// Reader-facing names; raw values remain stable identifiers.
    var displayName: String {
        switch self {
        case .freehand: "Drawing"
        case .pixelate: "Pixelation"
        default: rawValue
        }
    }
}
