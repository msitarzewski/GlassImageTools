import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import Photos
import UniformTypeIdentifiers
import VisionSnipCore
import CoreTransferable

/// Shares an immutable edit snapshot through the system sheet. No original thumbnail is supplied:
/// both the transferred PNG and any image a recipient generates from it contain the flattened edits.
struct EditedImageTransfer: Transferable, Sendable {
    let source: ImageSource
    let edits: EditState

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in try await item.pngData() }
            .suggestedFileName("Edited Image.png")
    }

    func pngData() async throws -> Data {
        try Task.checkCancellation()
        let output = try await ImageExportQueue.shared.export(source, edits: edits, format: .png)
        try Task.checkCancellation()
        let data = try Data(contentsOf: output.url, options: .mappedIfSafe)
        try Task.checkCancellation()
        return data
    }
}

/// Matches the system Share › Copy: one image item with the normal clipboard lifetime and reach,
/// including Universal Clipboard. Writes happen only on an explicit Copy; there is no app history.
@MainActor enum ClipboardService {
    @discardableResult static func copy(_ data: Data, format: ExportFormat = .png) -> Bool {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        return pasteboard.setData(data, forType: NSPasteboard.PasteboardType(format.type.identifier))
        #else
        UIPasteboard.general.setItems([[format.type.identifier: data]])
        return true
        #endif
    }
}

enum ExportService {
    static func saveToPhotos(_ image: ExportedImage) async throws {
        var authorization = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if authorization == .notDetermined {
            authorization = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        }
        guard authorization == .authorized || authorization == .limited else {
            throw PhotoSaveError.denied
        }
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, fileURL: image.url, options: nil)
        }
    }
    enum PhotoSaveError: LocalizedError {
        case denied
        var errorDescription: String? {
            #if os(macOS)
            "Photos saving is not allowed. Enable permission for Glass Image Tools in System Settings > Privacy & Security > Photos, or use Save As."
            #else
            "Photos saving is not allowed. Enable permission for Glass Image Tools in Settings, or use Save to Files."
            #endif
        }
    }
}

struct ExportFile: FileDocument {
    static var readableContentTypes: [UTType] { [.png, .jpeg] }
    let data: Data
    init(url: URL) throws { data = try Data(contentsOf: url, options: .mappedIfSafe) }
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else { throw ImageError.unreadable }
        self.data = data
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
