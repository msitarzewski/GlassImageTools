import SwiftUI

/// App-local preferences affect window presentation only; image rendering never reads them.
enum ImageWindowAppearance {
    static let opacityKey = "glassImageTools.appearance.opacity"
    static let glassKey = "glassImageTools.appearance.glass"
    static let cornerRadius: CGFloat = 46
    /// The system bottom toolbar ornament overlaps the window's lower edge and floats in front of it.
    /// Content that must stay readable ends this far above the edge; there is no system inset to query.
    static let bottomOrnamentClearance: CGFloat = 32

    static func unit(_ value: Double) -> Double {
        value.isFinite ? min(1, max(0, value)) : 0
    }

    static func percentage(_ value: Double) -> String { "\(Int((unit(value) * 100).rounded()))%" }

    static func sliderValue(_ value: Double) -> Double {
        let value = unit(value)
        return [0.0, 0.5, 1.0].first { abs($0 - value) < 0.015 } ?? value
    }
}

/// A plain window owns exactly one native glass surface, with independently painted theme opacity.
/// Only these background layers fade. Chrome, controls and image pixels retain their full opacity.
struct ImageWindowBackground: View {
    @AppStorage(ImageWindowAppearance.opacityKey) private var opacity = 0.0
    @AppStorage(ImageWindowAppearance.glassKey) private var glass = 1.0
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var resolvedGlass: Double { reduceTransparency ? 1 : ImageWindowAppearance.unit(glass) }
    private var resolvedOpacity: Double { reduceTransparency ? 1 : ImageWindowAppearance.unit(opacity) }
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: ImageWindowAppearance.cornerRadius, style: .continuous)
    }

    var body: some View {
        ZStack {
            if resolvedGlass > 0 {
                Color.clear.glassBackgroundEffect(in: shape).opacity(resolvedGlass)
            }
            if resolvedOpacity > 0 { shape.fill(.black).opacity(resolvedOpacity) }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct AppearanceSettings: View {
    @AppStorage(ImageWindowAppearance.opacityKey) private var opacity = 0.0
    @AppStorage(ImageWindowAppearance.glassKey) private var glass = 1.0
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    appearanceSlider("Opacity", value: $opacity, identifier: "appearance-opacity",
                                     minimum: "Transparent", maximum: "Opaque")
                    appearanceSlider("Glass", value: $glass, identifier: "appearance-glass",
                                     minimum: "No Glass", maximum: "Full Glass")
                    LabeledContent("Material", value: "System Glass")
                } header: {
                    Text("Window Appearance")
                } footer: {
                    Text(reduceTransparency
                        ? "Reduce Transparency is on in Accessibility. The window remains opaque while it is on."
                        : "Opacity colors the window background. Glass adjusts its glass surface. Set both to 0% for a clear window. Images, text and controls stay visible.")
                }
                .disabled(reduceTransparency)
                Section {
                    Button("Reset Appearance") { opacity = 0; glass = 1 }
                        .accessibilityIdentifier("appearance-reset")
                } footer: {
                    Text("Appearance is saved on this device and never changes exported images.")
                }
                .disabled(reduceTransparency)
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbar {
                // In the title bar, because the form fills the sheet and a last row would need scrolling to find.
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink { AboutSettings() } label: {
                        Label("About Glass Image Tools", systemImage: "info.circle")
                    }
                    .accessibilityIdentifier("settings-about")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.keyboardShortcut(.defaultAction)
                }
            }
        }
        .presentationSizing(.form)
        .accessibilityIdentifier("appearance-settings")
    }

    private func appearanceSlider(_ title: String, value: Binding<Double>, identifier: String,
                                  minimum: String, maximum: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            LabeledContent(title, value: ImageWindowAppearance.percentage(value.wrappedValue))
            Slider(value: Binding(get: { ImageWindowAppearance.unit(value.wrappedValue) },
                                  set: { value.wrappedValue = ImageWindowAppearance.sliderValue($0) }),
                   in: 0...1, step: 0.01) {
                Text(title)
            }
            .labelsHidden()
            .accessibilityLabel(title)
            .accessibilityIdentifier(identifier)
            .accessibilityValue(ImageWindowAppearance.percentage(value.wrappedValue))
            .accessibilityHint("Minimum: \(minimum). Maximum: \(maximum). Adjusts only the window background. Images and controls stay fully visible.")
            endpointLabels(minimum: minimum, maximum: maximum, identifier: identifier)
        }
    }

    private func endpointLabels(minimum: String, maximum: String, identifier: String) -> some View {
        // Text outside Slider's compressed value-label slots gets the full Form row width.
        // Fixed ideal widths select the vertical fallback before either endpoint can fragment.
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 24) {
                endpoint(minimum, role: "Minimum", identifier: "\(identifier)-minimum")
                Spacer(minLength: 0)
                endpoint(maximum, role: "Maximum", identifier: "\(identifier)-maximum")
            }
            VStack(alignment: .leading, spacing: 8) {
                endpoint(minimum, role: "Minimum", identifier: "\(identifier)-minimum")
                endpoint(maximum, role: "Maximum", identifier: "\(identifier)-maximum")
            }
        }
        .font(.callout)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func endpoint(_ value: String, role: String, identifier: String) -> some View {
        Text(value)
            .fixedSize()
            .accessibilityLabel("\(role): \(value)")
            .accessibilityIdentifier(identifier)
    }
}
