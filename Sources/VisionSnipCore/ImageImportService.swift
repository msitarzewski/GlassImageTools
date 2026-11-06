import Foundation
import ImageIO
import CoreGraphics
import UniformTypeIdentifiers

public enum ImageError: LocalizedError {
    case unreadable, invalidDimensions, tooLarge, encodedFileTooLarge, noPastedImage, noDroppedImage, renderFailed, encodeFailed
    public var errorDescription: String? {
        switch self {
        case .unreadable: "This file could not be opened as an image. Choose a PNG, JPEG, HEIC, or another supported still image."
        case .invalidDimensions: "The image has invalid dimensions."
        case .tooLarge: "This image is too large to process safely. Choose an image under 200 megapixels, or export a crop under 100 megapixels."
        case .encodedFileTooLarge: "This image file is too large to import safely. Choose a file under 256 MiB."
        case .noPastedImage: "There is no supported image to paste. Copy an image or a direct HTTPS image link, then choose Paste Image again."
        case .noDroppedImage: "This item does not contain a supported image. Drop an image from Photos or Files."
        case .renderFailed: "The image could not be rendered. Try a smaller crop."
        case .encodeFailed: "The exported image could not be saved."
        }
    }
}

/// An immutable, owned file and one bounded upright preview. In-flight exports retain their source.
public final class ImageSource: Sendable {
    public let url: URL?
    public let capturedImage: CGImage?
    public let orientation: Int
    public let name: String
    public let size: CGSize
    public let preview: CGImage
    public let typeIdentifier: String?
    public var typeLabel: String {
        guard let typeIdentifier, let type = UTType(typeIdentifier) else {
            return capturedImage == nil ? "Image" : "Captured Frame"
        }
        if type.conforms(to: .png) { return "PNG" }
        if type.conforms(to: .jpeg) { return "JPEG" }
        if type.conforms(to: .heic) { return "HEIC" }
        if type.conforms(to: .heif) { return "HEIF" }
        if type.conforms(to: .tiff) { return "TIFF" }
        if type.conforms(to: .gif) { return "GIF" }
        return type.preferredFilenameExtension?.uppercased() ?? type.localizedDescription ?? "Image"
    }
    public var bounds: CGRect { CGRect(origin: .zero, size: size) }
    private let ownedDirectory: URL?

    init(url: URL?, name: String, size: CGSize, preview: CGImage, ownedDirectory: URL?, capturedImage: CGImage? = nil,
         orientation: Int = 1, typeIdentifier: String? = nil) {
        self.url = url; self.name = name; self.size = size; self.preview = preview
        self.ownedDirectory = ownedDirectory
        self.capturedImage = capturedImage
        self.orientation = orientation
        self.typeIdentifier = typeIdentifier
    }
    deinit { if let ownedDirectory { try? FileManager.default.removeItem(at: ownedDirectory) } }
}

/// One process owns these dedicated roots. Static initialization serializes startup/import/export races.
/// A prior process's files are removed on the next launch; force termination cannot run deinitializers.
struct ImageTemporaryStorage: Sendable {
    enum Kind: String { case imports = "VisionSnip-Imports", exports = "VisionSnip-Exports" }
    static let shared = ImageTemporaryStorage(baseDirectory: FileManager.default.temporaryDirectory)
    private let preparation: Result<URL, any Error>

    /// Internal injection keeps cleanup tests away from the process's active files and other temporary data.
    init(baseDirectory: URL) {
        preparation = Result {
            for kind in [Kind.imports, .exports] {
                let root = baseDirectory.appendingPathComponent(kind.rawValue, isDirectory: true)
                if FileManager.default.fileExists(atPath: root.path) {
                    try FileManager.default.removeItem(at: root)
                }
                try Self.createPrivateDirectory(root)
                var rootURL = root
                var values = URLResourceValues()
                values.isExcludedFromBackup = true
                try rootURL.setResourceValues(values)
            }
            return baseDirectory
        }
    }

    func prepare() throws { _ = try preparation.get() }

    func createDirectory(for kind: Kind) throws -> URL {
        let baseDirectory = try preparation.get()
        let directory = baseDirectory.appendingPathComponent(kind.rawValue, isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try Self.createPrivateDirectory(directory)
        return directory
    }

    private static func createPrivateDirectory(_ url: URL) throws {
        var attributes: [FileAttributeKey: Any] = [.posixPermissions: 0o700]
        #if os(visionOS)
        attributes[.protectionKey] = FileProtectionType.complete
        #endif
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: attributes)
    }

    static func requireRegularFile(_ url: URL) throws {
        // attributesOfItem reports the link itself, so this check cannot chmod through a copied symlink.
        guard try FileManager.default.attributesOfItem(atPath: url.path)[.type] as? FileAttributeType == .typeRegular
        else { throw ImageError.unreadable }
    }

    func ownedImportDirectory(for url: URL) throws -> URL {
        let root = try preparation.get().appendingPathComponent(Kind.imports.rawValue, isDirectory: true).standardizedFileURL
        let file = url.standardizedFileURL
        let directory = file.deletingLastPathComponent()
        guard file.isFileURL, file.lastPathComponent == "source.image",
              UUID(uuidString: directory.lastPathComponent) != nil,
              directory.deletingLastPathComponent() == root,
              try FileManager.default.attributesOfItem(atPath: root.path)[.type] as? FileAttributeType == .typeDirectory,
              try FileManager.default.attributesOfItem(atPath: directory.path)[.type] as? FileAttributeType == .typeDirectory
        else { throw ImageError.unreadable }
        try Self.requireRegularFile(file)
        return directory
    }

    static func protectFile(_ url: URL) throws {
        try requireRegularFile(url)
        var attributes: [FileAttributeKey: Any] = [.posixPermissions: 0o600]
        #if os(visionOS)
        attributes[.protectionKey] = FileProtectionType.complete
        #endif
        try FileManager.default.setAttributes(attributes, ofItemAtPath: url.path)
    }
}

public enum ImageImportService {
    public static let previewLimit = 2048
    public static let importByteLimit = 256 * 1024 * 1024

    /// Invoke off the main actor at startup. Repeated calls and new windows preserve this process's files.
    public static func prepareTemporaryStorage() throws {
        try ImageTemporaryStorage.shared.prepare()
    }

    /// An authorized capture can enter the editor directly, without an intermediate Photos asset or file.
    public static func fromCapture(_ image: CGImage) throws -> ImageSource {
        try prepareTemporaryStorage()
        guard Int64(image.width) * Int64(image.height) <= 200_000_000 else { throw ImageError.tooLarge }
        let scale = min(1, CGFloat(previewLimit) / CGFloat(max(image.width, image.height)))
        let width = max(1, Int(CGFloat(image.width) * scale)), height = max(1, Int(CGFloat(image.height) * scale))
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
                                      bytesPerRow: 0, space: ImageRenderer.workingColorSpace(for: image),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { throw ImageError.renderFailed }
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let preview = context.makeImage() else { throw ImageError.renderFailed }
        return ImageSource(url: nil, name: "Captured Frame", size: CGSize(width: image.width, height: image.height),
                           preview: preview, ownedDirectory: nil, capturedImage: image)
    }

    /// Copy while security-scoped / Transferable access is alive; never edit the user's file.
    public static func copyForImport(_ url: URL) throws -> URL {
        try ImageTemporaryStorage.requireRegularFile(url)
        guard let byteCount = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? NSNumber,
              byteCount.int64Value <= Int64(importByteLimit) else { throw ImageError.encodedFileTooLarge }
        let directory = try ImageTemporaryStorage.shared.createDirectory(for: .imports)
        let destination = directory.appendingPathComponent("source.image")
        do {
            try FileManager.default.copyItem(at: url, to: destination)
            guard let byteCount = try FileManager.default.attributesOfItem(atPath: destination.path)[.size] as? NSNumber,
                  byteCount.int64Value <= Int64(importByteLimit) else { throw ImageError.encodedFileTooLarge }
            try ImageTemporaryStorage.protectFile(destination)
        }
        catch {
            // Report the copy failure itself; next-launch purge owns any directory left behind.
            try? FileManager.default.removeItem(at: directory)
            throw error
        }
        return destination
    }

    /// Retain a provider copy immediately, including the interval before preview decoding begins.
    public static func copyOwnedForImport(_ url: URL) throws -> OwnedImageImport {
        try OwnedImageImport(ownedURL: copyForImport(url))
    }

    /// The URL must be a private copy returned by copyForImport. Ownership transfers on success.
    public static func loadOwnedCopy(_ url: URL, name: String? = nil) throws -> ImageSource {
        // Validate the deletion boundary before entering any cleanup path.
        let ownedDirectory = try ImageTemporaryStorage.shared.ownedImportDirectory(for: url)
        do {
            guard let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache: false] as CFDictionary),
                  let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
                  let width = properties[kCGImagePropertyPixelWidth] as? Int,
                  let height = properties[kCGImagePropertyPixelHeight] as? Int,
                  width > 0, height > 0 else { throw ImageError.unreadable }
            guard width <= 100_000, height <= 100_000, Int64(width) * Int64(height) <= 200_000_000 else {
                throw ImageError.tooLarge
            }
            let orientation = properties[kCGImagePropertyOrientation] as? Int ?? 1
            let rotated = (5...8).contains(orientation)
            let size = CGSize(width: rotated ? height : width, height: rotated ? width : height)
            let options: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: previewLimit,
                kCGImageSourceShouldCacheImmediately: true
            ]
            guard let preview = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
                throw ImageError.unreadable
            }
            return ImageSource(url: url, name: name ?? "Image",
                               size: size, preview: preview, ownedDirectory: ownedDirectory, orientation: orientation,
                               typeIdentifier: CGImageSourceGetType(source) as String?)
        } catch {
            // Report the decoding failure itself; next-launch purge owns any directory left behind.
            try? FileManager.default.removeItem(at: ownedDirectory)
            throw error
        }
    }

    public static func importFile(_ url: URL, name: String? = nil) throws -> ImageSource {
        try loadOwnedCopy(copyForImport(url), name: name ?? url.lastPathComponent)
    }

    /// App file imports share the bounded preview worker with Photos and Paste.
    public static func importFileAsync(_ url: URL, name: String? = nil) async throws -> ImageSource {
        try await ImageImportQueue.shared.importFile(url, name: name ?? url.lastPathComponent)
    }

    public static func loadOwnedCopy(_ copy: OwnedImageImport, name: String? = nil) async throws -> ImageSource {
        try await ImageImportQueue.shared.load(copy, name: name ?? "Image")
    }

    /// Called only with providers delivered by an explicit system Paste or image-drop action. Never reads the clipboard.
    /// The file loader also materializes data-backed providers, preserving encoded bytes without UIImage decoding.
    @MainActor public static func importItemProviders(_ providers: [NSItemProvider], fallbackName: String = "Pasted Image",
                                           emptyError: ImageError = .noPastedImage, allowsImageLinks: Bool = false) async throws -> ImageSource {
        try Task.checkCancellation()
        guard let provider = providers.first(where: {
            $0.hasItemConformingToTypeIdentifier(UTType.image.identifier)
        }), let typeIdentifier = provider.registeredTypeIdentifiers.first(where: {
            UTType($0)?.conforms(to: .image) == true
        }) else {
            guard allowsImageLinks, let url = try await imageLinkURL(from: providers) else { throw emptyError }
            return try await ImageLinkImportService.importURL(url)
        }
        let name = provider.suggestedName.flatMap { $0.isEmpty ? nil : $0 } ?? fallbackName
        let request = ItemProviderImportRequest<OwnedImageImport>()
        let copy = try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                guard request.install(continuation) else { return }
                let progress = provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                    guard !request.isCancelled else { return }
                    do {
                        if let error { throw error }
                        guard let url else { throw ImageError.unreadable }
                        // The provider deletes its URL as soon as this callback returns.
                        let copy = try copyOwnedForImport(url)
                        request.complete(.success(copy))
                    } catch { request.complete(.failure(error)) }
                }
                request.store(progress)
            }
        } onCancel: { request.cancel() }
        try Task.checkCancellation()
        return try await loadOwnedCopy(copy, name: name)
    }

    /// Only the explicit Paste fallback calls this; arbitrary text and webpage content are never scanned for links.
    @MainActor static func imageLinkURL(from providers: [NSItemProvider]) async throws -> URL? {
        let urlProvider = providers.first {
            $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) && $0.canLoadObject(ofClass: NSURL.self)
        }
        let textProvider = providers.first { $0.canLoadObject(ofClass: NSString.self) }
        guard let provider = urlProvider ?? textProvider else { return nil }
        // NSString may advertise an auto-converted URL even for two links separated by spaces.
        // Prefer its original plain text so only one complete pasted URL is accepted.
        let hasPlainText = provider.registeredTypeIdentifiers.contains { UTType($0)?.conforms(to: .plainText) == true }
        let request = ItemProviderImportRequest<URL?>()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                guard request.install(continuation) else { return }
                let progress: Progress
                if urlProvider != nil && !hasPlainText {
                    progress = provider.loadObject(ofClass: NSURL.self) { object, error in
                        if let error { request.complete(.failure(error)); return }
                        request.complete(.success(object as? URL))
                    }
                } else {
                    progress = provider.loadObject(ofClass: NSString.self) { object, error in
                        if let error { request.complete(.failure(error)); return }
                        let text = (object as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        guard text.utf8.count <= 32_768, !text.contains(where: { $0.isWhitespace }),
                              let url = URL(string: text), url.scheme != nil else {
                            request.complete(.success(nil)); return
                        }
                        request.complete(.success(url))
                    }
                }
                request.store(progress)
            }
        } onCancel: { request.cancel() }
    }

}

/// Owns a provider copy even if cancellation occurs between delivery and preview decoding.
public final class OwnedImageImport: @unchecked Sendable {
    let url: URL
    private let ownedDirectory: URL
    private let lock = NSLock()
    private var transferred = false

    /// Validation precedes cleanup ownership. An arbitrary URL can never grant deletion of its directory.
    public init(ownedURL: URL) throws {
        ownedDirectory = try ImageTemporaryStorage.shared.ownedImportDirectory(for: ownedURL)
        url = ownedURL
    }

    fileprivate func load(name: String) throws -> ImageSource {
        lock.lock(); let alreadyTransferred = transferred; lock.unlock()
        guard !alreadyTransferred else { throw ImageError.unreadable }
        let source = try ImageImportService.loadOwnedCopy(url, name: name)
        lock.lock(); transferred = true; lock.unlock()
        return source
    }
    deinit {
        lock.lock(); let shouldRemove = !transferred; lock.unlock()
        if shouldRemove { try? FileManager.default.removeItem(at: ownedDirectory) }
    }
}

/// Bounded preview decoding uses the caller's task and cancellation, with no detached image work.
private actor ImageImportQueue {
    static let shared = ImageImportQueue()
    func load(_ copy: OwnedImageImport, name: String) throws -> ImageSource {
        try Task.checkCancellation()
        let source = try copy.load(name: name)
        try Task.checkCancellation()
        return source
    }

    func importFile(_ url: URL, name: String) throws -> ImageSource {
        try Task.checkCancellation()
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        let copy = try ImageImportService.copyOwnedForImport(url)
        return try load(copy, name: name)
    }
}

/// All mutable state is protected by the lock. A late provider callback loses its owned copy naturally.
private final class ItemProviderImportRequest<Value: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<Value, any Error>?
    private var progress: Progress?
    private var cancelled = false
    private var finished = false
    var isCancelled: Bool {
        lock.lock(); defer { lock.unlock() }
        return cancelled
    }
    func install(_ continuation: CheckedContinuation<Value, any Error>) -> Bool {
        lock.lock()
        guard !cancelled else {
            lock.unlock(); continuation.resume(throwing: CancellationError()); return false
        }
        self.continuation = continuation
        lock.unlock()
        return true
    }
    func store(_ progress: Progress) {
        lock.lock()
        let shouldCancel = cancelled
        if !finished && !cancelled { self.progress = progress }
        lock.unlock()
        if shouldCancel { progress.cancel() }
    }
    func complete(_ result: Result<Value, any Error>) {
        lock.lock()
        guard !finished, !cancelled, let continuation else { lock.unlock(); return }
        self.continuation = nil; progress = nil; finished = true
        lock.unlock()
        continuation.resume(with: result)
    }
    func cancel() {
        lock.lock()
        cancelled = true
        let continuation = self.continuation, progress = self.progress
        self.continuation = nil; self.progress = nil; finished = true
        lock.unlock()
        progress?.cancel()
        continuation?.resume(throwing: CancellationError())
    }
}
