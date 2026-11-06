import SwiftUI

@main struct GlassImageToolsMacApp: App {
    @NSApplicationDelegateAdaptor(MacApplicationDelegate.self) private var delegate
    var body: some Scene {
        WindowGroup("Glass Image Tools", id: "mac-editor") {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--sandbox-probe") { MacSandboxProbe() }
            else { MacEditorView() }
            #else
            MacEditorView()
            #endif
        }
            .defaultSize(width: 1180, height: 780)
            .commands { MacEditorCommands(); SidebarCommands(); InspectorCommands() }
        Settings { MacSettingsView() }
    }
}

struct MacSettingsView: View {
    var body: some View {
        TabView {
            Form {
                Section("Images") {
                    Text("Crop, annotations and exports are processed on your Mac. Your original stays unchanged.")
                    Text("Pasting an HTTPS image link requests that image from its host. No image is uploaded; downloads use no cookies, credentials or persistent cache.")
                }
                Section("Storage") { Text("Open Images and Recents last for the window’s session. Save a PNG or JPEG copy to keep your edits.") }
            }.formStyle(.grouped).tabItem { Label("General", systemImage: "gearshape") }
            AboutSettings().tabItem { Label("About", systemImage: "info.circle") }
        }.frame(width: 520, height: 400)
    }
}
