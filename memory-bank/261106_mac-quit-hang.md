# Mac Quit hang — November 6, 2026

State: APPLIED. Reviewed source applied with baseline guards; notarized canonical build 45 installed in Applications with signature, ticket, Gatekeeper and exact-tree readback. Prior bundle and running owner app preserved. Mac 1.0 (45), visionOS unchanged at 38.
Owner approved shipping build 44 appearance, then reported Quit freezes. Local fix, VM checks,
installation and docs are authorized; release resumes after this blocker. Host owner app/windows
are preserved. No delegation. [Evidence](../Documentation/Validation/mac-quit-hang.json).

## Diagnosis and change

The owner process's read-only stack sample waits in AppKit termination approval. MacWindowCloseRegistry
returned terminateLater before scheduling a SwiftUI save/close question, so the decision depended on
updates outside the pending termination loop. Source inspection plus actual fixed native behavior
support this diagnosis; the guest's first keyboard checks were ambiguous and are not claimed as a
baseline reproduction or Command-Q acceptance.

MacApplicationDelegate now asks the native NSAlert before termination. Discard returns terminateNow;
Cancel returns terminateCancel. Save also cancels termination, allowing SwiftUI export sheets to run,
saves edited windows sequentially, and reissues normal Quit only after their closure. Repeat Quit while
saving keeps that operation active. Existing MacWindowCloseGuard owns the new save callback. Confirmed
MacEditorView closure waits for sheet detachment and directly closes the already-approved window.
No source/edit/export model rewrite. Sibling Glass Power Tools provided a pattern reference only;
implementation remains independent in this MIT project.

## Actual verification

Signed Release build and final Debug build-for-testing exit 0. New regressions cover Cancel/Discard
process exit, export cancellation/retry, actual Save/exit and unchanged original bytes; Save panel steps
reuse one helper. Test sources compiled, not executed. A Release test compile failed because @testable
imports require testing-enabled modules; Debug is the correct test configuration and passes. App Intents
metadata warnings reflect no framework dependency, with no source compiler warnings.

Isolated native macOS 26 guest: native Quit event shows Save/Discard/Cancel; Cancel retains 400 × 300
crop; cancelling export preserves work and retry; Discard exits. Actual Save writes a 400 × 300 PNG
and exits. Two dirty windows save sequentially to 400 × 300 and 500 × 250 PNGs and the process exits;
both original fixture hashes match. AX actions, observed pointer targets and native Quit events were
used; not an XCTest run or keyboard-shortcut certification. Task guest stopped, others untouched.

Developer ID archive/export, four production permissions, universal architecture, hardened runtime,
privacy manifest, app and DMG notarization/stapling/Gatekeeper all pass. Packaging does not certify
Photos, Share, VoiceOver, performance or hardware acceptance. [Release work](261106_mac-release.md).
Installing the fix preserves the already-frozen owner's process; it cannot replace loaded code.
