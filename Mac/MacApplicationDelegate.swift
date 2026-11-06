import AppKit

@MainActor final class MacApplicationDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        MacWindowCloseRegistry.shared.requestTermination()
    }
}

/// Ask natively before entering AppKit termination. Saving runs with termination cancelled so
/// SwiftUI can present its sheets; once every edited window is saved, issue a normal Quit again.
@MainActor final class MacWindowCloseRegistry {
    static let shared = MacWindowCloseRegistry()
    private struct Entry { weak var coordinator: MacWindowCloseGuard.Coordinator? }
    private var entries: [Entry] = []
    private var savingBeforeQuit = false
    private var askingToQuit = false
    private weak var savingWindow: MacWindowCloseGuard.Coordinator?

    func register(_ coordinator: MacWindowCloseGuard.Coordinator) {
        entries.removeAll { $0.coordinator == nil }
        if !entries.contains(where: { $0.coordinator === coordinator }) { entries.append(Entry(coordinator: coordinator)) }
    }
    func allowClose(_ window: NSWindow?) {
        guard let window else { return }
        for entry in entries where entry.coordinator?.window === window { entry.coordinator?.forcedClose = true }
        window.isDocumentEdited = false
    }
    func closed(_ coordinator: MacWindowCloseGuard.Coordinator) {
        entries.removeAll { $0.coordinator == nil || $0.coordinator === coordinator }
        guard savingBeforeQuit, savingWindow === coordinator else { return }
        savingWindow = nil
        // Let SwiftUI finish releasing the closed window before advancing to another save or Quit.
        DispatchQueue.main.async { self.saveNextWindow() }
    }
    func requestTermination() -> NSApplication.TerminateReply {
        guard !savingBeforeQuit, !askingToQuit else { return .terminateCancel }
        guard let first = dirtyWindows.first, let window = first.window else { return .terminateNow }
        window.makeKeyAndOrderFront(nil)
        // A pending save/close sheet already owns the decision. Keep the app responsive until it ends.
        guard window.attachedSheet == nil else { return .terminateCancel }
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Save changes before quitting?"
        alert.informativeText = "Save a new PNG or JPEG for each edited image to keep your changes. Your originals stay unchanged."
        alert.addButton(withTitle: "Save a Copy…")
        let discard = alert.addButton(withTitle: "Discard Changes")
        discard.hasDestructiveAction = true
        alert.addButton(withTitle: "Cancel")
        askingToQuit = true
        defer { askingToQuit = false }
        switch alert.runModal() {
        case .alertFirstButtonReturn:
            savingBeforeQuit = true
            DispatchQueue.main.async { self.saveNextWindow() }
            return .terminateCancel
        case .alertSecondButtonReturn:
            return .terminateNow
        default:
            return .terminateCancel
        }
    }
    func cancelTermination() {
        savingBeforeQuit = false
        savingWindow = nil
    }
    private var dirtyWindows: [MacWindowCloseGuard.Coordinator] {
        entries.compactMap(\.coordinator).filter { $0.window != nil && !$0.canClose }
    }
    private func saveNextWindow() {
        guard savingBeforeQuit, savingWindow == nil else { return }
        guard let next = dirtyWindows.first else {
            savingBeforeQuit = false
            NSApp.terminate(nil)
            return
        }
        guard let save = next.requestSaveAndClose else {
            cancelTermination()
            let alert = NSAlert()
            alert.messageText = "Unable to Save Before Quitting"
            alert.informativeText = "Close and save the edited images, then try Quit again. Your images are still open."
            alert.runModal()
            return
        }
        savingWindow = next
        next.window?.makeKeyAndOrderFront(nil)
        save()
    }
}
