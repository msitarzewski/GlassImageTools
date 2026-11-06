import CoreGraphics
import SwiftUI

/// A caption for the original bounded preview, outside edited pixels and all export paths.
/// Loading and unavailable results intentionally have no visible footprint.
struct ImageDescriptionCaption: View {
    let image: CGImage
    let maximumHeight: CGFloat
    @State private var result: Result<String, Error>?
    @State private var contentHeight: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if case .success(let caption) = result, !caption.isEmpty {
                ScrollView {
                    captionContent(caption)
                        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
                            guard height.isFinite, height > 0 else { return }
                            contentHeight = height
                        }
                }
                .scrollBounceBehavior(.basedOnSize)
                .frame(height: min(contentHeight, maximumHeight))
                .padding(.top, 8)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("image-description")
            }
        }
        .task {
            do {
                let caption = try await describeWhenAvailable()
                guard !Task.isCancelled else { return }
                result = .success(caption)
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                // Retain the real outcome without an empty-state caption or blocking the editor.
                result = .failure(error)
            }
        }
    }

    /// Another window's inference or a model that is still getting ready is temporary. With no
    /// visible retry control, wait quietly while this image is shown; closing it cancels the wait.
    private func describeWhenAvailable() async throws -> String {
        var attempt = 0
        while true {
            do { return try await describe(attempt: attempt) }
            catch ImageDescriptionService.Unavailable.busy { try await Task.sleep(for: .seconds(2)) }
            catch ImageDescriptionService.Unavailable.notReady { try await Task.sleep(for: .seconds(30)) }
            attempt += 1
        }
    }

    private func describe(attempt: Int) async throws -> String {
        #if DEBUG && os(macOS)
        if ProcessInfo.processInfo.arguments.contains("--mac-ui-testing") { return "" }
        #endif
        #if DEBUG && os(visionOS)
        if ProcessInfo.processInfo.arguments.contains("--ui-testing"),
           let fixture = try EditorTestFixture.imageDescription(attempt: attempt) {
            return fixture
        }
        #endif
        return try await ImageDescriptionService.shared.describe(image)
    }

    private func captionContent(_ caption: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Original Image Description").font(.caption.weight(.semibold))
                .accessibilityAddTraits(.isHeader)
            Text(caption).font(.callout)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
                .accessibilityIdentifier("image-description-text")
        }
        .foregroundStyle(.secondary)
        // Align with the canvas edge; this also contains native text-selection interaction insets.
        .padding(.horizontal, ImageCanvas.contentInset).padding(.vertical, 8)
    }
}
