import SwiftUI

@main
struct CaptureProbeApp: App {
    @Environment(\.scenePhase) private var scenePhase
    #if canImport(ScreenCaptureKit)
    @State private var probe = CaptureCapabilityProbe()
    #endif
    var body: some Scene {
        WindowGroup("Capture Research") {
            Group {
            #if canImport(ScreenCaptureKit)
            if let source = probe.captured {
                EditorWindow(initialSource: source)
                    .toolbar { ToolbarItem(placement: .bottomOrnament) {
                        Button("Capture Research", systemImage: "chevron.backward") { probe.captured = nil }
                    } }
            } else {
                NavigationStack {
                    Form {
                        Section("System Authorization") {
                            LabeledContent("Capture Available", value: probe.available ? "Yes" : "No")
                                .accessibilityIdentifier("capture-available")
                            Button("Capture This Application…") { probe.chooseSource(ownApplication: true) }
                                .disabled(!probe.canChooseSource).accessibilityIdentifier("capture-own-app")
                            Button("Choose Content with System Picker…") { probe.chooseSource(ownApplication: false) }
                                .disabled(!probe.canChooseSource).accessibilityIdentifier("capture-system-picker")
                            Button("Freeze Next Frame") { probe.freezeFrame() }.disabled(!probe.active || probe.isFreezing)
                            Button("Stop Capture") { Task { await probe.stop() } }.disabled(!probe.canStop)
                        }
                        Section("Status") { Text(probe.status).textSelection(.enabled) }
                        Section("Probe Log") {
                            ForEach(Array(probe.events.enumerated()), id: \.offset) { _, event in
                                Text(event).font(.caption).textSelection(.enabled)
                            }
                        }
                        Section {
                            Text("Experimental. A successful build or simulator result does not establish physical-device support. No passthrough or enterprise entitlement is requested. The system decides which sources may be shared.")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .navigationTitle("Glass Image Tools Capture Research")
                }
            }
            #else
            ContentUnavailableView("Capture Requires a Physical Device",
                systemImage: "video.slash",
                description: Text("ScreenCaptureKit is absent from this simulator SDK. Build this research target for a Vision Pro running visionOS 27 or later. No capture capability is confirmed by this screen."))
                .frame(width: 650, height: 400)
            #endif
            }
            #if canImport(ScreenCaptureKit)
            .onDisappear { Task { await probe.stop() } }
            .onChange(of: scenePhase) { _, phase in
                if phase == .background { Task { await probe.stop() } }
            }
            #endif
        }.defaultSize(width: 1100, height: 760)
        // The shared editor's + opens an ordinary image workspace, separate from capture research.
        WindowGroup("Glass Image Tools", id: "editor") { EditorWindow() }
            .windowStyle(.plain)
            .defaultSize(width: 1100, height: 760)
            .windowResizability(.contentMinSize)
            .commands { EditorCommands() }
    }
}
