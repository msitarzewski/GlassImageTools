import XCTest

final class GlassImageToolsUITests: XCTestCase {
    @MainActor func testCropDimmingPreservesEditingAndCopy() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--ui-test-no-description"]
        app.launch()
        waitForFixtureEditor(app: app)
        app.showCropDimensions()
        for (identifier, value) in [("crop-width", "800"), ("crop-height", "600"),
                                    ("crop-left", "400"), ("crop-top", "200")] {
            replaceText(in: app.textFields[identifier], with: value, app: app)
        }
        app.buttons["crop-inspector-done"].tap()
        assertCropAxes(width: 800, height: 600, app: app)
        func capture(_ name: String) {
            // Let column/window resizing settle before the full compositor capture.
            Thread.sleep(forTimeInterval: 1)
            print("HIG_FIX_SCREEN|\(name)")
            Thread.sleep(forTimeInterval: 1)
        }
        capture("crop-dimming-fit")
        app.buttons["view-options"].tap(); app.buttons["Zoom In"].tap()
        XCTAssertEqual(app.buttons["view-options"].value as? String, "150%")
        assertCropAxes(width: 800, height: 600, app: app)
        for index in 0..<4 {
            XCTAssertTrue(app.descendants(matching: .any)["crop-handle-\(index)"].firstMatch.isHittable)
        }
        capture("crop-dimming-zoom")
        app.buttons["rotate-left"].tap()
        assertCropAxes(width: 600, height: 800, app: app)
        capture("crop-dimming-rotation")
        app.buttons["Annotate"].tap()
        capture("crop-dimming-annotate")
        app.editorAction("copy-image").tap()
        XCTAssertTrue(app.staticTexts["Copied 600 × 800"].waitForExistence(timeout: 20))
        app.buttons["Crop"].tap()
        app.tapEditorAction("undo")
        assertCropAxes(width: 800, height: 600, app: app)
        app.tapEditorAction("undo")
        assertCropAxes(width: 1600, height: 1000, app: app)
        XCTAssertFalse(app.editorAction("undo").isEnabled)
        capture("crop-dimming-reset")
    }

    @MainActor func testClearWindowWithBothSidePanels() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--ui-test-short-description"]
        app.launch()
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 10))
        let gear = app.buttons["appearance-settings-button"]
        gear.tap()
        setAppearanceSlider("appearance-opacity", to: "0%", endpoint: "Transparent", app: app)
        setAppearanceSlider("appearance-glass", to: "0%", endpoint: "No Glass", app: app)
        app.buttons["Done"].tap()
        print("HIG_FIX_SCREEN|clear-sidebar")
        XCTAssertTrue(app.staticTexts["image-title"].isHittable)
        app.buttons["Annotate"].tap()
        let panel = app.descendants(matching: .any)["annotation-panel"].firstMatch
        XCTAssertTrue(panel.waitForExistence(timeout: 5))
        print("HIG_FIX_SCREEN|clear-both-columns")
        XCTAssertEqual(app.navigationBars.count, 0,
                       "The main workspace must not retain navigation-container glass above the adjustable backplate.")
        XCTAssertTrue(app.buttons["annotation-inspector-done"].isHittable)
        app.buttons["annotation-inspector-done"].tap()
        XCTAssertFalse(panel.exists)
        gear.tap()
        setAppearanceSlider("appearance-opacity", to: "100%", endpoint: "Opaque", app: app)
        app.buttons["Done"].tap()
        print("HIG_FIX_SCREEN|opaque-sidebar")
        XCTAssertTrue(app.otherElements["image-canvas"].isHittable)
        XCTAssertTrue(app.editorAction("copy-image").isHittable)
        gear.tap()
        setAppearanceSlider("appearance-opacity", to: "0%", endpoint: "Transparent", app: app)
        setAppearanceSlider("appearance-glass", to: "100%", endpoint: "Full Glass", app: app)
        app.buttons["Done"].tap()
        print("HIG_FIX_SCREEN|default-glass-sidebar")
        try app.performAccessibilityAudit(for: .all)
    }

    @MainActor func testNativeLaunchAndPhotosPicker() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["choose-photos"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["appearance-settings-button"].exists)
        app.buttons["choose-photos"].tap()
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 10), app.debugDescription)
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.buttons["choose-photos"].exists)
    }

    @MainActor func testCropUndoCopyAndExport() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertTrue(app.staticTexts["image-title"].exists)
        XCTAssertEqual(app.staticTexts["image-source-details"].label,
                       "\(1600.formatted()) × \(1000.formatted()) pixels · Captured Frame")
        XCTAssertEqual(app.staticTexts["image-title"].frame.minX,
                       app.staticTexts["image-source-details"].frame.minX, accuracy: 2,
                       "The filename and original details must share a leading edge.")
        assertCropAxes(width: 1600, height: 1000, app: app)
        XCTAssertLessThan(app.staticTexts["crop-width-axis"].frame.midY,
                          app.staticTexts["crop-height-axis"].frame.midY)
        XCTAssertLessThan(app.staticTexts["crop-height-axis"].frame.midX,
                          app.staticTexts["crop-width-axis"].frame.midX)
        XCTAssertTrue(app.segmentedControls["editing-mode"].exists)
        XCTAssertEqual(app.buttons["view-options"].value as? String, "100%")
        XCTAssertFalse(app.staticTexts["output-dimensions"].exists)
        XCTAssertFalse(app.staticTexts["1600 × 1000 pixels"].exists)
        // visionOS exposes ornament frames in a separate coordinate space. Inspect its native placement visually.
        attachScreenshot(app, name: "Document title and bottom mode ornament")
        XCTAssertTrue(app.descendants(matching: .any)["crop-handle-0"].exists,
                      "The canvas container must preserve independently accessible crop handles.")
        app.showCropDimensions()
        let width = app.textFields["crop-width"]
        XCTAssertTrue(width.waitForExistence(timeout: 5))
        replaceText(in: width, with: "800", app: app)
        XCTAssertTrue(app.editorAction("undo").isEnabled,
                      "A pending inspector edit on a fresh image must be undoable before Done.")
        app.buttons["Done"].tap()
        assertCropAxes(width: 800, height: 1000, app: app)
        app.tapEditorAction("undo")
        assertCropAxes(width: 1600, height: 1000, app: app)
        app.tapEditorAction("redo")
        assertCropAxes(width: 800, height: 1000, app: app)
        app.buttons["view-options"].tap()
        app.buttons["Zoom In"].tap()
        XCTAssertEqual(app.buttons["view-options"].value as? String, "150%")
        assertCropAxes(width: 800, height: 1000, app: app)
        app.buttons["view-options"].tap()
        app.buttons["Fit to Window"].tap()
        app.tapEditorAction("undo")
        app.editorAction("copy-image").tap()
        XCTAssertFalse(app.buttons["processing-cancel"].exists, "Copy must not cover the editor with the processing overlay.")
        XCTAssertTrue(app.staticTexts["Copied 1600 × 1000"].waitForExistence(timeout: 20), app.debugDescription)
        app.tapEditorAction("export-image")
        XCTAssertTrue(app.buttons["save-files"].waitForExistence(timeout: 20), app.debugDescription)
        XCTAssertTrue(app.buttons["share-image"].exists)
        XCTAssertTrue(app.buttons["save-photos"].exists)
        app.buttons["Done"].tap()
    }

    @MainActor func testAnnotationCanBeAddedAndUndone() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 10))
        app.buttons["Annotate"].tap()
        chooseShape("rectangle", app: app)
        let canvas = app.otherElements["image-canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5), "Canvas identity must survive mode changes: \(app.debugDescription)")
        drawOnCanvas(app: app)
        XCTAssertTrue(app.editorAction("undo").isEnabled)
        app.showToolOptions()
        XCTAssertEqual(app.inspectorTitle.label, "Rectangle", app.debugDescription)
        let width = app.textFields["annotation-width"]
        scrollTo(width, app: app)
        let originalWidth = width.value as? String
        replaceText(in: width, with: "300", app: app)
        app.buttons["Done"].tap()
        app.tapEditorAction("undo")
        app.showToolOptions()
        XCTAssertEqual(app.inspectorTitle.label, "Rectangle", app.debugDescription)
        scrollTo(width, app: app)
        XCTAssertEqual(width.value as? String, originalWidth)
        app.buttons["Done"].tap()
        app.tapEditorAction("undo")
        app.showToolOptions()
        XCTAssertTrue(app.staticTexts["No Selection"].waitForExistence(timeout: 5),
                      "Undoing creation leaves nothing selected, and the inspector says so: \(app.debugDescription)")
        XCTAssertFalse(app.buttons["annotation-add-center"].exists, "Add at Center is no longer part of the inspector.")
        XCTAssertFalse(app.buttons["Delete Annotation"].exists)
    }

    @MainActor func testCropPresetIsRestoredByUndoAndRedo() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        let preset = app.buttons["crop-preset"]
        XCTAssertTrue(preset.waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertEqual(preset.value as? String, "Freeform")
        preset.tap()
        let square = app.buttons["1:1"]
        XCTAssertTrue(square.waitForExistence(timeout: 5), app.debugDescription)
        square.tap()
        assertCropAxes(width: 1000, height: 1000, app: app)
        XCTAssertEqual(preset.value as? String, "1:1")
        app.tapEditorAction("undo")
        assertCropAxes(width: 1600, height: 1000, app: app)
        XCTAssertEqual(preset.value as? String, "Freeform")
        app.tapEditorAction("redo")
        assertCropAxes(width: 1000, height: 1000, app: app)
        XCTAssertEqual(preset.value as? String, "1:1")
    }

    @MainActor func testTextCanBeEditedWithVisibleCharacterControls() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        let canvas = app.otherElements["image-canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 10))
        app.buttons["Annotate"].tap()
        app.descendants(matching: .any)["tool-text"].firstMatch.tap()
        let text = app.descendants(matching: .any)["annotation-text"].firstMatch
        XCTAssertTrue(text.waitForExistence(timeout: 5), "Text must be placed and its native controls presented at once: \(app.debugDescription)")
        XCTAssertEqual(app.inspectorTitle.label, "Text")
        replaceText(in: text, with: "Review this region", app: app)
        XCTAssertTrue(app.descendants(matching: .any)["annotation-font"].exists)
        let size = app.textFields["annotation-font-size"]
        replaceText(in: size, with: "64", app: app)
        app.descendants(matching: .any)["annotation-bold"].firstMatch.tap()
        XCTAssertTrue(app.descendants(matching: .any)["annotation-italic"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["annotation-underline"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["annotation-alignment"].firstMatch.isHittable)
        attachScreenshot(app, name: "Live text controls")
        app.buttons["Done"].tap()
        XCTAssertTrue(app.sidebarToggle.waitForExistence(timeout: 5))
        XCTAssertTrue(app.sidebarToggle.isEnabled)
        let object = app.descendants(matching: .any)["annotation-object-text"].firstMatch
        XCTAssertTrue(object.waitForExistence(timeout: 5), app.debugDescription)
        object.tap()
        XCTAssertTrue(text.waitForExistence(timeout: 5))
        XCTAssertEqual(text.value as? String, "Review this region")
        XCTAssertEqual(size.value as? String, "64")
        app.buttons["Done"].tap()
        app.tapEditorAction("undo")
        app.showToolOptions()
        XCTAssertTrue(text.waitForExistence(timeout: 5))
        XCTAssertEqual(text.value as? String, "Label", "One Undo must restore the entire content/style transaction.")
        XCTAssertEqual(size.value as? String, "48")
        app.buttons["Done"].tap()
    }

    @MainActor func testTextContextMenuBelongsToTheTextObject() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        let canvas = app.otherElements["image-canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 10))
        app.buttons["Annotate"].tap()
        app.descendants(matching: .any)["tool-text"].firstMatch.tap()
        XCTAssertTrue(app.descendants(matching: .any)["annotation-text"].firstMatch.waitForExistence(timeout: 5))
        app.buttons["Done"].tap()
        let object = app.descendants(matching: .any)["annotation-object-text"].firstMatch
        XCTAssertTrue(object.waitForExistence(timeout: 5), app.debugDescription)
        object.press(forDuration: 1.2)
        let edit = app.buttons.matching(NSPredicate(format: "label == %@ AND identifier != %@", "Edit Text", "annotation-options")).firstMatch
        XCTAssertTrue(edit.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(app.buttons["Duplicate"].exists)
        XCTAssertTrue(app.buttons["Delete Annotation"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["annotation-text"].firstMatch.exists,
                       "Holding the object should reveal its menu rather than open the text editor.")
        attachScreenshot(app, name: "Text object contextual menu")
        edit.tap()
        XCTAssertTrue(app.descendants(matching: .any)["annotation-text"].firstMatch.waitForExistence(timeout: 5))
        app.buttons["Done"].tap()
        let returnedCanvas = canvas.waitForExistence(timeout: 8)
        let anyCanvas = app.descendants(matching: .any)["image-canvas"].firstMatch
        let anyExists = anyCanvas.exists
        print("After context editing dismissal: Other canvas=\(returnedCanvas), any canvas=\(anyExists), type=\(anyExists ? String(describing: anyCanvas.elementType) : "missing"), editor=\(app.descendants(matching: .any)["annotation-text"].firstMatch.exists)")
        guard returnedCanvas else {
            XCTFail("The native editor must return to its canvas after Done: \(app.debugDescription)")
            return
        }
        // Text is placed at the crop center; hold image canvas above the object's hit region,
        // which extends 30 points beyond its box.
        XCTAssertTrue(object.waitForExistence(timeout: 5), app.debugDescription)
        object.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0)).withOffset(CGVector(dx: 0, dy: -40))
            .press(forDuration: 1.2)
        XCTAssertFalse(app.buttons["Duplicate"].waitForExistence(timeout: 2),
                       "Holding empty canvas must not expose the selected object's context menu.")
        XCTAssertFalse(app.buttons["Delete Annotation"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["annotation-text"].firstMatch.exists)
    }

    @MainActor func testCloseCancelSaveCancelAndDiscardPreserveOriginal() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        XCTAssertTrue(app.buttons["crop-dimensions"].waitForExistence(timeout: 10))
        app.showCropDimensions()
        replaceText(in: app.textFields["crop-width"], with: "800", app: app)
        app.buttons["Done"].tap()
        app.tapEditorAction("close-image")
        XCTAssertTrue(app.buttons["save-before-close"].waitForExistence(timeout: 5), app.debugDescription)
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.otherElements["image-canvas"].exists)
        assertCropAxes(width: 800, height: 1000, app: app)
        app.tapEditorAction("close-image")
        app.buttons["save-before-close"].tap()
        XCTAssertTrue(app.buttons["save-files"].waitForExistence(timeout: 20), app.debugDescription)
        XCTAssertFalse(app.buttons["share-image"].exists, "Sharing is not a durable save before closing.")
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 5))
        assertCropAxes(width: 800, height: 1000, app: app)
        app.tapEditorAction("close-image")
        app.buttons["discard-changes"].tap()
        XCTAssertTrue(app.buttons["choose-photos"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.otherElements["image-canvas"].exists)
        XCTAssertFalse(app.buttons["close-image"].exists)
    }

    @MainActor func testNewShapeDirectResizeAndCropMode() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        let canvas = app.otherElements["image-canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 10))
        app.buttons["Annotate"].tap()
        chooseShape("triangle", app: app)
        app.descendants(matching: .any)["tool-select"].firstMatch.tap()
        app.buttons["shapes-primary"].tap()
        XCTAssertTrue(app.buttons["tool-triangle"].waitForExistence(timeout: 5),
                      "A normal tap should immediately open the shape chooser.")
        app.buttons["tool-triangle"].tap()
        drawOnCanvas(app: app)
        let handle = app.descendants(matching: .any)["annotation-handle-3"].firstMatch
        let topRight = app.descendants(matching: .any)["annotation-handle-1"].firstMatch
        XCTAssertTrue(handle.waitForExistence(timeout: 5), app.debugDescription)
        let before = handle.value as? String
        print("Triangle before: canvas=\(canvas.frame), corner=\(handle.frame), source size=\(before ?? "missing"), target=\(topRight.frame)")
        handle.press(forDuration: 0.1, thenDragTo: topRight)
        guard handle.waitForExistence(timeout: 5) else { XCTFail(app.debugDescription); return }
        print("Triangle after: corner=\(handle.frame), source size=\(String(describing: handle.value))")
        XCTAssertNotEqual(handle.value as? String, before, "A direct corner edit must change retained source-pixel dimensions: \(app.debugDescription)")
        app.buttons["Crop"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["crop-handle-0"].waitForExistence(timeout: 5))
        XCTAssertFalse(handle.exists)
        attachScreenshot(app, name: "Retained triangle in Crop mode")
        app.buttons["Annotate"].tap()
        XCTAssertTrue(handle.waitForExistence(timeout: 5), "The retained selection must return after Crop mode.")
        app.showToolOptions()
        XCTAssertEqual(app.inspectorTitle.label, "Triangle", app.debugDescription)
        XCTAssertTrue(app.descendants(matching: .any)["annotation-fill"].exists)
        app.buttons["Done"].tap()
    }

    @MainActor func testLineEndpointMovesAndUndoes() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        let canvas = app.otherElements["image-canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 10))
        app.buttons["Annotate"].tap()
        chooseShape("line", app: app)
        drawOnCanvas(app: app)
        let endpoint = app.descendants(matching: .any)["annotation-endpoint-1"].firstMatch
        let startEndpoint = app.descendants(matching: .any)["annotation-endpoint-0"].firstMatch
        XCTAssertTrue(endpoint.waitForExistence(timeout: 5), app.debugDescription)
        let original = endpoint.value as? String
        let originalStart = startEndpoint.value as? String
        print("Line before: canvas=\(canvas.frame), end=\(endpoint.frame) source=\(original ?? "missing"), start=\(startEndpoint.frame) source=\(originalStart ?? "missing")")
        endpoint.press(forDuration: 0.1, thenDragTo: startEndpoint)
        guard endpoint.waitForExistence(timeout: 5) else { XCTFail(app.debugDescription); return }
        print("Line after: end=\(endpoint.frame) source=\(String(describing: endpoint.value)), start=\(String(describing: startEndpoint.value))")
        XCTAssertNotEqual(endpoint.value as? String, original, "The endpoint's retained source position must change: \(app.debugDescription)")
        XCTAssertEqual((startEndpoint.value as? String)?.components(separatedBy: "X ").last,
                       originalStart?.components(separatedBy: "X ").last,
                       "Moving one endpoint must preserve the other's source position; display-proxy status may change.")
        app.tapEditorAction("undo")
        XCTAssertTrue(endpoint.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertEqual(endpoint.value as? String, original)
        XCTAssertEqual(startEndpoint.value as? String, originalStart)
    }

    @MainActor func testSaveToPhotosBeforeCloseCompletesDocumentAction() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        addUIInterruptionMonitor(withDescription: "Add-only Photos permission") { alert in
            for title in ["Allow Photos to Be Added", "Allow", "Add Photos Only"] where alert.buttons[title].exists {
                alert.buttons[title].tap(); return true
            }
            return false
        }
        app.launch()
        XCTAssertTrue(app.buttons["crop-dimensions"].waitForExistence(timeout: 10))
        app.showCropDimensions()
        replaceText(in: app.textFields["crop-width"], with: "800", app: app)
        app.buttons["Done"].tap()
        app.tapEditorAction("close-image")
        app.buttons["save-before-close"].tap()
        let save = app.buttons["save-photos"]
        XCTAssertTrue(save.waitForExistence(timeout: 20))
        save.tap()
        // Configure add-only access in an isolated simulator before this save regression. The
        // system's first-consent scene is a separate manual check, not proof from this test.
        XCTAssertTrue(app.buttons["choose-photos"].waitForExistence(timeout: 30),
                      "The actual Photos save must complete before the editor closes: \(app.debugDescription)")
        XCTAssertFalse(app.otherElements["image-canvas"].exists)
    }

    @MainActor func testAppearanceSettingsPersistAndReset() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        waitForFixtureEditor(app: app)
        let gear = app.buttons["appearance-settings-button"]
        XCTAssertTrue(gear.waitForExistence(timeout: 10))
        gear.tap()
        let reset = app.buttons["appearance-reset"]
        scrollTo(reset, app: app)
        reset.tap()
        let opacity = app.sliders["appearance-opacity"]
        let glass = app.sliders["appearance-glass"]
        revealFromTop(opacity, app: app)
        XCTAssertEqual(opacity.value as? String, "0%")
        XCTAssertEqual(glass.value as? String, "100%")
        let opacityKnob = opacity.descendants(matching: .any)["AXSliderKnob"].firstMatch
        let glassKnob = glass.descendants(matching: .any)["AXSliderKnob"].firstMatch
        XCTAssertTrue(opacityKnob.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(glassKnob.exists, app.debugDescription)
        print("Appearance before drag: opacity=\(String(describing: opacity.value)), slider=\(opacity.frame), knob=\(opacityKnob.frame); glass=\(String(describing: glass.value)), slider=\(glass.frame), knob=\(glassKnob.frame)")
        print(app.debugDescription)
        opacityKnob.press(forDuration: 0.1, thenDragTo: opacity)
        glassKnob.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .press(forDuration: 0.1, thenDragTo: glass.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0.5)))
        guard let chosenOpacity = opacity.value as? String,
              let percentage = Int(chosenOpacity.replacingOccurrences(of: "%", with: "")),
              (1..<100).contains(percentage) else {
            XCTFail("Native dragging must choose partial opacity: \(app.debugDescription)")
            return
        }
        let chosenGlass = glass.value as? String
        print("Appearance after drag: opacity=\(String(describing: chosenOpacity)), knob=\(opacityKnob.frame); glass=\(String(describing: chosenGlass)), knob=\(glassKnob.frame)")
        XCTAssertEqual(chosenGlass, "0%")
        XCTAssertTrue(app.staticTexts["Material, System Glass"].exists)
        attachScreenshot(app, name: "Native appearance settings")
        app.descendants(matching: .any)["appearance-settings"].firstMatch.buttons["Done"].tap()
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 8))
        assertCropAxes(width: 1600, height: 1000, app: app)
        XCTAssertFalse(app.editorAction("undo").isEnabled, "Appearance must not mutate the image edit state.")
        app.terminate()
        app.launch()
        waitForFixtureEditor(app: app)
        XCTAssertTrue(gear.waitForExistence(timeout: 10))
        gear.tap()
        XCTAssertTrue(opacity.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertEqual(opacity.value as? String, chosenOpacity, "Appearance should persist across an actual app relaunch.")
        XCTAssertEqual(glass.value as? String, chosenGlass)
        scrollTo(reset, app: app)
        reset.tap()
        revealFromTop(opacity, app: app)
        XCTAssertEqual(opacity.value as? String, "0%")
        XCTAssertEqual(glass.value as? String, "100%")
        app.descendants(matching: .any)["appearance-settings"].firstMatch.buttons["Done"].tap()

        // Keep identical image/crop content in the full-screen captures. App screenshots clip
        // native ornaments on visionOS and cannot establish foreground/background ordering.
        XCTAssertTrue(app.buttons["crop-dimensions"].waitForExistence(timeout: 8))
        app.showCropDimensions()
        replaceAppearanceCropWidth(with: "1200", app: app)
        app.buttons["crop-inspector-done"].tap()
        assertAppearanceForeground(app: app)
        attachScreenScreenshot(name: "Foreground default - Opacity 0 Glass 100")

        gear.tap()
        setAppearanceSlider("appearance-opacity", to: "100%", endpoint: "Opaque", app: app)
        XCTAssertEqual(glass.value as? String, "100%")
        app.descendants(matching: .any)["appearance-settings"].firstMatch.buttons["Done"].tap()
        assertAppearanceForeground(app: app)
        attachScreenScreenshot(name: "Foreground opaque - Opacity 100 Glass 100")
        app.buttons["Annotate"].tap()
        chooseShape("rectangle", app: app)
        drawOnCanvas(app: app)
        let rectangleHandle = app.descendants(matching: .any)["annotation-handle-3"].firstMatch
        XCTAssertTrue(rectangleHandle.waitForExistence(timeout: 5),
                      "An opaque background must preserve actual canvas input: \(app.debugDescription)")
        app.tapEditorAction("undo")
        XCTAssertFalse(rectangleHandle.exists)
        app.buttons["Crop"].tap()
        assertAppearanceForeground(app: app)

        gear.tap()
        setAppearanceSlider("appearance-opacity", to: "0%", endpoint: "Transparent", app: app)
        setAppearanceSlider("appearance-glass", to: "0%", endpoint: "No Glass", app: app)
        app.descendants(matching: .any)["appearance-settings"].firstMatch.buttons["Done"].tap()
        assertAppearanceForeground(app: app)
        attachScreenScreenshot(name: "Foreground clear - Opacity 0 Glass 0")
        app.buttons["Annotate"].tap()
        app.descendants(matching: .any)["tool-text"].firstMatch.tap()
        let text = app.descendants(matching: .any)["annotation-text"].firstMatch
        XCTAssertTrue(text.waitForExistence(timeout: 5),
                      "A clear window must preserve native text creation and editing: \(app.debugDescription)")
        XCTAssertEqual(text.value as? String, "Label")
        XCTAssertTrue(app.textFields["annotation-font-size"].exists)
        app.buttons["annotation-inspector-done"].tap()
        let textObject = app.descendants(matching: .any)["annotation-object-text"].firstMatch
        XCTAssertTrue(textObject.waitForExistence(timeout: 5), app.debugDescription)
        print("HIG_FIX_SCREEN|clear-text-editor")
        attachScreenScreenshot(name: "Editable text above a clear background")
        textObject.tap()
        XCTAssertTrue(text.waitForExistence(timeout: 5), "Ordinary text selection must remain interactive at zero background strength.")
        app.buttons["annotation-inspector-done"].tap()
        app.tapEditorAction("undo")
        XCTAssertFalse(textObject.exists)
        app.buttons["Crop"].tap()
        assertAppearanceForeground(app: app)
        app.tapEditorAction("undo")
        assertCropAxes(width: 1600, height: 1000, app: app)
        XCTAssertFalse(app.editorAction("undo").isEnabled,
                       "Appearance changes must neither add history entries nor consume the retained crop edit.")

        gear.tap()
        scrollTo(reset, app: app)
        reset.tap()
        revealFromTop(opacity, app: app)
        XCTAssertEqual(opacity.value as? String, "0%")
        XCTAssertEqual(glass.value as? String, "100%")
        app.descendants(matching: .any)["appearance-settings"].firstMatch.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["close-image"].waitForExistence(timeout: 8))
        app.tapEditorAction("close-image")
        XCTAssertTrue(app.buttons["choose-photos"].waitForExistence(timeout: 5))
        XCTAssertTrue(gear.exists, "Settings must remain available without an open image.")
    }

    @MainActor func testCropRemainsEditableAtZoomWithPanEnabled() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        waitForFixtureEditor(app: app)
        for _ in 0..<2 {
            app.buttons["view-options"].tap()
            app.buttons["Zoom In"].tap()
        }
        XCTAssertEqual(app.buttons["view-options"].value as? String, "225%")
        let corner = app.descendants(matching: .any)["crop-handle-3"].firstMatch
        let opposite = app.descendants(matching: .any)["crop-handle-0"].firstMatch
        for index in 0..<4 {
            let handle = app.descendants(matching: .any)["crop-handle-\(index)"].firstMatch
            XCTAssertTrue(handle.isHittable, "Zoomed crop corner must remain reachable: \(app.debugDescription)")
        }
        XCTAssertTrue((corner.value as? String ?? "").localizedCaseInsensitiveContains("offscreen"))
        corner.press(forDuration: 0.1, thenDragTo: opposite)
        XCTAssertNotEqual(app.staticTexts["crop-width-axis"].label, "\(1600.formatted()) px")
        XCTAssertNotEqual(app.staticTexts["crop-height-axis"].label, "\(1000.formatted()) px")
        XCTAssertTrue(app.editorAction("undo").isEnabled)
        app.tapEditorAction("undo")
        assertCropAxes(width: 1600, height: 1000, app: app)
        XCTAssertEqual(app.buttons["view-options"].value as? String, "225%")
        app.buttons["view-options"].tap()
        app.buttons["Pan"].tap()
        XCTAssertTrue(corner.isHittable, "Pan must not disable crop resize controls.")
        corner.press(forDuration: 0.1, thenDragTo: opposite)
        XCTAssertNotEqual(app.staticTexts["crop-width-axis"].label, "\(1600.formatted()) px")
        app.tapEditorAction("undo")
        assertCropAxes(width: 1600, height: 1000, app: app)
        XCTAssertEqual(app.buttons["view-options"].value as? String, "225%")
    }

    @MainActor func testNativeImagePasteAddsDocumentAndRecoversAfterClose() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        waitForFixtureEditor(app: app)
        let rows = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "open-document-"))
        let originalID = rows.firstMatch.identifier
        app.editorAction("copy-image").tap()
        XCTAssertTrue(app.staticTexts["Copied 1600 × 1000"].waitForExistence(timeout: 20), app.debugDescription)
        app.showCropDimensions()
        replaceText(in: app.textFields["crop-width"], with: "800", app: app)
        app.buttons["Done"].tap()
        app.openPasteImage().tap()
        XCTAssertTrue(rows.element(boundBy: 1).waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertFalse(app.buttons["discard-changes"].exists)
        let originalDetails = "\(1600.formatted()) × \(1000.formatted()) pixels · PNG"
        XCTAssertEqual(app.staticTexts["image-source-details"].label, originalDetails)
        assertCropAxes(width: 1600, height: 1000, app: app)
        XCTAssertFalse(app.editorAction("undo").isEnabled)
        app.descendants(matching: .any)[originalID].firstMatch.tap()
        assertCropAxes(width: 800, height: 1000, app: app)
        XCTAssertTrue(app.editorAction("undo").isEnabled)
        app.tapEditorAction("close-image"); app.buttons["discard-changes"].tap()
        let recent = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "recent-document-")).firstMatch
        // Recents starts collapsed (build 20); expand it before looking for the closed image.
        XCTAssertTrue(app.buttons["Recents"].waitForExistence(timeout: 5), app.debugDescription)
        app.buttons["Recents"].tap()
        XCTAssertTrue(recent.waitForExistence(timeout: 5))
        XCTAssertEqual(rows.count, 1)
        app.tapEditorAction("close-image")
        XCTAssertTrue(app.buttons["choose-photos"].waitForExistence(timeout: 5))
        let emptyPaste = app.openPasteImage(empty: true)
        XCTAssertTrue(emptyPaste.waitForExistence(timeout: 8) && emptyPaste.isEnabled, app.debugDescription)
        emptyPaste.tap()
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 15), app.debugDescription)
        XCTAssertEqual(app.staticTexts["image-source-details"].label, originalDetails)
        assertCropAxes(width: 1600, height: 1000, app: app)
    }

    @MainActor func testLabeledDimensionPairsAndAccessibleAnnotationCreation() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        waitForFixtureEditor(app: app)
        app.showCropDimensions()
        let width = app.textFields["crop-width"]
        let height = app.textFields["crop-height"]
        XCTAssertTrue(width.waitForExistence(timeout: 5) && height.exists, app.debugDescription)
        XCTAssertTrue(width.label.contains("Width") && width.label.contains("pixel"), width.label)
        XCTAssertTrue(height.label.contains("Height") && height.label.contains("pixel"), height.label)
        XCTAssertEqual(width.frame.midY, height.frame.midY, accuracy: 3,
                       "Width and Height should share a native form row at normal text sizes.")
        app.buttons["Done"].tap()
        app.buttons["Annotate"].tap()
        chooseShape("rectangle", app: app)
        app.showToolOptions()
        let color = app.descendants(matching: .any)["annotation-color"].firstMatch
        XCTAssertTrue(color.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue((color.value as? String ?? "").localizedCaseInsensitiveContains("red"), app.debugDescription)
        drawOnCanvas(app: app)
        XCTAssertEqual(app.inspectorTitle.label, "Rectangle", app.debugDescription)
        app.buttons["Done"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["annotation-object-rectangle"].firstMatch.waitForExistence(timeout: 5))
        app.tapEditorAction("undo")
        XCTAssertFalse(app.descendants(matching: .any)["annotation-object-rectangle"].firstMatch.exists)
    }

    @MainActor func testCancelProcessingPreservesTheCurrentDocument() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--ui-test-slow-paste"]
        app.launch()
        let cancel = app.buttons["processing-cancel"]
        XCTAssertTrue(cancel.waitForExistence(timeout: 10) && cancel.isEnabled, app.debugDescription)
        XCTAssertFalse(app.editorAction("copy-image").isEnabled)
        cancel.tap()
        XCTAssertTrue(cancel.waitForNonExistence(timeout: 8), app.debugDescription)
        assertCropAxes(width: 1600, height: 1000, app: app)
        XCTAssertFalse(app.editorAction("undo").isEnabled)
        XCTAssertTrue(app.editorAction("copy-image").isEnabled)
        XCTAssertFalse(app.alerts["Unable to Complete"].exists)
    }

    @MainActor private func canvasTarget(_ identifier: String, app: XCUIApplication) -> XCUIElement {
        let target = app.descendants(matching: .any)[identifier].firstMatch
        XCTAssertTrue(target.waitForExistence(timeout: 5), app.debugDescription)
        return target
    }

    @MainActor private func waitForFixtureEditor(app: XCUIApplication) {
        // The empty window already exposes Settings. Wait for the asynchronously loaded fixture
        // and its additional toolbar items before targeting the gear's final native position.
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertTrue(app.buttons["crop-dimensions"].waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(app.buttons["Crop"].isHittable, app.debugDescription)
        XCTAssertTrue(app.buttons["appearance-settings-button"].isHittable, app.debugDescription)
    }

    @MainActor private func drawOnCanvas(app: XCUIApplication) {
        let start = canvasTarget("canvas-test-start", app: app)
        let end = canvasTarget("canvas-test-end", app: app)
        start.press(forDuration: 0.1, thenDragTo: end)
    }

    @MainActor private func revealFromTop(_ element: XCUIElement, app: XCUIApplication) {
        for _ in 0..<5 {
            if element.exists && element.isHittable { return }
            app.inspectorScrollView.swipeDown()
        }
        XCTFail("The native form did not reveal its top control: \(app.debugDescription)")
    }

    @MainActor private func attachScreenshot(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor private func attachScreenScreenshot(name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor private func setAppearanceSlider(_ identifier: String, to expected: String,
                                               endpoint: String, app: XCUIApplication) {
        let slider = app.sliders[identifier]
        revealFromTop(slider, app: app)
        // Do not introduce a new gesture when the requested endpoint is already selected.
        if slider.value as? String == expected { return }
        let knob = slider.descendants(matching: .any)["AXSliderKnob"].firstMatch
        XCTAssertTrue(knob.waitForExistence(timeout: 5), app.debugDescription)
        // Endpoint descriptions now sit below the full-width native track. Drag to the track's
        // actual end rather than the center of a caption, which would stop short of its limit.
        let position = expected == "0%" ? 0.0 : 1.0
        knob.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .press(forDuration: 0.1, thenDragTo: slider.coordinate(withNormalizedOffset: CGVector(dx: position, dy: 0.5)))
        XCTAssertEqual(slider.value as? String, expected,
                       "Native endpoint dragging must reach the requested appearance extreme: \(app.debugDescription)")
    }

    @MainActor private func replaceAppearanceCropWidth(with value: String, app: XCUIApplication) {
        let field = app.textFields["crop-width"]
        XCTAssertTrue(field.waitForExistence(timeout: 5), app.debugDescription)
        field.tap()
        field.doubleTap()
        let selectionActions = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label IN %@", ["Select All", "Select", "Cut"]))
        guard selectionActions.firstMatch.waitForExistence(timeout: 5) else {
            attachScreenScreenshot(name: "Crop replacement missing native selection menu")
            XCTFail("The numeric field must expose its native selection menu before replacement: \(app.debugDescription)")
            return
        }
        if let selectAll = editMenuAction("Select All", app: app) { selectAll.tap() }
        else if let select = editMenuAction("Select", app: app) {
            select.tap()
            let selectedActions = app.descendants(matching: .any)
                .matching(NSPredicate(format: "label IN %@", ["Select All", "Cut"]))
            XCTAssertTrue(selectedActions.firstMatch.waitForExistence(timeout: 5), app.debugDescription)
            if let selectAll = editMenuAction("Select All", app: app) { selectAll.tap() }
            else { XCTAssertNotNil(editMenuAction("Cut", app: app), "The initial numeric word must be selected: \(app.debugDescription)") }
        } else {
            XCTAssertNotNil(editMenuAction("Cut", app: app), "The initial numeric word must be selected: \(app.debugDescription)")
        }
        print("Crop replacement selection ready: value=\(String(describing: field.value)), actions=\(selectionActions.allElementsBoundByIndex.map(\.label))")
        field.typeText(value)
        if field.value as? String != value { attachScreenScreenshot(name: "Crop replacement native input failure") }
        XCTAssertEqual(field.value as? String, value,
                       "The native field must receive the exact replacement before capture: \(app.debugDescription)")
    }

    @MainActor private func assertAppearanceForeground(app: XCUIApplication) {
        XCTAssertTrue(app.otherElements["image-canvas"].waitForExistence(timeout: 8), app.debugDescription)
        assertCropAxes(width: 1200, height: 1000, app: app)
        XCTAssertTrue(app.editorAction("undo").isEnabled, "The real crop edit must survive appearance changes.")
        XCTAssertTrue(app.staticTexts["image-title"].exists)
        XCTAssertTrue(app.staticTexts["image-source-details"].exists)
        XCTAssertEqual(app.buttons["view-options"].value as? String, "100%")
        for identifier in ["view-options", "copy-image", "export-image", "close-image", "appearance-settings-button"] {
            XCTAssertTrue(app.editorAction(identifier).isHittable, "Foreground action must remain available: \(identifier)")
        }
        XCTAssertTrue(app.buttons["Crop"].isHittable)
        XCTAssertTrue(app.buttons["Annotate"].isHittable)
    }

    @MainActor private func assertCropAxes(width: Int, height: Int, app: XCUIApplication) {
        let widthLabel = app.staticTexts["crop-width-axis"]
        let heightLabel = app.staticTexts["crop-height-axis"]
        XCTAssertTrue(widthLabel.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(heightLabel.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertEqual(widthLabel.label, "\(width.formatted()) px")
        XCTAssertEqual(heightLabel.label, "\(height.formatted()) px")
    }

    @MainActor private func chooseShape(_ kind: String, app: XCUIApplication) {
        let menu = app.buttons["shapes-primary"]
        XCTAssertTrue(menu.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertFalse(app.buttons["shapes-menu"].exists, "Shapes should have one native chooser.")
        menu.tap()
        let shape = app.buttons["tool-\(kind)"]
        XCTAssertTrue(shape.waitForExistence(timeout: 5), app.debugDescription)
        shape.tap()
    }

    @MainActor private func scrollTo(_ element: XCUIElement, app: XCUIApplication) {
        app.revealInInspector(element)
    }

    @MainActor private func replaceText(in field: XCUIElement, with text: String, app: XCUIApplication) {
        field.tap()
        // Fixture fields start with one word or number. Native word selection avoids a long-press
        // moving the caret to the beginning; visionOS exposes edit-menu actions as buttons.
        field.doubleTap()
        if let selectAll = editMenuAction("Select All", app: app) { selectAll.tap() }
        else if let select = editMenuAction("Select", app: app) {
            select.tap()
            if let selectAll = editMenuAction("Select All", app: app) { selectAll.tap() }
        }
        field.typeText(text)
        XCTAssertEqual(field.value as? String, text, "The native field must receive the intended replacement: \(app.debugDescription)")
    }

    @MainActor private func editMenuAction(_ title: String, app: XCUIApplication) -> XCUIElement? {
        app.editMenuAction(title)
    }

}
