#if DEBUG
import CoreGraphics
import SwiftUI
import UIKit
import UniformTypeIdentifiers
import VisionSnipCore

enum EditorTestFixture {
    static func imageDescription(attempt: Int) throws -> String? {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--ui-test-no-description") { throw ImageDescriptionService.Unavailable.noVision }
        // Models another window's inference occupying the on-device model on the first request.
        if arguments.contains("--ui-test-busy-description") {
            if attempt == 0 { throw ImageDescriptionService.Unavailable.busy }
            return "Seven colored vertical rectangles, described after the model became free."
        }
        if arguments.contains("--ui-test-short-description") {
            return "Seven colored vertical rectangles on a dark blue background."
        }
        if arguments.contains("--ui-test-long-description") {
            return String(repeating: "A synthetic image contains seven colored vertical rectangles on a dark blue background. ", count: 5)
                + "End of synthetic description."
        }
        return nil
    }

    @MainActor static func seedImageLinkClipboard() {
        let text = ProcessInfo.processInfo.environment["UITEST_IMAGE_URL"] ?? "http://example.com/test.png"
        if ProcessInfo.processInfo.arguments.contains("--ui-test-plain-link") {
            UIPasteboard.general.string = text
        } else if let url = URL(string: text) { UIPasteboard.general.url = url }
    }

    @MainActor static func seedInvalidClipboard() {
        ClipboardService.copy(Data("Deliberately invalid image test fixture".utf8))
    }

    static func slowImageProvider() -> NSItemProvider {
        let provider = NSItemProvider()
        provider.registerFileRepresentation(forTypeIdentifier: UTType.png.identifier,
                                            fileOptions: [], visibility: .all) { completion in
            let progress = Progress(totalUnitCount: 1)
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 15) {
                completion(nil, false, ImageError.unreadable)
            }
            return progress
        }
        return provider
    }

    static func imageDropProvider() throws -> NSItemProvider {
        let image = try source()
        let output = try ImageRenderer.export(image, edits: EditState(crop: image.bounds), format: .png)
        let data = try Data(contentsOf: output.url)
        let provider = NSItemProvider()
        provider.suggestedName = "Example Image.png"
        provider.registerDataRepresentation(forTypeIdentifier: UTType.png.identifier, visibility: .all) { completion in
            completion(data, nil)
            return nil
        }
        return provider
    }

    static func source() throws -> ImageSource {
        guard let context = CGContext(data: nil, width: 1600, height: 1000, bitsPerComponent: 8,
            bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { throw ImageError.renderFailed }
        context.setFillColor(CGColor(red: 0.12, green: 0.22, blue: 0.35, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: 1600, height: 1000))
        for x in stride(from: 100, to: 1500, by: 200) {
            context.setFillColor(CGColor(red: CGFloat(x) / 1600, green: 0.65, blue: 0.75, alpha: 1))
            context.fill(CGRect(x: x, y: 150, width: 140, height: 700))
        }
        guard let image = context.makeImage() else { throw ImageError.renderFailed }
        let source = try ImageImportService.fromCapture(image)
        if ProcessInfo.processInfo.arguments.contains("--ui-test-long-title") {
            let output = try ImageRenderer.export(source, edits: EditState(crop: source.bounds), format: .png)
            let name = String(repeating: "Synthetic screenshot project detail ", count: 5) + "2026-10-16.png"
            return try ImageImportService.importFile(output.url, name: name)
        }
        return source
    }
}

/// Native element targets keep UI gesture synthesis on the image's scene when title/toolbars occupy
/// separate visionOS surfaces. These markers pass input through to the real canvas gestures.
struct EditorCanvasTestTargets: View {
    let transform: CanvasTransform
    let bounds: CGRect

    var body: some View {
        ZStack(alignment: .topLeading) {
            marker("canvas-test-start", x: 0.25, y: 0.3)
            marker("canvas-test-end", x: 0.7, y: 0.65)
        }
        .allowsHitTesting(false)
    }

    private func marker(_ identifier: String, x: CGFloat, y: CGFloat) -> some View {
        let point = transform.viewPoint(CGPoint(x: bounds.minX + bounds.width * x,
                                               y: bounds.minY + bounds.height * y))
        return Circle().fill(.white.opacity(0.6)).frame(width: 8, height: 8)
            .padding(26)
            .background(.white.opacity(0.01))
            .contentShape(Rectangle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Canvas gesture target")
            .accessibilityIdentifier(identifier)
            .position(x: point.x, y: point.y)
    }
}
#endif
