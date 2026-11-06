import SwiftUI
import AppKit
import PhotosUI
import UniformTypeIdentifiers
import VisionSnipCore

struct MacEditorView: View {
    @State private var workspace = DocumentWorkspace()
    @State private var showFiles = false
    @State private var showPhotos = false
    @State private var photo: PhotosPickerItem?
    @State private var showInspector = false
    @State private var showMarkup = true
    @State private var recentsExpanded = false
    @State private var openExpanded = true
    @State private var processing: Task<Void, Never>?
    @State private var operationID = UUID()
    @State private var exportRequest: ExportRequest?
    @State private var closeRequest: CloseRequest?
    @State private var closeAlert: NSAlert?
    @State private var afterExport: (() -> Void)?
    @State private var windowReference = MacEditorWindowReference()
    private var window: NSWindow? { windowReference.window }
    @State private var allowWindowClose = false
    @State private var finishingWindowClose = false
    @State private var closeWindowAfterSave = false
    private var model: EditorModel { workspace.model }
    private struct ExportRequest: Identifiable {
        let id = UUID()
        let documentID: UUID
        let source: ImageSource
        let edits: EditState
        var saveBeforeClose: Bool
    }
    private enum CloseRequest: Identifiable {
        case image(UUID), window
        var id: String { switch self { case .image(let id): id.uuidString; case .window: "window" } }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: Binding(get: { workspace.selectedID }, set: { if let id = $0 { workspace.select(id) } })) {
                DisclosureGroup(isExpanded: $openExpanded) {
                    ForEach(workspace.documents) { document in
                        Label(document.model.source?.name ?? "Image", systemImage: "photo")
                            .badge(document.model.hasUnsavedChanges ? "Edited" : "")
                            .tag(document.id)
                            .accessibilityIdentifier("mac-document-" + document.id.uuidString)
                    }
                } label: { Label("Open Images", systemImage: "photo.on.rectangle") }
                DisclosureGroup(isExpanded: $recentsExpanded) {
                    ForEach(workspace.recents) { recent in
                        Button { do { try workspace.reopen(recent.id) } catch { model.error = error.localizedDescription } } label: {
                            Label(recent.source.name, systemImage: "photo")
                        }.buttonStyle(.plain)
                    }
                    if !workspace.recents.isEmpty { Button("Clear Recents", role: .destructive) { workspace.clearRecents() } }
                } label: { Label("Recents", systemImage: "clock") }
            }.listStyle(.sidebar)
                .navigationTitle("Images")
                .navigationSplitViewColumnWidth(min: 180, ideal: 240, max: 340)
        } detail: {
            VStack(spacing: 0) {
                if let source = model.source {
                    ImageCanvas(model: model, source: source)
                    ImageDescriptionCaption(image: source.preview, maximumHeight: 90).id(ObjectIdentifier(source))
                    if let status = model.status { Text(status).font(.caption).foregroundStyle(.secondary).padding(6) }
                } else { welcome }
            }
            .frame(minWidth: 460, minHeight: 420)
            .navigationTitle(model.source?.name ?? "Glass Image Tools")
            .navigationSubtitle(model.source.map { "\(Int($0.size.width)) × \(Int($0.size.height)) pixels · \($0.typeLabel)" } ?? "")
            .inspector(isPresented: $showInspector) {
                Group {
                    if model.source != nil {
                        if model.mode == .crop { CropInspector(model: model) { showInspector = false } }
                        else { AnnotationInspector(model: model) { showInspector = false } }
                    } else { ContentUnavailableView("No Image", systemImage: "photo", description: Text("Open an image to crop or annotate it.")) }
                }.inspectorColumnWidth(min: 260, ideal: 300, max: 420)
            }
            .toolbar { editorToolbar }
        }
        .overlay { if processing != nil { processingOverlay } }
        .background { MacWindowCloseGuard(canClose: { allowWindowClose || !hasUnsavedWork }, edited: hasUnsavedWork,
            onWindow: { windowReference.window = $0 }, requestClose: { closeRequest = .window },
            requestSaveAndClose: { startCloseSave(.window) }) }
        .focusedSceneValue(\.macEditorActions, MacEditorActions(open: { showFiles = true }, photos: { showPhotos = true },
            paste: paste, copy: copy, export: { export(saveBeforeClose: false) }, closeImage: requestCloseImage,
            undo: model.undo, redo: model.redo, delete: model.deleteSelection,
            zoomIn: { model.setZoom(model.zoom * 1.5) }, zoomOut: { model.setZoom(model.zoom / 1.5) }, fit: model.fit,
            model: model, markupVisible: showMarkup, toggleMarkup: { showMarkup.toggle() },
            revealMarkup: { showMarkup = true }, cropDimensions: revealCropDimensions,
            annotationTool: chooseAnnotationTool))
        .fileImporter(isPresented: $showFiles, allowedContentTypes: [.image]) { result in
            switch result { case .success(let url): importFile(url)
            case .failure(let error): if !isCancelled(error) { model.error = error.localizedDescription } }
        }
        .photosPicker(isPresented: $showPhotos, selection: $photo, matching: .images)
        .onChange(of: photo) { _, item in
            if let item { importImage { await $0.importPhoto(item) }; photo = nil }
        }
        .onChange(of: model.textEditingRequest) { _, _ in showInspector = true }
        .onChange(of: model.mode) { _, _ in showInspector = model.source != nil }
        .onChange(of: model.source != nil) { _, hasImage in if !hasImage { showInspector = false } }
        .onChange(of: showInspector) { _, shown in if shown { model.revealSelection() } }
        .onOpenURL { url in if url.isFileURL { importFile(url) } }
        .onDrop(of: [.image], isTargeted: nil) { providers in
            guard processing == nil else { return false }
            importImage { await $0.dropImage(providers) }; return true
        }
        .sheet(item: $exportRequest, onDismiss: { if let next = afterExport { afterExport = nil; next() } else if closeWindowAfterSave { closeWindowAfterSave = false; MacWindowCloseRegistry.shared.cancelTermination() } }) { request in
            ExportView(source: request.source, edits: request.edits, saveBeforeContinuing: request.saveBeforeClose) { output in
                guard workspace.recordSave(output, documentID: request.documentID, source: request.source, edits: request.edits) else { return }
                if request.saveBeforeClose {
                    afterExport = { closeDocument(request.documentID, thenWindow: closeWindowAfterSave) }
                    exportRequest = nil
                }
            }
        }
        .onChange(of: closeRequest?.id) { _, _ in if let request = closeRequest { presentCloseDialog(request) } }
        .alert("Unable to Complete", isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })) {
            Button("OK", role: .cancel) { model.error = nil }
        } message: { Text(model.error ?? "") }
        .task { do { try await Task.detached { try ImageImportService.prepareTemporaryStorage() }.value } catch { model.error = error.localizedDescription } }
        .onDisappear { processing?.cancel(); processing = nil }
    }

    private var hasUnsavedWork: Bool { workspace.documents.contains { $0.model.hasUnsavedChanges } }
    private var welcome: some View {
        ContentUnavailableView {
            Label("Open an Image", systemImage: "photo")
        } description: {
            Text("Crop, mark up and share. Your original stays unchanged.")
        } actions: {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button("Photos…", systemImage: "photo.on.rectangle") { showPhotos = true }
                        .frame(maxWidth: .infinity).accessibilityIdentifier("mac-open-photos")
                    Button("Open…", systemImage: "folder") { showFiles = true }
                        .frame(maxWidth: .infinity).accessibilityIdentifier("mac-open-files")
                }.controlSize(.large)
                Button(action: paste) {
                    VStack(spacing: 8) {
                        Label("Drop or Paste an Image", systemImage: "square.and.arrow.down")
                        Text("Paste an image or direct HTTPS image link. ⌘V")
                            .font(.caption).foregroundStyle(.secondary)
                    }.frame(maxWidth: .infinity, minHeight: 82)
                }.buttonStyle(.bordered).accessibilityIdentifier("mac-paste-well")
            }.frame(maxWidth: 380)
        }
    }

    private var processingOverlay: some View {
        VStack(spacing: 12) {
            ProgressView("Opening Image…")
            Button("Cancel") { processing?.cancel() }
        }.padding(24).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    @ToolbarContentBuilder private var editorToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Menu {
                Button("Open…", systemImage: "folder") { showFiles = true }
                Button("Choose from Photos…", systemImage: "photo") { showPhotos = true }
                Button("Paste", systemImage: "doc.on.clipboard", action: paste)
            } label: { Label("Open Image", systemImage: "plus") }
            .help("Open an image").accessibilityIdentifier("mac-open-image")
        }
        if model.source != nil {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Undo", systemImage: "arrow.uturn.backward", action: model.undo).disabled(!model.canUndo)
                Button("Redo", systemImage: "arrow.uturn.forward", action: model.redo).disabled(!model.canRedo)
            }
            ToolbarSpacer(.fixed, placement: .primaryAction)
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Copy", systemImage: "doc.on.doc", action: copy).disabled(model.copying).accessibilityIdentifier("mac-copy")
                if let source = model.source { ShareLink(item: EditedImageTransfer(source: source, edits: model.edit), preview: SharePreview("Edited Image")) }
                Button("Export", systemImage: "square.and.arrow.down") { export(saveBeforeClose: false) }.accessibilityIdentifier("mac-export")
                Button("Close Image", systemImage: "xmark.circle", action: requestCloseImage).accessibilityIdentifier("mac-close-image")
            }
            ToolbarSpacer(.fixed, placement: .primaryAction)
        }
        ToolbarItemGroup(placement: .primaryAction) {
            if model.source != nil {
                Toggle(isOn: $showMarkup) { Label("Markup", systemImage: "pencil.tip.crop.circle") }
                    .toggleStyle(.button)
                    .help(showMarkup ? "Hide Markup Toolbar" : "Show Markup Toolbar")
                    .accessibilityLabel(showMarkup ? "Hide Markup Toolbar" : "Show Markup Toolbar")
                    .accessibilityIdentifier("mac-markup-toggle")
            }
            SettingsLink { Label("Settings", systemImage: "gearshape") }
                .help("Settings").accessibilityIdentifier("mac-editor-settings")
            Button("Inspector", systemImage: "sidebar.right") { showInspector.toggle() }
                .disabled(model.source == nil).accessibilityIdentifier("mac-inspector-toggle")
        }
        if model.source != nil && showMarkup {
            ToolbarItem(placement: .accessoryBar(id: "markup")) {
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    HStack(spacing: 8) {
                        Picker("Editing mode", selection: Binding(get: { model.mode }, set: model.changeMode)) {
                            ForEach(EditorMode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }.pickerStyle(.segmented).controlSize(.small).frame(width: 146)
                            .accessibilityIdentifier("mac-editor-mode")
                        Divider().frame(height: 16).accessibilityHidden(true)
                        Group {
                            if model.mode == .crop { cropTools }
                            else {
                                Toggle(isOn: Binding(get: { model.tool == .select }, set: { if $0 { model.tool = .select } })) {
                                    markupLabel("Select", symbol: "cursorarrow")
                                }
                                .toggleStyle(.button).buttonStyle(.borderless).controlSize(.regular).labelStyle(.iconOnly)
                                .help("Select an annotation").accessibilityIdentifier("mac-tool-select")
                                MacMarkupMenu(title: model.lastShape.rawValue, symbol: model.lastShape.symbol,
                                              identifier: "mac-shapes",
                                              value: model.tool == .annotation(model.lastShape) ? "Selected" : "Not selected",
                                              isSelected: model.tool == .annotation(model.lastShape),
                                              items: AnnotationKind.shapes.map { kind in
                                    .init(title: kind.rawValue, symbol: kind.symbol, action: { model.chooseTool(kind) })
                                }).frame(width: MacMarkupMenu.iconWidth, height: MacMarkupMenu.height)
                                drawingTool(.freehand)
                                Button { model.useTool(.text) } label: { markupLabel(AnnotationKind.text.rawValue, symbol: AnnotationKind.text.symbol) }
                                    .buttonStyle(.borderless).controlSize(.regular).labelStyle(.iconOnly)
                                    .help("Add an editable text label at the center of the crop")
                                    .accessibilityIdentifier("mac-tool-text")
                                Button { model.useTool(.pixelate) } label: { markupLabel(AnnotationKind.pixelate.rawValue, symbol: AnnotationKind.pixelate.symbol) }
                                    .buttonStyle(.borderless).controlSize(.regular).labelStyle(.iconOnly)
                                    .help("Add an editable pixelation region at the center of the crop")
                                    .accessibilityIdentifier("mac-tool-pixelate")
                            }
                        }
                        Divider().frame(height: 16).accessibilityHidden(true)
                        viewOptions
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Markup Toolbar")
                    .accessibilityIdentifier("mac-markup-controls")
                    Spacer(minLength: 0)
                }.frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder private var cropTools: some View {
        MacMarkupMenu(title: "Crop Preset", symbol: "aspectratio", identifier: "mac-crop-preset",
                      items: CropPreset.allCases.map { preset in
            .init(title: preset.rawValue, checked: model.preset == preset, action: { model.setPreset(preset) })
        } + [.init(title: "Reset Crop", symbol: "arrow.uturn.backward", action: model.resetCrop)])
            .frame(width: MacMarkupMenu.iconWidth, height: MacMarkupMenu.height)
        Button(action: revealCropDimensions) { markupLabel("Crop Dimensions", symbol: "ruler") }
            .buttonStyle(.borderless).controlSize(.regular).labelStyle(.iconOnly).accessibilityIdentifier("mac-crop-dimensions")
        Button(action: model.rotateLeft) { markupLabel("Rotate Left", symbol: "rotate.left") }
            .buttonStyle(.borderless).controlSize(.regular).labelStyle(.iconOnly).accessibilityIdentifier("mac-rotate-left")
    }

    private var viewOptions: some View {
        MacMarkupMenu(title: "\(Int(model.zoom * 100))%", symbol: "magnifyingglass", identifier: "mac-zoom",
                      value: "\(Int(model.zoom * 100))%", isSelected: model.tool == .pan, showsTitle: true, items: [
            .init(title: "Pan", symbol: "hand.draw", checked: model.tool == .pan,
                  action: { model.tool = model.tool == .pan ? .select : .pan }),
            .init(title: "Zoom Out", symbol: "minus.magnifyingglass", enabled: model.zoom > 1,
                  action: { model.setZoom(model.zoom / 1.5) }),
            .init(title: "Zoom In", symbol: "plus.magnifyingglass", enabled: model.zoom < 8,
                  action: { model.setZoom(model.zoom * 1.5) }),
            .init(title: "Fit to Window", symbol: "arrow.up.left.and.arrow.down.right", action: model.fit)
        ]).frame(width: MacMarkupMenu.zoomWidth, height: MacMarkupMenu.height)
    }

    private func drawingTool(_ kind: AnnotationKind) -> some View {
        Toggle(isOn: Binding(get: { model.tool == .annotation(kind) }, set: { selected in
            if selected { model.chooseTool(kind) } else { model.tool = .select }
        })) { markupLabel(kind.rawValue, symbol: kind.symbol) }
        .toggleStyle(.button).buttonStyle(.borderless).controlSize(.regular).labelStyle(.iconOnly)
        .help("Drag to add \(kind.displayName.lowercased())")
        .accessibilityIdentifier("mac-tool-" + kind.rawValue.lowercased().replacingOccurrences(of: " ", with: "-"))
    }


    private func markupLabel(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol)
            .labelStyle(.iconOnly).font(.body).imageScale(.medium)
            .frame(minWidth: 28, minHeight: 28)
            .contentShape(Rectangle())
    }

    private func revealCropDimensions() {
        showMarkup = true
        if model.mode != .crop { model.changeMode(.crop) }
        showInspector = true
    }

    private func chooseAnnotationTool(_ kind: AnnotationKind?) {
        showMarkup = true
        if model.mode != .annotate { model.changeMode(.annotate) }
        if let kind { model.useTool(kind) } else { model.tool = .select }
    }

    private func importFile(_ url: URL) { importImage { await $0.importFile(url) } }
    private func paste() {
        do {
            switch try MacPasteboard.input() {
            case .file(let url): importFile(url)
            case .providers(let providers): importImage { await $0.pasteImage(providers) }
            }
        } catch { model.error = error.localizedDescription }
    }
    private func copy() { Task { await model.copy() } }
    private func importImage(_ operation: @escaping @MainActor (EditorModel) async -> Void) {
        guard processing == nil else { return }
        guard workspace.canOpen else { model.error = DocumentWorkspace.LimitError.openLimit.localizedDescription; return }
        let id = UUID(); operationID = id
        let imported = EditorModel()
        processing = Task { @MainActor in
            defer { if operationID == id { processing = nil } }
            await operation(imported)
            guard !Task.isCancelled else { return }
            if let error = imported.error { model.error = error; return }
            do { try workspace.add(imported); showInspector = true } catch { model.error = error.localizedDescription }
        }
    }
    private func requestCloseImage() {
        guard let id = workspace.selectedID else { return }
        model.finishInspectorTransaction()
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--mac-ui-testing") { NSLog("MAC_CLOSE dirty=%d width=%g height=%g", model.hasUnsavedChanges ? 1 : 0, model.edit.crop.width, model.edit.crop.height) }
        #endif
        if model.hasUnsavedChanges { closeRequest = .image(id) } else { closeDocument(id) }
    }
    private func export(saveBeforeClose: Bool) {
        guard let id = workspace.selectedID, let source = model.source else { return }
        model.finishInspectorTransaction()
        exportRequest = ExportRequest(documentID: id, source: source, edits: model.edit, saveBeforeClose: saveBeforeClose)
    }
    private func presentCloseDialog(_ request: CloseRequest) {
        guard let window else { model.error = "The editor window is not ready. Try closing again."; closeRequest = nil; return }
        model.finishInspectorTransaction()
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Save changes before closing?"
        alert.informativeText = "Save a new PNG or JPEG to keep your edits. Your original stays unchanged."
        alert.addButton(withTitle: "Save a Copy…")
        alert.addButton(withTitle: "Discard Changes")
        alert.addButton(withTitle: "Cancel")
        closeAlert = alert
        alert.beginSheetModal(for: window) { response in
            closeRequest = nil; closeAlert = nil
            switch response {
            case .alertFirstButtonReturn: startCloseSave(request)
            case .alertSecondButtonReturn: discard(request)
            default: closeWindowAfterSave = false; MacWindowCloseRegistry.shared.cancelTermination()
            }
        }
    }
    private func finishWindowClose() {
        guard !finishingWindowClose, let window else { return }
        finishingWindowClose = true
        Task { @MainActor in
            // Sheet completions may run before the sheet has detached. Closing in that interval
            // is ignored by AppKit, so finish the already-approved close once the window is ready.
            for _ in 0..<50 {
                if window.attachedSheet == nil { break }
                do { try await Task.sleep(for: .milliseconds(20)) }
                catch {
                    finishingWindowClose = false; closeWindowAfterSave = false
                    MacWindowCloseRegistry.shared.cancelTermination()
                    return
                }
            }
            guard window.attachedSheet == nil else {
                finishingWindowClose = false; closeWindowAfterSave = false
                MacWindowCloseRegistry.shared.cancelTermination()
                model.error = "Close the open sheet, then try closing the window again. Your images are still open."
                return
            }
            allowWindowClose = true
            MacWindowCloseRegistry.shared.allowClose(window)
            // This decision was already confirmed; do not enter the close gate for a second time.
            window.close()
        }
    }
    private func startCloseSave(_ request: CloseRequest) {
        switch request {
        case .image(let id): workspace.select(id); closeWindowAfterSave = false; export(saveBeforeClose: true)
        case .window:
            closeWindowAfterSave = true
            if let document = workspace.documents.first(where: { $0.model.hasUnsavedChanges }) {
                workspace.select(document.id); export(saveBeforeClose: true)
            } else { finishWindowClose() }
        }
    }
    private func discard(_ request: CloseRequest) {
        switch request {
        case .image(let id): closeDocument(id)
        case .window: processing?.cancel(); finishWindowClose()
        }
    }
    private func closeDocument(_ id: UUID, thenWindow: Bool = false) {
        Task {
            do {
                let warning = try await workspace.closeDocument(id)
                if let warning { model.error = warning }
                if thenWindow { startCloseSave(.window) }
            } catch { closeWindowAfterSave = false; MacWindowCloseRegistry.shared.cancelTermination(); model.error = error.localizedDescription }
        }
    }
    private func isCancelled(_ error: Error) -> Bool { let e = error as NSError; return e.domain == NSCocoaErrorDomain && e.code == CocoaError.userCancelled.rawValue }
}

/// The editor must not retain its owning window and thereby keep closed image sources alive.
@MainActor private final class MacEditorWindowReference { weak var window: NSWindow? }
