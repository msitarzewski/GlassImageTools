# Review fixes and caption clearance — October 21, 2026

State: complete — reviewed, tested, applied; Release 1.0 (23) installed, identity verified, normally launched and running.

Objective: Fix every finding from the October 21 full-code review and the owner-reported caption that
hides behind the bottom toolbar ornaments, then produce a new build.

Authorization: The owner wrote "Fix all of these... Report back when you have a new build." Local
edits/builds/tests/docs and the standing same-headset signing/install/normal-launch authorization apply.
No Git, publication or delegation. Work was staged in a private copy and compared with a hashed baseline.

Owners/reuse: VisionSnipCore `StrokeColor`/`ImageRenderer` own color validation and output color space;
`EditorModel` owns color conversion, display-axis geometry, Undo availability and zoom; `ImageCanvas`,
`AnnotationInspector`, `ImageDescriptionCaption`, `EditorView` and `DocumentSidebar` own presentation;
`ImageWindowAppearance` owns window-frame constants. No new services or dependencies.

## Findings and changes

| Finding | Root cause | Change |
|---|---|---|
| Wide-gamut colors break rendering | UIKit reports Display P3 palette colors as extended sRGB outside 0–1; `validate` required 0–1 | `StrokeColor` is extended-range sRGB (−2…2, alpha 0–1) with `init(converting:)`; rounding within half an 8-bit step snaps to sRGB; color wells round-trip via `Color(cgColor:)` |
| Rotated annotation fields | Annotation fields/AX values used upright source axes; crop fields used rotated axes | `EditorModel.displayRect`/`displayPoint`/`selectedDisplayBounds`; fields, handle and object values use visible axes |
| Caption can silently never appear | `.busy`/`.notReady` were terminal after build 15 removed retry | Quiet retry: busy every 2 s, not-ready every 30 s while the image is shown; cancelled with the view |
| Undo disabled during first inspector edit | Button used `history.canUndo`; inspector edits commit later | `EditorModel.canUndo`/`canRedo` include a pending inspector change |
| Exports always 8-bit sRGB | Fixed sRGB contexts | `ImageRenderer.workingColorSpace`: Display P3 for wide-gamut sources/colors, sRGB otherwise; tiles keep source gamut; capture previews too |
| Docs contradict app | Build 15/20 owner changes not reflected | `BUILD_BRIEF.md` extension and `decisions.md` supersession updated |
| Cleanups | Dead code, masking errors, unanchored zoom, duplicate ⌘V | Removed `insets`/`pixelatedPreview`/unused inspector path; simplified caret condition; cleanup `try?` keeps original errors; `setZoom(_:around:)` anchors pinch/menu zoom; one Paste per window owns ⌘V |
| Caption behind bottom ornaments | Caption ran to the window edge under the overlapping toolbar | 32-point `bottomOrnamentClearance` below the image column and as sidebar/inspector bottom scroll margins; caption text aligned with the 36-point canvas inset |

The simulator compositor before the change shows the caption's last line clipped at the window edge with
the toolbar ornament over it (about 11 points of overlap head-on); after the change the full caption ends
above the ornament. Baseline probes reproduce `invalidDimensions` for an extended P3 color and a clipped
P3 export (`[117, 251, 76]` instead of vivid green).

### Found during QA

- **Paired dimensions (pre-existing since build 19).** In the 380-point inspector Width/Height and
  Left/Top stacked, contrary to the owner's October 15 same-row request. Paired fields now show their
  label above the value; accessibility sizes and narrower rows still stack labeled rows.
- **Color well binding (introduced, then fixed).** Returning `Color(cgColor:)` made the native palette
  intermittently drop a selection (2 of 3 repetitions passed; build 22 passed 3 of 3). Returning
  value-equal extended `Color(.sRGB, …)` passed 5 of 5 and keeps P3 values.
- **Conversion rounding (introduced, then fixed).** Display P3 white converts to 1.0000001; values within
  half an 8-bit step now snap to sRGB so ordinary colors keep sRGB output.
- **Stale UI tests (pre-existing).** Six cases failed identically on build 22: hittability-only Form
  reveal and buttons-only "Select All" helpers, native toggles queried as buttons, collapsed Recents,
  an assertion racing picker dismissal and a largest-text form needing scroll. Shared helpers in
  `EditorTestActions.swift` now serve all suites.

## Validation

| Check | Result |
|---|---|
| Core | 67 tests / 5 suites pass, 0.823 s, exit 0 (new `ColorGamutTests`) |
| Native services | 48 / 48 pass, including 4 new review-fix checks and 2 add-only Photos saves |
| First full UI run | 28 / 37; baseline comparison: 7 failures identical on build 22, 2 stage regressions |
| Final full UI suite | **37 / 37, exit 0, 1,254 s** on the final applied source; prior-source run also 37 / 37 (1,164 s) |
| Palette repetitions | value-equal binding 5 / 5; build 22 3 / 3 |
| Compositor | Full caption above the bottom toolbar; paired inspector fields readable |
| Signed Release | build + analyze exit 0 (35 s); strict signature; Glass Image Tools 1.0 (23), family 7; add-only Photos only; no Debug markers; two expected AppIntents skips |
| Capture probe | Device-SDK compile exit 0 (compilation only) |
| Application | 33 files; no baseline conflicts; workspace matches stage (121 files) |
| Headset | Install exit 0 (7.6 s); identity 1.0 (23); unlocked; normal launch exit 0 (0.67 s); exactly one process |

Limits: simulator compositor/automation evidence plus installation/launch. Physical appearance of the
clearance (ornament parallax), gaze/hand input, hardware keyboard ⌘V, assistive technology and a real P3
palette pick on hardware remain owner observations. Output is 8-bit SDR; HDR headroom is not preserved.

[Sanitized evidence](../Documentation/Validation/review-fixes.json),
[physical history](../Documentation/Validation/physical-deployment.json).
