import XCTest

/// Native audit output complements actual keyboard/VoiceOver/eye-hand acceptance; it cannot certify them.
final class AccessibilityAuditTests: XCTestCase {
    @MainActor func testNativeAccessibilityAuditForEmptyWindow() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["choose-photos"].waitForExistence(timeout: 10), app.debugDescription)
        try audit(app, screen: "Empty import window")
    }

    @MainActor func testNativeAccessibilityAuditForEditorSheetsAndText() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 10), app.debugDescription)
        try audit(app, screen: "Crop canvas and native ornaments")
        app.showCropDimensions()
        XCTAssertTrue(app.textFields["crop-width"].waitForExistence(timeout: 5))
        try audit(app, screen: "Exact crop dimensions form")
        app.buttons["Done"].tap()
        app.buttons["appearance-settings-button"].tap()
        XCTAssertTrue(app.sliders["appearance-opacity"].waitForExistence(timeout: 5))
        try audit(app, screen: "Window appearance form")
        try auditAbout(app, screen: "About")
        app.buttons["Done"].tap()
        app.buttons["Annotate"].tap()
        try audit(app, screen: "Annotation tools")
        app.showToolOptions()
        XCTAssertTrue(app.staticTexts["No Selection"].waitForExistence(timeout: 5), app.debugDescription)
        try audit(app, screen: "Inspector with no selection")
        app.drawShape("rectangle")
        XCTAssertTrue(app.inspectorTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(app.inspectorTitle.label, "Rectangle")
        try audit(app, screen: "Selected rectangle style and dimensions")
        reveal(app.buttons["Delete Annotation"], app: app)
        try audit(app, screen: "Selected rectangle arrangement actions")
        app.buttons["Done"].tap()
        // The Text action places a selected label at the crop center and opens its editor.
        app.descendants(matching: .any)["tool-text"].firstMatch.tap()
        XCTAssertTrue(app.descendants(matching: .any)["annotation-text"].firstMatch.waitForExistence(timeout: 5))
        try audit(app, screen: "Text content and character controls")
        app.buttons["Done"].tap()
        app.tapEditorAction("export-image")
        XCTAssertTrue(app.buttons["save-files"].waitForExistence(timeout: 20))
        try audit(app, screen: "PNG export and save actions")
        let format = app.descendants(matching: .any)["export-format"].firstMatch
        format.tap()
        XCTAssertTrue(app.buttons["JPEG"].waitForExistence(timeout: 5), app.debugDescription)
        app.buttons["JPEG"].tap()
        XCTAssertTrue(app.sliders["export-quality"].waitForExistence(timeout: 5), app.debugDescription)
        try audit(app, screen: "JPEG quality and output details")
        app.buttons["Done"].tap()
        app.tapEditorAction("close-image")
        XCTAssertTrue(app.buttons["save-before-close"].waitForExistence(timeout: 5))
        try audit(app, screen: "Unsaved image save discard cancel")
        app.buttons["Cancel"].tap()
    }

    @MainActor func testNativeAccessibilityAuditForPasteErrorAndColorPalette() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--ui-test-invalid-paste"]
        app.launch()
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 10))
        let paste = app.openPasteImage()
        XCTAssertTrue(paste.isEnabled)
        paste.tap()
        XCTAssertTrue(app.alerts["Unable to Complete"].waitForExistence(timeout: 10), app.debugDescription)
        try audit(app, screen: "Malformed pasted-image recovery alert")
        app.buttons["OK"].tap()
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.editorAction("undo").isEnabled)
        app.buttons["Annotate"].tap()
        app.drawShape("rectangle")
        app.showToolOptions()
        XCTAssertTrue(app.inspectorTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(app.inspectorTitle.label, "Rectangle")
        let color = app.descendants(matching: .any)["annotation-color"].firstMatch
        XCTAssertTrue(color.waitForExistence(timeout: 5) && color.isHittable, app.debugDescription)
        let original = color.value as? String ?? ""
        let components = original.split(whereSeparator: { !$0.isNumber }).compactMap { Int($0) }
        XCTAssertEqual(components.count, 3, original)
        try audit(app, screen: "Selected color well and style form")
        color.tap()
        // Observe the system host opened by the actual well; never launch the service ourselves.
        let palette = XCUIApplication(bundleIdentifier: "com.apple.UIKit.ColorPickerUIService")
        let palettePresented = palette.wait(for: .runningForeground, timeout: 10)
        print("HIG_FIX_SCREEN|\(palettePresented ? "color-palette-presented" : "color-palette-missing")")
        Thread.sleep(forTimeInterval: 3) // Allow a real compositor capture; keep the actual assertion.
        XCTAssertTrue(palettePresented,
                      "The native well must present the system palette: \(app.debugDescription)")
        XCTAssertTrue(palette.buttons["Sliders"].waitForExistence(timeout: 5), palette.debugDescription)
        palette.buttons["Sliders"].tap()
        for (index, id) in ["sliderRed", "sliderGreen", "sliderBlue"].enumerated() {
            let field = palette.textFields[id]
            XCTAssertTrue(field.waitForExistence(timeout: 5) && field.isEnabled, palette.debugDescription)
            if components.count == 3 { XCTAssertEqual(field.value as? String, String(components[index])) }
        }
        print("Native color-palette accessibility hierarchy: \(palette.debugDescription)")
        // Apple's audit API rejects this system host as an invalid target (-902). Verify its real
        // native controls instead; app audits still fail normally for every reported issue.
        palette.buttons["Grid"].tap()
        let black = palette.otherElements.matching(NSPredicate(format: "label == %@", "black 0")).firstMatch
        XCTAssertTrue(black.waitForExistence(timeout: 5) && black.isHittable, palette.debugDescription)
        black.tap()
        // The persistent native panel is behind the system palette's modal accessibility tree.
        // Dismiss by the normal outside-tap gesture before querying the editor's own controls.
        palette.buttons["Grid"].coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
            .withOffset(CGVector(dx: -100, dy: 80)).tap()
        let changed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", "Red 0, green 0, blue 0"), object: color)
        XCTAssertEqual(XCTWaiter.wait(for: [changed], timeout: 5), .completed,
                       "A native palette change must immediately update the selected annotation and its well: \(String(describing: color.value))")
        // An outside tap can first dismiss the palette, then the native inspector.
        for _ in 0..<2 { if app.buttons["Done"].exists { app.buttons["Done"].tap() } }
        XCTAssertTrue(app.sidebarToggle.waitForExistence(timeout: 5))
        app.tapEditorAction("undo")
        app.showToolOptions()
        XCTAssertTrue(color.waitForExistence(timeout: 5))
        XCTAssertEqual(color.value as? String, original, "One Undo must restore the entire selected-object color transaction.")
        app.buttons["Done"].tap()
    }

    /// Requests the largest native text category; also exercise with Increase Contrast enabled.
    @MainActor func testNativeAccessibilityAtLargestTextAndIncreasedContrast() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "-UIPreferredContentSizeCategoryName",
                               "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 10), app.debugDescription)
        try audit(app, screen: "Largest text crop canvas and ornaments")
        app.showCropDimensions()
        let width = app.textFields["crop-width"]
        let height = app.textFields["crop-height"]
        // Stacked largest-text rows extend below the inspector's fold; Forms materialize rows lazily.
        app.revealInInspector(height)
        XCTAssertTrue(width.waitForExistence(timeout: 5) && height.exists, app.debugDescription)
        XCTAssertGreaterThan(height.frame.midY - width.frame.midY, 20,
                             "At accessibility text sizes the labeled dimensions must stack instead of clipping.")
        try audit(app, screen: "Largest text exact crop form")
        app.buttons["Done"].tap()
        app.buttons["appearance-settings-button"].tap()
        XCTAssertTrue(app.sliders["appearance-opacity"].waitForExistence(timeout: 5))
        try audit(app, screen: "Largest text appearance form")
        try auditAbout(app, screen: "Largest text About")
        app.buttons["Done"].tap()
        app.buttons["Annotate"].tap()
        // At accessibility sizes Text lives in the compact Drawing Tools menu.
        let textTool = app.descendants(matching: .any)["tool-text"].firstMatch
        if !textTool.exists || !textTool.isHittable { app.buttons["drawing-tools-menu"].tap() }
        XCTAssertTrue(textTool.waitForExistence(timeout: 5), app.debugDescription)
        textTool.tap()
        app.showToolOptions()
        XCTAssertTrue(app.descendants(matching: .any)["annotation-text"].firstMatch.waitForExistence(timeout: 5), app.debugDescription)
        try audit(app, screen: "Largest text native text editor")
        reveal(app.descendants(matching: .any)["annotation-alignment"].firstMatch, app: app)
        try audit(app, screen: "Largest text typography and color form")
        app.buttons["Done"].tap()
        app.tapEditorAction("export-image")
        XCTAssertTrue(app.buttons["save-files"].waitForExistence(timeout: 20), app.debugDescription)
        try audit(app, screen: "Largest text export form")
        app.buttons["Done"].tap()
    }

    @MainActor private func reveal(_ element: XCUIElement, app: XCUIApplication) {
        app.revealInInspector(element)
    }

    /// Settings → About shows this build's own version and the website's pages, then leads back to Settings.
    @MainActor private func auditAbout(_ app: XCUIApplication, screen: String) throws {
        let about = app.buttons["settings-about"]
        XCTAssertTrue(about.waitForExistence(timeout: 5) && about.isHittable, app.debugDescription)
        about.tap()
        let version = app.staticTexts["about-version"]
        XCTAssertTrue(version.waitForExistence(timeout: 5), app.debugDescription)
        // The test bundle shares the project's version and build number.
        let info = Bundle(for: Self.self).infoDictionary ?? [:]
        let expected = "Version \(info["CFBundleShortVersionString"] ?? "") (\(info["CFBundleVersion"] ?? ""))"
        XCTAssertEqual(version.label, expected)
        for page in ["Website", "Privacy", "Help"] {
            XCTAssertTrue(app.links[page].exists || app.buttons[page].exists, "\(page): \(app.debugDescription)")
        }
        try audit(app, screen: screen)
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(about.waitForExistence(timeout: 5), "Back must return to Settings: \(app.debugDescription)")
    }

    @MainActor private func audit(_ app: XCUIApplication, screen: String) throws {
        try app.performAccessibilityAudit(for: .all) { issue in
            let element = issue.element
            print("Native accessibility audit [\(screen)]: \(issue.compactDescription); \(issue.detailedDescription); identifier=\(element?.identifier ?? "none"); label=\(element?.label ?? "none"); frame=\(String(describing: element?.frame))")
            return false
        }
    }
}
