import SwiftUI
import UniformTypeIdentifiers
import UIKit

/// The empty editor offers system import controls and an explicit image-only drop destination.
struct ImageStartView: View {
    let onPhotos: () -> Void
    let onFiles: () -> Void
    let onDrop: ([NSItemProvider]) -> Bool
    let onPaste: () -> Void
    @State private var isDropTargeted = false
    #if DEBUG
    @State private var dropTestProvider: NSItemProvider?
    @State private var dropTestError: String?
    @State private var dragStarted = false
    @State private var dropWasTargeted = false
    #endif

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Open an Image")
                            .font(.largeTitle.bold()).accessibilityAddTraits(.isHeader)
                        Text("Crop, mark up and share a screenshot or photo.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    #if DEBUG
                    if let dropTestProvider {
                        Text("Drag Example Image")
                            .padding(12)
                            .onDrag {
                                dragStarted = true
                                return dropTestProvider
                            }
                            .accessibilityIdentifier("test-image-drag-source")
                        Text("Drag started: \(dragStarted). Target reached: \(dropWasTargeted).")
                            .font(.caption).accessibilityIdentifier("test-image-drag-status")
                    }
                    if let dropTestError { Text(dropTestError).accessibilityIdentifier("test-drop-error") }
                    #endif
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 20) { photos; files }
                        VStack(spacing: 20) { photos; files }
                    }
                    Button(action: onPaste) {
                        VStack(spacing: 16) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.largeTitle).foregroundStyle(.secondary)
                                .accessibilityHidden(true)
                            Text(isDropTargeted ? "Release to Open Image" : "Drop or Paste an Image")
                                .font(.headline)
                            Text("Drop an image here, or paste an image or HTTPS image link. Tap here or press ⌘V.")
                                .foregroundStyle(.secondary)
                        }
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 140)
                        .padding(20)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle)
                    .background { ImagePasteKeyboardTarget(onPaste: onPaste).accessibilityHidden(true) }
                    .overlay {
                        if isDropTargeted {
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(.tint, lineWidth: 3)
                                .allowsHitTesting(false).accessibilityHidden(true)
                        }
                    }
                    .contentShape(Rectangle())
                    .onDrop(of: [UTType.image], isTargeted: $isDropTargeted, perform: onDrop)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Paste Image")
                    .accessibilityHint("Drop an image here, or paste an image or HTTPS image link. Activate or press Command V.")
                    .accessibilityIdentifier("image-drop-target")
                    Text("Your original stays unchanged.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: 600)
                .padding(32)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
            .accessibilityIdentifier("image-start-screen")
            #if DEBUG
            .onChange(of: isDropTargeted) { _, targeted in
                guard ProcessInfo.processInfo.arguments.contains("--ui-testing"),
                      ProcessInfo.processInfo.arguments.contains("--ui-test-drop-source") else { return }
                if targeted { dropWasTargeted = true }
            }
            .task {
                guard ProcessInfo.processInfo.arguments.contains("--ui-testing"),
                      ProcessInfo.processInfo.arguments.contains("--ui-test-drop-source") else { return }
                do { dropTestProvider = try EditorTestFixture.imageDropProvider() }
                catch { dropTestError = error.localizedDescription }
            }
            #endif
        }
    }

    private var photos: some View {
        importWell("Photos", symbol: "photo.on.rectangle", identifier: "choose-photos", action: onPhotos)
            .accessibilityLabel("Choose from Photos")
    }
    private var files: some View {
        importWell("Files", symbol: "folder", identifier: "import-files", action: onFiles)
            .accessibilityLabel("Import from Files")
    }
    private func importWell(_ title: String, symbol: String, identifier: String,
                            action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: symbol).font(.largeTitle).accessibilityHidden(true)
                Text(title).font(.title3.weight(.semibold))
            }
            .frame(minWidth: 180, maxWidth: .infinity, minHeight: 120)
            .padding(16)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle)
        .controlSize(.extraLarge)
        .accessibilityIdentifier(identifier)
    }
}

/// The empty workspace is a keyboard destination, not a text editor. UIKit routes standard
/// Paste to this responder only while it owns focus; a real text field keeps its own responder.
private struct ImagePasteKeyboardTarget: UIViewRepresentable {
    let onPaste: () -> Void
    func makeUIView(context: Context) -> PasteResponder { PasteResponder(onPaste: onPaste) }
    func updateUIView(_ view: PasteResponder, context: Context) { view.onPaste = onPaste }

    final class PasteResponder: UIView {
        var onPaste: () -> Void
        init(onPaste: @escaping () -> Void) {
            self.onPaste = onPaste
            super.init(frame: .zero)
        }
        @available(*, unavailable) required init?(coder: NSCoder) { fatalError("Use init(onPaste:)") }
        override var canBecomeFirstResponder: Bool { true }
        override var keyCommands: [UIKeyCommand]? {
            [UIKeyCommand(title: "Paste Image", action: #selector(paste(_:)), input: "v", modifierFlags: .command)]
        }
        override func didMoveToWindow() {
            super.didMoveToWindow()
            if window != nil {
                DispatchQueue.main.async { [weak self] in
                    guard let self, self.window != nil else { return }
                    self.becomeFirstResponder()
                }
            } else { resignFirstResponder() }
        }
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool { false }
        override func paste(_ sender: Any?) { onPaste() }
    }
}
