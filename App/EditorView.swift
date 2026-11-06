import SwiftUI
import Accessibility
import PhotosUI
import UniformTypeIdentifiers
import VisionSnipCore

struct EditorView: View {
    @State private var documents: DocumentWorkspace
    private var model: EditorModel { documents.model }
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding private var minimumWindowWidth: CGFloat
    init(initialSource: ImageSource? = nil, minimumWindowWidth: Binding<CGFloat>) {
        _documents = State(initialValue: DocumentWorkspace(source: initialSource))
        _minimumWindowWidth = minimumWindowWidth
    }
    @State private var photo: PhotosPickerItem?
    @State private var showPhotos = false
    @State private var showFiles = false
    @State private var showDocuments = true
    @State private var showInspector = false
    @State private var showAppearance = false
    @State private var pendingAction: DocumentAction?
    @State private var confirmUnsaved = false
    @State private var exportRequest: ExportRequest?
    @State private var afterExportAction: DocumentAction?
    @State private var processingTask: Task<Void, Never>?
    @State private var processingID: UUID?
    @State private var isCancellingProcessing = false
    @State private var windowSize = CGSize(width: 1100, height: 760)

    private enum DocumentAction { case close(UUID), photos, files, paste([NSItemProvider]), drop([NSItemProvider]) }
    private struct ExportRequest: Identifiable {
        let id = UUID()
        let documentID: UUID
        let source: ImageSource
        let edits: EditState
        let continuation: DocumentAction?
    }

    var body: some View {
        ZStack {
            // The native glass is a rear surface, never a translucent cover over image pixels.
            ImageWindowBackground()
                .accessibilityHidden(true)
                .ignoresSafeArea()
                .offset(z: -1)
                .zIndex(-1)
            workspace
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                .opacity(1)
                // Keep gestures on the native interaction plane; only the backplate moves back.
                .zIndex(1)
        }
            .onGeometryChange(for: CGSize.self) { $0.size } action: { windowSize = $0 }
            .clipShape(RoundedRectangle(cornerRadius: ImageWindowAppearance.cornerRadius, style: .continuous))
            .toolbar { editorToolbar }
            .disabled(isProcessing)
            .overlay {
                if isProcessing {
                    VStack(spacing: 16) {
                        ProgressView(isCancellingProcessing ? "Cancelling processing…" : "Processing image…")
                        Button("Cancel Processing", role: .cancel) { cancelProcessing() }
                            .disabled(isCancellingProcessing || processingTask == nil)
                            .accessibilityIdentifier("processing-cancel")
                    }
                    .padding(32).glassBackgroundEffect()
                }
            }

        .photosPicker(isPresented: $showPhotos, selection: $photo, matching: .images, preferredItemEncoding: .current)
        .onChange(of: photo) { _, item in
            if let item { importImage { await $0.importPhoto(item) }; photo = nil }
        }
        .onChange(of: model.textEditingRequest) { _, _ in
            if model.selected?.kind == .text { showInspector = true }
        }
        .onChange(of: model.mode) { _, mode in if mode == .annotate { showInspector = true } }
        .onChange(of: requestedWindowMinimumWidth, initial: true) { _, width in
            if minimumWindowWidth != width { minimumWindowWidth = width }
        }
        .onChange(of: showInspector) { _, shown in if shown { model.revealSelection() } }
        .onChange(of: model.source == nil) { _, empty in if empty { showInspector = false } }
        .onDisappear { cancelProcessing(announce: false) }
        .focusedSceneValue(\.editorCommands, EditorCommandActions(
            newWindow: { openWindow(id: "editor") }, showSettings: { showAppearance = true }))
        .fileImporter(isPresented: $showFiles, allowedContentTypes: [.image]) { result in
            switch result {
            case .success(let url): importImage { await $0.importFile(url) }
            case .failure(let error): if !isUserCancellation(error) { model.error = error.localizedDescription }
            }
        }
        .sheet(isPresented: $showAppearance) { AppearanceSettings() }
        .sheet(item: $exportRequest, onDismiss: {
            if let action = afterExportAction { afterExportAction = nil; perform(action) }
        }) { request in
            ExportView(source: request.source, edits: request.edits, saveBeforeContinuing: request.continuation != nil) { output in
                guard documents.recordSave(output, documentID: request.documentID, source: request.source, edits: request.edits) else { return }
                if let action = request.continuation {
                    afterExportAction = action
                    exportRequest = nil
                }
            }
        }
        .alert(model.error == nil ? "Save changes to this image?" : "Unable to Complete", isPresented: alertPresented) {
            if model.error != nil {
                Button("OK", role: .cancel) { model.error = nil }
            } else {
                Button("Save a Copy…") { beginExport(continuation: pendingAction); pendingAction = nil }
                    .accessibilityIdentifier("save-before-close")
                Button("Discard Changes", role: .destructive) {
                    if let action = pendingAction { perform(action) }; pendingAction = nil
                }.accessibilityIdentifier("discard-changes")
                Button("Cancel", role: .cancel) { pendingAction = nil }
            }
        } message: {
            Text(model.error ?? "Save a flattened PNG or JPEG copy, or discard the current edits. Your original stays unchanged.")
        }
        .task {
            do {
                try await Task.detached(priority: .utility) { try ImageImportService.prepareTemporaryStorage() }.value
                try Task.checkCancellation()
            } catch is CancellationError { return }
            catch { model.error = error.localizedDescription; return }
            #if DEBUG
            // Explicit synthetic fixtures are never included in Release.
            if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
                if !ProcessInfo.processInfo.arguments.contains("--ui-test-empty-window") {
                    do { try documents.add(EditorModel(source: try EditorTestFixture.source())) }
                    catch { model.error = error.localizedDescription }
                }
                if ProcessInfo.processInfo.arguments.contains("--ui-test-slow-paste") {
                    importImage { await $0.pasteImage([EditorTestFixture.slowImageProvider()]) }
                }
                if ProcessInfo.processInfo.arguments.contains("--ui-test-url-paste") {
                    EditorTestFixture.seedImageLinkClipboard()
                }
                if ProcessInfo.processInfo.arguments.contains("--ui-test-invalid-paste") {
                    EditorTestFixture.seedInvalidClipboard()
                }
            }
            if ProcessInfo.processInfo.arguments.contains("--integration-smoke") {
                await EditorIntegrationChecks.run(model: model,
                    savePhotos: ProcessInfo.processInfo.arguments.contains("--verify-photos-save"))
            }
            if ProcessInfo.processInfo.arguments.contains("--show-export") { beginExport() }
            if ProcessInfo.processInfo.arguments.contains("--show-photos-picker") { showPhotos = true }
            #endif
        }
    }

    private var zoomLabel: String { "\(Int(model.zoom * 100))%" }
    private var alertPresented: Binding<Bool> {
        Binding(get: { confirmUnsaved || model.error != nil }, set: { presented in
            if !presented { confirmUnsaved = false; model.error = nil }
        })
    }
    private var isProcessing: Bool { processingTask != nil || model.busy }
    private var compactDocumentActions: Bool {
        dynamicTypeSize.isAccessibilitySize || windowSize.width < 1100
    }
    private var compactTools: Bool { windowSize.width < 900 || dynamicTypeSize.isAccessibilitySize }
    private var sidebarWidth: CGFloat { dynamicTypeSize.isAccessibilitySize ? 380 : 360 }
    private var inspectorWidth: CGFloat { dynamicTypeSize.isAccessibilitySize ? 440 : 380 }
    private var requestedWindowMinimumWidth: CGFloat {
        max(720, 640 + (showDocuments ? sidebarWidth : 0)
            + (showInspector && model.source != nil ? inspectorWidth : 0))
    }
    // visionOS navigation containers own additional glass that ignores our window settings.
    // Match the Glass-family plain-window columns; native controls keep their own surfaces.
    private var workspace: some View {
        HStack(spacing: 0) {
            if showDocuments {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Images").font(.title2.bold())
                        .accessibilityAddTraits(.isHeader)
                        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
                        .padding(.horizontal, 24)
                    DocumentSidebar(workspace: documents, onSelect: selectDocument,
                        onClose: { request(.close($0)) }, onReopen: reopenDocument)
                }
                .frame(width: sidebarWidth)
                .accessibilityElement(children: .contain).accessibilityLabel("Images sidebar")
                .transition(.move(edge: .leading).combined(with: .opacity))
                Divider()
            }
            VStack(spacing: 0) {
                documentHeader
                HStack(spacing: 0) {
                    imageWorkspace
                        // The canvas, status and caption end above the system bottom toolbar.
                        .padding(.bottom, ImageWindowAppearance.bottomOrnamentClearance)
                        .frame(minWidth: 640, maxWidth: .infinity, maxHeight: .infinity)
                    if showInspector, model.source != nil {
                        Divider()
                        Group {
                            if model.mode == .annotate {
                                AnnotationInspector(model: model, onDone: { showInspector = false })
                            } else {
                                CropInspector(model: model, onDone: { showInspector = false })
                            }
                        }
                        .id(documents.selectedID)
                        .frame(width: inspectorWidth)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .animation(reduceMotion ? nil : .default, value: showDocuments)
        .animation(reduceMotion ? nil : .default, value: showInspector)
    }
    private var documentHeader: some View {
        HStack {
            Button(showDocuments ? "Hide Sidebar" : "Show Sidebar", systemImage: "sidebar.left") {
                showDocuments.toggle()
            }.labelStyle(.iconOnly).accessibilityIdentifier("document-sidebar-toggle")
            newImageMenu.fixedSize()
            documentTitle
                .frame(minWidth: dynamicTypeSize.isAccessibilitySize ? 230 : 180, maxWidth: 300)
                .layoutPriority(1)
            Spacer(minLength: 8)
            if model.source != nil {
                documentToolGroup
                Button("Close Image", systemImage: "xmark") {
                    if let id = documents.selectedID { request(.close(id)) }
                }
                .buttonBorderShape(.circle)
                .accessibilityIdentifier("close-image")
            }
        }
        .labelStyle(.iconOnly)
        .padding(.horizontal, 16)
        .frame(minHeight: 92)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Image toolbar").accessibilityIdentifier("editor-titlebar")
    }
    /// Every document tool in one glass capsule, like the bottom toolbar's groups. Navigation-style
    /// ControlGroups draw separate circles and the automatic style recesses its icons, so the
    /// platform glass material groups the standard buttons instead.
    private var documentToolGroup: some View {
        HStack(spacing: 4) {
            documentActions
            Button(showInspector ? "Hide Inspector" : "Show Inspector", systemImage: "sidebar.right") {
                model.finishInspectorTransaction(); showInspector.toggle()
            }
            .accessibilityIdentifier("editor-inspector-toggle")
            .keyboardShortcut("i", modifiers: [.command, .option])
        }
        .buttonStyle(.borderless).buttonBorderShape(.circle)
        .padding(.horizontal, 8).padding(.vertical, 4)
        .glassBackgroundEffect(in: .capsule)
        .fixedSize()
        .accessibilityElement(children: .contain).accessibilityLabel("Image actions")
        .accessibilityIdentifier("editor-tool-group")
    }
    @ViewBuilder private var imageWorkspace: some View {
        if let source = model.source {
            VStack(alignment: .leading, spacing: 0) {
                ImageCanvas(model: model, source: source)
                    .id(documents.selectedID)
                    .overlay(alignment: .bottom) {
                        if let status = model.status {
                            Text(status).font(.caption).monospacedDigit()
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .glassBackgroundEffect(in: .capsule).padding(.bottom, 12)
                                .allowsHitTesting(false).accessibilityIdentifier("editor-status")
                        }
                    }
                ImageDescriptionCaption(image: source.preview, maximumHeight: min(220, windowSize.height * 0.28))
                    .id(ObjectIdentifier(source))
            }
        } else {
            ImageStartView(onPhotos: { request(.photos) }, onFiles: { request(.files) }, onDrop: { providers in
                guard providers.contains(where: { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }) else { return false }
                request(.drop(providers))
                return true
            }, onPaste: { request(.paste(UIPasteboard.general.itemProviders)) })
        }
    }
    /// One round + offers every way to start on an image. Unlike the bottom toolbar's choosers it has
    /// no chevron: beside the title, the wider capsule crowded the image's name (owner, build 27).
    private var newImageMenu: some View {
        Menu {
            Group {
                // ⌘N is a scene command (EditorCommands); menu-item shortcuts are not registered.
                Button("New Window", systemImage: "macwindow.badge.plus") { openWindow(id: "editor") }
                    .accessibilityIdentifier("new-window")
                Divider()
                Button("Choose from Photos…", systemImage: "photo.on.rectangle") { request(.photos) }
                Button("Import from Files…", systemImage: "folder") { request(.files) }
                // The empty workspace's own Paste owns ⌘V while it is visible.
                pasteButton(identifier: model.source == nil ? "paste-image-empty" : "paste-image",
                            handlesKeyboardShortcut: model.source != nil)
            }
            .labelStyle(.titleAndIcon)
        } label: {
            Label("New Image", systemImage: "plus")
        }
        .menuIndicator(.hidden)
        .buttonBorderShape(.circle)
        .accessibilityIdentifier("new-image-menu")
        .accessibilityLabel("New Image")
        .help("New window, or open an image from Photos, Files or the clipboard")
    }
    @ViewBuilder private var documentTitle: some View {
        if let source = model.source {
            VStack(alignment: .leading, spacing: 2) {
                Text(source.name).font(.headline).lineLimit(1).truncationMode(.middle)
                    .accessibilityAddTraits(.isHeader)
                    .help(source.name).accessibilityLabel(source.name).accessibilityIdentifier("image-title")
                Text("\(Int(source.size.width)) × \(Int(source.size.height)) px · \(source.typeLabel)")
                    .font(.caption).foregroundStyle(.secondary).monospacedDigit().lineLimit(1)
                    .accessibilityLabel("\(Int(source.size.width)) × \(Int(source.size.height)) pixels · \(source.typeLabel)")
                    .accessibilityIdentifier("image-source-details")
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        } else {
            Text("Glass Image Tools").font(.headline)
        }
    }
    @ViewBuilder private var documentActions: some View {
        if model.source != nil {
            if !compactDocumentActions { historyActions.labelStyle(.iconOnly) }
            copyAction
            quickShareAction
            if compactDocumentActions {
                Menu {
                    historyActions
                    Divider()
                    secondaryDocumentActions
                } label: { Label("Image Actions", systemImage: "ellipsis.circle") }
                    .labelStyle(.iconOnly).accessibilityIdentifier("editor-actions-menu")
            } else { secondaryDocumentActions.labelStyle(.iconOnly) }
        }
    }
    private var secondaryDocumentActions: some View {
        Group {
            exportAction
        }
    }
    @ViewBuilder private var historyActions: some View {
        if model.source != nil {
            Button("Undo", systemImage: "arrow.uturn.backward", action: model.undo)
                .disabled(!model.canUndo).keyboardShortcut("z")
                .accessibilityIdentifier("undo")
            Button("Redo", systemImage: "arrow.uturn.forward", action: model.redo)
                .disabled(!model.canRedo).keyboardShortcut("z", modifiers: [.command, .shift])
                .accessibilityIdentifier("redo")
        }
    }
    @ViewBuilder private var copyAction: some View {
        if model.source != nil {
            Button("Copy", systemImage: "doc.on.doc") {
                // Like Share › Copy, no blocking overlay: the canvas shows a brief status instead.
                let copying = model
                Task {
                    await copying.copy()
                    if copying.error == nil, let status = copying.status {
                        AccessibilityNotification.Announcement(status).post()
                    }
                }
            }
                .labelStyle(.iconOnly).disabled(model.copying)
                .keyboardShortcut("c").accessibilityIdentifier("copy-image")
        }
    }
    @ViewBuilder private var quickShareAction: some View {
        if let source = model.source {
            ShareLink(item: EditedImageTransfer(source: source, edits: model.edit), preview: SharePreview("Edited Image")) {
                Label("Share PNG", systemImage: "square.and.arrow.up")
            }
            .labelStyle(.iconOnly).help("Share PNG")
            .accessibilityIdentifier("quick-share-image")
        }
    }
    @ViewBuilder private var exportAction: some View {
        if model.source != nil {
            Button("Export…", systemImage: "square.and.arrow.down") { beginExport() }
                .help("Export formats and save options")
                .accessibilityIdentifier("export-image")
        }
    }

    @ToolbarContentBuilder private var editorToolbar: some ToolbarContent {
        // Each control is a native toolbar item. A surrounding stack makes the system size the
        // entire bar as one item, bypassing its normal button sizing and spacing.
        ToolbarItemGroup(placement: .bottomOrnament) {
            if model.source != nil {
                editingMode
                if model.mode == .crop { cropTools }
                else if compactTools {
                    shapeTool
                    drawingToolsMenu
                }
                else { annotationTools }
                viewOptions
            }
            settingsButton
        }
    }
    private var editingMode: some View {
        Picker("Editing mode", selection: Binding(get: { model.mode }, set: { model.changeMode($0) })) {
            ForEach(EditorMode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
        }.pickerStyle(.segmented).accessibilityIdentifier("editing-mode")
    }
    private var drawingToolsMenu: some View {
        Menu {
            Button("Select") { model.tool = .select }
            ForEach([AnnotationKind.freehand, .text, .pixelate], id: \.self) { kind in
                Button(kind.rawValue) { model.useTool(kind) }
                    .accessibilityIdentifier("tool-\(kind.rawValue.lowercased())")
            }
        } label: {
            menuLabel { Label("Drawing Tools", systemImage: compactDrawingSymbol) }
        }
        .menuIndicator(.hidden)
        .help("Drawing tools: Select, Draw, Text and Pixelate")
        .accessibilityIdentifier("drawing-tools-menu")
        .accessibilityLabel("Drawing Tools")
        .accessibilityValue(model.tool == .select ? "Select" : model.effectiveAnnotationKind.rawValue)
    }
    // The visionOS menu style does not render menuIndicator(.visible). Keep the system Menu
    // and its native button surface; use Apple's symbol as a decorative part of the label.
    private func menuLabel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 6) {
            content()
            if !dynamicTypeSize.isAccessibilitySize {
                Image(systemName: "chevron.down").imageScale(.small).accessibilityHidden(true)
            }
        }
    }
    private var compactDrawingSymbol: String {
        if case .annotation(let kind) = model.tool, !kind.isShape { return kind.symbol }
        return model.tool == .select ? "cursorarrow" : "pencil.tip.crop.circle"
    }
    @ViewBuilder private var cropTools: some View {
        Menu {
            Picker("Crop preset", selection: Binding(get: { model.preset }, set: model.setPreset)) {
                ForEach(CropPreset.allCases, id: \.self) {
                    Text($0.rawValue).tag($0).accessibilityIdentifier("preset-\($0.rawValue)")
                }
            }
            Divider()
            if compactTools { cropDimensionsAction }
            Button("Reset Crop", systemImage: "arrow.uturn.backward", action: model.resetCrop)
                .accessibilityIdentifier("reset-crop")
        } label: {
            menuLabel { Label("Crop Preset", systemImage: "aspectratio") }
        }.menuIndicator(.hidden).accessibilityIdentifier("crop-preset")
            .accessibilityValue(model.preset.rawValue).help("Crop preset: \(model.preset.rawValue)")
        if !compactTools { cropDimensionsAction }
        Button("Rotate Left", systemImage: "rotate.left", action: model.rotateLeft)
            .accessibilityIdentifier("rotate-left")
            .help("Rotate image 90 degrees counterclockwise")
    }
    private var cropDimensionsAction: some View {
        Button("Crop Dimensions", systemImage: "ruler") { showInspector = true }
            .accessibilityIdentifier("crop-dimensions")
    }
    private var viewOptions: some View {
        Menu {
            Group {
            Toggle("Pan", systemImage: "hand.draw", isOn: Binding(
                get: { model.tool == .pan }, set: { model.tool = $0 ? .pan : .select }))
                .accessibilityHint("Move the view without changing the crop or annotations.")
            Button("Zoom Out", systemImage: "minus.magnifyingglass") { model.setZoom(model.zoom / 1.5) }
                .keyboardShortcut("-", modifiers: .command).disabled(model.zoom <= 1)
            Button("Zoom In", systemImage: "plus.magnifyingglass") { model.setZoom(model.zoom * 1.5) }
                .keyboardShortcut("+", modifiers: .command).disabled(model.zoom >= 8)
            Button("Fit to Window", systemImage: "arrow.up.left.and.arrow.down.right", action: model.fit)
                .keyboardShortcut("0", modifiers: .command)
            }.labelStyle(.titleAndIcon)
        } label: {
            menuLabel {
                Label {
                    Text(zoomLabel)
                } icon: {
                    Image(systemName: "magnifyingglass")
                        .overlay(alignment: .bottomTrailing) {
                            if model.tool == .pan {
                                Image(systemName: "hand.draw.fill").font(.system(size: 12))
                                    .padding(2).background(.regularMaterial, in: Circle())
                                    .offset(x: 5, y: 5).accessibilityHidden(true)
                            }
                        }
                }
                .labelStyle(.titleAndIcon)
            }
        }
        .menuIndicator(.hidden)
        .tint(model.tool == .pan ? Color.accentColor : nil)
        .help(model.tool == .pan ? "Pan is on. Drag to move the view." : "Zoom and View")
        .accessibilityIdentifier("view-options")
        .accessibilityLabel(model.tool == .pan ? "Zoom and View, Pan on" : "Zoom and View")
        .accessibilityValue(zoomLabel)
    }
    private var settingsButton: some View {
        // ⌘, is a scene command (EditorCommands); ornament shortcuts are not registered.
        Button("Settings", systemImage: "gearshape") { showAppearance = true }
            .accessibilityIdentifier("appearance-settings-button")
    }
    @ViewBuilder private var annotationTools: some View {
        selectTool
        shapeTool
        drawTool(.freehand)
        placeTool(.text)
        placeTool(.pixelate)
    }
    private var selectTool: some View {
        Toggle(isOn: Binding(get: { model.tool == .select }, set: { if $0 { model.tool = .select } })) {
            Label("Select", systemImage: "cursorarrow")
        }
        .toggleStyle(.button).accessibilityIdentifier("tool-select")
    }
    private var shapeTool: some View {
        Menu { shapeChoices } label: {
            menuLabel {
                Label(model.lastShape.rawValue, systemImage: model.lastShape.symbol)
            }
        }
        .menuIndicator(.hidden)
        .help("Choose a shape").accessibilityIdentifier("shapes-primary")
        .accessibilityLabel(model.lastShape.rawValue)
        .accessibilityHint("Opens the shape menu.")
        .accessibilityAddTraits(model.tool == .annotation(model.lastShape) ? .isSelected : [])
        .accessibilityValue(model.tool == .annotation(model.lastShape) ? "Selected" : "Not selected")
        .tint(model.tool == .annotation(model.lastShape) ? Color.accentColor : nil)
    }
    private func drawTool(_ kind: AnnotationKind) -> some View {
        Toggle(isOn: Binding(get: { model.tool == .annotation(kind) }, set: { enabled in
            if enabled { model.chooseTool(kind) } else { model.tool = .select }
        })) {
            Label(kind.rawValue, systemImage: kind.symbol)
        }
        .toggleStyle(.button)
        .help("Drag to add \(kind.rawValue.lowercased())")
        .accessibilityIdentifier("tool-\(kind.rawValue.lowercased())")
        .accessibilityLabel(kind.rawValue)
    }
    /// Text and pixelation are actions, not modes: each tap places a new selected object.
    private func placeTool(_ kind: AnnotationKind) -> some View {
        Button(kind.rawValue, systemImage: kind.symbol) { model.useTool(kind) }
            .help(kind == .text ? "Add a text label at the center of the crop"
                                : "Add a pixelation region at the center of the crop")
            .accessibilityIdentifier("tool-\(kind.rawValue.lowercased())")
            .accessibilityHint(kind == .text ? "Adds a text label you can type into and move."
                                             : "Adds a pixelation region you can move and resize.")
    }
    @ViewBuilder private var shapeChoices: some View {
        ForEach(AnnotationKind.shapes, id: \.self) { kind in
            Button(kind.rawValue, systemImage: kind.symbol) { model.chooseTool(kind) }
                .accessibilityIdentifier("tool-\(kind.rawValue.lowercased().replacingOccurrences(of: " ", with: "-"))")
                .labelStyle(.titleAndIcon).accessibilityLabel(kind.rawValue)
        }
    }
    /// The menu registers its Paste shortcut only while an image is open, avoiding duplicate bindings.
    private func pasteButton(identifier: String, handlesKeyboardShortcut: Bool) -> some View {
        PasteButton(supportedContentTypes: [.image, .url, .plainText]) { providers in
            // The system grants access through this explicit action; the image opens as a new document.
            request(.paste(providers))
        }
        .accessibilityLabel("Paste Image")
        .accessibilityHint("Open a copied image or download a direct HTTPS image link.")
        .accessibilityIdentifier(identifier)
        .keyboardShortcut(handlesKeyboardShortcut ? KeyboardShortcut("v", modifiers: .command) : nil)
    }
    private func selectDocument(_ id: UUID) {
        model.finishInspectorTransaction()
        documents.select(id)
    }
    private func reopenDocument(_ id: UUID) {
        do { try documents.reopen(id) } catch { model.error = error.localizedDescription }
    }
    private func importImage(_ operation: @escaping @MainActor (EditorModel) async -> Void) {
        guard documents.canOpen else { model.error = DocumentWorkspace.LimitError.openLimit.localizedDescription; return }
        let imported = EditorModel()
        startProcessing {
            await operation(imported)
            guard !Task.isCancelled else { return }
            if let error = imported.error { model.error = error; return }
            guard imported.source != nil else { return }
            do { try documents.add(imported) } catch { model.error = error.localizedDescription }
        }
    }
    private func request(_ action: DocumentAction) {
        if case .close(let id) = action {
            guard let document = documents.documents.first(where: { $0.id == id }) else { return }
            selectDocument(id)
            document.model.finishInspectorTransaction()
            if document.model.hasUnsavedChanges { pendingAction = action; confirmUnsaved = true; return }
        }
        perform(action)
    }
    private func perform(_ action: DocumentAction) {
        switch action {
        case .close(let id):
            startProcessing {
                do {
                    if let warning = try await documents.closeDocument(id) { model.error = warning }
                } catch is CancellationError {
                    // Cancellation keeps this document open and publishes no recent item.
                } catch { model.error = error.localizedDescription }
            }
        case .photos: showPhotos = true
        case .files: showFiles = true
        case .paste(let providers): importImage { await $0.pasteImage(providers) }
        case .drop(let providers): importImage { await $0.dropImage(providers) }
        }
    }
    private func startProcessing(_ operation: @escaping @MainActor () async -> Void) {
        processingTask?.cancel()
        let id = UUID()
        processingID = id
        isCancellingProcessing = false
        let reportingModel = model
        processingTask = Task {
            await operation()
            guard processingID == id else { return }
            if !Task.isCancelled, model === reportingModel, model.error == nil, let status = model.status {
                AccessibilityNotification.Announcement(status).post()
            }
            processingTask = nil; processingID = nil; isCancellingProcessing = false
        }
    }
    private func cancelProcessing(announce: Bool = true) {
        guard let processingTask, !isCancellingProcessing else { return }
        isCancellingProcessing = true
        if announce { AccessibilityNotification.Announcement("Cancellation requested").post() }
        // Keep the native progress surface until the worker actually returns.
        processingTask.cancel()
    }
    private func beginExport(continuation: DocumentAction? = nil) {
        guard let source = model.source else { return }
        model.finishInspectorTransaction()
        guard let id = documents.selectedID else { return }
        exportRequest = ExportRequest(documentID: id, source: source, edits: model.edit, continuation: continuation)
    }
    private func isUserCancellation(_ error: any Error) -> Bool {
        let error = error as NSError
        return error.domain == NSCocoaErrorDomain && error.code == CocoaError.userCancelled.rawValue
    }
}

