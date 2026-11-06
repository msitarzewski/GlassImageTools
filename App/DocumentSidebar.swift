import SwiftUI
import VisionSnipCore

/// Native List rows keep categories and documents in one selectable, vertically laid-out hierarchy.
struct DocumentSidebar: View {
    @Bindable var workspace: DocumentWorkspace
    let onSelect: (UUID) -> Void
    let onClose: (UUID) -> Void
    let onReopen: (UUID) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var openImagesExpanded = true
    @State private var recentsExpanded = false

    var body: some View {
        List(selection: Binding(get: { workspace.selectedID }, set: { if let id = $0 { onSelect(id) } })) {
            Group {
                category("Open Images", symbol: "photo.stack", count: workspace.documents.count, expanded: $openImagesExpanded)
                if openImagesExpanded {
                    if workspace.documents.isEmpty {
                        Text("No Open Images").foregroundStyle(.secondary).padding(.leading, 32)
                    }
                    ForEach(workspace.documents) { document in
                        if let source = document.model.source {
                            DocumentRow(source: source, modified: document.model.hasUnsavedChanges)
                                .padding(.leading, 32)
                                .tag(document.id)
                                .accessibilityIdentifier("open-document-\(document.id)")
                                .contextMenu { Button("Close Image", systemImage: "xmark") { onClose(document.id) } }
                        }
                    }
                }
                category("Recents", symbol: "clock", count: workspace.recents.count, expanded: $recentsExpanded)
                if recentsExpanded {
                    if workspace.recents.isEmpty {
                        Text("No Recent Images").foregroundStyle(.secondary).padding(.leading, 32)
                    } else {
                        ForEach(workspace.recents) { recent in
                            Button { onReopen(recent.id) } label: { DocumentRow(source: recent.source).padding(.leading, 32) }
                                .accessibilityIdentifier("recent-document-\(recent.id)")
                        }
                        Button("Clear Recents", systemImage: "trash", role: .destructive, action: workspace.clearRecents)
                            .accessibilityIdentifier("clear-recents")
                        Text("Available in this window until you quit.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 60)
        .scrollContentBackground(.hidden)
        .contentMargins(.bottom, ImageWindowAppearance.bottomOrnamentClearance, for: .scrollContent)
        .accessibilityIdentifier("document-sidebar")
    }

    // visionOS's automatic DisclosureGroup lays expanded content inline. Keep child rows directly
    // in the List so its standard selection, scrolling and accessibility continue to apply.
    private func category(_ title: String, symbol: String, count: Int, expanded: Binding<Bool>) -> some View {
        Button {
            withAnimation(reduceMotion ? nil : .default) { expanded.wrappedValue.toggle() }
        } label: {
            HStack {
                Label { Text(title).foregroundStyle(.primary) } icon: { Image(systemName: symbol).foregroundStyle(.tint) }
                Spacer(minLength: 8)
                if count > 0 { Text(count, format: .number).foregroundStyle(.secondary).monospacedDigit() }
                Image(systemName: expanded.wrappedValue ? "chevron.down" : "chevron.forward")
                    .imageScale(.small).foregroundStyle(.secondary)
            }
            .font(.body)
            .contentShape(Rectangle())
        }
        .accessibilityLabel(title)
        .accessibilityValue(Text("\(count) images, \(expanded.wrappedValue ? "Expanded" : "Collapsed")"))
    }
}

/// Compact bookmark-style entries; the List owns target sizing and selection.
private struct DocumentRow: View {
    let source: ImageSource
    var modified = false

    var body: some View {
        HStack {
            Label {
                Text(source.name).lineLimit(1).truncationMode(.middle)
            } icon: {
                Image(systemName: "photo").foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            if modified {
                Image(systemName: "circle.fill")
                    .font(.system(size: 6))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(Text(modified ? "\(source.typeLabel), Edited" : source.typeLabel))
    }
}
