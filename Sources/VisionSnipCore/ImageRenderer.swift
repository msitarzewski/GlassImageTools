import Foundation
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers

public enum ExportFormat: String, CaseIterable, Sendable {
    case png = "PNG", jpeg = "JPEG"
    public var type: UTType { self == .png ? .png : .jpeg }
    public var fileExtension: String { self == .png ? "png" : "jpg" }
}

public final class ExportedImage: Sendable {
    public let url: URL
    public let size: CGSize
    public let byteCount: Int
    public let format: ExportFormat
    init(url: URL, size: CGSize, byteCount: Int, format: ExportFormat) {
        self.url = url; self.size = size; self.byteCount = byteCount; self.format = format
    }
    deinit { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
}

public enum AnnotationEngine {
    public static func path(for annotation: Annotation) -> CGPath {
        let path = CGMutablePath()
        let rect = annotation.bounds
        switch annotation.kind {
        case .rectangle, .pixelate: path.addRect(rect)
        case .roundedRectangle:
            let radius = min(rect.width, rect.height) * 0.18
            path.addRoundedRect(in: rect, cornerWidth: radius, cornerHeight: radius)
        case .ellipse: path.addEllipse(in: rect)
        case .triangle:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)); path.closeSubpath()
        case .speechBubble:
            let radius = min(rect.width, rect.height) * 0.12
            let bottom = rect.maxY - rect.height * 0.22
            path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + radius),
                             control: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: bottom - radius))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - radius, y: bottom),
                             control: CGPoint(x: rect.maxX, y: bottom))
            path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.48, y: bottom))
            path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.22, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.29, y: bottom))
            path.addLine(to: CGPoint(x: rect.minX + radius, y: bottom))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: bottom - radius),
                             control: CGPoint(x: rect.minX, y: bottom))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            path.addQuadCurve(to: CGPoint(x: rect.minX + radius, y: rect.minY),
                             control: rect.origin)
            path.closeSubpath()
        case .line, .arrow:
            guard let start = annotation.points.first, let end = annotation.points.last else { break }
            path.move(to: start); path.addLine(to: end)
            if annotation.kind == .arrow {
                let angle = atan2(end.y - start.y, end.x - start.x)
                let length = min(hypot(end.x - start.x, end.y - start.y) * 0.4, max(16, annotation.lineWidth * 4))
                for offset in [-CGFloat.pi / 6, CGFloat.pi / 6] {
                    path.move(to: CGPoint(x: end.x - cos(angle + offset) * length,
                                         y: end.y - sin(angle + offset) * length))
                    path.addLine(to: end)
                }
            }
        case .freehand:
            guard let first = annotation.points.first else { break }
            path.move(to: first)
            for point in annotation.points.dropFirst() { path.addLine(to: point) }
            if annotation.points.count == 1 { path.addLine(to: CGPoint(x: first.x + 0.1, y: first.y)) }
        case .text: break
        }
        return path
    }

    /// Tolerance is in source pixels. The canvas converts its generous interaction target from view space.
    public static func hitTest(_ annotation: Annotation, at point: CGPoint, tolerance: CGFloat = 0) -> Bool {
        guard point.x.isFinite, point.y.isFinite, tolerance.isFinite, tolerance >= 0,
              annotation.points.allSatisfy({ $0.x.isFinite && $0.y.isFinite }),
              annotation.lineWidth.isFinite, annotation.lineWidth > 0 else { return false }
        if annotation.kind == .text || annotation.kind == .pixelate {
            return annotation.bounds.insetBy(dx: -tolerance, dy: -tolerance).contains(point)
        }
        let path = path(for: annotation)
        if annotation.kind.supportsFill, let fill = annotation.fillColor, fill.alpha > 0, path.contains(point) { return true }
        return path.copy(strokingWithWidth: annotation.lineWidth + tolerance * 2,
                         lineCap: .round, lineJoin: .round, miterLimit: 10).contains(point)
    }

    /// One CoreText frame owns wrapping, paragraph alignment and typography for preview and export.
    public static func drawText(_ annotation: Annotation, in context: CGContext) {
        let rect = annotation.bounds
        let baseFont: CTFont
        if annotation.fontName == "System" {
            baseFont = CTFontCreateUIFontForLanguage(.system, annotation.fontSize, nil)
                ?? CTFontCreateWithName("Helvetica" as CFString, annotation.fontSize, nil)
        } else {
            baseFont = CTFontCreateWithName(annotation.fontName as CFString, annotation.fontSize, nil)
        }
        var traits: CTFontSymbolicTraits = []
        if annotation.bold { traits.insert(.boldTrait) }
        if annotation.italic { traits.insert(.italicTrait) }
        let font = CTFontCreateCopyWithSymbolicTraits(baseFont, annotation.fontSize, nil, traits,
                                                     [.boldTrait, .italicTrait]) ?? baseFont
        var alignment: CTTextAlignment = switch annotation.textAlignment {
        case .leading: .left
        case .center: .center
        case .trailing: .right
        }
        var wrapping: CTLineBreakMode = .byWordWrapping
        let paragraph = withUnsafePointer(to: &alignment) { alignmentPointer in
            withUnsafePointer(to: &wrapping) { wrappingPointer in
                let settings = [
                    CTParagraphStyleSetting(spec: .alignment, valueSize: MemoryLayout<CTTextAlignment>.size, value: alignmentPointer),
                    CTParagraphStyleSetting(spec: .lineBreakMode, valueSize: MemoryLayout<CTLineBreakMode>.size, value: wrappingPointer)
                ]
                return CTParagraphStyleCreate(settings, settings.count)
            }
        }
        var attributes: [CFString: Any] = [kCTFontAttributeName: font,
            kCTForegroundColorAttributeName: annotation.color.cgColor, kCTParagraphStyleAttributeName: paragraph]
        if annotation.underline { attributes[kCTUnderlineStyleAttributeName] = CTUnderlineStyle.single.rawValue }
        guard let string = CFAttributedStringCreate(nil, annotation.text as CFString, attributes as CFDictionary) else { return }
        let framesetter = CTFramesetterCreateWithAttributedString(string)
        // A resized box may be shorter than a line. Lay out at least one line, then clip its visible
        // portion, rather than making a retained label disappear until the box grows again.
        let layoutHeight = max(rect.height, CTFontGetAscent(font) + CTFontGetDescent(font) + CTFontGetLeading(font) + 2)
        let path = CGPath(rect: CGRect(x: 0, y: 0, width: rect.width, height: layoutHeight), transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)
        context.saveGState()
        context.clip(to: rect)
        context.translateBy(x: rect.minX, y: rect.minY + layoutHeight); context.scaleBy(x: 1, y: -1)
        context.textMatrix = .identity
        CTFrameDraw(frame, context)
        context.restoreGState()
    }
}

/// Small pixelation tiles are cached independently of vector objects and the immutable bounded source.
/// Retain one value per canvas; this cache never retains or decodes full-resolution original images.
public struct PreviewPixelationCache: Sendable {
    private struct Tile: Sendable {
        let rect: CGRect
        let lineWidth: CGFloat
        let image: CGImage
    }
    private var sourceIdentity: ObjectIdentifier?
    private var imageIdentity: ObjectIdentifier?
    private var imageOwner: CGImage?
    private var flattenOnWhite = false
    private var tiles: [UUID: Tile] = [:]
    private var byteCount = 0
    private static let byteLimit = 8 * 1024 * 1024
    public init() {}

    mutating func prepare(source: ImageSource, image: CGImage, format: ExportFormat, annotations: [Annotation]) {
        let sourceID = ObjectIdentifier(source), imageID = ObjectIdentifier(image)
        if sourceID != sourceIdentity || imageID != imageIdentity || flattenOnWhite != (format == .jpeg) {
            tiles.removeAll(); byteCount = 0
            sourceIdentity = sourceID; imageIdentity = imageID; flattenOnWhite = format == .jpeg
            imageOwner = image
        }
        let current = Set(annotations.filter { $0.kind == .pixelate }.map(\.id))
        for id in Array(tiles.keys) where !current.contains(id) {
            if let tile = tiles.removeValue(forKey: id) { byteCount -= tile.image.bytesPerRow * tile.image.height }
        }
    }

    mutating func tile(for annotation: Annotation, rect: CGRect, create: () throws -> CGImage) throws -> CGImage {
        if let tile = tiles[annotation.id], tile.rect == rect, tile.lineWidth == annotation.lineWidth { return tile.image }
        let image = try create()
        if let previous = tiles.removeValue(forKey: annotation.id) { byteCount -= previous.image.bytesPerRow * previous.image.height }
        let size = image.bytesPerRow * image.height
        if size <= Self.byteLimit {
            if byteCount + size > Self.byteLimit { tiles.removeAll(); byteCount = 0 }
            tiles[annotation.id] = Tile(rect: rect, lineWidth: annotation.lineWidth, image: image)
            byteCount += size
        }
        return image
    }
}

/// Serializes full-resolution rendering without detaching work from the caller's cancellation.
public actor ImageExportQueue {
    public static let shared = ImageExportQueue()
    public init() {}

    public func export(_ source: ImageSource, edits: EditState, format: ExportFormat,
                       quality: Double = 0.9) throws -> ExportedImage {
        try Task.checkCancellation()
        return try ImageRenderer.export(source, edits: edits, format: format, quality: quality)
    }
}

public enum ImageRenderer {
    private static let standardColorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    private static let wideColorSpace = CGColorSpace(name: CGColorSpace.displayP3)!

    /// Wide-gamut sources (and, with edits, wide-gamut annotation colors) keep Display P3 instead of
    /// being clipped to sRGB. Output stays 8-bit SDR; ordinary sRGB images keep sRGB output.
    static func workingColorSpace(for image: CGImage, edits: EditState? = nil) -> CGColorSpace {
        if image.colorSpace?.isWideGamutRGB == true { return wideColorSpace }
        let wideAnnotation = edits?.annotations.contains {
            $0.color.isOutsideSRGBGamut || $0.fillColor?.isOutsideSRGBGamut == true
        } ?? false
        return wideAnnotation ? wideColorSpace : standardColorSpace
    }

    private static func rawImage(_ source: ImageSource) throws -> CGImage {
        try Task.checkCancellation()
        if let image = source.capturedImage { return image }
        guard let url = source.url,
              let decoder = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache: false] as CFDictionary),
              let image = CGImageSourceCreateImageAtIndex(decoder, 0, [kCGImageSourceShouldCache: false] as CFDictionary)
        else { throw ImageError.unreadable }
        try Task.checkCancellation()
        return image
    }

    /// EXIF transforms in top-left raw pixel coordinates. Mirrored orientations are first-class.
    private static func orientationTransform(_ orientation: Int, width: CGFloat, height: CGFloat) -> CGAffineTransform {
        switch orientation {
        case 2: CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: width, ty: 0)
        case 3: CGAffineTransform(a: -1, b: 0, c: 0, d: -1, tx: width, ty: height)
        case 4: CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: height)
        case 5: CGAffineTransform(a: 0, b: 1, c: 1, d: 0, tx: 0, ty: 0)
        case 6: CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: height, ty: 0)
        case 7: CGAffineTransform(a: 0, b: -1, c: -1, d: 0, tx: height, ty: width)
        case 8: CGAffineTransform(a: 0, b: -1, c: 1, d: 0, tx: 0, ty: width)
        default: .identity
        }
    }

    /// Draw either raw full-resolution data or the upright bounded preview into source-pixel coordinates.
    /// Crop in raw coordinates first to avoid allocating a second full-resolution upright image.
    private static func drawSource(_ image: CGImage, orientation: Int, region: CGRect,
                                   sourceSize: CGSize, in context: CGContext) throws {
        try Task.checkCancellation()
        let rotated = (5...8).contains(orientation)
        let upright = CGSize(width: rotated ? image.height : image.width,
                             height: rotated ? image.width : image.height)
        let sx = sourceSize.width / upright.width, sy = sourceSize.height / upright.height
        let transform = orientationTransform(orientation, width: CGFloat(image.width), height: CGFloat(image.height))
        let nativeRegion = CGRect(x: region.minX / sx, y: region.minY / sy,
                                  width: region.width / sx, height: region.height / sy)
        let rawRect = nativeRegion.applying(transform.inverted()).integral
            .intersection(CGRect(x: 0, y: 0, width: image.width, height: image.height))
        guard !rawRect.isNull, let clipped = image.cropping(to: rawRect) else { throw ImageError.renderFailed }
        context.saveGState()
        context.clip(to: region)
        context.scaleBy(x: sx, y: sy)
        context.concatenate(transform)
        context.translateBy(x: rawRect.minX, y: rawRect.maxY)
        context.scaleBy(x: 1, y: -1)
        context.interpolationQuality = .high
        context.draw(clipped, in: CGRect(origin: .zero, size: rawRect.size))
        context.restoreGState()
        try Task.checkCancellation()
    }

    private static func bitmap(width: Int, height: Int, colorSpace: CGColorSpace) throws -> CGContext {
        try Task.checkCancellation()
        guard width > 0, height > 0, width <= 100_000, height <= 100_000,
              Int64(width) * Int64(height) <= 100_000_000 else { throw ImageError.tooLarge }
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
            bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { throw ImageError.renderFailed }
        return context
    }

    /// The grid belongs to the full annotation/source intersection, never to the current crop or preview scale.
    private static func pixelated(_ image: CGImage, orientation: Int, region: CGRect, sourceSize: CGSize,
                                  blockSize: CGFloat, flattenOnWhite: Bool) throws -> CGImage {
        let width = max(1, Int(ceil(region.width / max(1, blockSize))))
        let height = max(1, Int(ceil(region.height / max(1, blockSize))))
        let context = try bitmap(width: width, height: height, colorSpace: workingColorSpace(for: image))
        if flattenOnWhite {
            context.setFillColor(CGColor(gray: 1, alpha: 1))
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
        context.translateBy(x: 0, y: CGFloat(height)); context.scaleBy(x: 1, y: -1)
        context.scaleBy(x: CGFloat(width) / region.width, y: CGFloat(height) / region.height)
        context.translateBy(x: -region.minX, y: -region.minY)
        try drawSource(image, orientation: orientation, region: region, sourceSize: sourceSize, in: context)
        guard let pixels = context.makeImage() else { throw ImageError.renderFailed }
        try Task.checkCancellation()
        return pixels
    }

    private static func validate(_ annotation: Annotation) throws {
        let limit = Annotation.maximumDimension
        guard annotation.points.allSatisfy({ $0.x.isFinite && $0.y.isFinite && abs($0.x) <= limit * 2 && abs($0.y) <= limit * 2 }),
              annotation.lineWidth.isFinite, annotation.lineWidth > 0, annotation.lineWidth <= limit,
              annotation.fontSize.isFinite, annotation.fontSize > 0, annotation.fontSize <= limit,
              annotation.fontName.utf8.count <= 256,
              isRenderable(annotation.color) else { throw ImageError.invalidDimensions }
        if let fill = annotation.fillColor {
            guard isRenderable(fill) else { throw ImageError.invalidDimensions }
        }
    }

    /// Extended-range components are valid colors; only nonfinite or unbounded values are rejected.
    private static func isRenderable(_ color: StrokeColor) -> Bool {
        [color.red, color.green, color.blue].allSatisfy { $0.isFinite && StrokeColor.componentRange.contains($0) }
            && color.alpha.isFinite && (0...1).contains(color.alpha)
    }

    /// One insertion-ordered composition pass is used by the preview and full-resolution export.
    private static func drawAnnotations(_ edits: EditState, image: CGImage, orientation: Int,
                                        source: ImageSource, crop: CGRect, format: ExportFormat,
                                        cache: inout PreviewPixelationCache, in context: CGContext) throws {
        context.saveGState()
        defer { context.restoreGState() }
        context.clip(to: crop)
        cache.prepare(source: source, image: image, format: format, annotations: edits.annotations)
        for annotation in edits.annotations {
            try Task.checkCancellation()
            try validate(annotation)
            context.saveGState()
            switch annotation.kind {
            case .pixelate:
                // Cover every intersected source pixel, including fractional selection edges.
                let rect = CropGeometry.pixelAligned(annotation.bounds, in: source.bounds)
                let visible = rect.intersection(crop)
                if !visible.isNull, visible.width > 0, visible.height > 0 {
                    let pixels = try cache.tile(for: annotation, rect: rect) {
                        try pixelated(image, orientation: orientation, region: rect, sourceSize: source.size,
                            blockSize: max(16, annotation.lineWidth * 4), flattenOnWhite: format == .jpeg)
                    }
                    context.translateBy(x: rect.minX, y: rect.maxY); context.scaleBy(x: 1, y: -1)
                    context.interpolationQuality = .none
                    // Replace underlying pixels, including their alpha. Source-over leaks original detail through
                    // translucent blocks. JPEG blocks are flattened separately to preserve an opaque output.
                    context.setBlendMode(.copy)
                    context.draw(pixels, in: CGRect(origin: .zero, size: rect.size))
                }
            case .text: AnnotationEngine.drawText(annotation, in: context)
            default:
                context.setStrokeColor(annotation.color.cgColor)
                context.setLineWidth(annotation.lineWidth)
                context.setLineCap(.round); context.setLineJoin(.round)
                context.addPath(AnnotationEngine.path(for: annotation))
                if annotation.kind.supportsFill, let fill = annotation.fillColor {
                    context.setFillColor(fill.cgColor); context.drawPath(using: .fillStroke)
                } else { context.strokePath() }
            }
            context.restoreGState()
        }
        try Task.checkCancellation()
    }

    public static func render(_ source: ImageSource, edits: EditState, format: ExportFormat) throws -> CGImage {
        try Task.checkCancellation()
        let crop = CropGeometry.pixelAligned(edits.crop, in: source.bounds)
        guard crop.width >= 1, crop.height >= 1 else { throw ImageError.invalidDimensions }
        guard crop.width * crop.height <= 100_000_000 else { throw ImageError.tooLarge }
        let outputSize = edits.rotation.size(for: crop.size)
        // Creating the image reads only its header; pixels decode when drawn below.
        let image = try rawImage(source)
        let context = try bitmap(width: Int(outputSize.width), height: Int(outputSize.height),
                                 colorSpace: workingColorSpace(for: image, edits: edits))
        if format == .jpeg {
            context.setFillColor(CGColor(gray: 1, alpha: 1))
            context.fill(CGRect(origin: .zero, size: outputSize))
        }
        context.translateBy(x: 0, y: outputSize.height); context.scaleBy(x: 1, y: -1)
        context.concatenate(edits.rotation.transform(in: crop))
        context.clip(to: crop)
        try drawSource(image, orientation: source.orientation, region: crop, sourceSize: source.size, in: context)
        var cache = PreviewPixelationCache()
        try drawAnnotations(edits, image: image, orientation: source.orientation, source: source,
                            crop: crop, format: format, cache: &cache, in: context)
        guard let result = context.makeImage() else { throw ImageError.renderFailed }
        try Task.checkCancellation()
        return result
    }

    /// Live source-space drawing uses the bounded upright source and retained vector objects.
    /// Pass source.bounds for Crop, or the current crop for Annotate. No original file is decoded.
    public static func drawPreview(_ source: ImageSource, edits: EditState, clippingTo region: CGRect? = nil,
                                   in context: CGContext) throws {
        var cache = PreviewPixelationCache()
        try drawPreview(source, edits: edits, clippingTo: region, cache: &cache, in: context)
    }

    /// Retain a value cache in the canvas to reuse bounded pixelation tiles during vector interaction.
    public static func drawPreview(_ source: ImageSource, edits: EditState, clippingTo region: CGRect? = nil,
                                   cache: inout PreviewPixelationCache, in context: CGContext) throws {
        try Task.checkCancellation()
        let requested = region ?? source.bounds
        guard [requested.minX, requested.minY, requested.width, requested.height].allSatisfy(\.isFinite)
        else { throw ImageError.invalidDimensions }
        let clip = requested.standardized.intersection(source.bounds)
        guard !clip.isNull, clip.width > 0, clip.height > 0 else { return }
        context.saveGState()
        defer { context.restoreGState() }
        context.clip(to: clip)
        try drawSource(source.preview, orientation: 1, region: clip, sourceSize: source.size, in: context)
        try drawAnnotations(edits, image: source.preview, orientation: 1, source: source,
                            crop: clip, format: .png, cache: &cache, in: context)
    }

    /// Legacy bounded bitmap convenience clips annotations to the crop; the live canvas uses drawPreview
    /// with explicit source/crop bounds so Crop mode can display every retained object.
    public static func renderPreview(_ source: ImageSource, edits: EditState) throws -> CGImage {
        let crop = CropGeometry.pixelAligned(edits.crop, in: source.bounds)
        guard crop.width >= 1, crop.height >= 1 else { throw ImageError.invalidDimensions }
        let size = edits.rotation.size(for: CGSize(width: source.preview.width, height: source.preview.height))
        let sourceSize = edits.rotation.size(for: source.size)
        let context = try bitmap(width: Int(size.width), height: Int(size.height),
                                 colorSpace: workingColorSpace(for: source.preview, edits: edits))
        context.translateBy(x: 0, y: size.height); context.scaleBy(x: 1, y: -1)
        context.scaleBy(x: size.width / sourceSize.width, y: size.height / sourceSize.height)
        context.concatenate(edits.rotation.transform(in: source.bounds))
        try drawSource(source.preview, orientation: 1, region: source.bounds, sourceSize: source.size, in: context)
        var cache = PreviewPixelationCache()
        try drawAnnotations(edits, image: source.preview, orientation: 1, source: source,
                            crop: crop, format: .png, cache: &cache, in: context)
        guard let result = context.makeImage() else { throw ImageError.renderFailed }
        try Task.checkCancellation()
        return result
    }

    public static func export(_ source: ImageSource, edits: EditState, format: ExportFormat,
                              quality: Double = 0.9) throws -> ExportedImage {
        try Task.checkCancellation()
        let directory = try ImageTemporaryStorage.shared.createDirectory(for: .exports)
        let url = directory.appendingPathComponent("Glass Image Tools.\(format.fileExtension)")
        do {
            let size = try autoreleasepool {
                let image = try render(source, edits: edits, format: format)
                try Task.checkCancellation()
                guard let destination = CGImageDestinationCreateWithURL(url as CFURL, format.type.identifier as CFString, 1, nil)
                else { throw ImageError.encodeFailed }
                let jpegQuality = quality.isFinite ? min(1, max(0.1, quality)) : 0.9
                let properties: [CFString: Any] = format == .jpeg
                    ? [kCGImageDestinationLossyCompressionQuality: jpegQuality] : [:]
                // Fresh destinations carry no location, device or original image metadata.
                CGImageDestinationAddImage(destination, image, properties as CFDictionary)
                try Task.checkCancellation()
                guard CGImageDestinationFinalize(destination) else { throw ImageError.encodeFailed }
                try ImageTemporaryStorage.protectFile(url)
                try Task.checkCancellation()
                return CGSize(width: image.width, height: image.height)
            }
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            try Task.checkCancellation()
            return ExportedImage(url: url, size: size, byteCount: (attributes[.size] as? NSNumber)?.intValue ?? 0,
                                 format: format)
        } catch {
            // Report the export failure itself; next-launch purge owns any directory left behind.
            try? FileManager.default.removeItem(at: directory)
            throw error
        }
    }
}
