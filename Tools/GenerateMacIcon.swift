import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

// Reuse the existing glass-series depth-plane artwork; Mac gets a flat high-resolution icon asset.
// Run from the repository root: swift Tools/GenerateMacIcon.swift
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let catalog = root.appendingPathComponent("Mac/Assets.xcassets")
let appIcon = catalog.appendingPathComponent("AppIcon.appiconset")
try FileManager.default.createDirectory(at: appIcon, withIntermediateDirectories: true)
let context = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8, bytesPerRow: 0,
    space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
context.addEllipse(in: CGRect(x: 32, y: 32, width: 960, height: 960)); context.clip()
for name in ["Back", "Middle", "Front"] {
    let path = root.appendingPathComponent("App/Assets.xcassets/AppIcon.solidimagestack/\(name).solidimagestacklayer/Content.imageset/\(name).png")
    guard let source = CGImageSourceCreateWithURL(path as CFURL, nil), let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
        throw CocoaError(.fileReadCorruptFile)
    }
    context.draw(image, in: CGRect(x: 32, y: 32, width: 960, height: 960))
}
guard let master = context.makeImage() else { throw CocoaError(.fileWriteUnknown) }
var entries: [[String: String]] = []
for points in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = points * scale
        let bitmap = CGContext(data: nil, width: pixels, height: pixels, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        bitmap.interpolationQuality = .high
        bitmap.draw(master, in: CGRect(x: 0, y: 0, width: pixels, height: pixels))
        guard let image = bitmap.makeImage() else { throw CocoaError(.fileWriteUnknown) }
        let name = "icon_\(points)x\(points)@\(scale)x.png"
        guard let destination = CGImageDestinationCreateWithURL(appIcon.appendingPathComponent(name) as CFURL,
            UTType.png.identifier as CFString, 1, nil) else { throw CocoaError(.fileWriteUnknown) }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw CocoaError(.fileWriteUnknown) }
        entries.append(["idiom": "mac", "size": "\(points)x\(points)", "scale": "\(scale)x", "filename": name])
    }
}
let info: [String: Any] = ["images": entries, "info": ["author": "xcode", "version": 1]]
try JSONSerialization.data(withJSONObject: info, options: [.prettyPrinted, .sortedKeys]).write(to: appIcon.appendingPathComponent("Contents.json"))
try JSONSerialization.data(withJSONObject: ["info": ["author": "xcode", "version": 1]], options: [.prettyPrinted]).write(to: catalog.appendingPathComponent("Contents.json"))
let about = catalog.appendingPathComponent("AboutIcon.imageset")
try FileManager.default.createDirectory(at: about, withIntermediateDirectories: true)
let existing = root.appendingPathComponent("App/Assets.xcassets/AboutIcon.imageset/AboutIcon.png")
let target = about.appendingPathComponent("AboutIcon.png")
if FileManager.default.fileExists(atPath: target.path) { try FileManager.default.removeItem(at: target) }
try FileManager.default.copyItem(at: existing, to: target)
let aboutInfo: [String: Any] = ["images": [["idiom": "universal", "filename": "AboutIcon.png"]], "info": ["author": "xcode", "version": 1]]
try JSONSerialization.data(withJSONObject: aboutInfo, options: [.prettyPrinted, .sortedKeys]).write(to: about.appendingPathComponent("Contents.json"))
print("Generated Mac AppIcon sizes and About asset from existing family artwork.")
