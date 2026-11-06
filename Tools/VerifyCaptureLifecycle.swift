import Foundation

/// Standalone verification of the production capture transition queue, without ScreenCaptureKit.
/// swiftc -swift-version 6 CaptureProbe/CaptureCapabilityProbe.swift Tools/VerifyCaptureLifecycle.swift -o /tmp/capture-lifecycle-check
@main struct VerifyCaptureLifecycle {
    @MainActor private final class Gate {
        private var paused = false
        private var waiting: CheckedContinuation<Void, Never>?
        private var observers: [CheckedContinuation<Void, Never>] = []
        func pause() async {
            await withCheckedContinuation { continuation in
                waiting = continuation; paused = true
                observers.forEach { $0.resume() }; observers.removeAll()
            }
        }
        func waitUntilPaused() async {
            if paused { return }
            await withCheckedContinuation { observers.append($0) }
        }
        func release() { waiting?.resume(); waiting = nil }
    }

    enum Failure: Error { case verification(String) }
    static func require(_ condition: Bool, _ message: String) throws {
        if !condition { throw Failure.verification(message) }
    }

    @MainActor static func main() async throws {
        let queue = CaptureLifecycleQueue()
        let gate = Gate()
        var events: [String] = []
        var active = false
        let start = queue.enqueue { token in
            events.append("starting")
            await gate.pause()
            if queue.isCurrent(token) { active = true }
            else { events.append("stale-start-cleanup") }
        }
        await gate.waitUntilPaused()
        let stop = queue.enqueue { _ in
            events.append("stopped"); active = false
        }
        gate.release()
        await stop.value; await start.value
        try require(!active && events == ["starting", "stale-start-cleanup", "stopped"],
                    "Stop must invalidate startup and wait for its cleanup")

        let secondGate = Gate()
        var executed: [Int] = []
        let first = queue.enqueue { token in
            await secondGate.pause()
            if queue.isCurrent(token) { executed.append(1) }
        }
        await secondGate.waitUntilPaused()
        let middle = queue.enqueue { _ in executed.append(2) }
        let latest = queue.enqueue { _ in executed.append(3) }
        secondGate.release()
        await latest.value; await middle.value; await first.value
        try require(executed == [3], "Superseded queued transitions must never run")

        let stale = queue.current
        await queue.enqueue { _ in }.value
        try require(!queue.isCurrent(stale), "Completed older frame callbacks must be rejected")
        print("Capture lifecycle: 3 deterministic checks passed.")
    }
}
