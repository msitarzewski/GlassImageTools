import XCTest

final class ImageStartTests: XCTestCase {
    @MainActor func testNativeImportWellsAndRealImageDrop() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--ui-test-empty-window", "--ui-test-drop-source", "--ui-test-no-description"]
        app.launch()
        let photos = app.buttons["choose-photos"], files = app.buttons["import-files"]
        XCTAssertTrue(photos.waitForExistence(timeout: 10))
        for well in [photos, files] {
            XCTAssertTrue(well.isHittable)
            XCTAssertGreaterThanOrEqual(well.frame.width, 180)
            XCTAssertGreaterThanOrEqual(well.frame.height, 120)
        }
        let target = app.descendants(matching: .any)["image-drop-target"].firstMatch
        XCTAssertTrue(target.exists)
        capture("start-import-wells")
        let source = app.staticTexts["test-image-drag-source"]
        XCTAssertTrue(source.waitForExistence(timeout: 10), app.debugDescription)
        source.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 1, thenDragTo: target.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.5)), withVelocity: .slow, thenHoldForDuration: 2)
        guard app.otherElements["image-canvas"].waitForExistence(timeout: 20) else {
            let status = app.staticTexts["test-image-drag-status"]
            if status.exists && status.label.contains("Drag started: false") {
                throw XCTSkip("The simulator gesture did not initiate a system drag. Real data/file provider imports are covered by core tests; hand-driven cross-app Drop needs a device check.")
            }
            XCTFail(app.debugDescription)
            return
        }
        XCTAssertEqual(app.staticTexts["image-title"].label, "Example Image.png")
        XCTAssertEqual(app.staticTexts["image-source-details"].label, "1,600 × 1,000 pixels · PNG")
        XCTAssertFalse(app.editorAction("undo").isEnabled, "A drop opens a clean new source.")
        capture("native-sidebar-after-drop")
        try app.performAccessibilityAudit(for: .all)
    }

    @MainActor func testStartScreenPasteOpensCopiedImage() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--ui-test-no-description"]
        app.launch()
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 10))
        app.editorAction("copy-image").tap()
        XCTAssertTrue(app.staticTexts["Copied 1600 × 1000"].waitForExistence(timeout: 20))
        app.tapEditorAction("close-image")
        let paste = app.descendants(matching: .any)["image-drop-target"].firstMatch
        XCTAssertTrue(paste.waitForExistence(timeout: 10))
        XCTAssertTrue(paste.isEnabled)
        XCTAssertGreaterThanOrEqual(paste.frame.width, 180)
        XCTAssertGreaterThanOrEqual(paste.frame.height, 140)
        paste.tap()
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 20))
        XCTAssertEqual(app.staticTexts["image-source-details"].label, "1,600 × 1,000 pixels · PNG")
        XCTAssertFalse(app.editorAction("undo").isEnabled)
    }

    @MainActor func testEmptyWorkspaceKeyboardPaste() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--ui-test-no-description"]
        app.launch()
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 10))
        app.editorAction("copy-image").tap()
        XCTAssertTrue(app.staticTexts["Copied 1600 × 1000"].waitForExistence(timeout: 20))
        app.tapEditorAction("close-image")
        XCTAssertTrue(app.descendants(matching: .any)["image-drop-target"].firstMatch.waitForExistence(timeout: 10))
        XCTAssertFalse(app.descendants(matching: .any)["paste-image-start"].exists, "There is no separate Paste button.")
        // Expanding native sidebar rows must not consume image Paste keyboard routing.
        app.buttons["Open Images"].tap(); app.buttons["Open Images"].tap()
        app.buttons["Recents"].tap(); app.buttons["Recents"].tap()
        capture("start-whole-well")
        app.typeKey(XCUIKeyboardKey(rawValue: "v"), modifierFlags: .command)
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 20), app.debugDescription)
        XCTAssertEqual(app.staticTexts["image-source-details"].label, "1,600 × 1,000 pixels · PNG")
        XCTAssertFalse(app.editorAction("undo").isEnabled)
    }

    @MainActor func testStartScreenAtLargestText() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--ui-test-empty-window", "--ui-test-minimum-window",
                               "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.buttons["choose-photos"].waitForExistence(timeout: 10))
        let scroll = app.scrollViews["image-start-screen"]
        let paste = app.descendants(matching: .any)["image-drop-target"].firstMatch
        for _ in 0..<5 {
            if paste.exists && paste.isHittable { break }
            scroll.swipeUp()
        }
        XCTAssertTrue(paste.exists && paste.isHittable, app.debugDescription)
        capture("start-largest-text")
        try app.performAccessibilityAudit(for: .all)
    }

    private func capture(_ name: String) {
        Thread.sleep(forTimeInterval: 1)
        print("HIG_FIX_SCREEN|\(name)")
        Thread.sleep(forTimeInterval: 1)
    }
}
