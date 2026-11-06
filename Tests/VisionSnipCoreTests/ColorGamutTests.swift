import Testing
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
@testable import VisionSnipCore

@Suite struct ColorGamutTests {
    private let p3 = CGColorSpace(name: CGColorSpace.displayP3)!
    private let srgb = CGColorSpace(name: CGColorSpace.sRGB)!

    private func image(width: Int = 64, height: Int = 64, space: CGColorSpace,
                       fill: [CGFloat]) throws -> CGImage {
        let context = try #require(CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
            bytesPerRow: width * 4, space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.setFillColor(try #require(CGColor(colorSpace: space, components: fill)))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        return try #require(context.makeImage())
    }

    /// Reads a pixel after Core Graphics converts it into the requested space.
    private func pixel(_ image: CGImage, x: Int, y: Int, in space: CGColorSpace) throws -> [Int] {
        let context = try #require(CGContext(data: nil, width: image.width, height: image.height, bitsPerComponent: 8,
            bytesPerRow: image.width * 4, space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        let data = try #require(context.data).assumingMemoryBound(to: UInt8.self)
        let offset = (y * image.width + x) * 4
        return (0..<4).map { Int(data[offset + $0]) }
    }

    private func decoded(_ output: ExportedImage) throws -> CGImage {
        let decoder = try #require(CGImageSourceCreateWithURL(output.url as CFURL, nil))
        return try #require(CGImageSourceCreateImageAtIndex(decoder, 0, nil))
    }

    @Test func displayP3PickerColorsConvertToExtendedSRGBAndRender() throws {
        let p3Green = try #require(CGColor(colorSpace: p3, components: [0, 1, 0, 1]))
        let color = try #require(StrokeColor(converting: p3Green))
        #expect(color.isOutsideSRGBGamut)
        #expect(color.red < -0.5 && color.green > 1 && color.blue < -0.3 && color.alpha == 1)
        let source = try ImageImportService.fromCapture(image(space: srgb, fill: [1, 1, 1, 1]))
        let mark = Annotation(kind: .rectangle, points: [CGPoint(x: 8, y: 8), CGPoint(x: 56, y: 56)],
                              color: color, lineWidth: 4, fillColor: color)
        let output = try ImageRenderer.export(source, edits: EditState(crop: source.bounds, annotations: [mark]), format: .png)
        let result = try decoded(output)
        #expect(result.colorSpace?.isWideGamutRGB == true, "A wide-gamut annotation needs a wide-gamut output")
        let green = try pixel(result, x: 32, y: 32, in: p3)
        #expect(green[0] <= 3 && green[1] >= 252 && green[2] <= 3, "The annotation must keep its Display P3 green")
        var cache = PreviewPixelationCache()
        let preview = try #require(CGContext(data: nil, width: 64, height: 64, bitsPerComponent: 8, bytesPerRow: 256,
            space: p3, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        try ImageRenderer.drawPreview(source, edits: EditState(crop: source.bounds, annotations: [mark]),
                                      cache: &cache, in: preview)
    }

    @Test(arguments: ExportFormat.allCases)
    func wideGamutSourcesKeepDisplayP3ThroughPixelationAndExport(format: ExportFormat) throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("GlassImageTools-p3-\(UUID()).png")
        defer { try? FileManager.default.removeItem(at: url) }
        let destination = try #require(CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, try image(space: p3, fill: [0, 1, 0, 1]), nil)
        #expect(CGImageDestinationFinalize(destination))
        let source = try ImageImportService.importFile(url)
        #expect(source.preview.colorSpace?.isWideGamutRGB == true)
        let mask = Annotation(kind: .pixelate, points: [.zero, CGPoint(x: 32, y: 64)], lineWidth: 4)
        let output = try ImageRenderer.export(source, edits: EditState(crop: source.bounds, annotations: [mask]),
                                              format: format, quality: 1)
        let result = try decoded(output)
        #expect(result.colorSpace?.isWideGamutRGB == true)
        // An sRGB pipeline would clip this to roughly [117, 251, 74] in Display P3.
        for x in [16, 48] {
            let green = try pixel(result, x: x, y: 32, in: p3)
            #expect(green[0] <= 6 && green[1] >= 248 && green[2] <= 6, "Pixel \(x): \(green)")
        }
    }

    @Test func standardImagesAndColorsKeepSRGBOutput() throws {
        let source = try ImageImportService.fromCapture(image(space: srgb, fill: [0.2, 0.4, 0.6, 1]))
        let mark = Annotation(kind: .rectangle, points: [CGPoint(x: 8, y: 8), CGPoint(x: 56, y: 56)],
                              color: StrokeColor(red: 0, green: 0, blue: 0))
        // Retain the export: its owner deletes the file, and decoding is lazy.
        let output = try ImageRenderer.export(source, edits: EditState(crop: source.bounds, annotations: [mark]), format: .png)
        let result = try decoded(output)
        #expect(result.colorSpace?.name == CGColorSpace.sRGB)
        let unchanged = try pixel(result, x: 32, y: 32, in: srgb)
        #expect(unchanged == [51, 102, 153, 255], "\(unchanged)")
    }

    @Test func unboundedOrNonFiniteColorsAreRejectedAndConversionIsBounded() throws {
        let source = try ImageImportService.fromCapture(image(space: srgb, fill: [1, 1, 1, 1]))
        for color in [StrokeColor(red: 3, green: 0, blue: 0), StrokeColor(red: 0, green: 0, blue: 0, alpha: 1.5),
                      StrokeColor(red: .infinity, green: 0, blue: 0)] {
            let mark = Annotation(kind: .rectangle, points: [.zero, CGPoint(x: 20, y: 20)], color: color)
            #expect(throws: ImageError.self) {
                try ImageRenderer.render(source, edits: EditState(crop: source.bounds, annotations: [mark]), format: .png)
            }
        }
        let extended = try #require(CGColorSpace(name: CGColorSpace.extendedSRGB))
        let extreme = try #require(CGColor(colorSpace: extended, components: [5, -5, 0.5, 2]))
        let bounded = try #require(StrokeColor(converting: extreme))
        #expect(bounded.red == StrokeColor.componentRange.upperBound && bounded.green == StrokeColor.componentRange.lowerBound)
        #expect(abs(bounded.blue - 0.5) < 0.000001 && bounded.alpha == 1)
    }

    @Test func conversionRoundingDoesNotMakeOrdinaryColorsWide() throws {
        // Display P3 white converts to about (0.99999994, 1.0000001, 1.0000001) in extended sRGB.
        for components in [[1, 1, 1, 1], [0, 0, 0, 1], [0.5, 0.5, 0.5, 1]] as [[CGFloat]] {
            let cgColor = try #require(CGColor(colorSpace: p3, components: components))
            let color = try #require(StrokeColor(converting: cgColor))
            #expect(!color.isOutsideSRGBGamut, "\(components) → \(color)")
        }
        let p3White = try #require(CGColor(colorSpace: p3, components: [1, 1, 1, 1]))
        let white = try #require(StrokeColor(converting: p3White))
        #expect([white.red, white.green, white.blue].allSatisfy { (0...1).contains($0) && abs($0 - 1) < 0.0001 })
        let source = try ImageImportService.fromCapture(image(space: srgb, fill: [0.2, 0.4, 0.6, 1]))
        let mark = Annotation(kind: .rectangle, points: [CGPoint(x: 8, y: 8), CGPoint(x: 56, y: 56)], color: white)
        #expect(ImageRenderer.workingColorSpace(for: source.preview, edits: EditState(crop: source.bounds, annotations: [mark])).name
                == CGColorSpace.sRGB)
    }
}
