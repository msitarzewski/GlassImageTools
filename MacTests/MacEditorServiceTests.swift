import XCTest
import AppKit
import ImageIO
import UniformTypeIdentifiers
import VisionSnipCore
@testable import GlassImageToolsMac

final class MacEditorServiceTests: XCTestCase {
    private func source() throws -> ImageSource {
        let context = try XCTUnwrap(CGContext(data: nil, width: 640, height: 480, bitsPerComponent: 8,
            bytesPerRow: 640 * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.setFillColor(CGColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: 640, height: 480))
        let data = NSMutableData()
        let destination = try XCTUnwrap(CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, try XCTUnwrap(context.makeImage()), nil)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".png")
        defer { try? FileManager.default.removeItem(at: url) }
        try (data as Data).write(to: url)
        return try ImageImportService.importFile(url, name: "Synthetic Image.png")
    }
    private func size(_ data: Data) throws -> CGSize {
        let source = try XCTUnwrap(CGImageSourceCreateWithData(data as CFData, nil))
        let image = try XCTUnwrap(CGImageSourceCreateImageAtIndex(source, 0, nil))
        return CGSize(width: image.width, height: image.height)
    }
    @MainActor func testCropRotationUndoAndActualMacClipboard() async throws {
        let source = try source(), model = EditorModel(source: source)
        model.beginInspectorTransaction()
        model.setCropDimension(320, keyPath: \.size.width); model.setCropDimension(240, keyPath: \.size.height)
        XCTAssertTrue(model.hasUnsavedChanges)
        model.rotateLeft(); await model.copy()
        XCTAssertNil(model.error)
        XCTAssertEqual(try size(XCTUnwrap(NSPasteboard.general.data(forType: .png))), CGSize(width: 240, height: 320))
        model.undo(); XCTAssertEqual(model.outputSize, CGSize(width: 320, height: 240))
        model.undo(); XCTAssertEqual(model.outputSize, CGSize(width: 640, height: 480))
    }
    @MainActor func testVectorTextRemainsEditableAndUndoable() throws {
        let model = EditorModel(source: try source())
        model.useTool(.text)
        XCTAssertNotNil(model.selected)
        model.beginInspectorTransaction()
        model.updateSelected { $0.text = "Editable label"; $0.fontSize = 64 }
        model.finishInspectorTransaction()
        XCTAssertEqual(model.selected?.text, "Editable label"); XCTAssertEqual(model.selected?.fontSize, 64)
        model.undo(); XCTAssertNotEqual(model.selected?.text, "Editable label")
        model.redo(); XCTAssertEqual(model.selected?.text, "Editable label")
    }
    @MainActor func testNativePasteboardImageImportRoundTrip() async throws {
        let source = try source()
        let data = try await EditedImageTransfer(source: source, edits: EditState(crop: source.bounds)).pngData()
        XCTAssertTrue(ClipboardService.copy(data))
        guard case .providers(let providers) = try MacPasteboard.input() else { return XCTFail("Expected encoded image providers") }
        let model = EditorModel(); await model.pasteImage(providers)
        XCTAssertNil(model.error); XCTAssertEqual(model.source?.size, CGSize(width: 640, height: 480))
    }
    @MainActor func testImageRepresentationWinsOverLinkText() throws {
        let source = try source()
        let image = try Data(contentsOf: XCTUnwrap(source.url))
        let item = NSPasteboardItem(); item.setData(image, forType: .png)
        item.setString("https://example.com/never-requested.png", forType: .string)
        NSPasteboard.general.clearContents(); XCTAssertTrue(NSPasteboard.general.writeObjects([item]))
        guard case .providers(let providers) = try MacPasteboard.input() else { return XCTFail("Expected image") }
        XCTAssertTrue(providers[0].hasItemConformingToTypeIdentifier(UTType.png.identifier))
    }
    @MainActor func testPNGAndJPEGExportPreserveOriginalBytes() async throws {
        let source = try source(), original = try Data(contentsOf: XCTUnwrap(source.url))
        let state = EditState(crop: CGRect(x: 80, y: 90, width: 320, height: 240))
        for format in ExportFormat.allCases {
            let output = try await ImageExportQueue.shared.export(source, edits: state, format: format)
            let file = try ExportFile(url: output.url)
            XCTAssertEqual(try size(file.data), CGSize(width: 320, height: 240))
            let properties = try XCTUnwrap(CGImageSourceCopyPropertiesAtIndex(XCTUnwrap(CGImageSourceCreateWithData(file.data as CFData, nil)), 0, nil)) as NSDictionary
            XCTAssertNil(properties[kCGImagePropertyGPSDictionary])
            let exif = properties[kCGImagePropertyExifDictionary] as? NSDictionary
            XCTAssertNil(exif?[kCGImagePropertyExifDateTimeOriginal]); XCTAssertNil(exif?[kCGImagePropertyExifBodySerialNumber]); XCTAssertNil(exif?[kCGImagePropertyExifMakerNote])
        }
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(source.url)), original)
    }
    @MainActor func testSavedFlattenedRecentHasNoEdits() async throws {
        let workspace = DocumentWorkspace(source: try source()), model = workspace.model
        model.setCropDimension(320, keyPath: \.size.width)
        let source = try XCTUnwrap(model.source), id = try XCTUnwrap(workspace.selectedID)
        let output = try await ImageExportQueue.shared.export(source, edits: model.edit, format: .png)
        XCTAssertTrue(workspace.recordSave(output, documentID: id, source: source, edits: model.edit))
        XCTAssertFalse(model.hasUnsavedChanges)
        _ = try await workspace.closeDocument(id)
        let recent = try XCTUnwrap(workspace.recents.first)
        try workspace.reopen(recent.id)
        XCTAssertEqual(workspace.model.source?.size, CGSize(width: 320, height: 480))
        XCTAssertFalse(workspace.model.hasUnsavedChanges)
    }
}
