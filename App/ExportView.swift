import SwiftUI
import Accessibility
import VisionSnipCore

struct ExportView: View {
    let source: ImageSource
    let edits: EditState
    var saveBeforeContinuing = false
    var onSaved: ((ExportedImage) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var format = ExportFormat.png
    @State private var quality = 0.9
    @State private var output: ExportedImage?
    @State private var document: ExportFile?
    @State private var showFiles = false
    @State private var isSaving = false
    @State private var isPreparing = true
    @State private var preparedKey: String?
    @State private var status: String?
    @State private var error: String?
    @State private var fileSaveOutput: ExportedImage?

    private var renderKey: String { "\(format.rawValue)-\(format == .jpeg ? quality : 1)" }
    private var preparedOutput: ExportedImage? { preparedKey == renderKey ? output : nil }
    var body: some View {
        NavigationStack {
            Form {
                Section("Image") {
                    Picker("Format", selection: $format) {
                        ForEach(ExportFormat.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.menu).accessibilityIdentifier("export-format")
                    if format == .jpeg {
                        LabeledContent("JPEG Quality", value: "\(Int((quality * 100).rounded()))%")
                        Slider(value: $quality, in: 0.1...1, step: 0.1) { Text("JPEG Quality") }
                            .accessibilityIdentifier("export-quality")
                            .accessibilityValue("\(Int((quality * 100).rounded())) percent")
                        Text("Transparency is flattened onto white.").foregroundStyle(.secondary)
                    }
                    let size = edits.rotation.size(for: CropGeometry.pixelAligned(edits.crop, in: source.bounds).size)
                    LabeledContent("Dimensions", value: "\(Int(size.width)) × \(Int(size.height)) pixels")
                    if let output = preparedOutput {
                        LabeledContent("File Size", value: ByteCountFormatter.string(fromByteCount: Int64(output.byteCount), countStyle: .file))
                            .accessibilityIdentifier("export-size")
                    } else if isPreparing || preparedKey != renderKey { ProgressView("Preparing full-resolution image…") }
                    else { Text("The image could not be prepared. Try another format or close this sheet.").foregroundStyle(.secondary) }
                }
                Section {
                    if let output = preparedOutput {
                        if !saveBeforeContinuing {
                            ShareLink(item: output.url) { Label("Share…", systemImage: "square.and.arrow.up") }
                            .accessibilityIdentifier("share-image")
                        }
                        Button(saveFileLabel, systemImage: "folder") {
                            fileSaveOutput = output; showFiles = true
                        }
                            .disabled(document == nil).accessibilityIdentifier("save-files")
                        Button("Save New Image to Photos", systemImage: "photo.badge.plus") {
                            isSaving = true; error = nil
                            Task {
                                do {
                                    try await ExportService.saveToPhotos(output)
                                    announceStatus("Saved a new image to Photos.")
                                    onSaved?(output)
                                }
                                catch { self.error = error.localizedDescription }
                                isSaving = false
                            }
                        }.accessibilityIdentifier("save-photos")
                        if !saveBeforeContinuing { Button("Copy Image", systemImage: "doc.on.doc") {
                            if let document {
                                if ClipboardService.copy(document.data, format: output.format) { announceStatus("Copied image.") }
                                else { error = "The image could not be copied. Try Copy again or save a new file." }
                            }
                        }.accessibilityIdentifier("export-copy-image") }
                    }
                    if isSaving { ProgressView("Saving…") }
                    if let status { Text(status).foregroundStyle(.secondary) }
                } footer: {
                    Text("A new image is created locally. Your original is never overwritten. Location and camera metadata are excluded.")
                }
                .disabled(isSaving)
            }
            .formStyle(.grouped)
            .navigationTitle(saveBeforeContinuing ? "Save a Copy" : "Export Image")
            .toolbar {
                if saveBeforeContinuing {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) { dismiss() }
                            .disabled(isSaving).keyboardShortcut(.cancelAction)
                    }
                } else {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }.disabled(isSaving).keyboardShortcut(.defaultAction)
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 440, idealWidth: 480, minHeight: 420)
        #endif
        .presentationSizing(.form)
        .interactiveDismissDisabled(isSaving)
        .task(id: renderKey) {
            let key = renderKey, chosenFormat = format, chosenQuality = quality
            output = nil; document = nil; preparedKey = nil; status = nil; error = nil; isPreparing = true
            do {
                // Native quality controls can change rapidly; render only the settled selection.
                try await Task.sleep(for: .milliseconds(250))
                let image = try await ImageExportQueue.shared.export(source, edits: edits,
                    format: chosenFormat, quality: chosenQuality)
                try Task.checkCancellation()
                let file = try await Task.detached {
                    try ExportFile(url: image.url)
                }.value
                try Task.checkCancellation()
                guard key == renderKey else { return }
                output = image; document = file; preparedKey = key; isPreparing = false
            } catch is CancellationError {
                // A newer request owns the sheet's progress and error state.
            } catch {
                guard !Task.isCancelled, key == renderKey else { return }
                isPreparing = false; preparedKey = key; self.error = error.localizedDescription
            }
        }
        .fileExporter(isPresented: $showFiles, document: document, contentType: format.type,
                      defaultFilename: suggestedFilename) { result in
            switch result {
            case .success:
                guard let output = fileSaveOutput else { return }
                announceStatus("Saved a new image to Files."); onSaved?(output)
            case .failure(let error):
                let cocoa = error as NSError
                if cocoa.domain != NSCocoaErrorDomain || cocoa.code != CocoaError.userCancelled.rawValue {
                    self.error = error.localizedDescription
                }
            }
            fileSaveOutput = nil
        }
        .alert("Unable to Export", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
            Button("OK", role: .cancel) { error = nil }
        } message: { Text(error ?? "") }
    }
    private var saveFileLabel: String {
        #if os(macOS)
        "Save As…"
        #else
        "Save to Files…"
        #endif
    }
    private var suggestedFilename: String {
        #if os(macOS)
        let stem = URL(fileURLWithPath: source.name).deletingPathExtension().lastPathComponent
        return (stem.isEmpty ? "Edited Image" : stem + " Edited") + "." + format.fileExtension
        #else
        return "Glass Image Tools.\(format.fileExtension)"
        #endif
    }
    private func announceStatus(_ message: String) {
        status = message
        AccessibilityNotification.Announcement(message).post()
    }
}

