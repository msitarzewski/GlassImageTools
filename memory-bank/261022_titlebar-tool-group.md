# Title-bar tool group — October 22, 2026

State: complete — reviewed, tested, applied; Release 1.0 (25) installed, identity verified, normally
launched and running (headset unlocked; exactly one process).

Objective: With an annotated build-24 screenshot, the owner asked: "Let's move the close box to the
upper-right corner and wrap the rest of the tools in a single group." The close box was the circular ✕
above the canvas; the remaining title-bar tools were Undo, Redo, Copy, Share, Export and the inspector
toggle, each drawn as a separate circle.

Authorization: The request covers local edits, builds, tests and documentation; the standing
same-headset signing/install/normal-launch authorization applies. No Git, publication or delegation.
Staged in a private copy against a hashed baseline.

Owners/reuse: `EditorView.documentHeader` owns the title bar; `documentActions` keeps its compact
overflow menu; `request(.close)` keeps Close Image recovery. No new files beyond this record.

## Changes

- `documentToolGroup`: Undo, Redo, Copy, Share, Export and the inspector toggle in one capsule
  (`glassBackgroundEffect(in: .capsule)`, borderless standard buttons with circular hover shape),
  identifier `editor-tool-group`, accessibility container "Image actions". Compact layouts (largest text
  or narrower than 1,100 points) keep Copy, Share, the ⋯ menu (Undo, Redo, Export) and the toggle.
- Close Image moves from its own row above the canvas into the header's trailing corner, after the
  group; the canvas gains that row's height.
- Style choice, from simulator captures of each option in the real header: navigation-style ControlGroup
  draws separate circles (build 24); automatic draws a recessed capsule whose icons are nearly invisible;
  palette collapses to one empty circle. The glass capsule matches the bottom toolbar's groups.
- UI tests: `assertDocumentToolsGrouped()` replaces two assertions that Close was outside the title bar.

## Validation

| Check | Result |
|---|---|
| Core | 67 tests / 5 suites pass, exit 0 (core unchanged) |
| Focused UI | Document switching/close and compact long-title cases (normal and largest text) pass, exit 0 |
| Compositor | One capsule and corner ✕ at normal width; compact and largest text keep the capsule with ⋯ |
| Signed Release | build + analyze exit 0 (28 s); strict signature; 1.0 (25); add-only Photos only; no Debug markers |
| Capture probe | Device-SDK compile exit 0 (compilation only) |
| Native services | 50 / 50 pass |
| Full UI suite | **37 / 37, exit 0, 1,223 s** on the final applied source |
| Application | 12 files; no baseline conflicts; workspace matches stage (123 files) |
| Headset | Install exit 0 (7.8 s); identity 1.0 (25); unlocked; normal launch exit 0 (1.6 s); exactly one process |

Installing build 25 replaced the running build 24; the owner's screenshot had shown build 24 running.
Limits: gaze/hand use of the capsule and corner Close and assistive technology are owner observations.

[Sanitized evidence](../Documentation/Validation/titlebar-tool-group.json),
[physical history](../Documentation/Validation/physical-deployment.json).
