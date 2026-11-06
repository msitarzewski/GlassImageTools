import SwiftUI
import AppKit

/// A standard AppKit pop-up keeps its full-size symbol and target in SwiftUI's accessory toolbar.
/// SwiftUI Menu is otherwise synthesized as a compact toolbar item, ignoring its label geometry.
struct MacMarkupMenu: NSViewRepresentable {
    static let height: CGFloat = 28
    static let iconWidth: CGFloat = 40
    static let zoomWidth: CGFloat = 90
    struct Item {
        var title: String
        var symbol: String? = nil
        var enabled = true
        var checked = false
        var action: () -> Void
    }
    var title: String
    var symbol: String
    var identifier: String
    var value: String? = nil
    var isSelected = false
    var showsTitle = false
    var items: [Item]

    func makeCoordinator() -> Coordinator { Coordinator() }
    func makeNSView(context: Context) -> NSPopUpButton {
        let button = NSPopUpButton(frame: .zero, pullsDown: true)
        button.isBordered = false
        button.bezelStyle = .recessed
        button.controlSize = .regular
        button.imageScaling = .scaleProportionallyDown
        if let cell = button.cell as? NSPopUpButtonCell { cell.arrowPosition = .arrowAtBottom }
        return button
    }
    func updateNSView(_ button: NSPopUpButton, context: Context) {
        let menu = NSMenu()
        let label = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        label.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)?
            .withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 14, weight: .regular))
        menu.addItem(label)
        context.coordinator.items = items
        for item in items {
            let entry = NSMenuItem(title: item.title, action: nil, keyEquivalent: "")
            entry.isEnabled = item.enabled
            entry.state = item.checked ? .on : .off
            if let symbol = item.symbol { entry.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil) }
            menu.addItem(entry)
        }
        menu.autoenablesItems = false
        button.menu = menu
        button.target = context.coordinator
        button.action = #selector(Coordinator.choose(_:))
        button.contentTintColor = isSelected ? .controlAccentColor : nil
        button.imagePosition = showsTitle ? .imageLeading : .imageOnly
        button.setAccessibilityLabel(showsTitle ? "Zoom and View" : title)
        button.setAccessibilityIdentifier(identifier)
        if let value { button.setAccessibilityValue(value) }
        button.toolTip = showsTitle ? "Zoom and View" : title
    }
    func sizeThatFits(_ proposal: ProposedViewSize, nsView: NSPopUpButton, context: Context) -> CGSize? {
        CGSize(width: showsTitle ? Self.zoomWidth : Self.iconWidth, height: Self.height)
    }
    @MainActor final class Coordinator: NSObject {
        var items: [Item] = []
        @objc func choose(_ sender: NSPopUpButton) {
            let index = sender.indexOfSelectedItem - 1
            guard items.indices.contains(index), items[index].enabled else { return }
            items[index].action()
        }
    }
}
