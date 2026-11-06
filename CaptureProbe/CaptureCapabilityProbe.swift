import Foundation

/// Serializes asynchronous capture transitions and invalidates superseded completions.
/// Kept independent of ScreenCaptureKit so its ordering can be verified without capture hardware.
@MainActor final class CaptureLifecycleQueue {
    private var generation = UUID()
    private var pending: Task<Void, Never>?
    var current: UUID { generation }

    func isCurrent(_ token: UUID) -> Bool { generation == token && !Task.isCancelled }

    @discardableResult
    func enqueue(_ operation: @escaping @MainActor (UUID) async -> Void) -> Task<Void, Never> {
        generation = UUID()
        let token = generation
        pending?.cancel()
        let previous = pending
        let next = Task { [weak self] in
            if let previous { await previous.value }
            guard let self, self.isCurrent(token) else { return }
            await operation(token)
        }
        pending = next
        return next
    }
}

#if os(visionOS) && canImport(ScreenCaptureKit)
import SwiftUI
import ScreenCaptureKit
import CoreMedia
import CoreImage
import VisionSnipCore

// The SDK's opaque filter has no mutating API here. Transfer the system selection once, then
// access it only on the main actor. SCStream owns its use after initialization.
private struct CaptureSelection: @unchecked Sendable { let filter: SCContentFilter }

/// This target is experimental and never linked into the released editor.
@MainActor protocol CaptureService: AnyObject {
    var available: Bool { get }
    func chooseSource(ownApplication: Bool)
    func freezeFrame()
    func stop() async
}

@Observable @MainActor
final class CaptureCapabilityProbe: NSObject, CaptureService, SCContentSharingPickerObserver, SCStreamDelegate {
    var available: Bool { SCContentSharingPicker.shared.isAvailable }
    var status = "No capture requested."
    var active = false
    var transitioning = false
    var isFreezing = false
    var canChooseSource: Bool { stream == nil && !transitioning }
    var canStop: Bool { stream != nil || transitioning }
    var captured: ImageSource?
    var events: [String] = []
    private var stream: SCStream?
    private let receiver = CaptureFrameReceiver()
    private var timeout: Task<Void, Never>?
    private let lifecycle = CaptureLifecycleQueue()
    private var awaitingSelection = false

    override init() {
        super.init()
        SCContentSharingPicker.shared.add(self)
        record("ScreenCaptureKit picker available: \(available). Simulator results do not establish device support.")
    }

    private func record(_ message: String) {
        status = message
        events.append("\(Date.now.formatted(date: .omitted, time: .standard)) — \(message)")
    }

    func chooseSource(ownApplication: Bool) {
        guard available else { record("System reports capture unavailable on this device."); return }
        guard canChooseSource else { record("Wait for the current capture transition or stop the stream."); return }
        awaitingSelection = true
        transitioning = true
        let picker = SCContentSharingPicker.shared
        var configuration = SCContentSharingPickerConfiguration()
        configuration.showsMicrophoneControl = false
        picker.defaultConfiguration = configuration
        picker.isActive = true
        record("Requesting the system's \(ownApplication ? "current application" : "content") sharing picker.")
        if ownApplication { picker.presentForCurrentApplication() }
        else { picker.present() }
    }

    func freezeFrame() {
        guard active, !isFreezing, let stream else { return }
        isFreezing = true
        let token = lifecycle.current
        record("Waiting for the next complete video frame…")
        receiver.requestFrame(from: stream) { [weak self] image in
            Task { @MainActor in
                guard let self, self.lifecycle.isCurrent(token), self.active else { return }
                self.timeout?.cancel()
                do {
                    let source = try await Task.detached(priority: .userInitiated) {
                        try ImageImportService.fromCapture(image)
                    }.value
                    guard self.lifecycle.isCurrent(token), self.active else { return }
                    guard await self.requestStop() else { return }
                    self.captured = source
                    self.record("Received \(image.width) × \(image.height) pixels directly in memory.")
                } catch {
                    guard self.lifecycle.isCurrent(token) else { return }
                    guard await self.requestStop() else { return }
                    self.record("Frame import failed: \(error.localizedDescription)")
                }
            }
        }
        timeout?.cancel()
        timeout = Task {
            do { try await Task.sleep(for: .seconds(10)) } catch { return }
            guard lifecycle.isCurrent(token) else { return }
            guard await requestStop() else { return }
            record("No complete frame arrived in 10 seconds. This capture path is not confirmed working.")
        }
    }

    func stop() async {
        _ = await requestStop()
    }

    private func requestStop() async -> Bool {
        timeout?.cancel(); receiver.cancel()
        awaitingSelection = false; active = false; isFreezing = false; transitioning = true
        SCContentSharingPicker.shared.isActive = false
        let task = lifecycle.enqueue { [weak self] token in
            guard let self else { return }
            _ = await self.stopCurrentStream()
            guard self.lifecycle.isCurrent(token) else { return }
            self.transitioning = false
        }
        let token = lifecycle.current
        await task.value
        return lifecycle.isCurrent(token) && stream == nil && !transitioning
    }

    private func stopCurrentStream() async -> Bool {
        let previous = stream
        stream = nil; active = false
        if let previous {
            // Cleanup must run even when the superseded startup task was cancelled.
            let cleanup = Task { @MainActor () -> String? in
                do { try await previous.stopCapture(); return nil }
                catch { return error.localizedDescription }
            }
            if let message = await cleanup.value {
                stream = previous
                record("Stopping capture failed: \(message). Retry Stop before choosing another source.")
                return false
            }
        }
        return true
    }

    nonisolated func contentSharingPicker(_ picker: SCContentSharingPicker, didCancelFor stream: SCStream?) {
        Task { @MainActor in
            guard self.awaitingSelection else { return }
            guard await self.requestStop() else { return }
            self.record("System picker cancelled. No authorization assumed.")
        }
    }
    nonisolated func contentSharingPickerStartDidFailWithError(_ error: any Error) {
        Task { @MainActor in
            guard self.awaitingSelection else { return }
            guard await self.requestStop() else { return }
            self.record("Picker failed: \(error.localizedDescription)")
        }
    }
    nonisolated func contentSharingPicker(_ picker: SCContentSharingPicker, didUpdateWith filter: SCContentFilter, for stream: SCStream?) {
        let selection = CaptureSelection(filter: filter)
        let requestedStream = stream.map(ObjectIdentifier.init)
        Task { @MainActor [weak self] in
            guard let self else { return }
            if let requestedStream {
                guard self.stream.map(ObjectIdentifier.init) == requestedStream else { return }
            } else {
                guard self.awaitingSelection else { return }
            }
            self.awaitingSelection = false; self.transitioning = true; self.active = false
            self.timeout?.cancel(); self.receiver.cancel(); self.isFreezing = false
            self.lifecycle.enqueue { [weak self] token in
                guard let self else { return }
                guard await self.stopCurrentStream() else {
                    if self.lifecycle.isCurrent(token) { self.transitioning = false }
                    return
                }
                guard self.lifecycle.isCurrent(token) else { return }
                SCContentSharingPicker.shared.isActive = true
                let configuration = SCStreamConfiguration()
                configuration.capturesAudio = false
                let capture = SCStream(filter: selection.filter, configuration: configuration, delegate: self)
                do {
                    try capture.addStreamOutput(self.receiver, type: .screen,
                        sampleHandlerQueue: DispatchQueue(label: "GlassImageTools.CaptureFrames", qos: .userInitiated))
                    self.stream = capture
                    try await capture.startCapture()
                    guard self.lifecycle.isCurrent(token) else {
                        _ = await self.stopCurrentStream()
                        return
                    }
                    self.active = true; self.transitioning = false
                    self.record("Authorized stream started. Freeze a frame to verify image delivery.")
                } catch {
                    _ = await self.stopCurrentStream()
                    guard self.lifecycle.isCurrent(token) else { return }
                    self.transitioning = false
                    SCContentSharingPicker.shared.isActive = false
                    self.record("Stream failed: \(error.localizedDescription)")
                }
            }
        }
    }
    nonisolated func stream(_ stream: SCStream, didStopWithError error: any Error) {
        let identifier = ObjectIdentifier(stream)
        Task { @MainActor in
            guard self.stream.map(ObjectIdentifier.init) == identifier else { return }
            guard await self.requestStop() else { return }
            self.record("Stream ended: \(error.localizedDescription)")
        }
    }
}

/// SCStream calls this on a serial queue. Only a requested frame is decoded; other buffers are dropped.
private final class CaptureFrameReceiver: NSObject, SCStreamOutput, @unchecked Sendable {
    private let lock = NSLock()
    private var pending: (stream: ObjectIdentifier, callback: @Sendable (CGImage) -> Void)?
    private let context = CIContext(options: [.cacheIntermediates: false])
    func requestFrame(from stream: SCStream, _ callback: @escaping @Sendable (CGImage) -> Void) {
        lock.withLock { pending = (ObjectIdentifier(stream), callback) }
    }
    func cancel() { lock.withLock { pending = nil } }
    func stream(_ stream: SCStream, didOutputSampleBuffer buffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen, buffer.isValid, let pixels = buffer.imageBuffer else { return }
        guard let attachments = CMSampleBufferGetSampleAttachmentsArray(buffer, createIfNecessary: false) as? [[SCStreamFrameInfo: Any]],
              let status = attachments.first?[.status] as? Int, status == SCFrameStatus.complete.rawValue else { return }
        let callback: (@Sendable (CGImage) -> Void)? = lock.withLock {
            guard let request = pending, request.stream == ObjectIdentifier(stream) else { return nil }
            pending = nil
            return request.callback
        }
        guard let callback else { return }
        let image = CIImage(cvPixelBuffer: pixels)
        guard image.extent.width * image.extent.height <= 100_000_000,
              let cgImage = context.createCGImage(image, from: image.extent) else { return }
        callback(cgImage)
    }
}

#endif
