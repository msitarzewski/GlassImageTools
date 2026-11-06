# Native start screen and sidebar — October 29, 2026

State: DOCS / deployed; scoped physical acceptance remains.

Objective: Refresh the empty editor with large native Photos/Files wells, a real image drop target that also explains Paste, and a sidebar using Apple default selection/disclosure/row behavior.

Authorization: Owner requests implementation, with existing local build/test/docs and same-headset signing/install/normal-launch authorization. No Git, upload/publication, new permission/backend/dependency or delegation.

Owners/reuse: EditorView owns acquisition/workspace and document requests; DocumentSidebar currently draws custom compact buttons/disclosure style. Replace those row/selection surfaces with native List behavior. Keep plain window columns/hidden scroll background and the single rear glass owner. ImportItemProviders already owns bounded private copies, cancellation and original-byte preservation; reuse it for explicit Drop/Paste with accurate contextual names/errors.

Acceptance: Large native import options; genuine drag acceptance and clear hover feedback; native Paste and one keyboard-shortcut owner; Photos/Files return, document selection/Undo/close/Recents unchanged. No original changes or extra material over window transparency. Native UI/compositor at normal/compact/largest sizes and audits, real provider/drop import, native services, core tests if import API changes and signed Release checks. Physical input/drag interoperability remains separate from simulator and installation evidence.

Risks: Native List surfaces can affect transparency/selection; custom empty actions must fit small windows and accessibility text. Drops must not poll the clipboard, consume text/file paths indiscriminately or add a second image decode path.

Primary references: Apple's HIG Buttons and Drag and Drop, PasteButton and SwiftUI drop API documentation; confirm actual API declarations in the installed target SDK before use.

## Implementation

- `ImageStartView`: adaptive system bordered Photos/Files wells; a native GroupBox with image-only Drop, live target highlight and native Paste. Scrollable at compact/largest text sizes.
- `DocumentSidebar`: system `.sidebar` List and expandable Sections replace the custom button, selection, disclosure and spacing styles. Open Images begins expanded; Recents begins collapsed. Existing source thumbnails/metadata and independent document edits remain.
- Drop goes through EditorView's new-document request, EditorModel and the existing protected `ImageImportService.importItemProviders`. Suggested source names are retained; unnamed drops use Dropped Image. Empty-drop recovery differs from Paste; no clipboard polling or new permission.
- One adjustable rear glass owner and plain window columns remain; no persistent navigation container was introduced.

## Validation checkpoint

Core: 68 tests/5 suites pass. Initial signed Release build/analyze and strict signature pass (build 32); only the existing AppIntents metadata warnings appeared. The initial UI run passes the normal empty-screen and largest-text accessibility audits, but its synthetic drag did not open a source. The next run instruments the Debug-only drag source/target and uses a slower gesture with a hold before release. No successful drag claim yet. Xcode result finalization stalled after all assertions and was interrupted (native exit -15); this is not a clean UI command result.

Primary guidance: [Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons), [Drag and drop](https://developer.apple.com/design/human-interface-guidelines/drag-and-drop), [PasteButton](https://developer.apple.com/documentation/swiftui/pastebutton), [SwiftUI drop destination](https://developer.apple.com/documentation/swiftui/view/ondrop(of:istargeted:perform:)). Declarations were checked in the installed visionOS SDK; hardware input acceptance is separate.

## Diagnostic checkpoint

The second UI command finalized normally (exit 65): Paste round-trip, Photos picker and clear/opaque/default-glass sidebars pass. Document switching, independent Undo, close/cancel, Recents and inspector behavior run through; six assertions count three accessibility descendants per document instead of one. `DocumentRow` now explicitly combines its children into a single accessible item. The drop gesture still does not open an image; Debug-only status distinguishes whether a system drag ever began from a received-drop failure. The test skips only when its synthetic gesture demonstrably never starts a drag; an initiated but unsuccessful drop remains a failure.

A 160 × 60 minimum native `UIPasteControl` replaces only the empty screen's compact SwiftUI PasteButton. It uses Apple's accepted-type configuration, explicit user authorization and provider callback, forwarding into the existing acquisition owner. It never reads UIPasteboard. The final signed Release build/analyze passes (exit 0, 26.438 s) and the simulator test bundle compiles (exit 0, 19.324 s); these are not final UI execution evidence.

The owner reported audible but invisible simulators. The task-owned runtime was stopped (exit 0), leaving other devices unchanged. Xcode 27 hosts simulator windows in Device Hub, which launched but timed out while showing/reading its window through computer use. The runtime remains stopped while visibility is unresolved; optional feedback is pending and quiet non-simulator work continues.

Real file-backed and data-backed PNG provider imports on the Mac now pass: suggested/fallback names, decoded dimensions/type, independent owned copy and byte equality for both source and imported file. Core: 69 tests/5 suites, exit 0, 5.468 s. This confirms the import boundary, not cross-application gesture delivery on Vision Pro.

## Owner follow-up — build 33

Build 32 was applied, installed, read back as 1.0 (32), normally launched and independently verified running (all exit 0). The owner responded “Nice” and asked to remove the blue Paste button, then clarified that Command V or clicking the entire area should paste an image. Build 33 replaces the separate UIPasteControl with one large native bordered button/well that also receives drops. Clipboard providers are requested only from an explicit tap or standard keyboard Paste action. A public UIKit first responder belongs only to the empty workspace; text fields retain their own native responder. No clipboard polling on render or enablement. Final keyboard, tap, permission and focus behavior require scoped runtime verification.

Build-33 focused run: well tap, native document lifecycle, normal and largest-text accessibility pass. The keyboard case's only failure was querying the drop/Paste identifier as Button when its native drop container exposes it as Other; the actual Command V subsequently opened the PNG with correct source dimensions and clean Undo. The test now uses the container's known identifier without a type assumption. This is test-query remediation, not a failed shortcut hidden by a skip. A final short run checks that corrected case and the genuine drag diagnostic.

## Applied outcome

Installed and normally launched on the headset; identity 1.0 (33), exactly one running app process, all commands exit 0. 5 focused UI cases pass across two runs on identical final production source; corrected-selector follow-up native exit 0 (127 s); synthetic drag skipped because the gesture never started a system drag. Core 69/5 and final signed Release boundaries pass. The simulator is shut down after the announced test run. The initial failed UI runs remain historical; final focused scope is not a full-suite or physical acceptance claim. Source diff, baseline-conflict, private-data and documentation link checks precede final application. No commit, publication, upload or external message.
