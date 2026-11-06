#if DEBUG
import SwiftUI
import AppKit

/// Explicit Debug-only integration probe. It never runs in ordinary app startup or a Release build.
struct MacSandboxProbe: View {
    @State private var result = "Checking sandbox"
    var body: some View {
        Text(result).accessibilityIdentifier("sandbox-probe-result").padding().task {
            guard let path = ProcessInfo.processInfo.environment["SANDBOX_UNSELECTED_FILE"] else {
                result = "Missing probe input"; return
            }
            let outsideDenied: Bool
            var readOutcome = "read succeeded"
            do { _ = try Data(contentsOf: URL(fileURLWithPath: path)); outsideDenied = false }
            catch {
                let cocoa = error as NSError
                outsideDenied = cocoa.code == NSFileReadNoPermissionError || cocoa.code == NSFileReadUnknownError
                readOutcome = "\(cocoa.domain) \(cocoa.code)"
            }
            let own = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            do {
                let data = Data("sandbox-private-probe".utf8)
                try data.write(to: own, options: .atomic)
                let matches = try Data(contentsOf: own) == data
                try FileManager.default.removeItem(at: own)
                result = "Outside denied: \(outsideDenied); Container read/write: \(matches)"
            } catch { result = "Container probe failed: \(error.localizedDescription)" }
            if ProcessInfo.processInfo.arguments.contains("--sandbox-probe-report-only") {
                NSLog("MAC_SANDBOX_PROBE %@; read outcome: %@; container: %d", result, readOutcome, NSHomeDirectory().contains("/Library/Containers/") ? 1 : 0)
                NSApp.terminate(nil)
            }
        }
    }
}
#endif
