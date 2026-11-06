import SwiftUI
import VisionSnipCore

extension EnvironmentValues {
    /// Paired dimension fields place their labels above the value, as Mac inspectors do.
    @Entry var pixelFieldLabelAbove = false
}

/// Shared native form row keeps dimensions together. In the narrow trailing inspector an inline
/// label, value and unit cannot pair, so paired fields put labels above; narrower rows and
/// accessibility text sizes stack labeled rows instead.
struct AdaptiveFieldPair<First: View, Second: View>: View {
    let first: First
    let second: Second
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            stacked
        } else {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .bottom, spacing: 16) { first; second }
                    .environment(\.pixelFieldLabelAbove, true)
                stacked
            }
        }
    }
    private var stacked: some View { VStack(alignment: .leading, spacing: 16) { first; second } }
}

struct PixelField: View {
    let title: String
    @Binding var value: Int
    let identifier: String
    @Environment(\.pixelFieldLabelAbove) private var labelAbove
    var body: some View {
        if labelAbove {
            VStack(alignment: .leading, spacing: 4) {
                // The field itself carries the spoken "Width, pixels" label.
                Text(title).font(.subheadline).foregroundStyle(.secondary).accessibilityHidden(true)
                valueField
            }
        } else {
            LabeledContent { valueField } label: { Text(title) }
        }
    }
    private var valueField: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            TextField(title, value: $value, format: .number.grouping(.never))
                .editorNumericKeyboard()
                // Under a label above, the value starts beneath it; inline rows keep trailing values.
                .multilineTextAlignment(labelAbove ? .leading : .trailing)
                // A modest ideal width lets two fields pair; the field still fills its column.
                .frame(minWidth: 56, idealWidth: 72)
                .accessibilityLabel("\(title), pixels")
                .accessibilityIdentifier(identifier)
            Text("px").foregroundStyle(.secondary).accessibilityHidden(true)
        }
    }
}

struct CropInspector: View {
    @Bindable var model: EditorModel
    var onDone: () -> Void
    var body: some View {
            Form {
                // The pane header already says Crop; the first group needs no second title.
                Section {
                    Picker("Preset", selection: Binding(get: { model.preset }, set: model.setPreset)) {
                        ForEach(CropPreset.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.menu)
                    Button("Rotate Left", systemImage: "rotate.left", action: model.rotateLeft)
                    Button("Reset Crop", systemImage: "arrow.uturn.backward", action: model.resetCrop)
                }
                Section("Position") {
                    AdaptiveFieldPair(first: field("Left", keyPath: \.origin.x, id: "crop-left"),
                                      second: field("Top", keyPath: \.origin.y, id: "crop-top"))
                }
                Section {
                    AdaptiveFieldPair(first: field("Width", keyPath: \.size.width, id: "crop-width"),
                                      second: field("Height", keyPath: \.size.height, id: "crop-height"))
                } header: { Text("Size") } footer: {
                    Text("Values use original image pixels. Changing an exact dimension switches to Freeform.")
                }
                Section {
                    LabeledContent("Output", value: "\(Int(model.outputSize.width)) × \(Int(model.outputSize.height)) pixels")
                } footer: {
                    Text("Annotations outside the crop are clipped on export.")
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .contentMargins(.bottom, EditorPlatform.bottomClearance, for: .scrollContent)
            .accessibilityIdentifier("crop-panel")
            .safeAreaInset(edge: .top, spacing: 0) {
                InspectorHeader(title: "Crop", doneIdentifier: "crop-inspector-done", onDone: finish)
            }
        .onAppear(perform: model.beginInspectorTransaction)
        .onDisappear(perform: model.finishInspectorTransaction)
    }
    private func finish() { model.finishInspectorTransaction(); onDone() }
    private func field(_ title: String, keyPath: WritableKeyPath<CGRect, CGFloat>, id: String) -> some View {
        PixelField(title: title, value: Binding(
            get: { model.displayedPixelValue(model.displayCrop[keyPath: keyPath]) },
            set: { model.setCropDimension($0, keyPath: keyPath) }), identifier: id)
    }
}

