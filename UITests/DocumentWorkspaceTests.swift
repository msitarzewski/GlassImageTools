import XCTest

final class DocumentWorkspaceTests: XCTestCase {
    @MainActor func testCollapsedPanelsKeepNewImageReachable() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--ui-test-minimum-window"]
        app.launch()
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 10))
        app.buttons["Annotate"].tap()
        app.buttons["document-sidebar-toggle"].tap()
        app.buttons["editor-inspector-toggle"].tap()
        print("COLLAPSED_WORKSPACE_HIERARCHY|\(app.debugDescription)")
        print("HIG_FIX_SCREEN|collapsed-workspace")
        let menu = app.buttons["new-image-menu"]
        XCTAssertTrue(menu.exists)
        // The native toolbar Menu wrapper can report nonhittable after column reparenting;
        // exercise its real action and picker return rather than treating that hint as behavior.
        menu.tap()
        XCTAssertTrue(app.buttons["Choose from Photos…"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Import from Files…"].isHittable)
        app.buttons["Import from Files…"].tap()
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 10), app.debugDescription)
        app.buttons["Cancel"].tap()
        for id in ["image-title", "image-source-details"] {
            let hittable = XCTNSPredicateExpectation(predicate: NSPredicate(format: "isHittable == true"),
                                                     object: app.staticTexts[id])
            XCTAssertEqual(XCTWaiter.wait(for: [hittable], timeout: 10), .completed,
                           "\(id) must be reachable once the system picker has dismissed: \(app.debugDescription)")
        }
        try app.performAccessibilityAudit(for: .all)
    }

    @MainActor func testSidebarLibraryRowsAndEmptyStates() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--ui-test-empty-window", "--ui-test-no-description"]
        app.launch()
        let open = app.buttons["Open Images"]
        let recents = app.buttons["Recents"]
        XCTAssertTrue(open.waitForExistence(timeout: 10), app.debugDescription)
        for category in [open, recents] {
            XCTAssertTrue(category.isEnabled)
            XCTAssertGreaterThanOrEqual(category.frame.height, 60)
        }
        XCTAssertTrue(app.staticTexts["No Open Images"].exists)
        XCTAssertFalse(app.staticTexts["No Recent Images"].exists)
        print("HIG_FIX_SCREEN|sidebar-library-empty")
        Thread.sleep(forTimeInterval: 1)
        recents.tap()
        XCTAssertTrue(app.staticTexts["No Recent Images"].waitForExistence(timeout: 5))
        open.tap()
        XCTAssertFalse(app.staticTexts["No Open Images"].exists)
        open.tap()
        XCTAssertTrue(app.staticTexts["No Open Images"].exists)
        recents.tap()
        XCTAssertFalse(app.staticTexts["No Recent Images"].exists)
        try app.performAccessibilityAudit(for: .all)
    }

    @MainActor func testDocumentSwitchingUndoCloseAndRecents() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--ui-test-short-description"]
        app.launch()
        let canvas = app.otherElements["image-canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 10), app.debugDescription)
        let rows = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "open-document-"))
        XCTAssertEqual(rows.count, 1, app.debugDescription)
        let firstID = rows.firstMatch.identifier
        let sidebar = app.descendants(matching: .any)["document-sidebar"].firstMatch
        XCTAssertTrue(sidebar.exists)
        XCTAssertGreaterThanOrEqual(sidebar.frame.width, 300, "The default sidebar should be wider.")
        app.buttons["Open Images"].tap()
        XCTAssertEqual(rows.count, 0, "Open Images uses an actual native disclosure.")
        app.buttons["Open Images"].tap()
        XCTAssertEqual(rows.count, 1)
        XCTAssertLessThanOrEqual(sidebar.frame.maxX, canvas.frame.minX + 1)
        app.editorAction("copy-image").tap()
        XCTAssertTrue(app.staticTexts["editor-status"].waitForExistence(timeout: 10))
        app.showCropDimensions()
        let crop = app.descendants(matching: .any)["crop-panel"].firstMatch
        XCTAssertTrue(crop.waitForExistence(timeout: 5))
        XCTAssertGreaterThanOrEqual(crop.frame.minX, canvas.frame.maxX - 1)
        let done = app.buttons["crop-inspector-done"]
        XCTAssertTrue(done.isHittable)
        XCTAssertGreaterThanOrEqual(done.frame.minX, crop.frame.minX)
        XCTAssertGreaterThanOrEqual(done.frame.minY, app.buttons["close-image"].frame.minY)
        XCTAssertLessThanOrEqual(done.frame.maxY, crop.frame.maxY)
        let titleBar = app.editorTitleBar
        XCTAssertTrue(titleBar.exists)
        app.assertDocumentToolsGrouped()
        XCTAssertFalse(titleBar.buttons["crop-inspector-done"].exists)
        done.tap()
        app.buttons["crop-preset"].tap(); app.buttons["1:1"].tap()
        XCTAssertEqual(app.staticTexts["crop-width-axis"].label.filter(\.isNumber), "1000")
        let paste = app.openPasteImage()
        XCTAssertTrue(paste.isEnabled); paste.tap()
        XCTAssertTrue(rows.element(boundBy: 1).waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertFalse(app.buttons["save-before-close"].exists, "New images must not replace an edited document.")
        XCTAssertEqual(app.staticTexts["crop-width-axis"].label.filter(\.isNumber), "1600")
        XCTAssertFalse(app.editorAction("undo").isEnabled)
        app.descendants(matching: .any)[firstID].firstMatch.tap()
        XCTAssertEqual(app.staticTexts["crop-width-axis"].label.filter(\.isNumber), "1000")
        app.tapEditorAction("undo")
        XCTAssertEqual(app.staticTexts["crop-width-axis"].label.filter(\.isNumber), "1600")
        app.tapEditorAction("redo")
        XCTAssertEqual(app.staticTexts["crop-width-axis"].label.filter(\.isNumber), "1000")
        app.tapEditorAction("close-image")
        XCTAssertTrue(app.buttons["save-before-close"].waitForExistence(timeout: 5))
        app.buttons["Cancel"].tap()
        XCTAssertEqual(rows.count, 2)
        XCTAssertEqual(app.staticTexts["crop-width-axis"].label.filter(\.isNumber), "1000")
        app.tapEditorAction("close-image"); app.buttons["discard-changes"].tap()
        let recent = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "recent-document-")).firstMatch
        XCTAssertTrue(app.buttons["Recents"].waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertFalse(recent.exists, "Recents must stay collapsed until explicitly expanded.")
        app.buttons["Recents"].tap()
        XCTAssertTrue(recent.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertEqual(rows.count, 1)
        recent.tap()
        XCTAssertEqual(rows.count, 2)
        XCTAssertEqual(app.staticTexts["crop-width-axis"].label.filter(\.isNumber), "1600")
        XCTAssertFalse(app.editorAction("undo").isEnabled)
        app.tapEditorAction("close-image")
        XCTAssertTrue(app.buttons["clear-recents"].waitForExistence(timeout: 5))
        app.buttons["clear-recents"].tap()
        XCTAssertFalse(recent.exists)
        XCTAssertEqual(rows.count, 1)
        app.buttons["Annotate"].tap()
        let inspector = app.descendants(matching: .any)["annotation-panel"].firstMatch
        XCTAssertTrue(inspector.waitForExistence(timeout: 5))
        XCTAssertTrue(sidebar.exists)
        app.buttons["document-sidebar-toggle"].tap()
        XCTAssertFalse(sidebar.exists); XCTAssertTrue(inspector.exists)
        app.buttons["editor-inspector-toggle"].tap()
        XCTAssertFalse(inspector.exists)
        app.openNewImageMenu()
        XCTAssertTrue(app.buttons["Import from Files…"].waitForExistence(timeout: 5))
        app.buttons["Import from Files…"].tap()
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 10))
        app.buttons["Cancel"].tap()
        app.buttons["document-sidebar-toggle"].tap()
        XCTAssertTrue(sidebar.waitForExistence(timeout: 5)); XCTAssertFalse(inspector.exists)
        print("HIG_FIX_SCREEN|document-navigation-and-independent-inspector")
        try app.performAccessibilityAudit(for: .all)
    }
    @MainActor func testNewWindowOffersExplicitAcquisitionChoices() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--ui-test-empty-window"]
        app.launch()
        let photos = app.buttons.matching(identifier: "choose-photos")
        XCTAssertTrue(photos.firstMatch.waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertEqual(photos.count, 1)
        XCTAssertTrue(app.buttons["import-files"].isHittable)
        XCTAssertTrue(app.descendants(matching: .any)["paste-image-start"].firstMatch.exists)
        // New Window is the first choice in the single + menu.
        app.openNewImageMenu()
        XCTAssertTrue(app.buttons["New Window"].waitForExistence(timeout: 5), app.debugDescription)
        app.buttons["New Window"].tap()
        XCTAssertTrue(photos.element(boundBy: 1).waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertEqual(photos.count, 2, "The + must create a separate native window.")
        XCTAssertEqual(app.buttons.matching(identifier: "import-files").count, 2)
        XCTAssertGreaterThanOrEqual(app.descendants(matching: .any).matching(identifier: "paste-image-start").count, 2)
        XCTAssertFalse(app.otherElements["image-canvas"].exists, "New windows start with acquisition choices.")
        let files = app.buttons.matching(identifier: "import-files").allElementsBoundByIndex
        print("MULTIWINDOW_TARGETS|\(files.map { "hittable=\($0.isHittable), frame=\($0.frame)" })")
        print("HIG_FIX_SCREEN|two-window-acquisition")
        let foregroundFiles = try XCTUnwrap(files.first(where: { $0.isHittable }))
        foregroundFiles.tap()
        print("HIG_FIX_SCREEN|two-window-files-picker")
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 10), app.debugDescription)
        app.buttons["Cancel"].tap()
        let foregroundPhotos = try XCTUnwrap(photos.allElementsBoundByIndex.first(where: { $0.isHittable }))
        foregroundPhotos.tap()
        print("HIG_FIX_SCREEN|two-window-photos-picker")
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 10), app.debugDescription)
        app.buttons["Cancel"].tap()
        XCTAssertEqual(photos.count, 2, "Cancelling either picker must keep both windows available.")
        print("HIG_FIX_SCREEN|new-window-acquisition")
        // ⌘N keeps working now that New Window lives inside the + menu.
        app.typeKey(XCUIKeyboardKey(rawValue: "n"), modifierFlags: .command)
        XCTAssertTrue(photos.element(boundBy: 2).waitForExistence(timeout: 10),
                      "Command-N must open another window: \(app.debugDescription)")
        app.terminate()
    }

}
