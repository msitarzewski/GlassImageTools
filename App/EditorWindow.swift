import SwiftUI
import VisionSnipCore

/// Each window owns its native minimum independently of other open editor windows.
struct EditorWindow: View {
    var initialSource: ImageSource? = nil
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var minimumWidth: CGFloat = 720

    var body: some View {
        EditorView(initialSource: initialSource, minimumWindowWidth: $minimumWidth)
            .frame(minWidth: minimumWidth, minHeight: dynamicTypeSize.isAccessibilitySize ? 600 : 540)
    }
}

/// Actions the focused editor window offers to hardware-keyboard commands.
struct EditorCommandActions {
    let newWindow: () -> Void
    let showSettings: () -> Void
}

extension FocusedValues {
    @Entry var editorCommands: EditorCommandActions?
}

/// Scene commands own ⌘N and ⌘,. Shortcuts on controls inside a closed menu or a toolbar
/// ornament are not registered, so the keys act on the focused window from here instead.
struct EditorCommands: Commands {
    @FocusedValue(\.editorCommands) private var actions
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Window") { actions?.newWindow() }
                .keyboardShortcut("n").disabled(actions == nil)
        }
        CommandGroup(replacing: .appSettings) {
            Button("Settings…") { actions?.showSettings() }
                .keyboardShortcut(",").disabled(actions == nil)
        }
    }
}

