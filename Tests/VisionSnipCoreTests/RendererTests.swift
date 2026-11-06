import Testing
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
#if os(macOS)
import Darwin
#endif
@testable import VisionSnipCore

@Suite(.serialized) struct RendererTests {
    @Test @MainActor func emptyImageDropHasDropSpecificRecovery() async {
        do {
            _ = try await ImageImportService.importItemProviders([], fallbackName: "Dropped Image", emptyError: .noDroppedImage)
            Issue.record("An empty drop must fail without accepting a source.")
        } catch ImageError.noDroppedImage {
            #expect(ImageError.noDroppedImage.localizedDescription.contains("Drop"))
            #expect(!ImageError.noDroppedImage.localizedDescription.lowercased().contains("clipboard"))
        } catch { Issue.record("Unexpected drop failure: \(error)") }
        do {
            _ = try await ImageImportService.importItemProviders([])
            Issue.record("An empty Paste must retain its own recovery.")
        } catch ImageError.noPastedImage {
            #expect(ImageError.noPastedImage.localizedDescription.contains("Paste Image"))
        } catch { Issue.record("Unexpected Paste failure: \(error)") }
    }

    @Test(arguments: [true, false])
    @MainActor func imageDropOwnsUnchangedBytesAndUsesContextualNames(dataBacked: Bool) async throws {
        let url = try original(bitmap())
        defer { try? FileManager.default.removeItem(at: url) }
        let bytes = try Data(contentsOf: url)
        let provider = NSItemProvider()
        if dataBacked {
            provider.suggestedName = "Example Image.png"
            provider.registerDataRepresentation(forTypeIdentifier: UTType.png.identifier, visibility: .all) {
                completion in completion(bytes, nil); return nil
            }
        } else {
            provider.registerFileRepresentation(forTypeIdentifier: UTType.png.identifier, fileOptions: [], visibility: .all) {
                completion in completion(url, false, nil); return nil
            }
        }
        let source = try await ImageImportService.importItemProviders([provider], fallbackName: "Dropped Image", emptyError: .noDroppedImage)
        let owned = try #require(source.url)
        #expect(owned != url)
        #expect(try Data(contentsOf: owned) == bytes)
        #expect(try Data(contentsOf: url) == bytes)
        #expect(source.size == CGSize(width: 30, height: 20))
        #expect(source.typeIdentifier == UTType.png.identifier)
        #expect(source.name == (dataBacked ? "Example Image.png" : "Dropped Image"))
    }

    private let colors: [[UInt8]] = [[255, 0, 0], [0, 255, 0], [0, 0, 255],
                                     [255, 255, 0], [255, 0, 255], [0, 255, 255]]

    private func bitmap(width: Int = 30, height: Int = 20, checker: Bool = false) throws -> CGImage {
        let context = try #require(CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
            bytesPerRow: width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.translateBy(x: 0, y: CGFloat(height)); context.scaleBy(x: 1, y: -1)
        if checker {
            for y in stride(from: 0, to: height, by: 2) {
                for x in stride(from: 0, to: width, by: 2) {
                    context.setFillColor(CGColor(gray: ((x + y) / 2).isMultiple(of: 2) ? 0 : 1, alpha: 1))
                    context.fill(CGRect(x: x, y: y, width: 2, height: 2))
                }
            }
        } else {
            for index in 0..<6 {
                let color = colors[index]
                context.setFillColor(CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
                    components: [CGFloat(color[0]) / 255, CGFloat(color[1]) / 255, CGFloat(color[2]) / 255, 1])!)
                context.fill(CGRect(x: CGFloat(index % 3) * CGFloat(width) / 3,
                                    y: CGFloat(index / 3) * CGFloat(height) / 2,
                                    width: CGFloat(width) / 3, height: CGFloat(height) / 2))
            }
        }
        return try #require(context.makeImage())
    }

    private func original(_ image: CGImage, orientation: Int = 1) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("VisionSnipTest-\(UUID()).png")
        let destination = try #require(CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, image, [kCGImagePropertyOrientation: orientation,
            kCGImagePropertyExifDictionary: [kCGImagePropertyExifUserComment: "Private source fixture metadata"],
            kCGImagePropertyTIFFDictionary: [kCGImagePropertyTIFFMake: "VisionSnipFixtureCamera"],
            kCGImagePropertyGPSDictionary: [kCGImagePropertyGPSLatitude: 51.5, kCGImagePropertyGPSLatitudeRef: "N",
                                           kCGImagePropertyGPSLongitude: 0.12, kCGImagePropertyGPSLongitudeRef: "W"]] as CFDictionary)
        #expect(CGImageDestinationFinalize(destination))
        return url
    }

    private func pixel(_ image: CGImage, x: Int, y: Int) throws -> [UInt8] {
        Array(try rgba(image, x: x, y: y).prefix(3))
    }

    @Test(arguments: Array(1...8))
    func allExifOrientationsHaveCorrectUprightPixels(orientation: Int) throws {
        let url = try original(bitmap(), orientation: orientation)
        defer { try? FileManager.default.removeItem(at: url) }
        let source = try ImageImportService.importFile(url)
        let image = try ImageRenderer.render(source, edits: EditState(crop: source.bounds), format: .png)
        let layouts = [[0,1,2,3,4,5], [2,1,0,5,4,3], [5,4,3,2,1,0], [3,4,5,0,1,2],
                       [0,3,1,4,2,5], [3,0,4,1,5,2], [5,2,4,1,3,0], [2,5,1,4,0,3]]
        let columns = orientation >= 5 ? 2 : 3
        #expect(image.width == columns * 10)
        #expect(image.height == (6 / columns) * 10)
        #expect(source.size == CGSize(width: image.width, height: image.height))
        for index in 0..<6 {
            let actual = try pixel(image, x: index % columns * 10 + 5, y: index / columns * 10 + 5)
            let expected = colors[layouts[orientation - 1][index]]
            #expect(actual == expected)
        }
        let crop = CGRect(x: 10, y: 0, width: 10, height: 10)
        let cropped = try ImageRenderer.render(source, edits: EditState(crop: crop), format: .png)
        #expect(try pixel(cropped, x: 5, y: 5) == colors[layouts[orientation - 1][1]])
    }

    @Test func cropUsesFullResolutionAndDoesNotMutateOriginal() throws {
        let url = try original(bitmap(width: 8192, height: 4096))
        defer { try? FileManager.default.removeItem(at: url) }
        let originalData = try Data(contentsOf: url)
        let source = try ImageImportService.importFile(url)
        #expect(max(source.preview.width, source.preview.height) <= 2048)
        let crop = CGRect(x: 7000, y: 3000, width: 451, height: 327)
        let image = try ImageRenderer.render(source, edits: EditState(crop: crop), format: .png)
        #expect(image.width == 451 && image.height == 327)
        #expect(try pixel(image, x: 225, y: 160) == colors[5])
        #expect(try Data(contentsOf: url) == originalData)
    }

    @MainActor @Test(arguments: ExportFormat.allCases)
    func explicitPasteImportsEncodedFileAndDataProvidersWithoutChangingTheirBytes(format: ExportFormat) async throws {
        let captured = try ImageImportService.fromCapture(bitmap(width: 300, height: 200))
        let output = try ImageRenderer.export(captured, edits: EditState(crop: captured.bounds), format: format)
        let bytes = try Data(contentsOf: output.url)
        for fileBacked in [true, false] {
            let provider = NSItemProvider()
            provider.suggestedName = "Pasted fixture.\(format.type.preferredFilenameExtension ?? "image")"
            if fileBacked {
                provider.registerFileRepresentation(forTypeIdentifier: format.type.identifier, fileOptions: [], visibility: .all) {
                    completion in completion(output.url, false, nil); return nil
                }
            } else {
                provider.registerDataRepresentation(forTypeIdentifier: format.type.identifier, visibility: .all) {
                    completion in completion(bytes, nil); return nil
                }
            }
            var pasted: ImageSource? = try await ImageImportService.importItemProviders([
                NSItemProvider(object: "Unrelated copied text" as NSString), provider
            ])
            let ownedURL = try #require(pasted?.url)
            #expect(pasted?.size == CGSize(width: 300, height: 200))
            #expect(pasted?.typeIdentifier == format.type.identifier)
            #expect(pasted?.name == provider.suggestedName)
            #expect(try Data(contentsOf: ownedURL) == bytes)
            #expect(try Data(contentsOf: output.url) == bytes)
            #expect((try FileManager.default.attributesOfItem(atPath: ownedURL.path)[.posixPermissions] as? NSNumber)?.intValue == 0o600)
            pasted = nil
            #expect(!FileManager.default.fileExists(atPath: ownedURL.deletingLastPathComponent().path))
        }
    }

    @MainActor @Test func pasteRejectsEmptyUnsupportedAndMalformedProviders() async throws {
        try ImageImportService.prepareTemporaryStorage()
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("VisionSnip-Imports")
        let before = Set(try FileManager.default.contentsOfDirectory(atPath: root.path))
        for providers in [[], [NSItemProvider(object: "Copied text" as NSString)]] {
            do {
                _ = try await ImageImportService.importItemProviders(providers)
                Issue.record("Non-image paste unexpectedly succeeded")
            } catch ImageError.noPastedImage {} catch { Issue.record(error) }
        }
        let provider = NSItemProvider()
        provider.registerDataRepresentation(forTypeIdentifier: UTType.png.identifier, visibility: .all) {
            completion in completion(Data("Not an encoded image".utf8), nil); return nil
        }
        do {
            _ = try await ImageImportService.importItemProviders([provider])
            Issue.record("Malformed paste unexpectedly succeeded")
        } catch ImageError.unreadable {} catch { Issue.record(error) }
        #expect(Set(try FileManager.default.contentsOfDirectory(atPath: root.path)) == before)
    }

    @MainActor @Test func cancelledPasteCancelsProviderProgressAndIgnoresLateDelivery() async throws {
        try ImageImportService.prepareTemporaryStorage()
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("VisionSnip-Imports")
        let before = Set(try FileManager.default.contentsOfDirectory(atPath: root.path))
        let url = try original(bitmap())
        defer { try? FileManager.default.removeItem(at: url) }
        let bytes = try Data(contentsOf: url)
        let progress = Progress(totalUnitCount: 1)
        let (started, signal) = AsyncStream<Bool>.makeStream()
        let provider = NSItemProvider()
        provider.registerFileRepresentation(forTypeIdentifier: UTType.png.identifier, fileOptions: [], visibility: .all) {
            completion in
            signal.yield(true)
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(150)) { completion(url, false, nil) }
            return progress
        }
        let task = Task { try await ImageImportService.importItemProviders([provider]) }
        for await _ in started { break }
        task.cancel()
        do { _ = try await task.value; Issue.record("Cancelled paste unexpectedly succeeded") }
        catch is CancellationError {} catch { Issue.record(error) }
        try await Task.sleep(for: .milliseconds(250))
        #expect(progress.isCancelled)
        #expect(Set(try FileManager.default.contentsOfDirectory(atPath: root.path)) == before)
        #expect(try Data(contentsOf: url) == bytes)
    }

    @Test func encodedImportLimitRejectsLargeFilesBeforeCopyAndPreservesOriginal() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("GlassImageTools-large-import-\(UUID()).png")
        #expect(FileManager.default.createFile(atPath: url.path, contents: nil))
        defer { try? FileManager.default.removeItem(at: url) }
        let handle = try FileHandle(forWritingTo: url)
        try handle.truncate(atOffset: UInt64(ImageImportService.importByteLimit) + 1)
        try handle.close()
        let before = try FileManager.default.attributesOfItem(atPath: url.path)
        #expect(throws: ImageError.encodedFileTooLarge) { try ImageImportService.copyForImport(url) }
        let after = try FileManager.default.attributesOfItem(atPath: url.path)
        #expect(after[.size] as? NSNumber == before[.size] as? NSNumber)
        #expect(after[.posixPermissions] as? NSNumber == before[.posixPermissions] as? NSNumber)
    }

    @MainActor @Test func ownedProviderCopyCleansBeforeDecodeAndAfterCancelledDecode() async throws {
        let originalURL = try original(bitmap())
        defer { try? FileManager.default.removeItem(at: originalURL) }
        let bytes = try Data(contentsOf: originalURL)
        var neverDecoded: OwnedImageImport? = try ImageImportService.copyOwnedForImport(originalURL)
        let abandoned = try #require(neverDecoded?.url)
        neverDecoded = nil
        #expect(!FileManager.default.fileExists(atPath: abandoned.deletingLastPathComponent().path))

        var pending: OwnedImageImport? = try ImageImportService.copyOwnedForImport(originalURL)
        let cancelled = try #require(pending?.url)
        let task = Task { [copy = try #require(pending)] in
            try await ImageImportService.loadOwnedCopy(copy, name: "Cancelled provider copy")
        }
        task.cancel()
        do { _ = try await task.value; Issue.record("Cancelled owned-copy decode unexpectedly succeeded") }
        catch is CancellationError {} catch { Issue.record(error) }
        pending = nil
        #expect(!FileManager.default.fileExists(atPath: cancelled.deletingLastPathComponent().path))
        #expect(try Data(contentsOf: originalURL) == bytes)
        #expect(throws: (any Error).self) { try OwnedImageImport(ownedURL: originalURL) }
        #expect(try Data(contentsOf: originalURL) == bytes)
    }

    @MainActor @Test func asynchronousFileAndOwnedCopyImportsShareImmutableSourceOwnership() async throws {
        let originalURL = try original(bitmap(width: 300, height: 200), orientation: 6)
        defer { try? FileManager.default.removeItem(at: originalURL) }
        let bytes = try Data(contentsOf: originalURL)
        var fileSource: ImageSource? = try await ImageImportService.importFileAsync(originalURL)
        let fileOwnedURL = try #require(fileSource?.url)
        #expect(fileSource?.size == CGSize(width: 200, height: 300))
        #expect(fileSource?.orientation == 6)
        #expect(try Data(contentsOf: fileOwnedURL) == bytes)
        fileSource = nil
        #expect(!FileManager.default.fileExists(atPath: fileOwnedURL.deletingLastPathComponent().path))

        let copy = try ImageImportService.copyOwnedForImport(originalURL)
        let copiedURL = copy.url
        var copiedSource: ImageSource? = try await ImageImportService.loadOwnedCopy(copy, name: "Owned photo fixture")
        #expect(copiedSource?.size == CGSize(width: 200, height: 300))
        #expect(copiedSource?.name == "Owned photo fixture")
        #expect(try Data(contentsOf: copiedURL) == bytes)
        #expect(throws: (any Error).self) { try ImageImportService.loadOwnedCopy(originalURL) }
        copiedSource = nil
        #expect(!FileManager.default.fileExists(atPath: copiedURL.deletingLastPathComponent().path))
        #expect(try Data(contentsOf: originalURL) == bytes)
    }

    @Test func annotationIsTranslatedAfterCropAndClipped() throws {
        let url = try original(bitmap(width: 300, height: 200))
        defer { try? FileManager.default.removeItem(at: url) }
        let source = try ImageImportService.importFile(url)
        let crop = CGRect(x: 100, y: 50, width: 80, height: 80)
        let line = Annotation(kind: .freehand, points: [CGPoint(x: 90, y: 80), CGPoint(x: 190, y: 80)],
            color: StrokeColor(red: 1, green: 1, blue: 1), lineWidth: 8)
        let image = try ImageRenderer.render(source, edits: EditState(crop: crop, annotations: [line]), format: .png)
        #expect(image.width == 80 && image.height == 80)
        #expect(try pixel(image, x: 40, y: 30) == [255, 255, 255])
        #expect(try pixel(image, x: 40, y: 10) == colors[1])
    }

    @Test func pixelationChangesOnlySelectedRegion() throws {
        let url = try original(bitmap(width: 128, height: 128, checker: true))
        defer { try? FileManager.default.removeItem(at: url) }
        let source = try ImageImportService.importFile(url)
        let annotation = Annotation(kind: .pixelate, points: [CGPoint(x: 32, y: 32), CGPoint(x: 96, y: 96)], lineWidth: 8)
        let plain = try ImageRenderer.render(source, edits: EditState(crop: source.bounds), format: .png)
        let redacted = try ImageRenderer.render(source, edits: EditState(crop: source.bounds, annotations: [annotation]), format: .png)
        #expect(try pixel(plain, x: 8, y: 8) == pixel(redacted, x: 8, y: 8))
        #expect(try pixel(redacted, x: 40, y: 40) == pixel(redacted, x: 42, y: 40))
        #expect(try pixel(plain, x: 40, y: 40) != pixel(plain, x: 42, y: 40))
    }

    @Test(arguments: ExportFormat.allCases)
    func encodedExportHasExpectedTypeSizeAndNoOriginalMetadata(format: ExportFormat) throws {
        let url = try original(bitmap())
        defer { try? FileManager.default.removeItem(at: url) }
        let source = try ImageImportService.importFile(url)
        let originalDecoder = try #require(CGImageSourceCreateWithURL(url as CFURL, nil))
        let originalProperties = try #require(CGImageSourceCopyPropertiesAtIndex(originalDecoder, 0, nil) as? [CFString: Any])
        let gps = try #require(originalProperties[kCGImagePropertyGPSDictionary] as? [CFString: Any])
        #expect(gps[kCGImagePropertyGPSLatitude] as? Double == 51.5)
        #expect(gps[kCGImagePropertyGPSLatitudeRef] as? String == "N")
        #expect(abs(try #require(gps[kCGImagePropertyGPSLongitude] as? Double) - 0.12) < 0.000001)
        #expect(gps[kCGImagePropertyGPSLongitudeRef] as? String == "W")
        let output = try ImageRenderer.export(source, edits: EditState(crop: CGRect(x: 10, y: 0, width: 10, height: 20)), format: format)
        #expect(output.url != source.url && output.url != url)
        #expect(output.byteCount > 0)
        let encoded = try #require(CGImageSourceCreateWithURL(output.url as CFURL, nil))
        #expect(CGImageSourceGetType(encoded) as String? == format.type.identifier)
        #expect(CGImageSourceGetCount(encoded) == 1)
        let properties = try #require(CGImageSourceCopyPropertiesAtIndex(encoded, 0, nil) as? [CFString: Any])
        #expect(properties[kCGImagePropertyPixelWidth] as? Int == 10)
        #expect(properties[kCGImagePropertyPixelHeight] as? Int == 20)
        #expect(properties[kCGImagePropertyGPSDictionary] == nil)
        let exif = properties[kCGImagePropertyExifDictionary] as? [CFString: Any]
        let tiff = properties[kCGImagePropertyTIFFDictionary] as? [CFString: Any]
        #expect(exif?[kCGImagePropertyExifUserComment] == nil)
        #expect(tiff?[kCGImagePropertyTIFFMake] == nil)
    }

    @Test func directCaptureEntersEditorWithoutAFile() throws {
        let source = try ImageImportService.fromCapture(bitmap())
        #expect(source.url == nil)
        let crop = CGRect(x: 10, y: 0, width: 10, height: 10)
        let image = try ImageRenderer.render(source, edits: EditState(crop: crop), format: .png)
        #expect(try pixel(image, x: 5, y: 5) == colors[1])
    }

    @Test func textIsPositionedAfterCropAndClippedToItsEditableBounds() throws {
        let source = try ImageImportService.fromCapture(bitmap(width: 300, height: 200))
        let crop = CGRect(x: 100, y: 50, width: 80, height: 80)
        let annotation = Annotation(kind: .text, points: [CGPoint(x: 120, y: 65), CGPoint(x: 150, y: 90)],
            color: StrokeColor(red: 0, green: 0, blue: 0), text: "MMMMMMMM", fontSize: 48)
        let plain = try ImageRenderer.render(source, edits: EditState(crop: crop), format: .png)
        let marked = try ImageRenderer.render(source, edits: EditState(crop: crop, annotations: [annotation]), format: .png)
        func bytes(_ image: CGImage) throws -> [UInt8] {
            let context = try #require(CGContext(data: nil, width: 80, height: 80, bitsPerComponent: 8,
                bytesPerRow: 320, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
            context.draw(image, in: CGRect(x: 0, y: 0, width: 80, height: 80))
            let pointer = try #require(context.data).assumingMemoryBound(to: UInt8.self)
            return Array(UnsafeBufferPointer(start: pointer, count: 80 * 80 * 4))
        }
        let before = try bytes(plain), after = try bytes(marked)
        var changed = 0
        for y in 0..<80 {
            for x in 0..<80 {
                let offset = (y * 80 + x) * 4
                if Array(before[offset..<offset+4]) != Array(after[offset..<offset+4]) {
                    changed += 1
                    #expect((20..<50).contains(x) && (15..<40).contains(y))
                }
            }
        }
        #expect(changed > 20)
    }

    @Test func pngPreservesAlphaAndJPEGFlattensOntoWhite() throws {
        let context = try #require(CGContext(data: nil, width: 12, height: 8, bitsPerComponent: 8,
            bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        let source = try ImageImportService.fromCapture(#require(context.makeImage()))
        let png = try ImageRenderer.render(source, edits: EditState(crop: source.bounds), format: .png)
        let jpeg = try ImageRenderer.render(source, edits: EditState(crop: source.bounds), format: .jpeg)
        #expect(try pixel(png, x: 5, y: 4) == [0, 0, 0])
        #expect(try pixel(jpeg, x: 5, y: 4) == [255, 255, 255])
        let bytes = try #require(png.dataProvider?.data)
        #expect(CFDataGetBytePtr(bytes)?[3] == 0)
    }

    @Test func failedImportPreservesOriginalAndOwnedSourceCleansUp() throws {
        let bad = FileManager.default.temporaryDirectory.appendingPathComponent("VisionSnipTest-\(UUID()).jpg")
        try Data("not an image".utf8).write(to: bad)
        defer { try? FileManager.default.removeItem(at: bad) }
        #expect(throws: (any Error).self) { try ImageImportService.importFile(bad) }
        #expect(FileManager.default.fileExists(atPath: bad.path))
        let url = try original(bitmap())
        defer { try? FileManager.default.removeItem(at: url) }
        var source: ImageSource? = try ImageImportService.importFile(url)
        let owned = try #require(source?.url)
        #expect(owned.lastPathComponent == "source.image")
        #expect(source?.name == url.lastPathComponent)
        #expect(FileManager.default.fileExists(atPath: owned.path))
        #expect((try FileManager.default.attributesOfItem(atPath: owned.path)[.posixPermissions] as? NSNumber)?.intValue == 0o600)
        source = nil
        #expect(!FileManager.default.fileExists(atPath: owned.path))
        #expect(FileManager.default.fileExists(atPath: url.path))
    }

    private func rgba(_ image: CGImage, x: Int, y: Int) throws -> [UInt8] {
        let context = try #require(CGContext(data: nil, width: image.width, height: image.height, bitsPerComponent: 8,
            bytesPerRow: image.width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        let data = try #require(context.data).assumingMemoryBound(to: UInt8.self)
        let offset = (y * image.width + x) * 4
        return Array(UnsafeBufferPointer(start: data + offset, count: 4))
    }

    @Test(arguments: ExportFormat.allCases, ImageRotation.allCases)
    func transparentPixelationRemovesFineDetailInEncodedOutput(format: ExportFormat, rotation: ImageRotation) throws {
        let context = try #require(CGContext(data: nil, width: 64, height: 64, bitsPerComponent: 8,
            bytesPerRow: 256, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        for x in stride(from: 0, to: 64, by: 2) {
            context.setFillColor(CGColor(gray: (x / 2).isMultiple(of: 2) ? 0 : 1, alpha: 0.5))
            context.fill(CGRect(x: x, y: 0, width: 2, height: 64))
        }
        let source = try ImageImportService.fromCapture(#require(context.makeImage()))
        let mask = Annotation(kind: .pixelate, points: [.zero, CGPoint(x: 64, y: 64)], lineWidth: 16)
        let output = try ImageRenderer.export(source, edits: EditState(crop: source.bounds, annotations: [mask], rotation: rotation), format: format)
        let decoder = try #require(CGImageSourceCreateWithURL(output.url as CFURL, nil))
        let encoded = try #require(CGImageSourceCreateImageAtIndex(decoder, 0, nil))
        let a = try rgba(encoded, x: 20, y: 20), b = try rgba(encoded, x: 22, y: 20)
        #expect(a == b, "A single pixelation block must replace original fine detail, including translucent pixels")
        #expect(a[3] == (format == .png ? 128 : 255))
    }

    @Test func partialPixelationCropPreservesTheFullAnnotationGridAndPreview() throws {
        let context = try #require(CGContext(data: nil, width: 128, height: 128, bitsPerComponent: 8,
            bytesPerRow: 512, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.setFillColor(CGColor(gray: 0, alpha: 1)); context.fill(CGRect(x: 0, y: 0, width: 128, height: 128))
        context.setFillColor(CGColor(gray: 1, alpha: 1)); context.fill(CGRect(x: 32, y: 0, width: 96, height: 128))
        let source = try ImageImportService.fromCapture(#require(context.makeImage()))
        let mask = Annotation(kind: .pixelate, points: [.zero, CGPoint(x: 128, y: 128)], lineWidth: 16)
        let crop = CGRect(x: 32, y: 0, width: 32, height: 128)
        let edits = EditState(crop: crop, annotations: [mask])
        let preview = try ImageRenderer.renderPreview(source, edits: edits)
        let cropped = try ImageRenderer.render(source, edits: edits, format: .png)
        let full = try ImageRenderer.render(source, edits: EditState(crop: source.bounds, annotations: [mask]), format: .png)
        #expect(preview.width == 128 && preview.height == 128)
        for y in [0, 20, 64, 127] {
            for x in [0, 8, 20, 31] {
                #expect(try rgba(cropped, x: x, y: y) == rgba(full, x: x + 32, y: y))
                #expect(try rgba(cropped, x: x, y: y) == rgba(preview, x: x + 32, y: y))
            }
        }
        #expect(try pixel(cropped, x: 8, y: 20) != [255, 255, 255])
        #expect(try pixel(preview, x: 8, y: 20) == [0, 0, 0]) // Outside the crop stays unannotated.
    }

    @Test func previewAndExportComposeShapesAndPixelationInInsertionOrder() throws {
        let context = try #require(CGContext(data: nil, width: 128, height: 128, bitsPerComponent: 8,
            bytesPerRow: 512, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.setFillColor(CGColor(gray: 0, alpha: 1)); context.fill(CGRect(x: 0, y: 0, width: 128, height: 128))
        let source = try ImageImportService.fromCapture(#require(context.makeImage()))
        let line = Annotation(kind: .freehand, points: [CGPoint(x: 32, y: 64), CGPoint(x: 96, y: 64)],
                              color: StrokeColor(red: 1, green: 1, blue: 1), lineWidth: 8)
        let mask = Annotation(kind: .pixelate, points: [CGPoint(x: 32, y: 32), CGPoint(x: 96, y: 96)])
        for annotations in [[line, mask], [mask, line]] {
            let edits = EditState(crop: source.bounds, annotations: annotations)
            let preview = try ImageRenderer.renderPreview(source, edits: edits)
            let result = try ImageRenderer.render(source, edits: edits, format: .png)
            let expected: [UInt8] = annotations.last?.kind == .pixelate ? [0, 0, 0] : [255, 255, 255]
            #expect(try pixel(result, x: 64, y: 64) == expected)
            #expect(try pixel(preview, x: 64, y: 64) == expected)
        }
    }

    @Test func boundedPreviewDoesNotDecodeTheOriginalFileAgain() throws {
        let url = try original(bitmap(width: 4096, height: 2048))
        defer { try? FileManager.default.removeItem(at: url) }
        let source = try ImageImportService.importFile(url)
        try FileManager.default.removeItem(at: #require(source.url))
        let annotation = Annotation(kind: .rectangle, points: [CGPoint(x: 100, y: 100), CGPoint(x: 500, y: 500)])
        let preview = try ImageRenderer.renderPreview(source, edits: EditState(crop: source.bounds, annotations: [annotation]))
        #expect(preview.width == source.preview.width && preview.height == source.preview.height)
        #expect(max(preview.width, preview.height) <= 2048)
    }

    @Test func nonFiniteOrExtremeAnnotationStylesAreRejectedBeforeRendering() throws {
        let source = try ImageImportService.fromCapture(bitmap())
        for annotation in [Annotation(kind: .pixelate, points: [CGPoint(x: CGFloat.nan, y: 0)]),
                           Annotation(kind: .text, points: [.zero], fontSize: .infinity),
                           Annotation(kind: .rectangle, points: [.zero], lineWidth: CGFloat(Int.max))] {
            #expect(throws: (any Error).self) {
                try ImageRenderer.render(source, edits: EditState(crop: source.bounds, annotations: [annotation]), format: .png)
            }
        }
    }

    @Test func cancelledQueuedExportDoesNotRenderOrEncode() async throws {
        let source = try ImageImportService.fromCapture(bitmap())
        let queue = ImageExportQueue()
        let gate = DispatchSemaphore(value: 0)
        let entered = AsyncStream<Void>.makeStream(), queued = AsyncStream<Void>.makeStream()
        let blocker = Task { await queue.holdForCancellationTest(gate: gate, entered: entered.continuation) }
        var enteredIterator = entered.stream.makeAsyncIterator()
        await enteredIterator.next()
        let export = Task {
            queued.continuation.yield(())
            return try await queue.export(source, edits: EditState(crop: source.bounds), format: .png)
        }
        var queuedIterator = queued.stream.makeAsyncIterator()
        await queuedIterator.next()
        export.cancel()
        gate.signal()
        await blocker.value
        do {
            _ = try await export.value
            Issue.record("A cancelled queued export unexpectedly completed")
        } catch is CancellationError {
            // Cancellation reaches the actor-isolated synchronous renderer before any file is created.
        }
        let next = try await queue.export(source, edits: EditState(crop: source.bounds), format: .png)
        #expect(next.byteCount > 0)
    }

    @Test func malformedAndForgedImageHeadersAreRejectedWithoutChangingTheOriginal() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("GlassImageTools-hostile-\(UUID())")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        for count in 0..<64 {
            let url = directory.appendingPathComponent("malformed-\(count).png")
            let bytes = Data((0..<(count * 31)).map { UInt8(truncatingIfNeeded: $0 * 17 + count) })
            try bytes.write(to: url)
            #expect(throws: (any Error).self) { try ImageImportService.importFile(url) }
            #expect(try Data(contentsOf: url) == bytes)
        }
        let valid = try original(bitmap())
        defer { try? FileManager.default.removeItem(at: valid) }
        for (width, height) in [(UInt32(20_000), UInt32(20_000)), (100_001, 1), (0, 32)] {
            var bytes = try Data(contentsOf: valid)
            for (offset, value) in [(16, width), (20, height)] {
                for byte in 0..<4 { bytes[offset + byte] = UInt8(truncatingIfNeeded: value >> (24 - byte * 8)) }
            }
            var crc: UInt32 = 0xffff_ffff
            for byte in bytes[12..<29] {
                crc ^= UInt32(byte)
                for _ in 0..<8 { crc = (crc >> 1) ^ (crc & 1 == 0 ? 0 : 0xedb8_8320) }
            }
            crc ^= 0xffff_ffff
            for byte in 0..<4 { bytes[29 + byte] = UInt8(truncatingIfNeeded: crc >> (24 - byte * 8)) }
            let url = directory.appendingPathComponent("forged-\(width)-\(height).png")
            try bytes.write(to: url)
            #expect(throws: (any Error).self) { try ImageImportService.importFile(url) }
            #expect(try Data(contentsOf: url) == bytes)
        }
    }


    @Test func temporaryStoragePrunesOnlyItsDedicatedPreviousSessionRoots() throws {
        let base = FileManager.default.temporaryDirectory.appendingPathComponent("GlassImageTools-storage-\(UUID())")
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: base) }
        let unrelated = base.appendingPathComponent("unrelated-user-file")
        let original = Data("Keep this unrelated file".utf8)
        try original.write(to: unrelated)
        var stale: [URL] = []
        for kind in [ImageTemporaryStorage.Kind.imports, .exports] {
            let directory = base.appendingPathComponent(kind.rawValue).appendingPathComponent("previous-session")
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let file = directory.appendingPathComponent("private.image")
            try Data("old private pixels".utf8).write(to: file)
            stale.append(file)
        }
        let storage = ImageTemporaryStorage(baseDirectory: base)
        try storage.prepare()
        for file in stale { #expect(!FileManager.default.fileExists(atPath: file.path)) }
        #expect(try Data(contentsOf: unrelated) == original)
        for kind in [ImageTemporaryStorage.Kind.imports, .exports] {
            let root = base.appendingPathComponent(kind.rawValue)
            #if os(macOS)
            // On macOS verify the persisted Time Machine exclusion marker, including its plist value.
            let markerKey = "com.apple.metadata:com_apple_backup_excludeItem"
            let markerSize = getxattr(root.path, markerKey, nil, 0, 0, 0)
            #expect(markerSize > 0)
            if markerSize > 0 {
                var marker = [UInt8](repeating: 0, count: markerSize)
                let readCount = marker.withUnsafeMutableBytes {
                    getxattr(root.path, markerKey, $0.baseAddress, $0.count, 0, 0)
                }
                #expect(readCount == markerSize)
                let value = try PropertyListSerialization.propertyList(from: Data(marker), format: nil)
                #expect(value as? String == "com.apple.backupd")
            }
            #else
            #expect((try root.resourceValues(forKeys: [.isExcludedFromBackupKey])).isExcludedFromBackup == true)
            #endif
            #expect((try FileManager.default.attributesOfItem(atPath: root.path)[.posixPermissions] as? NSNumber)?.intValue == 0o700)
        }
    }

    @Test func repeatedPreparationPreservesActiveFilesUntilTheNextProcessSession() throws {
        let base = FileManager.default.temporaryDirectory.appendingPathComponent("GlassImageTools-storage-\(UUID())")
        defer { try? FileManager.default.removeItem(at: base) }
        let storage = ImageTemporaryStorage(baseDirectory: base)
        let source = try storage.createDirectory(for: .imports).appendingPathComponent("source.image")
        let export = try storage.createDirectory(for: .exports).appendingPathComponent("result.png")
        let bytes = Data("active process image bytes".utf8)
        try bytes.write(to: source)
        try bytes.write(to: export)
        for _ in 0..<10 { try storage.prepare() }
        #expect(try Data(contentsOf: source) == bytes)
        #expect(try Data(contentsOf: export) == bytes)
        // A new isolated storage instance models the next process's one-time static initialization.
        let nextProcess = ImageTemporaryStorage(baseDirectory: base)
        try nextProcess.prepare()
        #expect(!FileManager.default.fileExists(atPath: source.path))
        #expect(!FileManager.default.fileExists(atPath: export.path))
    }

    @Test(arguments: ExportFormat.allCases)
    func publicPreparationKeepsLiveSourceAndExportOwnersIntact(format: ExportFormat) throws {
        let url = try original(bitmap())
        defer { try? FileManager.default.removeItem(at: url) }
        let source = try ImageImportService.importFile(url, name: "A friendly name")
        let exported = try ImageRenderer.export(source, edits: EditState(crop: source.bounds), format: format)
        let owned = try #require(source.url)
        let sourceBytes = try Data(contentsOf: owned), exportBytes = try Data(contentsOf: exported.url)
        let reimported = try ImageImportService.importFile(exported.url, name: "A shared result")
        #expect(reimported.url?.lastPathComponent == "source.image")
        #expect(reimported.size == exported.size && reimported.name == "A shared result")
        for _ in 0..<10 { try ImageImportService.prepareTemporaryStorage() }
        #expect(source.name == "A friendly name" && owned.lastPathComponent == "source.image")
        #expect(try Data(contentsOf: owned) == sourceBytes)
        #expect(try Data(contentsOf: exported.url) == exportBytes)
        #expect((try FileManager.default.attributesOfItem(atPath: exported.url.path)[.posixPermissions] as? NSNumber)?.intValue == 0o600)
    }

    @Test func temporaryStoragePreparationFailuresRemainVisibleAndPreserveUnownedFiles() throws {
        let base = FileManager.default.temporaryDirectory.appendingPathComponent("GlassImageTools-storage-file-\(UUID())")
        let bytes = Data("This is a file rather than a storage directory".utf8)
        try bytes.write(to: base)
        defer { try? FileManager.default.removeItem(at: base) }
        let storage = ImageTemporaryStorage(baseDirectory: base)
        #expect(throws: (any Error).self) { try storage.prepare() }
        #expect(throws: (any Error).self) { try storage.createDirectory(for: .imports) }
        #expect(try Data(contentsOf: base) == bytes)
    }


    @Test func importingASymbolicLinkCannotChangeItsTargetBytesOrPermissions() throws {
        let originalURL = try original(bitmap())
        let link = originalURL.deletingLastPathComponent().appendingPathComponent("GlassImageTools-link-\(UUID()).png")
        defer {
            try? FileManager.default.removeItem(at: link)
            try? FileManager.default.removeItem(at: originalURL)
        }
        try FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: originalURL.path)
        let before = try Data(contentsOf: originalURL)
        let mode = try FileManager.default.attributesOfItem(atPath: originalURL.path)[.posixPermissions] as? NSNumber
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: originalURL)
        #expect(throws: (any Error).self) { try ImageImportService.importFile(link) }
        #expect(try Data(contentsOf: originalURL) == before)
        #expect((try FileManager.default.attributesOfItem(atPath: originalURL.path)[.posixPermissions] as? NSNumber) == mode)
        #expect((try FileManager.default.attributesOfItem(atPath: link.path)[.type] as? FileAttributeType) == .typeSymbolicLink)
    }

    @Test func loadOwnedCopyRejectsUnownedOriginalsWithoutDeletingTheirDirectory() throws {
        let base = FileManager.default.temporaryDirectory.appendingPathComponent("GlassImageTools-originals-\(UUID())")
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: base) }
        let fixture = try original(bitmap())
        defer { try? FileManager.default.removeItem(at: fixture) }
        let good = base.appendingPathComponent("source.image"), bad = base.appendingPathComponent("bad.png")
        let sibling = base.appendingPathComponent("another-important-file")
        try FileManager.default.copyItem(at: fixture, to: good)
        try Data("Malformed original file".utf8).write(to: bad)
        try Data("Unrelated sibling".utf8).write(to: sibling)
        for url in [good, bad] {
            try FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: url.path)
            let before = try Data(contentsOf: url)
            #expect(throws: (any Error).self) { try ImageImportService.loadOwnedCopy(url) }
            #expect(FileManager.default.fileExists(atPath: base.path))
            #expect(try Data(contentsOf: url) == before)
            #expect((try FileManager.default.attributesOfItem(atPath: url.path)[.posixPermissions] as? NSNumber)?.intValue == 0o644)
            #expect(try Data(contentsOf: sibling) == Data("Unrelated sibling".utf8))
        }
    }


    @Test func copiedSymbolicLinksAreRejectedBeforeProtectionOrOwnerTransfer() throws {
        let originalURL = try original(bitmap())
        defer { try? FileManager.default.removeItem(at: originalURL) }
        try FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: originalURL.path)
        let before = try Data(contentsOf: originalURL)
        let owned = try ImageImportService.copyForImport(originalURL)
        defer { try? FileManager.default.removeItem(at: owned.deletingLastPathComponent()) }
        try FileManager.default.removeItem(at: owned)
        try FileManager.default.createSymbolicLink(at: owned, withDestinationURL: originalURL)
        #expect(throws: (any Error).self) { try ImageTemporaryStorage.protectFile(owned) }
        #expect(throws: (any Error).self) { try ImageImportService.loadOwnedCopy(owned) }
        #expect(try Data(contentsOf: originalURL) == before)
        #expect((try FileManager.default.attributesOfItem(atPath: originalURL.path)[.posixPermissions] as? NSNumber)?.intValue == 0o644)
    }


    @Test(arguments: [CGFloat(0.25), 0.75])
    func fractionalPixelationReplacesEveryOutwardAlignedBoundaryPixelInEncodedPNG(fraction: CGFloat) throws {
        let context = try #require(CGContext(data: nil, width: 64, height: 64, bitsPerComponent: 8,
            bytesPerRow: 256, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        for y in stride(from: 0, to: 64, by: 2) {
            for x in stride(from: 0, to: 64, by: 2) {
                context.setFillColor(CGColor(gray: ((x + y) / 2).isMultiple(of: 2) ? 0 : 1, alpha: 0.5))
                context.fill(CGRect(x: x, y: y, width: 2, height: 2))
            }
        }
        let source = try ImageImportService.fromCapture(#require(context.makeImage()))
        let mask = Annotation(kind: .pixelate,
            points: [CGPoint(x: 3 + fraction, y: 3 + fraction), CGPoint(x: 61 - fraction, y: 61 - fraction)], lineWidth: 16)
        let exported = try ImageRenderer.export(source, edits: EditState(crop: source.bounds, annotations: [mask]), format: .png)
        let decoder = try #require(CGImageSourceCreateWithURL(exported.url as CFURL, nil))
        let image = try #require(CGImageSourceCreateImageAtIndex(decoder, 0, nil))
        let interior = try rgba(image, x: 20, y: 20)
        for (x, y) in [(3, 20), (60, 20), (20, 3), (20, 60), (3, 3), (60, 60)] {
            let boundary = try rgba(image, x: x, y: y)
            #expect(boundary == interior,
                    "Every pixel covered by the outward-aligned redaction must replace original detail")
        }
        for (x, y) in [(2, 20), (61, 20), (20, 2), (20, 61), (2, 2), (61, 61)] {
            #expect(try rgba(image, x: x, y: y) == rgba(source.preview, x: x, y: y))
        }
    }

}


private extension ImageExportQueue {
    /// Occupies this actor without suspension so cancellation can be tested while an export is queued.
    func holdForCancellationTest(gate: DispatchSemaphore, entered: AsyncStream<Void>.Continuation) {
        entered.yield(())
        gate.wait()
    }
}
