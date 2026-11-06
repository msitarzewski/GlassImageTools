import SwiftUI
import AppKit

/// Intercept only edited-window closure; forward other AppKit callbacks to SwiftUI's existing delegate.
struct MacWindowCloseGuard: NSViewRepresentable {
    let canClose: @MainActor () -> Bool
    let edited: Bool
    let onWindow: (NSWindow) -> Void
    let requestClose: () -> Void
    let requestSaveAndClose: @MainActor () -> Void
    func makeCoordinator() -> Coordinator { Coordinator() }
    func makeNSView(context: Context) -> NSView { NSView() }
    func updateNSView(_ view: NSView, context: Context) {
        context.coordinator.readCanClose = canClose
        context.coordinator.requestClose = requestClose
        context.coordinator.requestSaveAndClose = requestSaveAndClose
        DispatchQueue.main.async { [weak view, weak coordinator = context.coordinator] in
            guard let window = view?.window, let coordinator else { return }
            coordinator.window = window
            MacWindowCloseRegistry.shared.register(coordinator)
            if window.delegate !== coordinator { coordinator.previous = window.delegate; window.delegate = coordinator }
            let isEdited = edited && !coordinator.forcedClose
            if window.isDocumentEdited != isEdited { window.isDocumentEdited = isEdited }
            onWindow(window)
        }
    }
    final class Coordinator: NSObject, NSWindowDelegate {
        weak var window: NSWindow?
        weak var previous: (any NSWindowDelegate)?
        var readCanClose: (@MainActor () -> Bool)?
        var forcedClose = false
        @MainActor var canClose: Bool { forcedClose || (readCanClose?() ?? true) }
        var requestClose: (() -> Void)?
        var requestSaveAndClose: (@MainActor () -> Void)?
        func windowShouldClose(_ sender: NSWindow) -> Bool {
            guard canClose else { requestClose?(); return false }
            return previous?.windowShouldClose?(sender) ?? true
        }
        func windowWillClose(_ notification: Notification) {
            previous?.windowWillClose?(notification)
            MacWindowCloseRegistry.shared.closed(self)
        }
        override func responds(to selector: Selector!) -> Bool { super.responds(to: selector) || previous?.responds(to: selector) == true }
        override func forwardingTarget(for selector: Selector!) -> Any? { previous?.responds(to: selector) == true ? previous : super.forwardingTarget(for: selector) }
    }
}
