import Testing
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
@testable import VisionSnipCore

@Suite struct RotationTests {
    @Test(arguments: ImageRotation.allCases)
    func rotatedCropHandlesAndZoomKeepTheirSourceAnchors(rotation: ImageRotation) {
        let bounds = CGRect(x: 0, y: 0, width: 1600, height: 1000)
        let crop = CGRect(x: 240, y: 180, width: 700, height: 500)
        let transform = CanvasTransform(bounds: bounds, viewport: CGSize(width: 960, height: 680),
                                        zoom: 3, pan: CGSize(width: -71, height: 93), rotation: rotation)
        for corner in CropCorner.allCases {
            let delta = CGSize(width: corner.left ? 24 : -24, height: corner.top ? 20 : -20)
            let screen = corner.point(in: transform.viewRect(crop))
            let sourceCorner = transform.sourceCorner(for: corner)
            let resized = CropGeometry.resized(crop, corner: sourceCorner,
                                               by: transform.sourceDelta(delta), in: bounds)
            let changed = corner.point(in: transform.viewRect(resized))
            #expect(abs(changed.x - screen.x - delta.width) < 0.000001)
            #expect(abs(changed.y - screen.y - delta.height) < 0.000001)
            let opposite = CropCorner.allCases.first { $0.left != sourceCorner.left && $0.top != sourceCorner.top }!
            #expect(opposite.point(in: resized) == opposite.point(in: crop))
        }
        let point = CGPoint(x: 532, y: 327)
        let roundTrip = transform.sourcePoint(transform.viewPoint(point))
        #expect(abs(roundTrip.x - point.x) < 0.000001 && abs(roundTrip.y - point.y) < 0.000001)
        let projected = transform.viewRect(crop)
        #expect(abs(projected.width / projected.height - rotation.size(for: crop.size).width / rotation.size(for: crop.size).height) < 0.000001)
    }

    @Test(arguments: ImageRotation.allCases)
    func presetsUseVisibleRotatedAxes(rotation: ImageRotation) {
        let bounds = CGRect(x: 0, y: 0, width: 1600, height: 1000)
        let crop = CropGeometry.preset(.wide, inside: bounds, rotation: rotation)
        let output = rotation.size(for: crop.size)
        #expect(abs(output.width / output.height - 16.0 / 9.0) < 0.000001)
        #expect(bounds.contains(crop))
    }

    @Test func quarterTurnsAreOneValueOnlyUndoStep() {
        let original = EditState(crop: CGRect(x: 100, y: 120, width: 300, height: 200), annotations: [
            Annotation(kind: .text, points: [CGPoint(x: 110, y: 140), CGPoint(x: 350, y: 210)], text: "Retained text")
        ])
        var history = EditHistory(original)
        var changed = original
        changed.rotation = changed.rotation.turnedLeft
        history.commit(changed)
        #expect(history.current.crop == original.crop && history.current.annotations == original.annotations)
        history.undo(); #expect(history.current == original)
        history.redo(); #expect(history.current == changed)
        for _ in 0..<3 { changed.rotation = changed.rotation.turnedLeft }
        #expect(changed == original)
    }

    private func fixture(orientation: Int) throws -> (URL, ImageSource, Data) {
        let colorSpace = try #require(CGColorSpace(name: CGColorSpace.sRGB))
        let context = try #require(CGContext(data: nil, width: 30, height: 20, bitsPerComponent: 8,
            bytesPerRow: 120, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.translateBy(x: 0, y: 20); context.scaleBy(x: 1, y: -1)
        let colors: [[CGFloat]] = [[1,0,0,1],[0,1,0,1],[0,0,1,1],[1,1,0,1],[1,0,1,1],[0,1,1,1]]
        for (index, color) in colors.enumerated() {
            context.setFillColor(try #require(CGColor(colorSpace: colorSpace, components: color)))
            context.fill(CGRect(x: index % 3 * 10, y: index / 3 * 10, width: 10, height: 10))
        }
        let image = try #require(context.makeImage())
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Rotation-\(UUID()).png")
        let destination = try #require(CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, image, [kCGImagePropertyOrientation: orientation,
            kCGImagePropertyGPSDictionary: [kCGImagePropertyGPSLatitude: 0.0, kCGImagePropertyGPSLongitude: 0.0]] as CFDictionary)
        #expect(CGImageDestinationFinalize(destination))
        return (url, try ImageImportService.importFile(url), try Data(contentsOf: url))
    }

    private func pixel(_ image: CGImage, x: Int, y: Int) throws -> [UInt8] {
        let space = try #require(CGColorSpace(name: CGColorSpace.sRGB))
        let context = try #require(CGContext(data: nil, width: image.width, height: image.height, bitsPerComponent: 8,
            bytesPerRow: image.width * 4, space: space,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        let data = try #require(context.data).assumingMemoryBound(to: UInt8.self)
        let offset = (y * image.width + x) * 4
        return Array(UnsafeBufferPointer(start: data + offset, count: 4))
    }

    @Test(arguments: Array(1...8))
    func rotatedPixelsComposeWithEveryExifOrientation(orientation: Int) throws {
        let (url, source, bytes) = try fixture(orientation: orientation)
        defer { try? FileManager.default.removeItem(at: url) }
        let plain = try ImageRenderer.render(source, edits: EditState(crop: source.bounds), format: .png)
        for rotation in ImageRotation.allCases {
            let image = try ImageRenderer.render(source, edits: EditState(crop: source.bounds, rotation: rotation), format: .png)
            let size = rotation.size(for: source.size)
            #expect(image.width == Int(size.width) && image.height == Int(size.height))
            for y in stride(from: 5, to: image.height, by: 10) {
                for x in stride(from: 5, to: image.width, by: 10) {
                    let original: (Int, Int)
                    switch rotation {
                    case .none: original = (x, y)
                    case .left: original = (plain.width - 1 - y, x)
                    case .upsideDown: original = (plain.width - 1 - x, plain.height - 1 - y)
                    case .right: original = (y, plain.height - 1 - x)
                    }
                    #expect(try pixel(image, x: x, y: y) == pixel(plain, x: original.0, y: original.1))
                }
            }
            let preview = try ImageRenderer.renderPreview(source, edits: EditState(crop: source.bounds, rotation: rotation))
            #expect(preview.width == image.width && preview.height == image.height)
            #expect(try pixel(preview, x: 5, y: 5) == pixel(image, x: 5, y: 5))
        }
        #expect(try Data(contentsOf: url) == bytes)
    }

    @Test(arguments: ExportFormat.allCases)
    func rotatedOffsetCropExportsRetainedAnnotationsAndStripsMetadata(format: ExportFormat) throws {
        let (url, source, bytes) = try fixture(orientation: 1)
        defer { try? FileManager.default.removeItem(at: url) }
        let mark = Annotation(kind: .rectangle, points: [CGPoint(x: 11, y: 1), CGPoint(x: 17, y: 8)],
                              lineWidth: 1, fillColor: StrokeColor(red: 1, green: 1, blue: 1))
        let edits = EditState(crop: CGRect(x: 10, y: 0, width: 20, height: 10), annotations: [mark], rotation: .left)
        let output = try ImageRenderer.export(source, edits: edits, format: format, quality: 1)
        #expect(output.size == CGSize(width: 10, height: 20))
        let decoded = try #require(CGImageSourceCreateWithURL(output.url as CFURL, nil))
        let image = try #require(CGImageSourceCreateImageAtIndex(decoded, 0, nil))
        let props = try #require(CGImageSourceCopyPropertiesAtIndex(decoded, 0, nil) as? [String: Any])
        #expect(props[kCGImagePropertyGPSDictionary as String] == nil)
        #expect(image.width == 10 && image.height == 20)
        let white = try pixel(image, x: 4, y: 16)
        #expect(white.prefix(3).allSatisfy { $0 > 225 })
        let blue = try pixel(image, x: 5, y: 4)
        #expect(blue[2] > 225 && blue[0] < 30 && blue[1] < 30)
        #expect(edits.annotations == [mark] && source.size == CGSize(width: 30, height: 20))
        #expect(try Data(contentsOf: url) == bytes)
    }
}
