import SwiftUI

/// Interaction dimensions and keyboard/hover affordances belong to each platform, never source pixels.
enum EditorPlatform {
    #if os(macOS)
    static let canvasInset: CGFloat = 20
    static let controlTarget: CGFloat = 20
    static let hitTolerance: CGFloat = 6
    static let bottomClearance: CGFloat = 0
    #else
    static let canvasInset: CGFloat = 36
    static let controlTarget: CGFloat = 60
    static let hitTolerance: CGFloat = 30
    static let bottomClearance: CGFloat = ImageWindowAppearance.bottomOrnamentClearance
    #endif
}

extension View {
    @ViewBuilder func editorNumericKeyboard() -> some View {
        #if os(visionOS)
        keyboardType(.numberPad)
        #else
        self // Mac text fields use the hardware keyboard and their existing numeric formatter.
        #endif
    }
    @ViewBuilder func editorHover(isEnabled: Bool = true) -> some View {
        #if os(visionOS)
        hoverEffect(.highlight, isEnabled: isEnabled)
        #else
        self // Pointer interaction uses native Mac controls; no gaze highlight surface is added.
        #endif
    }
}

extension View {
    @ViewBuilder func editorContextMenu<Items: View, Preview: View>(@ViewBuilder items: () -> Items,
        @ViewBuilder preview: () -> Preview) -> some View {
        #if os(visionOS)
        contextMenu(menuItems: items, preview: preview)
        #else
        contextMenu(menuItems: items)
        #endif
    }
}
