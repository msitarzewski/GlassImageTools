import AppKit
import UniformTypeIdentifiers
import VisionSnipCore

/// Read only for an explicit Paste. Preserve encoded bytes; never rasterize an NSImage or retain URL history.
@MainActor enum MacPasteboard {
    enum Input { case file(URL), providers([NSItemProvider]) }
    static func input() throws -> Input {
        let board = NSPasteboard.general
        for item in board.pasteboardItems ?? [] {
            let types = item.types.sorted { $0 == .png && $1 != .png }
            for type in types where UTType(type.rawValue)?.conforms(to: .image) == true {
                if let data = item.data(forType: type) {
                    guard data.count <= ImageImportService.importByteLimit else { throw ImageError.encodedFileTooLarge }
                    let provider = NSItemProvider(item: data as NSData, typeIdentifier: type.rawValue)
                    return .providers([provider])
                }
            }
        }
        if let urls = board.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], let url = urls.first {
            if url.isFileURL { return .file(url) }
        }
        // Keep the original text so Foundation cannot turn two copied URLs into one escaped NSURL.
        if let text = board.string(forType: .string) { return .providers([NSItemProvider(object: text as NSString)]) }
        if let urls = board.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], let url = urls.first {
            return .providers([NSItemProvider(object: url as NSURL)])
        }
        throw ImageError.noPastedImage
    }
}
