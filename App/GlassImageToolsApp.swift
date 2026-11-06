import SwiftUI

@main
struct GlassImageToolsApp: App {
    var body: some Scene {
        WindowGroup("Glass Image Tools", id: "editor") {
            EditorWindow()
        }
        .windowStyle(.plain)
        .defaultSize(width: initialWindowSize.width, height: initialWindowSize.height)
        .windowResizability(.contentMinSize)
        .commands { EditorCommands() }
    }
    private var initialWindowSize: CGSize {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--ui-test-minimum-window") {
            return CGSize(width: 720, height: 540)
        }
        #endif
        return CGSize(width: 1100, height: 760)
    }
}

