import SwiftUI
import VisionSnipCore

/// Per-window documents retain independent edit/history/viewport owners. Recents retain only images,
/// never vectors or history, and use the same protected process-temporary lifetime as imports.
@Observable @MainActor final class DocumentWorkspace {
    struct Document: Identifiable {
        let id = UUID()
        let model: EditorModel
        var savedOutput: ExportedImage?
    }
    struct Recent: Identifiable {
        let id = UUID()
        let source: ImageSource
    }
    enum LimitError: LocalizedError {
        case openLimit, storageLimit
        var errorDescription: String? {
            switch self {
            case .openLimit: "Close an image before opening another. Up to eight images can be open in this window."
            case .storageLimit: "These images exceed this window’s 512 MiB working limit. Close an image or clear Recents, then try again."
            }
        }
    }
    private(set) var documents: [Document] = []
    private(set) var recents: [Recent] = []
    private(set) var selectedID: UUID?
    let emptyModel = EditorModel()
    private let maximumDocuments: Int
    private let maximumBytes: Int
    init(source: ImageSource? = nil, maximumDocuments: Int = 8, maximumBytes: Int = 512 * 1024 * 1024) {
        self.maximumDocuments = maximumDocuments; self.maximumBytes = maximumBytes
        if let source {
            do { try add(EditorModel(source: source)) }
            catch { emptyModel.error = error.localizedDescription }
        }
    }
    var model: EditorModel { documents.first { $0.id == selectedID }?.model ?? emptyModel }
    var canOpen: Bool { documents.count < maximumDocuments }
    func select(_ id: UUID) {
        guard documents.contains(where: { $0.id == id }), selectedID != id else { return }
        model.finishInspectorTransaction(); model.annotationInspectorPresented = false
        selectedID = id
    }
    @discardableResult func add(_ model: EditorModel) throws -> UUID {
        guard let source = model.source else { throw ImageError.unreadable }
        guard canOpen else { throw LimitError.openLimit }
        let openCost = try cost(documents.compactMap { $0.model.source } + [source])
        guard openCost <= maximumBytes else { throw LimitError.storageLimit }
        // Eviction releases the source's protected private copy; open documents are never evicted.
        var retained = recents.filter { $0.source !== source }
        while !retained.isEmpty {
            let bytes = try cost(documents.compactMap { $0.model.source } + [source] + retained.map(\.source))
            if retained.count <= 8 && bytes <= maximumBytes { break }
            retained.removeLast()
        }
        self.model.finishInspectorTransaction(); self.model.annotationInspectorPresented = false
        let document = Document(model: model)
        documents.append(document); recents = retained; selectedID = document.id
        return document.id
    }
    func reopen(_ id: UUID) throws {
        guard let recent = recents.first(where: { $0.id == id }) else { return }
        try add(EditorModel(source: recent.source))
    }
    @discardableResult func recordSave(_ output: ExportedImage, documentID: UUID, source: ImageSource, edits: EditState) -> Bool {
        guard let index = documents.firstIndex(where: { $0.id == documentID }),
              documents[index].model.markSaved(source: source, edits: edits) else { return false }
        documents[index].savedOutput = output
        return true
    }
    /// A failed optional Recent copy must never trap a successfully saved/discarded image open.
    /// Cancellation keeps the document open; a real cache failure closes it and returns visible recovery.
    func closeDocument(_ id: UUID) async throws -> String? {
        guard let document = documents.first(where: { $0.id == id }), let source = document.model.source else { return nil }
        do {
            try Task.checkCancellation()
            let recentSource: ImageSource
            if let output = document.savedOutput {
                let name = URL(fileURLWithPath: source.name).deletingPathExtension().lastPathComponent + "." + output.format.fileExtension
                recentSource = try await ImageImportService.importFileAsync(output.url, name: name)
            } else { recentSource = source }
            try Task.checkCancellation()
            guard documents.first(where: { $0.id == id })?.model.source === source else { throw CancellationError() }
            try close(id, recentSource: recentSource)
            return nil
        } catch is CancellationError { throw CancellationError() }
        catch {
            try Task.checkCancellation()
            guard documents.first(where: { $0.id == id })?.model.source === source else { throw CancellationError() }
            try close(id, recentSource: nil)
            return "The image closed, but couldn’t be added to Recents. " + error.localizedDescription
        }
    }
    /// Caller supplies the last saved flattened copy, or original pixels when edits were discarded.
    func close(_ id: UUID, recentSource: ImageSource?) throws {
        guard let index = documents.firstIndex(where: { $0.id == id }) else { return }
        let document = documents[index]
        var retained = recents
        if let recentSource {
            retained = [Recent(source: recentSource)] + recents.filter { $0.source !== recentSource }
            let remaining = documents.enumerated().filter { $0.offset != index }.compactMap { $0.element.model.source }
            while !retained.isEmpty {
                let bytes = try cost(remaining + retained.map(\.source))
                if retained.count <= 8 && bytes <= maximumBytes { break }
                retained.removeLast()
            }
        }
        document.model.finishInspectorTransaction(); document.model.closeImage()
        documents.remove(at: index); recents = retained
        if selectedID == id { selectedID = documents.isEmpty ? nil : documents[min(index, documents.count - 1)].id }
    }
    func clearRecents() { recents.removeAll() }
    private func cost(_ sources: [ImageSource]) throws -> Int {
        var seen: Set<ObjectIdentifier> = []
        return try sources.reduce(0) { total, source in
            guard seen.insert(ObjectIdentifier(source)).inserted else { return total }
            let encoded = try source.url?.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            let captured = source.capturedImage.map { $0.bytesPerRow * $0.height } ?? 0
            return total + encoded + captured + source.preview.bytesPerRow * source.preview.height
        }
    }
}
