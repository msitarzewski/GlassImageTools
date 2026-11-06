import SwiftUI
import AppKit
import VisionSnipCore

@MainActor struct MacEditorActions {
    let open: () -> Void
    let photos: () -> Void
    let paste: () -> Void
    let copy: () -> Void
    let export: () -> Void
    let closeImage: () -> Void
    let undo: () -> Void
    let redo: () -> Void
    let delete: () -> Void
    let zoomIn: () -> Void
    let zoomOut: () -> Void
    let fit: () -> Void
    let model: EditorModel
    let markupVisible: Bool
    let toggleMarkup: () -> Void
    let revealMarkup: () -> Void
    let cropDimensions: () -> Void
    let annotationTool: (AnnotationKind?) -> Void
}

extension FocusedValues { @Entry var macEditorActions: MacEditorActions? }

struct MacEditorCommands: Commands {
    @FocusedValue(\.macEditorActions) private var actions
    @Environment(\.openWindow) private var openWindow
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Window") { openWindow(id: "mac-editor") }.keyboardShortcut("n")
            Button("Open…") { actions?.open() }.keyboardShortcut("o").disabled(actions == nil)
            Button("Choose from Photos…") { actions?.photos() }.disabled(actions == nil)
        }
        CommandGroup(after: .saveItem) {
            Button("Export Image…") { actions?.export() }.keyboardShortcut("s").disabled(actions?.model.source == nil)
            if let model = actions?.model, let source = model.source {
                ShareLink(item: EditedImageTransfer(source: source, edits: model.edit), preview: SharePreview("Edited Image"))
            }
            Button("Close Image") { actions?.closeImage() }.keyboardShortcut("w", modifiers: [.command, .shift]).disabled(actions?.model.source == nil)
        }
        CommandGroup(replacing: .undoRedo) {
            Button("Undo") {
                if let text = NSApp.keyWindow?.firstResponder as? NSTextView, text.undoManager?.canUndo == true { text.undoManager?.undo() }
                else { actions?.undo() }
            }.keyboardShortcut("z").disabled(actions == nil)
            Button("Redo") {
                if let text = NSApp.keyWindow?.firstResponder as? NSTextView, text.undoManager?.canRedo == true { text.undoManager?.redo() }
                else { actions?.redo() }
            }.keyboardShortcut("z", modifiers: [.command, .shift]).disabled(actions == nil)
        }
        CommandGroup(replacing: .pasteboard) {
            Button("Cut") { if let text = NSApp.keyWindow?.firstResponder as? NSTextView { text.cut(nil) } }.keyboardShortcut("x")
            Button("Copy") {
                if let text = NSApp.keyWindow?.firstResponder as? NSTextView { text.copy(nil) }
                else { actions?.copy() }
            }.keyboardShortcut("c")
            Button("Paste") {
                if let text = NSApp.keyWindow?.firstResponder as? NSTextView { text.paste(nil) }
                else { actions?.paste() }
            }.keyboardShortcut("v")
            Button("Delete Annotation") {
                if let text = NSApp.keyWindow?.firstResponder as? NSTextView { text.deleteBackward(nil) }
                else { actions?.delete() }
            }.keyboardShortcut(.delete, modifiers: [])
        }
        CommandGroup(after: .textEditing) {
            Button("Select All") { NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil) }
                .keyboardShortcut("a")
        }
        CommandGroup(after: .toolbar) {
            Button(actions?.markupVisible == true ? "Hide Markup Toolbar" : "Show Markup Toolbar") {
                actions?.toggleMarkup()
            }.keyboardShortcut("m", modifiers: [.command, .shift]).disabled(actions?.model.source == nil)
            Toggle("Pan", isOn: Binding(get: { actions?.model.tool == .pan }, set: { enabled in
                actions?.model.tool = enabled ? .pan : .select
            })).disabled(actions?.model.source == nil)
            Button("Zoom In") { actions?.zoomIn() }.keyboardShortcut("+")
                .disabled(actions?.model.source == nil || (actions?.model.zoom ?? 8) >= 8)
            Button("Zoom Out") { actions?.zoomOut() }.keyboardShortcut("-")
                .disabled(actions?.model.source == nil || (actions?.model.zoom ?? 1) <= 1)
            Button("Fit to Window") { actions?.fit() }.keyboardShortcut("0").disabled(actions?.model.source == nil)
        }
        CommandMenu("Image") {
            Group {
                Picker("Editing Mode", selection: Binding(get: { actions?.model.mode ?? .crop }, set: { mode in
                    actions?.revealMarkup(); actions?.model.changeMode(mode)
                })) {
                    ForEach(EditorMode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                Divider()
                Menu("Crop") {
                    Picker("Preset", selection: Binding(get: { actions?.model.preset ?? .freeform }, set: { preset in
                        actions?.revealMarkup()
                        if actions?.model.mode != .crop { actions?.model.changeMode(.crop) }
                        actions?.model.setPreset(preset)
                    })) {
                        ForEach(CropPreset.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    Button("Crop Dimensions…") { actions?.cropDimensions() }
                    Button("Reset Crop") { actions?.model.resetCrop() }
                }
                Button("Rotate Left", systemImage: "rotate.left") { actions?.model.rotateLeft() }
                Divider()
                Button("Select", systemImage: "cursorarrow") { actions?.annotationTool(nil) }
                Menu("Shapes") {
                    ForEach(AnnotationKind.shapes, id: \.self) { kind in
                        Button(kind.rawValue, systemImage: kind.symbol) { actions?.annotationTool(kind) }
                    }
                }
                ForEach([AnnotationKind.freehand, .text, .pixelate], id: \.self) { kind in
                    Button(kind.rawValue, systemImage: kind.symbol) { actions?.annotationTool(kind) }
                }
            }.disabled(actions?.model.source == nil)
        }
    }
}
