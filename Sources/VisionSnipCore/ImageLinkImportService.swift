import Foundation

public enum ImageLinkError: LocalizedError {
    case unsupportedURL, notAnImage, response(Int), tooManyRedirects, downloadFailed

    public var errorDescription: String? {
        switch self {
        case .unsupportedURL:
            "Paste a direct HTTPS image link without a username or password, or copy the image itself in your browser."
        case .notAnImage:
            "This link did not return an image. Open the page in your browser and copy the image itself, then paste again."
        case .response(let status):
            "The website could not provide the image (HTTP \(status)). Open it in your browser and copy the image itself."
        case .tooManyRedirects:
            "This image link redirects too many times. Open it in your browser and copy the image instead."
        case .downloadFailed:
            "The image could not be downloaded. Check your connection, or open it in your browser and copy the image itself."
        }
    }
}

/// Explicit Paste only. No shared cookies, credentials, URL history, cache, uploads or background session.
public enum ImageLinkImportService {
    static func validate(_ url: URL) throws {
        guard url.scheme?.lowercased() == "https", let host = url.host, !host.isEmpty,
              url.user == nil, url.password == nil else { throw ImageLinkError.unsupportedURL }
    }

    static func configuration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.urlCache = nil
        config.urlCredentialStorage = nil
        config.httpCookieStorage = nil
        config.httpShouldSetCookies = false
        config.httpCookieAcceptPolicy = .never
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 60
        config.httpMaximumConnectionsPerHost = 1
        return config
    }

    public static func importURL(_ url: URL) async throws -> ImageSource {
        try await importURL(url, configuration: configuration(), byteLimit: ImageImportService.importByteLimit)
    }

    // Configuration/limit injection is internal: deterministic tests need neither a real host nor large allocations.
    static func importURL(_ url: URL, configuration: URLSessionConfiguration, byteLimit: Int) async throws -> ImageSource {
        try Task.checkCancellation()
        try validate(url)
        let transfer = ImageLinkDownload(configuration: configuration, byteLimit: byteLimit)
        let downloaded = try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { transfer.start(url, continuation: $0) }
        } onCancel: { transfer.cancel() }
        try Task.checkCancellation()
        return try await ImageImportService.loadOwnedCopy(downloaded.copy, name: downloaded.name)
    }
}

private struct DownloadedImage: Sendable {
    let copy: OwnedImageImport
    let name: String
}

/// Delegate callbacks and cancellation share one lock; only bounded chunks are written to protected storage.
private final class ImageLinkDownload: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    private let lock = NSLock()
    private let configuration: URLSessionConfiguration
    private let byteLimit: Int
    private var continuation: CheckedContinuation<DownloadedImage, any Error>?
    private var session: URLSession?
    private var task: URLSessionDataTask?
    private var directory: URL?
    private var file: FileHandle?
    private var received = 0
    private var redirects = 0
    private var name = "Downloaded Image"
    private var finished = false

    init(configuration: URLSessionConfiguration, byteLimit: Int) {
        self.configuration = configuration; self.byteLimit = byteLimit
    }

    func start(_ url: URL, continuation: CheckedContinuation<DownloadedImage, any Error>) {
        lock.lock()
        guard !finished else { lock.unlock(); continuation.resume(throwing: CancellationError()); return }
        self.continuation = continuation
        do {
            let directory = try ImageTemporaryStorage.shared.createDirectory(for: .imports)
            self.directory = directory
            let destination = directory.appendingPathComponent("source.image")
            guard FileManager.default.createFile(atPath: destination.path, contents: nil,
                                                 attributes: [.posixPermissions: 0o600]) else { throw ImageError.unreadable }
            try ImageTemporaryStorage.protectFile(destination)
            file = try FileHandle(forWritingTo: destination)
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1
            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
            request.httpShouldHandleCookies = false
            request.setValue("image/*,application/octet-stream;q=0.5", forHTTPHeaderField: "Accept")
            let task = session.dataTask(with: request)
            self.session = session; self.task = task
            lock.unlock()
            task.resume()
        } catch { lock.unlock(); finish(.failure(error)) }
    }

    func cancel() { finish(.failure(CancellationError())) }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                    didReceive response: URLResponse, completionHandler: @escaping @Sendable (URLSession.ResponseDisposition) -> Void) {
        do {
            guard let http = response as? HTTPURLResponse, let url = http.url else { throw ImageLinkError.downloadFailed }
            try ImageLinkImportService.validate(url)
            guard http.statusCode == 200 else { throw ImageLinkError.response(http.statusCode) }
            let mime = response.mimeType?.lowercased()
            guard mime == nil || mime == "application/octet-stream" || mime!.hasPrefix("image/") else {
                throw ImageLinkError.notAnImage
            }
            guard response.expectedContentLength <= Int64(byteLimit) else { throw ImageError.encodedFileTooLarge }
            lock.lock()
            let active = !finished
            // Keep only a filename; signed URL queries, hosts and full URLs never enter document/history metadata.
            if let suggested = response.suggestedFilename {
                let filename = URL(fileURLWithPath: suggested).lastPathComponent
                if !filename.isEmpty { name = filename }
            }
            lock.unlock()
            completionHandler(active ? .allow : .cancel)
        } catch { completionHandler(.cancel); finish(.failure(error)) }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        lock.lock()
        guard !finished else { lock.unlock(); return }
        do {
            guard data.count <= byteLimit - received else { throw ImageError.encodedFileTooLarge }
            guard let file else { throw ImageError.unreadable }
            try file.write(contentsOf: data)
            received += data.count
            lock.unlock()
        } catch { lock.unlock(); finish(.failure(error)) }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest, completionHandler: @escaping @Sendable (URLRequest?) -> Void) {
        do {
            guard let url = request.url else { throw ImageLinkError.unsupportedURL }
            try ImageLinkImportService.validate(url)
            lock.lock(); redirects += 1; let count = redirects, active = !finished; lock.unlock()
            guard count <= 5 else { throw ImageLinkError.tooManyRedirects }
            var clean = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
            clean.httpShouldHandleCookies = false
            clean.setValue("image/*,application/octet-stream;q=0.5", forHTTPHeaderField: "Accept")
            completionHandler(active ? clean : nil)
        } catch { completionHandler(nil); finish(.failure(error)) }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Keep system certificate validation; never answer website/proxy authentication with stored credentials.
        completionHandler(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
                          ? .performDefaultHandling : .cancelAuthenticationChallenge, nil)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        if error != nil { finish(.failure(ImageLinkError.downloadFailed)); return }
        lock.lock()
        let directory = directory, name = name, active = !finished
        lock.unlock()
        guard active, let directory else { return }
        do {
            let copy = try OwnedImageImport(ownedURL: directory.appendingPathComponent("source.image"))
            finish(.success(DownloadedImage(copy: copy, name: name)))
        } catch { finish(.failure(error)) }
    }

    private func finish(_ result: Result<DownloadedImage, any Error>) {
        lock.lock()
        guard !finished else { lock.unlock(); return }
        finished = true
        var result = result
        do { try file?.close() } catch { if case .success = result { result = .failure(error) } }
        file = nil
        let directory = directory, continuation = continuation, session = session
        self.directory = nil; self.continuation = nil; self.session = nil; task = nil
        lock.unlock()
        session?.invalidateAndCancel()
        if case .failure = result, let directory { try? FileManager.default.removeItem(at: directory) }
        continuation?.resume(with: result)
    }
}
