import Testing
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
@testable import VisionSnipCore

@Suite struct EditorPolishTests {
    private let black = StrokeColor(red: 0, green: 0, blue: 0)
    private let blue = StrokeColor(red: 0, green: 0.2, blue: 1)

    private func context(width: Int = 192, height: Int = 160) throws -> CGContext {
        try #require(CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
            bytesPerRow: width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
    }

    private func source(checker: Bool = false) throws -> ImageSource {
        let context = try context()
        if checker {
            for x in stride(from: 0, to: 192, by: 2) {
                context.setFillColor(CGColor(gray: (x / 2).isMultiple(of: 2) ? 0 : 1, alpha: 0.5))
                context.fill(CGRect(x: x, y: 0, width: 2, height: 160))
            }
        } else {
            context.setFillColor(CGColor(gray: 1, alpha: 1))
            context.fill(CGRect(x: 0, y: 0, width: 192, height: 160))
        }
        return try ImageImportService.fromCapture(#require(context.makeImage()))
    }

    private func live(_ source: ImageSource, edits: EditState, clip: CGRect? = nil,
                      cache: inout PreviewPixelationCache) throws -> CGImage {
        let context = try context()
        context.translateBy(x: 0, y: 160); context.scaleBy(x: 1, y: -1)
        try ImageRenderer.drawPreview(source, edits: edits, clippingTo: clip, cache: &cache, in: context)
        return try #require(context.makeImage())
    }

    private func bytes(_ image: CGImage) throws -> Data {
        let context = try context(width: image.width, height: image.height)
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return Data(bytes: try #require(context.data), count: image.width * image.height * 4)
    }

    private func rgba(_ image: CGImage, x: Int, y: Int) throws -> [UInt8] {
        let data = try bytes(image), offset = (y * image.width + x) * 4
        return Array(data[offset..<(offset + 4)])
    }

    @Test(arguments: AnnotationKind.shapes)
    func newAndExistingShapesUseIdenticalLiveAndExportGeometry(kind: AnnotationKind) throws {
        let source = try source()
        let shape = Annotation(kind: kind, points: [CGPoint(x: 20, y: 20), CGPoint(x: 160, y: 130)],
                               color: black, lineWidth: 5, fillColor: kind.supportsFill ? blue : nil)
        let edits = EditState(crop: source.bounds, annotations: [shape])
        var cache = PreviewPixelationCache()
        let preview = try live(source, edits: edits, cache: &cache)
        let exported = try ImageRenderer.render(source, edits: edits, format: .png)
        #expect(try bytes(preview) == bytes(exported))
        #expect(try bytes(exported) != bytes(source.preview))
        if kind.supportsFill { #expect(try rgba(exported, x: 90, y: 70) == [0, 51, 255, 255]) }
    }

    @Test func hitTestingUsesVisibleShapePathsRatherThanEmptyBoundingBoxSpace() {
        let points = [CGPoint(x: 20, y: 20), CGPoint(x: 160, y: 130)]
        let line = Annotation(kind: .line, points: points, lineWidth: 4)
        #expect(AnnotationEngine.hitTest(line, at: CGPoint(x: 90, y: 75), tolerance: 8))
        #expect(!AnnotationEngine.hitTest(line, at: CGPoint(x: 25, y: 125), tolerance: 8))
        var triangle = Annotation(kind: .triangle, points: points, lineWidth: 4)
        #expect(!AnnotationEngine.hitTest(triangle, at: CGPoint(x: 90, y: 75), tolerance: 0))
        triangle.fillColor = blue
        #expect(AnnotationEngine.hitTest(triangle, at: CGPoint(x: 90, y: 75)))
        #expect(!AnnotationEngine.hitTest(triangle, at: CGPoint(x: 25, y: 25), tolerance: 4))
        let ellipse = Annotation(kind: .ellipse, points: points, lineWidth: 4)
        #expect(!AnnotationEngine.hitTest(ellipse, at: CGPoint(x: 20, y: 20), tolerance: 4))
        let bubble = Annotation(kind: .speechBubble, points: points, fillColor: blue)
        #expect(AnnotationEngine.hitTest(bubble, at: CGPoint(x: 60, y: 110), tolerance: 2))
        #expect(!AnnotationEngine.hitTest(bubble, at: CGPoint(x: 150, y: 125), tolerance: 2))
        #expect(!AnnotationEngine.hitTest(line, at: CGPoint(x: CGFloat.nan, y: 10), tolerance: 4))
    }

    @Test func cropModeShowsRetainedAnnotationsOutsideTheCropAndAnnotateClipsThem() throws {
        let source = try source()
        let shape = Annotation(kind: .rectangle, points: [CGPoint(x: 20, y: 20), CGPoint(x: 60, y: 60)],
                               color: black, fillColor: blue)
        var edits = EditState(crop: CGRect(x: 100, y: 20, width: 80, height: 100), annotations: [shape])
        var cache = PreviewPixelationCache()
        let cropMode = try live(source, edits: edits, clip: source.bounds, cache: &cache)
        #expect(try rgba(cropMode, x: 40, y: 40) == [0, 51, 255, 255])
        let annotate = try live(source, edits: edits, clip: edits.crop, cache: &cache)
        #expect(try rgba(annotate, x: 40, y: 40) == [0, 0, 0, 0])
        edits.crop = source.bounds
        let expanded = try ImageRenderer.render(source, edits: edits, format: .png)
        #expect(try rgba(expanded, x: 40, y: 40) == [0, 51, 255, 255])
        #expect(edits.annotations == [shape])
    }

    @Test func livePixelationReplacesAlphaAndInvalidatesTilesWhenRegionOrSourceChanges() throws {
        let source = try source(checker: true)
        let mask = Annotation(kind: .pixelate,
            points: [CGPoint(x: 3.25, y: 3.25), CGPoint(x: 60.75, y: 60.75)], lineWidth: 16)
        var edits = EditState(crop: source.bounds, annotations: [mask])
        var cache = PreviewPixelationCache()
        let first = try live(source, edits: edits, cache: &cache)
        #expect(try rgba(first, x: 3, y: 20) == rgba(first, x: 20, y: 20))
        #expect(try rgba(first, x: 20, y: 20)[3] == 128)
        #expect(try bytes(first) == bytes(ImageRenderer.render(source, edits: edits, format: .png)))
        edits.annotations[0] = mask.moved(by: CGSize(width: 80, height: 0))
        let moved = try live(source, edits: edits, cache: &cache)
        #expect(try rgba(moved, x: 20, y: 20) == rgba(source.preview, x: 20, y: 20))
        #expect(try rgba(moved, x: 100, y: 20) == rgba(moved, x: 102, y: 20))
        let replacement = try self.source()
        let replaced = try live(replacement, edits: edits, cache: &cache)
        #expect(try rgba(replaced, x: 100, y: 20) == [255, 255, 255, 255])
    }

    @Test func decodedSourceTypeDoesNotTrustTheFilenameAndCaptureHasNoInventedFileType() throws {
        let source = try source()
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("GlassImageTools-type-\(UUID()).jpg")
        defer { try? FileManager.default.removeItem(at: url) }
        let destination = try #require(CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, source.preview, nil)
        #expect(CGImageDestinationFinalize(destination))
        let imported = try ImageImportService.importFile(url, name: "An image")
        #expect(imported.url?.lastPathComponent == "source.image")
        #expect(imported.typeIdentifier == UTType.png.identifier && imported.typeLabel == "PNG")
        #expect(source.typeIdentifier == nil && source.typeLabel == "Captured Frame")
        let jpeg = try ImageRenderer.export(source, edits: EditState(crop: source.bounds), format: .jpeg)
        let reimported = try ImageImportService.importFile(jpeg.url)
        #expect(reimported.typeIdentifier == UTType.jpeg.identifier && reimported.typeLabel == "JPEG")
    }

    @Test func textWrapsAcrossLinesAndAlignmentUsesTheRetainedLayoutBox() throws {
        let source = try source()
        var label = Annotation(kind: .text, points: [CGPoint(x: 10, y: 10), CGPoint(x: 182, y: 150)],
                               color: black, text: "I\nI", fontSize: 28)
        var starts: [Int] = []
        for alignment in AnnotationTextAlignment.allCases {
            label.textAlignment = alignment
            let image = try ImageRenderer.render(source, edits: EditState(crop: source.bounds, annotations: [label]), format: .png)
            let data = try bytes(image)
            var xs: [Int] = [], rows: Set<Int> = []
            for y in 0..<160 {
                for x in 0..<192 where data[(y * 192 + x) * 4] < 100 {
                    xs.append(x); rows.insert(y)
                }
            }
            starts.append(try #require(xs.min()))
            let sortedRows = rows.sorted()
            #expect(zip(sortedRows, sortedRows.dropFirst()).contains { $1 - $0 > 3 }, "Both explicit text lines must be rendered")
        }
        #expect(starts[0] < starts[1] && starts[1] < starts[2])
        label.text = "Many words should wrap into multiple lines inside this box"
        let wrapped = try ImageRenderer.render(source, edits: EditState(crop: source.bounds, annotations: [label]), format: .png)
        var cache = PreviewPixelationCache()
        #expect(try bytes(wrapped) == bytes(live(source, edits: EditState(crop: source.bounds, annotations: [label]), cache: &cache)))
    }

    @Test func textStyleEditsRemainVectorsAndMatchTheLiveComposition() throws {
        let source = try source()
        let label = Annotation(kind: .text, points: [CGPoint(x: 12, y: 12), CGPoint(x: 180, y: 140)],
                               color: black, text: "Editable\nText", fontSize: 28)
        let plain = try ImageRenderer.render(source, edits: EditState(crop: source.bounds, annotations: [label]), format: .png)
        var styled = label
        styled.fontName = "Georgia"; styled.bold = true; styled.italic = true; styled.underline = true
        styled.textAlignment = .center
        let edits = EditState(crop: source.bounds, annotations: [styled])
        let image = try ImageRenderer.render(source, edits: edits, format: .png)
        var cache = PreviewPixelationCache()
        #expect(try bytes(image) != bytes(plain))
        #expect(try bytes(image) == bytes(live(source, edits: edits, cache: &cache)))
        let moved = styled.moved(by: CGSize(width: 4, height: 6)).resized(to: CGRect(x: 16, y: 18, width: 150, height: 130))
        #expect(moved.id == styled.id && moved.fontName == "Georgia" && moved.bold && moved.italic && moved.underline)
        #expect(moved.text == styled.text && moved.textAlignment == .center)
        var history = EditHistory(EditState(crop: source.bounds, annotations: [label]))
        history.commit(edits); history.undo(); #expect(history.current.annotations == [label])
        history.redo(); #expect(history.current == edits)
    }

    @Test func invalidFillAndFontInputCannotEnterRasterRendering() throws {
        let source = try source()
        for annotation in [
            Annotation(kind: .triangle, points: [.zero, CGPoint(x: 80, y: 80)], fillColor: StrokeColor(red: .nan, green: 0, blue: 1)),
            Annotation(kind: .text, points: [.zero, CGPoint(x: 80, y: 80)], fontName: String(repeating: "x", count: 257))
        ] {
            #expect(throws: ImageError.self) {
                try ImageRenderer.render(source, edits: EditState(crop: source.bounds, annotations: [annotation]), format: .png)
            }
        }
    }
}
