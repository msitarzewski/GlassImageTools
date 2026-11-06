import Testing
import Foundation
import CoreGraphics
import UniformTypeIdentifiers
@testable import VisionSnipCore

// Reuse the existing serialized ImageIO suite: its private-storage assertions must not race other imports.
extension RendererTests {
    private func config() -> URLSessionConfiguration {
        let config = ImageLinkImportService.configuration()
        config.protocolClasses = [ImageLinkProtocol.self]
        return config
    }

    private func bytes() throws -> Data {
        let context = try #require(CGContext(data: nil, width: 32, height: 24, bitsPerComponent: 8,
            bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.setFillColor(CGColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: 32, height: 24))
        let source = try ImageImportService.fromCapture(#require(context.makeImage()))
        let image = try ImageRenderer.export(source, edits: EditState(crop: source.bounds), format: .png)
        return try Data(contentsOf: image.url)
    }

    private func directories() throws -> Set<String> {
        try ImageImportService.prepareTemporaryStorage()
        return Set(try FileManager.default.contentsOfDirectory(atPath:
            FileManager.default.temporaryDirectory.appendingPathComponent("VisionSnip-Imports").path))
    }

    @Test func ephemeralConfigurationAndURLRestrictions() throws {
        let c = ImageLinkImportService.configuration()
        #expect(c.urlCache == nil && c.urlCredentialStorage == nil && c.httpCookieStorage == nil)
        #expect(!c.httpShouldSetCookies && c.httpCookieAcceptPolicy == .never)
        #expect(c.requestCachePolicy == .reloadIgnoringLocalCacheData)
        #expect(c.timeoutIntervalForRequest == 20 && c.timeoutIntervalForResource == 60)
        try ImageLinkImportService.validate(URL(string: "https://example.com/image.png?size=large")!)
        for text in ["http://example.com/image.png", "file:///example.png", "data:image/png;base64,AA==",
                     "https://user@example.com/image.png", "ftp://example.com/image.png"] {
            #expect(throws: ImageLinkError.self) { try ImageLinkImportService.validate(URL(string: text)!) }
        }
    }

    @MainActor @Test func explicitProviderURLAndPlainTextFallback() async throws {
        let url = URL(string: "https://example.com/image.png?size=large")!
        for provider in [NSItemProvider(object: url as NSURL), NSItemProvider(object: ("  "+url.absoluteString+"\n") as NSString)] {
            #expect(try await ImageImportService.imageLinkURL(from: [provider]) == url)
        }
        for text in ["some ordinary text", "look at https://example.com/image.png", "https://example.com/a https://example.com/b"] {
            let probe = NSItemProvider(object: text as NSString)
            let value = try await ImageImportService.imageLinkURL(from: [probe])
            #expect(value == nil)
        }
        // A drop still accepts only image representations; it never fetches a copied URL.
        do {
            _ = try await ImageImportService.importItemProviders([NSItemProvider(object: url as NSURL)], emptyError: .noDroppedImage)
            Issue.record("An image-only drop must not fetch a link")
        } catch ImageError.noDroppedImage {}
    }

    @MainActor @Test func realImageRepresentationWinsOverLinkWithoutFetching() async throws {
        let data = try bytes()
        let provider = NSItemProvider()
        provider.registerDataRepresentation(forTypeIdentifier: UTType.png.identifier, visibility: .all) { completion in
            completion(data, nil); return nil
        }
        let url = NSItemProvider(object: URL(string: "https://example.com/must-not-be-fetched.png")! as NSURL)
        let image = try await ImageImportService.importItemProviders([url, provider], allowsImageLinks: true)
        #expect(image.size == CGSize(width: 32, height: 24))
        #expect(try Data(contentsOf: #require(image.url)) == data)
    }

    @Test func downloadsExactBytesRendersCropAndReleasesPrivateFile() async throws {
        let data = try bytes(), before = try directories()
        ImageLinkProtocol.set { proto in
            #expect(proto.request.value(forHTTPHeaderField: "Cookie") == nil)
            #expect(proto.request.value(forHTTPHeaderField: "Authorization") == nil)
            #expect(proto.request.value(forHTTPHeaderField: "Referer") == nil)
            proto.respond(headers: ["Content-Type": "image/png", "Content-Length": String(data.count)], chunks: [data])
        }
        var image: ImageSource? = try await ImageLinkImportService.importURL(
            URL(string: "https://example.com/photo.png?private-query=example")!, configuration: config(), byteLimit: data.count)
        let owned = try #require(image?.url)
        #expect(image?.size == CGSize(width: 32, height: 24))
        #expect(image?.name == "photo.png")
        #expect(try Data(contentsOf: owned) == data)
        #expect((try FileManager.default.attributesOfItem(atPath: owned.path)[.posixPermissions] as? NSNumber)?.intValue == 0o600)
        let source = try #require(image)
        let output = try ImageRenderer.export(source, edits: EditState(crop: CGRect(x: 4, y: 3, width: 8, height: 9)), format: .png)
        #expect(output.size == CGSize(width: 8, height: 9))
        // The immutable local source contains only downloaded image bytes, never the URL/query.
        #expect(!data.contains(Data("private-query".utf8)))
        image = nil
        // 'source' still retains the file until this test's scope ends; a second import proves release directly.
        var released: ImageSource? = try await ImageLinkImportService.importURL(
            URL(string: "https://example.com/second.png")!, configuration: config(), byteLimit: data.count)
        let releasedURL = try #require(released?.url); released = nil
        #expect(!FileManager.default.fileExists(atPath: releasedURL.deletingLastPathComponent().path))
        let retainedDirectories = try directories().subtracting(before)
        withExtendedLifetime(source) { #expect(retainedDirectories.count == 1) }
    }

    @Test(arguments: [true, false]) func byteLimitRejectsHeaderAndStreamingOverflow(knownLength: Bool) async throws {
        let data = try bytes(), before = try directories()
        ImageLinkProtocol.set { proto in
            var headers = ["Content-Type": "image/png"]
            if knownLength { headers["Content-Length"] = String(data.count) }
            proto.respond(headers: headers, chunks: [data.prefix(data.count/2), data.suffix(data.count-data.count/2)])
        }
        do {
            _ = try await ImageLinkImportService.importURL(URL(string: "https://example.com/large.png")!,
                configuration: config(), byteLimit: data.count-1)
            Issue.record("Oversized image must fail")
        } catch ImageError.encodedFileTooLarge {}
        #expect(try directories() == before)
    }

    @Test(arguments: ["webpage", "missing", "invalid-image"])
    func badResponsesRemoveWorkingFiles(kind: String) async throws {
        let before = try directories()
        ImageLinkProtocol.set { proto in
            proto.respond(status: kind == "missing" ? 404 : 200,
                headers: ["Content-Type": kind == "webpage" ? "text/html" : "image/png"],
                chunks: [Data("Not image bytes".utf8)])
        }
        do {
            _ = try await ImageLinkImportService.importURL(URL(string: "https://example.com/item")!, configuration: config(), byteLimit: 4096)
            Issue.record("Non-image response must fail")
        } catch ImageLinkError.notAnImage { #expect(kind == "webpage") }
        catch ImageLinkError.response(let status) { #expect(kind == "missing" && status == 404) }
        catch ImageError.unreadable { #expect(kind == "invalid-image") }
        #expect(try directories() == before)
    }

    @Test func insecureRedirectIsNotFollowed() async throws {
        let before = try directories()
        ImageLinkProtocol.set { proto in
            #expect(proto.request.url?.scheme == "https")
            let response = HTTPURLResponse(url: proto.request.url!, statusCode: 302, httpVersion: nil,
                                           headerFields: ["Location": "http://example.com/image.png"])!
            proto.client?.urlProtocol(proto, wasRedirectedTo: URLRequest(url: URL(string: "http://example.com/image.png")!), redirectResponse: response)
        }
        do {
            _ = try await ImageLinkImportService.importURL(URL(string: "https://example.com/redirect")!, configuration: config(), byteLimit: 4096)
            Issue.record("Insecure redirect must fail")
        } catch ImageLinkError.unsupportedURL {}
        #expect(try directories() == before)
    }

    @Test(arguments: [false, true]) func secureRedirectsWorkAndLoopsAreBounded(loop: Bool) async throws {
        let data = try bytes(), before = try directories()
        ImageLinkProtocol.set { proto in
            #expect(proto.request.value(forHTTPHeaderField: "Cookie") == nil)
            #expect(proto.request.value(forHTTPHeaderField: "Authorization") == nil)
            #expect(proto.request.value(forHTTPHeaderField: "Referer") == nil)
            if !loop && proto.request.url?.path == "/image.png" {
                proto.respond(headers: ["Content-Type": "application/octet-stream"], chunks: [data])
            } else {
                let next = URL(string: "https://example.com/" + (loop ? "loop" : "image.png"))!
                let response = HTTPURLResponse(url: proto.request.url!, statusCode: 302, httpVersion: nil,
                                               headerFields: ["Location": next.absoluteString])!
                proto.client?.urlProtocol(proto, wasRedirectedTo: URLRequest(url: next), redirectResponse: response)
            }
        }
        do {
            var image: ImageSource? = try await ImageLinkImportService.importURL(URL(string: "https://example.com/start")!,
                configuration: config(), byteLimit: 4096)
            #expect(!loop)
            #expect(try Data(contentsOf: #require(image?.url)) == data)
            image = nil
        } catch ImageLinkError.tooManyRedirects { #expect(loop) }
        #expect(try directories() == before)
    }

    @Test func cancellationStopsTransferAndCleansPartialData() async throws {
        let before = try directories()
        let (events, signal) = AsyncStream<Bool>.makeStream()
        ImageLinkProtocol.set { proto in
            proto.respond(headers: ["Content-Type": "image/png"], chunks: [Data([1, 2, 3])], finish: false)
            signal.yield(true)
        }
        let config = config(), stoppedBefore = ImageLinkProtocol.stoppedRequests
        let task = Task { try await ImageLinkImportService.importURL(URL(string: "https://example.com/slow.png")!, configuration: config, byteLimit: 4096) }
        for await _ in events { break }
        task.cancel()
        do { _ = try await task.value; Issue.record("Cancelled download must not publish") }
        catch is CancellationError {}
        #expect(try directories() == before)
        for _ in 0..<50 {
            if ImageLinkProtocol.stoppedRequests > stoppedBefore { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(ImageLinkProtocol.stoppedRequests > stoppedBefore)
        signal.finish()
    }
}

/// Test transport only. No real requests, production flags or mutable production configuration.
private final class ImageLinkProtocol: URLProtocol, @unchecked Sendable {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var handler: (@Sendable (ImageLinkProtocol) -> Void)?
    nonisolated(unsafe) private static var stopCount = 0
    static var stoppedRequests: Int { lock.lock(); defer { lock.unlock() }; return stopCount }
    static func set(_ handler: @escaping @Sendable (ImageLinkProtocol) -> Void) {
        lock.lock(); self.handler = handler; lock.unlock()
    }
    override class func canInit(with request: URLRequest) -> Bool { request.url?.host == "example.com" }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        Self.lock.lock(); let handler = Self.handler; Self.lock.unlock()
        if let handler { handler(self) } else { client?.urlProtocol(self, didFailWithError: URLError(.resourceUnavailable)) }
    }
    override func stopLoading() { Self.lock.lock(); Self.stopCount += 1; Self.lock.unlock() }
    func respond(status: Int = 200, headers: [String: String], chunks: [Data], finish: Bool = true) {
        let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: headers)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        for chunk in chunks { client?.urlProtocol(self, didLoad: chunk) }
        if finish { client?.urlProtocolDidFinishLoading(self) }
    }
}
