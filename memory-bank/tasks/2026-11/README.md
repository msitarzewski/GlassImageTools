# November 2026 tasks

## Current handoff

Mac 45 Quit fix passes native guest Save/Discard exit, cancellation/retry and sequential saves with
unchanged originals. Developer ID universal app/DMG notarization, staples and Gatekeeper pass.
Reviewed source applied, notarized Mac 45 installed and public source/release live; download hashes verified. Pages deployment and final live URL checks remain. Owner shipping instruction authorizes that
publication; preserve the existing frozen host process. VisionOS stays 38.
[Quit](../../261106_mac-quit-hang.md), [release](../../261106_mac-release.md).

## Completed implementation

### November 3 — Direct HTTPS image-link Paste, build 37

Native Paste accepts URL and plain-text links with bounded private downloads, image-first priority and useful recovery; privacy/site/store wording updated. Core 78/5, eight focused native cases including real HTTPS/PNG Copy, signed Release/analyze/signature and packet/site checks pass. Simulator stopped; no publication/upload. [Task](../../261103_paste-image-links.md), [evidence](../../../Documentation/Validation/paste-image-links.json).

### November 4 — Memory-bank handoff refresh

Reconciled build-37 local readiness, retained November 3 validation, current source/product/packet references and the pending paired-connection delivery. Fixed stale build-31 and implementation-next-step wording. No app changes, new test/build/device operations or publication. [Detailed checkpoint](../../261103_paste-image-links.md#november-4-memory-bank-refresh).

### November 5 — Native sandboxed Mac app, build 38

Native Mac sidebar/inspector, menus/keyboard/file panels and shared nondestructive editor. Explicit App
Sandbox, private container, native clipboard and save-before-close/quit flow. Final local delivery and
limits in the [task](../../261105_native-sandboxed-mac.md) and [evidence](../../../Documentation/Validation/native-sandboxed-mac.json).

### November 5 — Native Mac markup toolbar, build 39

Select and ten direct icon tools in Apple's accessory bar; unchanged editor/model and native inspector.
VM-only GUI verification after owner steering, actual annotated 480 × 320 clipboard PNG, source/Undo and
native constrained-layout checks. Approval review blocked the optional screen-capture notice; it was
left unapproved. [Task](../../261105_mac-markup-toolbar.md), [evidence](../../../Documentation/Validation/mac-markup-toolbar.json).

### November 5 — Correct complete toolbar parity, Mac build 40

Owner clarified exact Vision Pro toolbar parity after build 39's incorrect expanded-shape interpretation.
Mode/contextual tools/zoom/settings now match the existing visionOS source. Native VM functional checks
and actual 400 × 300 PNG copy pass. [Task](../../261105_mac-toolbar-parity.md), [evidence](../../../Documentation/Validation/mac-toolbar-parity.json).

### November 5 — Install canonical Mac build 40 in Applications

Explicit owner request completed: fresh signed Release, canonical Mac app ID, `/Applications/Glass Image Tools.app`.
Installed tree/signature/grants read back; existing windows preserved and no host GUI test/launch.
[Checkpoint](../../261105_mac-toolbar-parity.md#applications-installation--november-5),
[evidence](../../../Documentation/Validation/mac-applications-install.json).


### November 5 — Main-toolbar Settings, Mac build 41

Settings uses the main toolbar beside Inspector; the accessory row is omitted when empty. Actual VM
empty/image/close/settings checks and signed Release/compile-only checks pass. Installed canonical 41 in
`/Applications`, signature/exact tree verified; prior bundle and running windows preserved. Task VM stopped.
[Checkpoint](../../261105_mac-toolbar-parity.md#settings-in-main-toolbar--build-41), [evidence](../../../Documentation/Validation/mac-settings-toolbar.json).

### November 5 — Native Mac toolbar layout, build 42

Owner-approved leading Open Image, standard spaced groups and hideable Markup row with native menu
commands/shortcut. Guest order/visibility/editing/clipboard/close protection pass; Release signature,
production grants and test compilation pass. Reviewed source applied and canonical 42 installed in
`/Applications`, signature/exact tree verified. Prior bundle and host windows preserved; task VM stopped.
[Task](../../261105_mac-native-toolbar.md).

### November 5 — Preview Markup visual reference, build 43

Replaced compact scope styling with full-size native targets/menu symbols and Dividers. Standard AppKit
popups retain label geometry and reuse model actions. Actual guest targets/menu dispatch, editable
annotations, Zoom/crop, annotated 400 × 300 PNG Copy and empty recovery pass. Signed Release and existing
test-source compile pass. Applied and installed canonical 43 in `/Applications`, signature/tree verified;
prior bundle/host windows preserved and task guest stopped. [Checkpoint](../../261105_mac-native-toolbar.md#preview-markup-reference-follow-up--build-43).

### November 6 — Compact centered Mac Markup, build 44

Reused native controls/actions with smaller proportions and a centered content row inside the system
accessory bar. Actual native bounds across modes/windows/inspector states and annotated 400 × 300 PNG
Copy pass; signed Release/compile-only/signature/grants pass. Canonical 44 installed, signature/tree
verified. Prior bundle, other VMs and host windows preserved; task guest stopped.
[Task](../../261106_compact-centered-markup.md).

### November 6 — Quit correction and Mac distribution preparation

Native decision before termination and deferred confirmed window closure. Actual guest Save/Discard
exit and two-window save sequence pass. Release/Debug test-source compilation and Developer ID
notarization/stapling/Gatekeeper pass; public application/deployment checkpoint follows.
[Task](../../261106_mac-quit-hang.md), [release](../../261106_mac-release.md).
