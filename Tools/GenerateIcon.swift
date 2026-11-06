import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

// Editable SVG masters own the artwork; this macOS authoring tool exports visionOS depth planes.
// Usage: swift Tools/GenerateIcon.swift [asset-catalog] [--palette red|cobalt] [--proof-directory directory]

enum IconError: LocalizedError {
    case invalidArguments, invalidMaster(String), rasterization(String), invalidPlane(String), encoding
    var errorDescription: String? {
        switch self {
        case .invalidArguments: "Usage: GenerateIcon.swift [asset-catalog] [--palette red|cobalt] [--proof-directory directory]"
        case .invalidMaster(let name): "Invalid or missing editable SVG master: \(name)."
        case .rasterization(let detail): "SVG conversion failed. Install rsvg-convert and make it available on PATH. \(detail)"
        case .invalidPlane(let name): "Invalid size, opacity or transparency in icon plane: \(name)."
        case .encoding: "Could not encode the icon proof."
        }
    }
}

struct Options {
    var catalog = URL(fileURLWithPath: "App/Assets.xcassets")
    var palette = "red"
    var proof: URL?

    init(_ arguments: [String]) throws {
        var index = 0
        if let first = arguments.first, !first.hasPrefix("--") {
            catalog = URL(fileURLWithPath: first)
            index += 1
        }
        while index < arguments.count {
            guard index + 1 < arguments.count else { throw IconError.invalidArguments }
            let value = arguments[index + 1]
            switch arguments[index] {
            case "--palette": palette = value
            case "--proof-directory": proof = URL(fileURLWithPath: value)
            default: throw IconError.invalidArguments
            }
            index += 2
        }
        guard ["red", "cobalt"].contains(palette) else {
            throw IconError.invalidArguments
        }
    }
}

let manager = FileManager.default
let info: [String: Any] = ["author": "xcode", "version": 1]
let space = CGColorSpace(name: CGColorSpace.sRGB)!
let planeNames = ["Back", "Middle", "Front"]

func writeJSON(_ object: [String: Any], to url: URL) throws {
    try manager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]).write(to: url)
}

func readImage(_ url: URL) throws -> CGImage {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
          image.width == 1024, image.height == 1024 else { throw IconError.invalidPlane(url.lastPathComponent) }
    return image
}

func makeContext(_ size: Int = 1024) throws -> CGContext {
    guard let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8,
                                  bytesPerRow: size * 4, space: space,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { throw IconError.encoding }
    return context
}

func writePNG(_ image: CGImage, to url: URL) throws {
    try manager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        throw IconError.encoding
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { throw IconError.encoding }
}

func proofImage(_ images: [CGImage], size: Int = 1024, checkerboard: Bool = false) throws -> CGImage {
    let context = try makeContext(size)
    if checkerboard {
        for y in stride(from: 0, to: size, by: 32) {
            for x in stride(from: 0, to: size, by: 32) {
                context.setFillColor(CGColor(gray: ((x / 32 + y / 32) % 2 == 0) ? 0.9 : 0.8, alpha: 1))
                context.fill(CGRect(x: x, y: y, width: 32, height: 32))
            }
        }
    }
    context.interpolationQuality = .high
    for image in images { context.draw(image, in: CGRect(x: 0, y: 0, width: size, height: size)) }
    guard let image = context.makeImage() else { throw IconError.encoding }
    return image
}

/// The stack's contract. Back is opaque. Middle (sun and hills) stays inside radius 490, under the
/// frame. Front (the frame) is clear inside radius 450, where the glass shows, and opaque from radius
/// 462 to the icon's edge, so parallax never shows the Middle's edge or a gap at the rim.
func verifyAlpha(_ image: CGImage, plane: String) throws -> [String: Any] {
    let context = try makeContext()
    context.draw(image, in: CGRect(x: 0, y: 0, width: 1024, height: 1024))
    guard let data = context.data else { throw IconError.invalidPlane(plane) }
    let bytes = data.assumingMemoryBound(to: UInt8.self)
    var clear = 0, opaque = 0, partial = 0
    var minimumRadius = Double.infinity, maximumRadius = 0.0
    var beyondFrame = 0, insideGlass = 0, frameGaps = 0
    for y in 0..<1024 {
        for x in 0..<1024 {
            let alpha = bytes[(y * 1024 + x) * 4 + 3]
            let radius = hypot(Double(x) - 511.5, Double(y) - 511.5)
            if alpha == 0 { clear += 1 }
            else {
                if alpha == 255 { opaque += 1 } else { partial += 1 }
                minimumRadius = min(minimumRadius, radius)
                maximumRadius = max(maximumRadius, radius)
                if radius > 490 { beyondFrame += 1 }
                if radius < 450 { insideGlass += 1 }
            }
            if alpha < 255, radius >= 462, radius <= 511.5 { frameGaps += 1 }
        }
    }
    let valid = switch plane {
    case "Back": opaque == 1024 * 1024
    case "Middle": clear > 0 && opaque > 0 && beyondFrame == 0
    default: clear > 0 && insideGlass == 0 && frameGaps == 0
    }
    guard valid else { throw IconError.invalidPlane(plane) }
    var result: [String: Any] = ["width": 1024, "height": 1024, "fullyTransparentPixels": clear,
                                 "fullyOpaquePixels": opaque, "partiallyTransparentPixels": partial,
                                 "canvasOccupancyPercent": Double(opaque + partial) / Double(1024 * 1024) * 100]
    switch plane {
    case "Middle":
        result["maximumContentRadiusPixels"] = maximumRadius
        result["contentBeyond490PixelRadius"] = beyondFrame
    case "Front":
        result["minimumContentRadiusPixels"] = minimumRadius
        result["contentInside450PixelRadius"] = insideGlass
        result["nonOpaquePixelsFrom462ToEdge"] = frameGaps
    default: break
    }
    return result
}

func specializedSVG(_ source: String, palette: String) -> String {
    var result = source
    // The masters use Glass Power Tools' visionOS screen red: lit #f83835, #e20707, deep #b00100, and a
    // #7d1010 rim. Cobalt is the same ramp built from the family's #0047ab.
    if palette == "cobalt" {
        let colors = ["#f83835": "#3a78d6", "#e20707": "#0047ab", "#b00100": "#00337d", "#7d1010": "#0b2350"]
        for (red, cobalt) in colors { result = result.replacingOccurrences(of: red, with: cobalt) }
    }
    return result
}

do {
    let options = try Options(Array(CommandLine.arguments.dropFirst()))
    let sources = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("Icon")
    let scratch = manager.temporaryDirectory.appendingPathComponent("GlassImageTools-Icon-\(UUID().uuidString)", isDirectory: true)
    try manager.createDirectory(at: scratch, withIntermediateDirectories: true)
    defer { try? manager.removeItem(at: scratch) }

    let catalogInfo = options.catalog.appendingPathComponent("Contents.json")
    if !manager.fileExists(atPath: catalogInfo.path) { try writeJSON(["info": info], to: catalogInfo) }
    let stack = options.catalog.appendingPathComponent("AppIcon.solidimagestack")
    try writeJSON(["info": info, "layers": planeNames.reversed().map { ["filename": "\($0).solidimagestacklayer"] }],
                  to: stack.appendingPathComponent("Contents.json"))
    var images: [CGImage] = []
    var validation: [String: Any] = [:]
    for name in planeNames {
        let master = sources.appendingPathComponent("\(name).svg")
        let raw = try String(contentsOf: master, encoding: .utf8)
        guard raw.contains("viewBox=\"0 0 1024 1024\""), !raw.contains("<image"), !raw.contains("<script"),
              !raw.contains("<mask"), !raw.contains("<filter") else { throw IconError.invalidMaster(name) }
        let svg = scratch.appendingPathComponent("\(name).svg")
        try specializedSVG(raw, palette: options.palette).write(to: svg, atomically: true, encoding: .utf8)
        let layer = stack.appendingPathComponent("\(name).solidimagestacklayer")
        let content = layer.appendingPathComponent("Content.imageset")
        try writeJSON(["info": info], to: layer.appendingPathComponent("Contents.json"))
        try writeJSON(["info": info, "images": [["filename": "\(name).png", "idiom": "vision", "scale": "2x"]]],
                      to: content.appendingPathComponent("Contents.json"))
        let output = content.appendingPathComponent("\(name).png")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["rsvg-convert", "--width", "1024", "--height", "1024", "--output", output.path, svg.path]
        let errors = Pipe(); process.standardError = errors
        try process.run(); process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            let detail = String(data: errors.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            throw IconError.rasterization(detail)
        }
        let image = try readImage(output)
        validation[name] = try verifyAlpha(image, plane: name)
        images.append(image)
    }
    // Settings → About shows the icon flat; the view clips it to the icon's circle.
    let about = options.catalog.appendingPathComponent("AboutIcon.imageset")
    try writeJSON(["info": info, "images": [["filename": "AboutIcon.png", "idiom": "vision", "scale": "2x"]]],
                  to: about.appendingPathComponent("Contents.json"))
    try writePNG(proofImage(images, size: 256), to: about.appendingPathComponent("AboutIcon.png"))
    if let proof = options.proof {
        for (name, image) in zip(planeNames, images) {
            try writePNG(proofImage([image], checkerboard: name != "Back"), to: proof.appendingPathComponent("\(name)-plane.png"))
        }
        for size in [1024, 256, 64, 32] {
            try writePNG(proofImage(images, size: size), to: proof.appendingPathComponent("composite-\(size).png"))
        }
        try writeJSON(["palette": options.palette, "planes": validation,
                       "stackOrderFrontToBack": ["Front", "Middle", "Back"],
                       "proofScope": "Flat artwork composition; system lighting, motion and circular clipping require platform review."],
                      to: proof.appendingPathComponent("validation.json"))
    }
    print("Generated and validated three 1024-pixel planes and the About image: \(options.palette).")
} catch {
    FileHandle.standardError.write(Data("\(error.localizedDescription)\n".utf8))
    exit(1)
}
