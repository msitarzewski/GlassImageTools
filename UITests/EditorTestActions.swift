import XCTest

extension XCUIApplication {
    @MainActor var editorTitleBar: XCUIElement {
        descendants(matching: .any)["editor-titlebar"].firstMatch
    }
    // Menu items and system toolbar items can drop SwiftUI accessibility identifiers; their
    // visible/spoken labels survive.
    @MainActor func editorAction(_ identifier: String) -> XCUIElement {
        let direct = buttons[identifier]
        if direct.exists { return direct }
        let labels = ["copy-image": "Copy", "quick-share-image": "Share PNG", "undo": "Undo",
                      "redo": "Redo", "export-image": "Export…", "new-window": "New Window"]
        return buttons[labels[identifier] ?? identifier]
    }
    @MainActor func revealEditorAction(_ identifier: String, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        let action = editorAction(identifier)
        if !action.exists || !action.isHittable { buttons["editor-actions-menu"].tap() }
        XCTAssertTrue(action.waitForExistence(timeout: 5) && action.isHittable, debugDescription, file: file, line: line)
        return action
    }
    @MainActor func tapEditorAction(_ identifier: String, file: StaticString = #filePath, line: UInt = #line) {
        revealEditorAction(identifier, file: file, line: line).tap()
    }
    @MainActor func inspectorShows(_ element: XCUIElement) -> Bool {
        guard element.exists else { return false }
        if element.isHittable { return true }
        // Plain-window native Form controls can report a -1 hit point despite being visible
        // and accepting a real tap. Stop scrolling at the visible row; callers still tap it
        // and assert the actual edit, palette or selection outcome.
        let bounds = element.frame
        return bounds.width > 0 && bounds.height > 0 && inspectorScrollView.frame.contains(bounds)
    }
    @MainActor var inspectorScrollView: XCUIElement {
        for identifier in ["annotation-panel", "crop-panel"] {
            let form = collectionViews[identifier]
            if form.exists { return form }
        }
        return collectionViews.firstMatch
    }
    /// Scrolls the inspector Form until the element's row is visible. Forms materialize rows lazily.
    @MainActor func revealInInspector(_ element: XCUIElement, towardTop: Bool = false,
                                      file: StaticString = #filePath, line: UInt = #line) {
        for _ in 0..<8 {
            if inspectorShows(element) { return }
            scrollInspector(towardTop: towardTop)
        }
        XCTFail("A native form control must be reachable by scrolling: \(debugDescription)", file: file, line: line)
    }
    /// A synthesized swipe that begins on a color well, slider or toggle row can leave the Form
    /// unscrolled, and the Form's center may be such a row. Try the Form, then each visible row
    /// from the bottom up, until the rows move.
    @MainActor private func scrollInspector(towardTop: Bool) {
        let form = inspectorScrollView
        let visible = form.frame
        let rows = form.cells.allElementsBoundByIndex.filter { visible.contains($0.frame) }
        let layout = { form.cells.allElementsBoundByIndex.map(\.frame.minY) }
        let before = layout()
        for origin in [form] + rows.reversed() {
            if towardTop { origin.swipeDown() } else { origin.swipeUp() }
            if layout() != before { return }
        }
    }
    /// visionOS exposes text edit-menu commands as buttons or menu items.
    @MainActor func editMenuAction(_ title: String) -> XCUIElement? {
        let button = buttons[title].firstMatch
        if button.exists { return button }
        let item = menuItems[title].firstMatch
        return item.exists ? item : nil
    }
    /// Document tools share one title-bar group; Close Image sits alone after it, in the corner.
    @MainActor func assertDocumentToolsGrouped(file: StaticString = #filePath, line: UInt = #line) {
        let titleBar = editorTitleBar
        let group = titleBar.descendants(matching: .any)["editor-tool-group"].firstMatch
        let close = titleBar.buttons["close-image"]
        XCTAssertTrue(group.exists && close.exists, debugDescription, file: file, line: line)
        for id in ["copy-image", "quick-share-image", "editor-inspector-toggle"] {
            XCTAssertTrue(group.buttons[id].exists, "\(id) belongs to the document tool group", file: file, line: line)
        }
        let more = group.buttons["editor-actions-menu"]
        XCTAssertTrue(more.exists || (group.buttons["undo"].exists && group.buttons["export-image"].exists),
                      "History and Export stay in the group, directly or in its overflow menu", file: file, line: line)
        XCTAssertFalse(group.buttons["close-image"].exists, file: file, line: line)
        XCTAssertGreaterThanOrEqual(close.frame.minX, group.frame.maxX, "Close follows the group", file: file, line: line)
        XCTAssertEqual(close.frame.maxX, titleBar.frame.maxX, accuracy: 24, "Close sits in the trailing corner",
                       file: file, line: line)
    }
    @MainActor var sidebarToggle: XCUIElement {
        buttons["editor-inspector-toggle"]
    }

    /// The single + menu offers New Window, Photos, Files and Paste.
    @MainActor func openNewImageMenu(file: StaticString = #filePath, line: UInt = #line) {
        let menu = buttons["new-image-menu"]
        XCTAssertTrue(menu.waitForExistence(timeout: 5), debugDescription, file: file, line: line)
        menu.tap()
    }
    @MainActor func openPasteImage(empty: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        openNewImageMenu(file: file, line: line)
        let paste = descendants(matching: .any)[empty ? "paste-image-empty" : "paste-image"].firstMatch
        XCTAssertTrue(paste.waitForExistence(timeout: 5), debugDescription, file: file, line: line)
        return paste
    }

    @MainActor func showCropDimensions() {
        let action = buttons["crop-dimensions"]
        if !action.exists || !action.isHittable { buttons["crop-preset"].tap() }
        action.tap()
    }

    /// Inspector panes have one title: the edited object, "New …" for a tool's style, or Annotate.
    @MainActor var inspectorTitle: XCUIElement { staticTexts["inspector-title"] }
    /// Draws a shape with the real canvas gesture between the Debug scene targets.
    @MainActor func drawShape(_ kind: String, file: StaticString = #filePath, line: UInt = #line) {
        buttons["shapes-primary"].tap()
        let shape = buttons["tool-\(kind)"]
        XCTAssertTrue(shape.waitForExistence(timeout: 5), debugDescription, file: file, line: line)
        shape.tap()
        let start = descendants(matching: .any)["canvas-test-start"].firstMatch
        let end = descendants(matching: .any)["canvas-test-end"].firstMatch
        XCTAssertTrue(start.waitForExistence(timeout: 5) && end.exists, debugDescription, file: file, line: line)
        start.press(forDuration: 0.1, thenDragTo: end)
    }
    @MainActor func showToolOptions(file: StaticString = #filePath, line: UInt = #line) {
        let panel = descendants(matching: .any)["annotation-panel"].firstMatch
        if !panel.exists { sidebarToggle.tap() }
        XCTAssertTrue(panel.waitForExistence(timeout: 5), debugDescription, file: file, line: line)
    }
}
