import XCTest

final class ImageLinkPasteTests: XCTestCase {
    @MainActor func testURLPasteMenuAcceptsLinkAndPreservesCurrentImageOnFailure() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--ui-test-no-description", "--ui-test-url-paste"]
        app.launch()
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 10))
        let title = app.staticTexts["image-title"].label
        let paste = app.openPasteImage()
        XCTAssertTrue(paste.isEnabled, "Native Paste must accept a URL provider, not only image data.")
        paste.tap()
        let alert = app.alerts["Unable to Complete"]
        XCTAssertTrue(alert.waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertTrue(alert.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "direct HTTPS image link")).firstMatch.exists)
        alert.buttons["OK"].tap()
        XCTAssertEqual(app.staticTexts["image-title"].label, title)
        XCTAssertTrue(app.otherElements["image-canvas"].exists)
    }

    @MainActor func testEmptyKeyboardPasteAcceptsPlainTextLink() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--ui-test-empty-window", "--ui-test-no-description", "--ui-test-url-paste", "--ui-test-plain-link"]
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["image-drop-target"].firstMatch.waitForExistence(timeout: 10))
        app.typeKey(XCUIKeyboardKey(rawValue: "v"), modifierFlags: .command)
        let alert = app.alerts["Unable to Complete"]
        XCTAssertTrue(alert.waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertTrue(alert.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "direct HTTPS image link")).firstMatch.exists)
        alert.buttons["OK"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["image-drop-target"].firstMatch.exists)
        XCTAssertFalse(app.otherElements["image-canvas"].exists)
    }
}
