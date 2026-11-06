import XCTest
import AppKit
import ImageIO
import UniformTypeIdentifiers

final class GlassImageToolsMacUITests: XCTestCase {
    @MainActor private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--mac-ui-testing"]; app.launch(); app.activate(); return app
    }
    private func fixture() throws -> URL {
        let context = try XCTUnwrap(CGContext(data: nil, width: 640, height: 480, bitsPerComponent: 8,
            bytesPerRow: 640 * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.setFillColor(CGColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1)); context.fill(CGRect(x: 0, y: 0, width: 640, height: 480))
        context.setFillColor(CGColor(red: 1, green: 0.2, blue: 0.1, alpha: 1)); context.fill(CGRect(x: 80, y: 90, width: 100, height: 80))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".png")
        let destination = try XCTUnwrap(CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, try XCTUnwrap(context.makeImage()), nil)
        XCTAssertTrue(CGImageDestinationFinalize(destination)); return url
    }
    @MainActor private func open(_ url: URL, app: XCUIApplication) {
        app.typeKey("o", modifierFlags: .command)
        XCTAssertTrue(app.sheets["open-panel"].waitForExistence(timeout: 5), app.debugDescription)
        app.typeKey("g", modifierFlags: [.command, .shift])
        let path = app.textFields["PathTextField"]
        XCTAssertTrue(path.waitForExistence(timeout: 5), app.debugDescription)
        path.click(); app.typeKey("a", modifierFlags: .command); path.typeText(url.path)
        app.typeKey(.return, modifierFlags: [])
        let open = app.buttons["Open"].firstMatch
        XCTAssertTrue(open.waitForExistence(timeout: 5)); open.click()
        XCTAssertTrue(app.descendants(matching: .any)["image-canvas"].firstMatch.waitForExistence(timeout: 10), app.debugDescription)
    }
    @MainActor private func replace(_ id: String, with value: String, app: XCUIApplication) {
        let field = app.textFields[id]
        XCTAssertTrue(field.waitForExistence(timeout: 5), app.debugDescription)
        field.click(); app.typeKey("a", modifierFlags: .command); field.typeText(value); app.typeKey(.tab, modifierFlags: [])
        XCTAssertEqual(field.value as? String, value, app.debugDescription)
    }
    @MainActor private func crop(app: XCUIApplication) {
        replace("crop-width", with: "320", app: app); replace("crop-height", with: "240", app: app)
    }
    @MainActor private func copiedSize(app: XCUIApplication) throws -> CGSize {
        let change = NSPasteboard.general.changeCount
        app.buttons["mac-copy"].click()
        let copied = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in NSPasteboard.general.changeCount > change }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [copied], timeout: 10), .completed, app.debugDescription)
        let data = try XCTUnwrap(NSPasteboard.general.data(forType: .png))
        let image = try XCTUnwrap(CGImageSourceCreateWithData(data as CFData, nil))
        let pixels = try XCTUnwrap(CGImageSourceCreateImageAtIndex(image, 0, nil))
        return CGSize(width: pixels.width, height: pixels.height)
    }
    @MainActor func testWelcomeLayout() {
        // Xcode injects a root read exception into UI-test apps. Sandbox denial is tested by
        // MacSandboxProbe in a normal signed Debug build, never inferred from this test process.
        let app = launch()
        XCTAssertTrue(app.buttons["mac-paste-well"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["No Image"].exists)
        XCTAssertTrue(app.toolbars.descendants(matching: .any)["mac-editor-settings"].firstMatch.isHittable)
        XCTAssertFalse(app.radioGroups["mac-editor-mode"].exists)
        let photos = app.buttons["mac-open-photos"], files = app.buttons["mac-open-files"]
        XCTAssertEqual(photos.frame.minY, files.frame.minY, accuracy: 2)
        XCTAssertGreaterThan(app.buttons["mac-paste-well"].frame.minY, photos.frame.maxY)
    }
    @MainActor func testOpenExactCropCopyAndUndo() throws {
        let url = try fixture(); defer { try? FileManager.default.removeItem(at: url) }
        let original = try Data(contentsOf: url)
        let app = launch(); open(url, app: app); crop(app: app)
        XCTAssertEqual(try copiedSize(app: app), CGSize(width: 320, height: 240))
        app.buttons["Undo"].click()
        XCTAssertEqual(try copiedSize(app: app), CGSize(width: 640, height: 480))
        XCTAssertEqual(try Data(contentsOf: url), original)
    }
    @MainActor func testClipboardImageAndDirtyCloseCancelDiscard() throws {
        let url = try fixture(); defer { try? FileManager.default.removeItem(at: url) }
        NSPasteboard.general.clearContents(); XCTAssertTrue(NSPasteboard.general.setData(try Data(contentsOf: url), forType: .png))
        let app = launch(); app.typeKey("v", modifierFlags: .command)
        XCTAssertTrue(app.textFields["crop-width"].waitForExistence(timeout: 10), app.debugDescription)
        crop(app: app)
        app.buttons["mac-close-image"].click()
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 5), app.debugDescription)
        app.buttons["Cancel"].click()
        XCTAssertTrue(app.buttons["mac-copy"].exists)
        app.buttons["mac-close-image"].click(); app.buttons["Discard Changes"].click()
        XCTAssertTrue(app.buttons["mac-paste-well"].waitForExistence(timeout: 5))
    }
    @MainActor func testMarkupVisibilityAndMenuRecovery() throws {
        let url = try fixture(); defer { try? FileManager.default.removeItem(at: url) }
        let app = launch(); open(url, app: app)
        let toggle = app.descendants(matching: .any)["mac-markup-toggle"].firstMatch
        XCTAssertTrue(toggle.isHittable)
        toggle.click()
        XCTAssertFalse(app.radioGroups["mac-editor-mode"].exists)
        app.menuBars.menuBarItems["View"].click()
        app.menuItems["Show Markup Toolbar"].click()
        XCTAssertTrue(app.radioGroups["mac-editor-mode"].waitForExistence(timeout: 3))
        toggle.click()
        app.menuBars.menuBarItems["Image"].click()
        app.menuItems["Text"].click()
        XCTAssertTrue(app.radioGroups["mac-editor-mode"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.descendants(matching: .any)["annotation-object-text"].firstMatch.exists)
    }

    @MainActor func testNativeMarkupToolbarAndDrawing() throws {
        let url = try fixture(); defer { try? FileManager.default.removeItem(at: url) }
        let app = launch(); open(url, app: app)
        XCTAssertFalse(app.descendants(matching: .any)["mac-tool-select"].firstMatch.exists)
        app.radioButtons["Annotate"].click()
        let select = app.descendants(matching: .any)["mac-tool-select"].firstMatch
        XCTAssertTrue(select.waitForExistence(timeout: 5), app.debugDescription)
        let tools = ["mac-tool-select", "mac-shapes", "mac-tool-draw", "mac-tool-text", "mac-tool-pixelate", "mac-zoom"]
        var lastX = -CGFloat.infinity
        for id in tools {
            let control = app.descendants(matching: .any)[id].firstMatch
            XCTAssertTrue(control.isHittable, id)
            XCTAssertGreaterThan(control.frame.midX, lastX)
            lastX = control.frame.midX
        }
        app.descendants(matching: .any)["mac-shapes"].firstMatch.click()
        for shape in ["Rectangle", "Rounded Rectangle", "Ellipse", "Triangle", "Speech Bubble", "Line", "Arrow"] {
            XCTAssertTrue(app.menuItems[shape].exists, shape)
        }
        app.menuItems["Rectangle"].click()
        let canvas = app.descendants(matching: .any)["image-canvas"].firstMatch
        let start = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.25))
        start.click(forDuration: 0.1, thenDragTo: canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.65, dy: 0.65)))
        XCTAssertTrue(app.descendants(matching: .any)["annotation-object-rectangle"].firstMatch.exists)
        XCTAssertTrue(app.buttons["Undo"].isEnabled)
        app.descendants(matching: .any)["mac-tool-pixelate"].firstMatch.click()
        XCTAssertTrue(app.descendants(matching: .any)["annotation-object-pixelate"].firstMatch.exists, app.debugDescription)
        select.click()
        XCTAssertTrue(app.descendants(matching: .any)["mac-tool-select"].firstMatch.isHittable)
        app.radioButtons["Crop"].click()
        XCTAssertFalse(app.descendants(matching: .any)["mac-tool-select"].firstMatch.exists)
        XCTAssertTrue(app.descendants(matching: .any)["mac-crop-preset"].firstMatch.isHittable)
        XCTAssertTrue(app.buttons["mac-rotate-left"].isHittable)
    }
    @MainActor func testTextAnnotationEditAndQuitCancel() throws {
        let url = try fixture(); defer { try? FileManager.default.removeItem(at: url) }
        let app = launch(); open(url, app: app)
        app.radioButtons["Annotate"].click(); app.buttons["mac-tool-text"].click()
        let text = app.textViews["annotation-text"].firstMatch
        let field = text.exists ? text : app.textFields["annotation-text"].firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5), app.debugDescription)
        field.click(); app.typeKey("a", modifierFlags: .command); field.typeText("Editable vector text")
        replace("annotation-font-size", with: "48", app: app)
        XCTAssertEqual(app.textFields["annotation-font-size"].value as? String, "48")
        app.typeKey("q", modifierFlags: .command)
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 5), app.debugDescription)
        app.buttons["Cancel"].click()
        XCTAssertTrue(app.buttons["mac-copy"].exists)
    }
    @MainActor func testQuitCancelThenDiscardExits() throws {
        let url = try fixture(); defer { try? FileManager.default.removeItem(at: url) }
        let app = launch(); open(url, app: app); crop(app: app)
        app.typeKey("q", modifierFlags: .command)
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 5), app.debugDescription)
        app.buttons["Cancel"].click()
        XCTAssertTrue(app.buttons["mac-copy"].isHittable)
        app.typeKey("q", modifierFlags: .command)
        XCTAssertTrue(app.buttons["Discard Changes"].waitForExistence(timeout: 5), app.debugDescription)
        app.buttons["Discard Changes"].click()
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 8), app.debugDescription)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }
    @MainActor func testQuitSaveCancellationKeepsWorkAndCanRetry() throws {
        let url = try fixture(); defer { try? FileManager.default.removeItem(at: url) }
        let app = launch(); open(url, app: app); crop(app: app)
        app.typeKey("q", modifierFlags: .command)
        XCTAssertTrue(app.buttons["Save a Copy…"].waitForExistence(timeout: 5), app.debugDescription)
        app.buttons["Save a Copy…"].click()
        XCTAssertTrue(app.buttons["save-files"].waitForExistence(timeout: 8), app.debugDescription)
        app.buttons["Cancel"].click()
        XCTAssertTrue(app.buttons["mac-copy"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.textFields["crop-width"].value as? String, "320")
        app.typeKey("q", modifierFlags: .command)
        XCTAssertTrue(app.buttons["Discard Changes"].waitForExistence(timeout: 5))
        app.buttons["Discard Changes"].click()
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 8), app.debugDescription)
    }

    @MainActor private func saveExport(app: XCUIApplication, to output: URL) {
        let saveAs = app.buttons["save-files"]
        XCTAssertTrue(saveAs.waitForExistence(timeout: 10), app.debugDescription); saveAs.click()
        app.typeKey("g", modifierFlags: [.command, .shift])
        let path = app.textFields["PathTextField"]
        XCTAssertTrue(path.waitForExistence(timeout: 5), app.debugDescription)
        path.click(); app.typeKey("a", modifierFlags: .command); path.typeText(output.deletingLastPathComponent().path); app.typeKey(.return, modifierFlags: [])
        let name = app.textFields.matching(NSPredicate(format: "value ENDSWITH '.png'")).firstMatch
        XCTAssertTrue(name.waitForExistence(timeout: 5), app.debugDescription)
        name.click(); app.typeKey("a", modifierFlags: .command); name.typeText(output.lastPathComponent)
        let panel = app.sheets["save-panel"]
        XCTAssertTrue(panel.waitForExistence(timeout: 5), app.debugDescription)
        let save = panel.buttons["Export"].exists ? panel.buttons["Export"] : panel.buttons["Save"]
        XCTAssertTrue(save.exists, app.debugDescription); save.click()
    }
    @MainActor func testQuitSaveExitsAndPreservesOriginal() throws {
        let url = try fixture(); defer { try? FileManager.default.removeItem(at: url) }
        let original = try Data(contentsOf: url)
        let output = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".png")
        defer { try? FileManager.default.removeItem(at: output) }
        let app = launch(); open(url, app: app); crop(app: app)
        app.typeKey("q", modifierFlags: .command)
        XCTAssertTrue(app.buttons["Save a Copy…"].waitForExistence(timeout: 5), app.debugDescription)
        app.buttons["Save a Copy…"].click()
        saveExport(app: app, to: output)
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10), app.debugDescription)
        let source = try XCTUnwrap(CGImageSourceCreateWithURL(output as CFURL, nil))
        let image = try XCTUnwrap(CGImageSourceCreateImageAtIndex(source, 0, nil))
        XCTAssertEqual(image.width, 320); XCTAssertEqual(image.height, 240)
        XCTAssertEqual(try Data(contentsOf: url), original)
    }

    @MainActor func testPNGSaveAsAndCloseSave() throws {
        let url = try fixture(); defer { try? FileManager.default.removeItem(at: url) }
        let output = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".png")
        defer { try? FileManager.default.removeItem(at: output) }
        let app = launch(); open(url, app: app); crop(app: app)
        app.buttons["mac-close-image"].click(); app.buttons["Save a Copy…"].click()
        saveExport(app: app, to: output)
        XCTAssertTrue(app.buttons["mac-paste-well"].waitForExistence(timeout: 10), app.debugDescription)
        let image = try XCTUnwrap(CGImageSourceCreateWithURL(output as CFURL, nil))
        let pixels = try XCTUnwrap(CGImageSourceCreateImageAtIndex(image, 0, nil))
        XCTAssertEqual(pixels.width, 320); XCTAssertEqual(pixels.height, 240)
    }
    @MainActor func testMouseCropAtZoom() throws {
        let url = try fixture(); defer { try? FileManager.default.removeItem(at: url) }
        let app = launch(); open(url, app: app); crop(app: app)
        app.descendants(matching: .any)["mac-zoom"].firstMatch.click()
        let zoom = try XCTUnwrap(app.menuItems.matching(identifier: "Zoom In").allElementsBoundByIndex.first { $0.isHittable })
        zoom.click()
        let handle = app.descendants(matching: .any)["crop-handle-3"].firstMatch
        XCTAssertTrue(handle.isHittable, app.debugDescription)
        let start = handle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.click(forDuration: 0.1, thenDragTo: start.withOffset(CGVector(dx: -35, dy: -25)))
        let width = Int(app.textFields["crop-width"].value as? String ?? "") ?? 0
        XCTAssertGreaterThan(width, 0); XCTAssertLessThan(width, 320)
        XCTAssertTrue(app.buttons["Undo"].isEnabled)
    }
    @MainActor func testHTTPSLinkPaste() throws {
        guard let link = ProcessInfo.processInfo.environment["MAC_IMAGE_URL"] else { throw XCTSkip("Set TEST_RUNNER_MAC_IMAGE_URL to an actual public HTTPS image for this integration check.") }
        NSPasteboard.general.clearContents(); XCTAssertTrue(NSPasteboard.general.setString(link, forType: .string))
        let app = launch(); app.typeKey("v", modifierFlags: .command)
        XCTAssertTrue(app.buttons["mac-copy"].waitForExistence(timeout: 60), app.debugDescription)
        let size = try copiedSize(app: app); XCTAssertGreaterThan(size.width, 0); XCTAssertGreaterThan(size.height, 0)
    }
}
