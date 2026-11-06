import XCTest

final class HIGPolishTests: XCTestCase {
    @MainActor func testNativeSidebarDefaultsAndRotatedCrop() throws {
        let app = launch()
        XCTAssertFalse(app.descendants(matching: .any)["paste-image"].firstMatch.exists,
                       "The title bar must not show the redundant blue Paste control.")
        XCTAssertTrue(app.editorAction("copy-image").isHittable)
        let width = app.staticTexts["crop-width-axis"], height = app.staticTexts["crop-height-axis"]
        XCTAssertEqual(width.label.filter(\.isNumber), "1600"); XCTAssertEqual(height.label.filter(\.isNumber), "1000")
        app.buttons["rotate-left"].tap()
        XCTAssertEqual(width.label.filter(\.isNumber), "1000"); XCTAssertEqual(height.label.filter(\.isNumber), "1600")
        capture("rotated-crop", app: app)
        app.tapEditorAction("undo")
        XCTAssertEqual(width.label.filter(\.isNumber), "1600"); XCTAssertEqual(height.label.filter(\.isNumber), "1000")
        app.tapEditorAction("redo")
        XCTAssertEqual(width.label.filter(\.isNumber), "1000"); XCTAssertEqual(height.label.filter(\.isNumber), "1600")
        app.showCropDimensions()
        XCTAssertEqual(app.textFields["crop-width"].value as? String, "1000")
        XCTAssertEqual(app.textFields["crop-height"].value as? String, "1600")
        app.buttons["Done"].tap()
        app.buttons["view-options"].tap(); app.buttons["Zoom In"].tap()
        app.buttons["view-options"].tap(); app.descendants(matching: .any)["Pan"].firstMatch.tap()
        let handle = app.descendants(matching: .any)["crop-handle-3"].firstMatch
        let opposite = app.descendants(matching: .any)["crop-handle-0"].firstMatch
        XCTAssertTrue(handle.isHittable && opposite.isHittable)
        handle.press(forDuration: 0.1, thenDragTo: opposite)
        XCTAssertNotEqual(width.label.filter(\.isNumber), "1000"); XCTAssertNotEqual(height.label.filter(\.isNumber), "1600")
        app.tapEditorAction("undo")
        XCTAssertEqual(width.label.filter(\.isNumber), "1000"); XCTAssertEqual(height.label.filter(\.isNumber), "1600")
        app.buttons["crop-preset"].tap(); app.buttons["reset-crop"].tap()
        XCTAssertEqual(width.label.filter(\.isNumber), "1000", "Reset Crop must preserve the chosen image orientation.")
        app.buttons["Annotate"].tap()
        let panel = app.descendants(matching: .any)["annotation-panel"].firstMatch
        XCTAssertTrue(panel.waitForExistence(timeout: 5))
        let toggle = app.sidebarToggle
        XCTAssertTrue(toggle.waitForExistence(timeout: 5) && toggle.isHittable, app.debugDescription)
        XCTAssertFalse(app.buttons["annotation-options"].exists, "No title-bar duplicate toggle.")
        XCTAssertEqual(app.buttons.matching(identifier: "editor-inspector-toggle").count, 1)
        XCTAssertGreaterThan(toggle.frame.midX, app.otherElements["image-canvas"].frame.midX,
                          "The inspector toggle belongs at the trailing side of the native navigation toolbar.")
        capture("native-default-sidebar", app: app)
        print("SIDEBAR_DEFAULT_GEOMETRY|panel=\(panel.frame)|window=\(contentWindow(app).frame)|toggle=\(toggle.frame)")
        toggle.tap(); XCTAssertFalse(panel.exists)
        toggle.tap(); XCTAssertTrue(panel.waitForExistence(timeout: 5))
        try app.performAccessibilityAudit(for: .all)
    }

    @MainActor func testRotatedTextRemainsSelectableAndEditable() {
        let app = launch()
        app.buttons["rotate-left"].tap()
        app.buttons["Annotate"].tap()
        app.descendants(matching: .any)["tool-text"].firstMatch.tap()
        app.showToolOptions()
        let text = app.descendants(matching: .any)["annotation-text"].firstMatch
        XCTAssertTrue(text.waitForExistence(timeout: 5))
        app.buttons["annotation-inspector-done"].tap()
        let object = app.descendants(matching: .any)["annotation-object-text"].firstMatch
        XCTAssertTrue(object.waitForExistence(timeout: 5) && object.isHittable)
        object.tap()
        XCTAssertTrue(text.waitForExistence(timeout: 5), "Rotated text hit regions must target the retained text object.")
        XCTAssertTrue(app.buttons["annotation-inspector-done"].isHittable)
        capture("rotated-editable-text", app: app)
        // The centered label is 960 × 200 upright source pixels; after Rotate Left it is 200 wide on screen.
        let width = app.textFields["annotation-width"], height = app.textFields["annotation-height"]
        reveal(width, app: app)
        XCTAssertEqual(width.value as? String, "200", "Annotation fields must use the visible rotated axes, like crop fields.")
        XCTAssertEqual(height.value as? String, "960")
        replaceNumber(width, with: "150", app: app)
        XCTAssertEqual(height.value as? String, "960", "Changing the visible width must not change the visible height.")
    }

    @MainActor func testBusyDescriptionRetriesQuietly() throws {
        let app = launch(busyCaption: true)
        XCTAssertFalse(app.buttons["image-description-retry"].exists)
        XCTAssertFalse(app.progressIndicators["image-description-progress"].exists)
        let text = app.staticTexts["image-description-text"]
        XCTAssertTrue(text.waitForExistence(timeout: 10),
                      "A busy on-device model must not leave the image permanently without its description.")
        XCTAssertTrue(text.label.contains("model became free"))
    }

    @MainActor func testCompactLongTitleAndToolbar() throws {
        let app = launch(compact: true, longTitle: true)
        assertTitleActions(app)
        capture("compact-title", app: app)
        app.buttons["Annotate"].tap()
        let content = contentWindow(app)
        let toolbar = app.windows.allElementsBoundByIndex
            .filter { $0.descendants(matching: .any)["editing-mode"].exists }
            .min { $0.frame.width < $1.frame.width }
        XCTAssertNotNil(toolbar, app.debugDescription)
        if let toolbar { XCTAssertLessThanOrEqual(toolbar.frame.width, content.frame.width + 2) }
        for id in ["shapes-primary", "view-options", "appearance-settings-button"] {
            XCTAssertTrue(app.editorAction(id).isHittable, id)
            if let toolbar {
                let frame = app.descendants(matching: .any)[id].firstMatch.frame
                XCTAssertGreaterThanOrEqual(frame.minY, 0, "Native ornament content must stay inside its hosting height.")
                XCTAssertLessThanOrEqual(frame.maxY, toolbar.frame.height + 1)
            }
        }
        XCTAssertTrue(app.sidebarToggle.isHittable)
        if let toolbar { XCTAssertFalse(toolbar.descendants(matching: .any)["annotation-options"].exists) }
        if app.buttons["drawing-tools-menu"].exists {
            app.buttons["drawing-tools-menu"].tap()
            capture("compact-drawing-menu", app: app)
            for name in ["Select", "Draw", "Text", "Pixelate"] {
                XCTAssertTrue(app.buttons[name].waitForExistence(timeout: 5), "\(name): \(app.debugDescription)")
            }
            app.buttons["Pixelate"].tap()
            XCTAssertTrue(app.descendants(matching: .any)["annotation-object-pixelate"].firstMatch.waitForExistence(timeout: 5),
                          "Pixelate places a region at once: \(app.debugDescription)")
        } else {
            // Native tool toggles are exposed as switches/other elements, not buttons.
            for id in ["tool-select", "tool-draw", "tool-text", "tool-pixelate"] {
                XCTAssertTrue(app.descendants(matching: .any)[id].firstMatch.isHittable, id)
            }
        }
        XCTAssertFalse(app.buttons["shapes-menu"].exists)
        capture("compact-toolbar", app: app)
    }

    @MainActor func testCompactLongTitleAtLargestText() throws {
        let app = launch(compact: true, longTitle: true, largestText: true, longCaption: true)
        assertTitleActions(app)
        assertToolbarFits(app)
        XCTAssertLessThan(app.staticTexts["image-title"].frame.height, 100,
                          "The visible filename must stay bounded to one native line.")
        capture("compact-largest-title", app: app)
        app.buttons["Annotate"].tap()
        chooseDrawingTool("text", app: app)
        assertToolbarFits(app)
        capture("compact-largest-toolbar", app: app)
        try app.performAccessibilityAudit(for: .all)
        let options = app.sidebarToggle
        XCTAssertTrue(options.waitForExistence(timeout: 5) && options.isHittable,
                      "The native title sidebar toggle must stay reachable at largest text.")
        app.showToolOptions()
        XCTAssertTrue(app.descendants(matching: .any)["annotation-text"].firstMatch.waitForExistence(timeout: 5))
        capture("compact-largest-options", app: app)
        assertCaptionBounds(app)
        let captionScroll = app.scrollViews["image-description"]
        XCTAssertTrue(captionScroll.exists, "Long captions must remain readable through native scrolling at largest text.")
        let captionText = app.staticTexts["image-description-text"]
        let beforeScroll = captionText.frame.minY
        captionScroll.swipeUp()
        XCTAssertLessThan(captionText.frame.minY, beforeScroll, "Scrolling must reveal more of the actual description.")
        capture("compact-largest-caption-scrolled", app: app)
        try app.performAccessibilityAudit(for: .all)
    }

    @MainActor func testContextualOptionsAndVisibleCanvas() throws {
        let app = launch()
        app.buttons["Annotate"].tap()
        app.descendants(matching: .any)["tool-text"].firstMatch.tap()
        app.showToolOptions()
        let text = app.descendants(matching: .any)["annotation-text"].firstMatch
        XCTAssertTrue(text.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertFalse(app.sliders["annotation-stroke-width"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["annotation-fill"].exists)
        XCTAssertEqual(app.descendants(matching: .any)["annotation-color"].firstMatch.label, "Text Color")
        capture("text-default-options", app: app)
        app.descendants(matching: .any)["tool-pixelate"].firstMatch.tap()
        let size = app.sliders["annotation-pixelation-size"]
        XCTAssertTrue(size.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertEqual(size.value as? String, "16 source pixels")
        XCTAssertEqual(app.inspectorTitle.label, "Pixelation", "The Pixelate action selects the region it placed.")
        XCTAssertFalse(app.descendants(matching: .any)["annotation-color"].exists)
        XCTAssertFalse(app.sliders["annotation-stroke-width"].exists)
        XCTAssertFalse(app.buttons["annotation-add-center"].exists)
        let panel = app.descendants(matching: .any)["annotation-panel"].firstMatch
        let canvas = app.otherElements["image-canvas"]
        XCTAssertTrue(panel.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertGreaterThanOrEqual(panel.frame.minX, canvas.frame.maxX - 1,
                                 "The property form must sit beside the canvas instead of covering it.")
        capture("pixelation-beside-canvas", app: app)
        app.buttons["annotation-inspector-done"].tap()
        XCTAssertFalse(panel.exists)
    }

    @MainActor func testAutomaticLeftSidebarAndOriginalImageCaption() throws {
        let app = launch(longCaption: true)
        let caption = app.descendants(matching: .any)["image-description"].firstMatch
        let canvas = app.otherElements["image-canvas"]
        XCTAssertTrue(caption.waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["image-description-text"].label.isEmpty)
        XCTAssertGreaterThanOrEqual(caption.frame.minY, canvas.frame.maxY - 1,
                                    "The original-image caption must be below the editable pixels.")
        app.buttons["Annotate"].tap()
        let panel = app.descendants(matching: .any)["annotation-panel"].firstMatch
        XCTAssertTrue(panel.waitForExistence(timeout: 5), "Annotate must open Tool Options automatically.")
        XCTAssertGreaterThanOrEqual(panel.frame.minX, canvas.frame.maxX - 1)
        XCTAssertGreaterThanOrEqual(panel.frame.minX, app.staticTexts["Original Image Description"].frame.maxX - 1)
        let toggle = app.sidebarToggle
        XCTAssertTrue(toggle.isHittable)
        toggle.tap()
        XCTAssertFalse(panel.exists)
        XCTAssertTrue(toggle.isHittable)
        toggle.tap()
        XCTAssertTrue(panel.waitForExistence(timeout: 5))
        capture("automatic-sidebar-caption", app: app)
        assertCaptionBounds(app)
        try app.performAccessibilityAudit(for: .all)
        app.tapEditorAction("close-image")
        XCTAssertTrue(app.buttons["choose-photos"].waitForExistence(timeout: 5))
        XCTAssertFalse(caption.exists, "Closing the image must remove its caption and cancel its task.")
        XCTAssertFalse(panel.exists)
    }

    @MainActor func testPanFeedbackAndReadableAppearanceEndpoints() {
        let app = launch()
        app.buttons["view-options"].tap()
        app.buttons["Zoom In"].tap()
        app.buttons["view-options"].tap()
        app.descendants(matching: .any)["Pan"].firstMatch.tap()
        XCTAssertTrue(app.buttons["view-options"].label.contains("Pan on"))
        XCTAssertEqual(app.buttons["view-options"].value as? String, "150%")
        XCTAssertFalse(app.editorAction("undo").isEnabled, "Viewport-only changes must not create edit history.")
        capture("persistent-pan", app: app)
        app.buttons["appearance-settings-button"].tap()
        for id in ["appearance-opacity-minimum", "appearance-opacity-maximum", "appearance-glass-minimum", "appearance-glass-maximum"] {
            let label = app.staticTexts[id]
            XCTAssertTrue(label.waitForExistence(timeout: 5), id)
            XCTAssertGreaterThan(label.frame.width, 35, "Readable endpoint words need space, not tiny fragments.")
        }
        capture("readable-appearance", app: app)
    }

    @MainActor func testDirectPNGShareOpensWithoutExportForm() {
        let app = launch()
        let share = app.editorAction("quick-share-image")
        XCTAssertTrue(share.isHittable)
        XCTAssertEqual(app.editorAction("copy-image").label, "Copy")
        share.tap()
        XCTAssertTrue(app.otherElements["ActivityListView"].waitForExistence(timeout: 10),
                      "One Share action must present the real native activity sheet.")
        capture("direct-share", app: app)
        XCTAssertFalse(app.staticTexts["Export Image"].exists)
        print("HIG_FIX_SHARE_HIERARCHY|\(app.debugDescription)")
        // Observation intentionally stops before selecting any recipient or transmitting content.
        app.terminate()
    }

    @MainActor func testTinyAnnotationRevealDragAndIndependentUndoInOpenPanel() {
        let app = launch()
        app.buttons["Annotate"].tap()
        app.drawShape("rectangle")
        app.showToolOptions()
        let width = app.textFields["annotation-width"], height = app.textFields["annotation-height"]
        reveal(width, app: app)
        let originalWidth = width.value as? String
        let originalHeight = height.value as? String
        replaceNumber(width, with: "1", app: app)
        replaceNumber(height, with: "1", app: app)
        // The drawn shape starts at canvas-test-start; move the tiny shape down and right of it
        // (in the same form edit) so dragging the top-left proxy to that marker enlarges it.
        replaceNumber(app.textFields["annotation-left"], with: "480", app: app)
        replaceNumber(app.textFields["annotation-top"], with: "350", app: app)
        for _ in 0..<3 { app.buttons["view-options"].tap(); app.buttons["Zoom In"].tap() }
        reveal(app.buttons["annotation-show-selection"], app: app)
        app.buttons["annotation-show-selection"].tap()
        let first = app.descendants(matching: .any)["annotation-handle-0"].firstMatch
        let last = app.descendants(matching: .any)["annotation-handle-3"].firstMatch
        XCTAssertTrue(first.waitForExistence(timeout: 5) && first.isHittable && last.isHittable)
        XCTAssertGreaterThanOrEqual(abs(last.frame.midX - first.frame.midX), 59)
        XCTAssertGreaterThanOrEqual(abs(last.frame.midY - first.frame.midY), 59)
        capture("tiny-selection-proxies", app: app)
        // Element-to-element: a coordinate press-drag reaches the canvas move gesture, not the handle.
        let destination = app.descendants(matching: .any)["canvas-test-start"].firstMatch
        XCTAssertTrue(destination.exists)
        first.press(forDuration: 0.1, thenDragTo: destination)
        revealTop(width, app: app)
        XCTAssertNotEqual(width.value as? String, "1", "Dragging a displaced handle must change the actual source geometry.")
        app.tapEditorAction("undo")
        XCTAssertEqual(width.value as? String, "1")
        XCTAssertEqual(height.value as? String, "1")
        app.tapEditorAction("undo")
        XCTAssertEqual(width.value as? String, originalWidth)
        XCTAssertEqual(height.value as? String, originalHeight)
        XCTAssertTrue(app.descendants(matching: .any)["annotation-panel"].firstMatch.exists,
                      "Undo must preserve live editing beside the canvas.")
    }

    @MainActor func testShortDescriptionUsesOnlyItsContentHeight() throws {
        let app = launch(compact: true, shortCaption: true)
        let caption = app.descendants(matching: .any)["image-description"].firstMatch
        let text = app.staticTexts["image-description-text"]
        let heading = app.staticTexts["Original Image Description"]
        XCTAssertTrue(caption.waitForExistence(timeout: 5) && text.exists && heading.exists)
        XCTAssertLessThan(caption.frame.height, 120, "A short caption must not reserve a full-height text panel.")
        XCTAssertLessThanOrEqual(caption.frame.height, text.frame.height + heading.frame.height + 36,
                                 "Only modest margins should surround the actual caption content.")
        let wideHeight = caption.frame.height
        // The system bottom toolbar overlaps the window edge, so the caption must end above it.
        // Selectable text reports a 16-point interaction inset beyond its glyphs; with 8-point
        // padding and 32-point clearance its frame ends 24 points above the edge (about -8 before).
        XCTAssertGreaterThanOrEqual(contentWindow(app).frame.maxY - text.frame.maxY, 20,
                                    "Caption text must keep the bottom-ornament clearance.")
        capture("short-caption-natural-height", app: app)
        app.buttons["Annotate"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["annotation-panel"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertGreaterThanOrEqual(caption.frame.height, wideHeight - 1,
                                    "The native window may expand for its sidebar; caption height still follows actual wrapping.")
        XCTAssertLessThan(caption.frame.height, 170)
        XCTAssertLessThanOrEqual(caption.frame.height, text.frame.height + heading.frame.height + 36)
        XCTAssertGreaterThanOrEqual(app.descendants(matching: .any)["annotation-panel"].firstMatch.frame.minX, heading.frame.maxX - 1)
        capture("short-caption-wrapped-height", app: app)
        try app.performAccessibilityAudit(for: .all)
    }

    @MainActor func testUnavailableDescriptionHasNoPlaceholder() throws {
        let app = launch(noDescription: true)
        XCTAssertFalse(app.descendants(matching: .any)["image-description"].firstMatch.exists)
        XCTAssertFalse(app.staticTexts["Original Image Description"].exists)
        XCTAssertFalse(app.staticTexts["image-description-unavailable"].exists)
        XCTAssertFalse(app.progressIndicators["image-description-progress"].exists)
        XCTAssertFalse(app.buttons["image-description-retry"].exists)
        app.buttons["Annotate"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["annotation-panel"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertGreaterThanOrEqual(app.otherElements["image-canvas"].frame.height, 300)
        capture("quiet-description-and-sliding-tools", app: app)
        try app.performAccessibilityAudit(for: .all)
    }

    @MainActor func testDrawingStaysClearAndSelectRestoresEditableVectors() throws {
        let app = launch(noDescription: true)
        app.buttons["Annotate"].tap()
        chooseDrawingTool("draw", app: app)
        let first = app.descendants(matching: .any)["canvas-test-start"].firstMatch
        let last = app.descendants(matching: .any)["canvas-test-end"].firstMatch
        XCTAssertTrue(first.waitForExistence(timeout: 5) && last.exists)
        let corner = app.descendants(matching: .any)["annotation-handle-0"].firstMatch
        for _ in 0..<2 {
            first.press(forDuration: 0.1, thenDragTo: last)
            XCTAssertFalse(corner.exists, "Drawing must not leave a box or handles over the active pen.")
        }
        XCTAssertTrue(app.otherElements["image-canvas"].value.debugDescription.contains("2 editable annotations"))
        capture("unobstructed-freehand", app: app)
        chooseDrawingTool("select", app: app)
        XCTAssertTrue(corner.waitForExistence(timeout: 5), "Select must restore vector handles.")
        XCTAssertTrue(app.descendants(matching: .any)["annotation-object-draw"].firstMatch.exists)
        let originalDimensions = corner.value as? String
        let topRight = app.descendants(matching: .any)["annotation-handle-1"].firstMatch
        XCTAssertTrue(topRight.waitForExistence(timeout: 5))
        corner.press(forDuration: 0.1, thenDragTo: topRight)
        XCTAssertTrue(corner.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertNotEqual(corner.value as? String, originalDimensions, "The resize must actually change vector geometry.")
        app.tapEditorAction("undo")
        XCTAssertTrue(corner.exists, "Undoing a resize must retain editable selection.")
        XCTAssertEqual(corner.value as? String, originalDimensions)
        app.tapEditorAction("undo")
        XCTAssertTrue(app.otherElements["image-canvas"].value.debugDescription.contains("1 editable annotations"))
        app.tapEditorAction("undo")
        XCTAssertTrue(app.otherElements["image-canvas"].value.debugDescription.contains("0 editable annotations"))
        app.tapEditorAction("redo")
        XCTAssertTrue(app.otherElements["image-canvas"].value.debugDescription.contains("1 editable annotations"))
    }

    @MainActor private func launch(compact: Bool = false, longTitle: Bool = false, largestText: Bool = false, longCaption: Bool = false, shortCaption: Bool = false, noDescription: Bool = false, busyCaption: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        if shortCaption { app.launchArguments.append("--ui-test-short-description") }
        if busyCaption { app.launchArguments.append("--ui-test-busy-description") }
        if longCaption { app.launchArguments.append("--ui-test-long-description") }
        if noDescription { app.launchArguments.append("--ui-test-no-description") }
        if compact { app.launchArguments.append("--ui-test-minimum-window") }
        if longTitle { app.launchArguments.append("--ui-test-long-title") }
        if largestText { app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"] }
        app.launch()
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 10), app.debugDescription)
        return app
    }
    @MainActor private func assertTitleActions(_ app: XCUIApplication) {
        print("HIG_FIX_SCREEN|titlebar-largest-text")
        print("TITLEBAR_LAYOUT|\(app.debugDescription)")
        let title = app.staticTexts["image-title"]
        let details = app.staticTexts["image-source-details"]
        XCTAssertGreaterThan(title.label.count, 120)
        XCTAssertTrue(title.isHittable && details.isHittable, app.debugDescription)
        let titleBar = app.editorTitleBar
        XCTAssertTrue(titleBar.exists, "Image metadata belongs in the window header.")
        XCTAssertTrue(titleBar.staticTexts["image-source-details"].exists)
        XCTAssertTrue(app.buttons["close-image"].isHittable)
        app.assertDocumentToolsGrouped()
        let numbers = details.label.filter(\.isNumber)
        XCTAssertTrue(numbers.contains("1600") && numbers.contains("1000"))
        XCTAssertTrue(details.label.contains("PNG"))
        XCTAssertEqual(title.frame.minX, details.frame.minX, accuracy: 2)
        for id in ["copy-image", "quick-share-image"] {
            XCTAssertTrue(app.editorAction(id).isHittable, id)
        }
        if app.buttons["editor-actions-menu"].exists {
            app.buttons["editor-actions-menu"].tap()
            XCTAssertTrue(app.editorAction("export-image").isHittable)
            app.editorAction("export-image").tap()
            XCTAssertTrue(app.buttons["save-files"].waitForExistence(timeout: 20))
            app.buttons["Done"].tap()
        } else {
            for id in ["close-image", "export-image"] { XCTAssertTrue(app.editorAction(id).isHittable) }
        }
    }
    @MainActor private func assertCaptionBounds(_ app: XCUIApplication) {
        let caption = app.descendants(matching: .any)["image-description"].firstMatch
        let canvas = app.otherElements["image-canvas"]
        let panel = app.descendants(matching: .any)["annotation-panel"].firstMatch
        XCTAssertGreaterThanOrEqual(canvas.frame.height, 140,
                                    "Caption layout must leave a usable image canvas at large text sizes.")
        XCTAssertTrue(caption.exists, "The deterministic long description must be displayed.")
        guard caption.exists else { return }
        XCTAssertGreaterThanOrEqual(caption.frame.minY, canvas.frame.maxY - 1)
        if panel.exists {
            XCTAssertGreaterThanOrEqual(panel.frame.minX, app.staticTexts["Original Image Description"].frame.maxX - 1)
            let text = app.staticTexts["image-description-text"]
            if text.exists {
                // Native scroll-container AX frames can extend across columns. Check the visible
                // leading caption heading and the text's column center/right edge instead.
                XCTAssertGreaterThanOrEqual(text.frame.midX, canvas.frame.minX)
                XCTAssertLessThanOrEqual(text.frame.maxX, panel.frame.minX + 1,
                                         "The caption text must remain inside the visible detail column.")
                // Long captions may scroll vertically; they must never extend beneath the pane.
                XCTAssertTrue(app.scrollViews.containing(.staticText, identifier: "image-description-text").firstMatch.exists
                              || text.frame.maxY <= caption.frame.maxY + 1)
            }
        }
    }
    @MainActor private func contentWindow(_ app: XCUIApplication) -> XCUIElement {
        let window = app.windows.allElementsBoundByIndex
            .filter { $0.descendants(matching: .any)["image-canvas"].exists }
            .min { $0.frame.width < $1.frame.width }
        XCTAssertNotNil(window, app.debugDescription)
        return window ?? app.windows.firstMatch
    }
    @MainActor private func assertToolbarFits(_ app: XCUIApplication) {
        let content = contentWindow(app)
        let toolbar = app.windows.allElementsBoundByIndex
            .filter { $0.descendants(matching: .any)["editing-mode"].exists }
            .min { $0.frame.width < $1.frame.width }
        XCTAssertNotNil(toolbar, app.debugDescription)
        if let toolbar {
            XCTAssertLessThanOrEqual(toolbar.frame.width, content.frame.width + 2,
                                     "Native items must adapt rather than overhang at largest text.")
        }
    }
    @MainActor private func chooseDrawingTool(_ kind: String, app: XCUIApplication) {
        let tool = app.descendants(matching: .any)["tool-\(kind)"].firstMatch
        if !tool.exists || !tool.isHittable { app.buttons["drawing-tools-menu"].tap() }
        XCTAssertTrue(tool.waitForExistence(timeout: 5) && tool.isHittable)
        tool.tap()
    }
    @MainActor private func reveal(_ element: XCUIElement, app: XCUIApplication) {
        app.revealInInspector(element)
    }
    @MainActor private func revealTop(_ element: XCUIElement, app: XCUIApplication) {
        app.revealInInspector(element, towardTop: true)
    }
    @MainActor private func replaceNumber(_ field: XCUIElement, with number: String, app: XCUIApplication) {
        field.tap(); field.doubleTap()
        if let selectAll = app.editMenuAction("Select All") { selectAll.tap() }
        else if let select = app.editMenuAction("Select") {
            select.tap()
            if let selectAll = app.editMenuAction("Select All") { selectAll.tap() }
        }
        field.typeText(number)
        XCTAssertEqual(field.value as? String, number)
    }
    @MainActor private func capture(_ name: String, app: XCUIApplication) {
        print("HIG_FIX_HIERARCHY|\(name)\n\(app.debugDescription)\nHIG_FIX_HIERARCHY_END|\(name)")
        print("HIG_FIX_SCREEN|\(name)")
        Thread.sleep(forTimeInterval: 3)
    }
}
