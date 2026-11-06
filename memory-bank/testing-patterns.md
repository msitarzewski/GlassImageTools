# Testing patterns

[Verified status](../Documentation/STATUS.md) owns actual results; this page defines what each check proves.

## Sidebar hierarchy — build 34

Test actual layout and row selection: this runtime's DisclosureGroup put children inline and passed compilation while breaking document switching. The corrected native flat List uses direct conditional children; whole-row targets, empty states, expansion, per-document Undo/close/Recents, ⌘V after category taps, largest text and clear/opaque/default-glass compositors are required. A standalone isHittable readiness predicate also fails on the unchanged build-33 sidebar despite successful native taps. Preserve that diagnostic; assert actual tap outcomes, geometry, enabled state and audits rather than treating the simulator property as physical gaze evidence. [Exact results](../Documentation/Validation/sidebar-hierarchy.json).

## Native start/sidebar follow-up — October 29, 2026

Core 69/5 includes actual data/file NSItemProvider decoding, private-copy ownership, original/copy byte equality and contextual Drop/Paste recovery. Focused UI cases cover real tap/Command V after Copy/Close, compact/largest text, native List disclosure/document selection/Undo/close/Recents and all-issue empty-screen audit. Record final native command exit separately from completed assertions.

A Debug-only, doubly gated image drag source records whether the synthetic gesture begins and ever reaches the target. Skip only when the automation never starts a system drag; an initiated but unsuccessful drop must fail. Provider tests do not establish cross-app hand/gaze delivery. Keep the task simulator visible in Xcode 27's Device Hub when possible, announce any necessary headless run, and shut down only that task-owned runtime afterward so no hidden audio remains.

## Current evidence and reproduction scope

The [release notes](../Documentation/RELEASE_NOTES.md#recorded-validation) link per-build results.
Build 23 (October 21): core 67 tests/5 suites, 48 native service checks and the full 37-case UI suite
(exit 0, clean finalization) pass on the final applied source. Prefer the full suite after shared
presentation or helper changes; focused runs between builds 19 and 22 let seven failures go unnoticed.
Use `-collect-test-diagnostics never` and a dedicated simulator; compare a failing case against the
unchanged baseline before attributing it.

For build 21 onward, header ancestry uses `editor-titlebar`/`editorTitleBar`, not a NavigationBar query.
Crop-mask review includes full compositor fit/zoom/rotation/Annotate/reset views; clip only the mask to
the image Canvas viewport. Keep real crop/zoom/Pan drags, Copy and Undo assertions. A passing audit or
interaction case alone did not reveal the earlier margin spill.

## Core regressions

Run `swift test` on the local `VisionSnipCore` package for geometry/rendering/history changes. Use small,
deterministic synthetic fixtures except for a deliberate bounded large-image case. Check output pixels,
not only success returns or private implementation flags. Existing coverage includes all EXIF orientations,
mirrors/crops, preset/anchor constraints, zoom/letterbox transforms, annotation clipping/movement, metadata,
PNG alpha, JPEG white flattening, original byte preservation and source-resolution export.

The security remediation adds meaningful adversarial cases: translucent checkerboard pixelation in both
formats, crop crossing a source-anchored pixelation grid, annotation composition order, non-finite/extreme
numeric values, inspector transaction/preset history, malformed/forged image input and cancellation/resource
ownership. Record final suite counts from actual output; parameterized cases and test definitions differ.

Inspect actual encoded output for privacy claims. The source fixture must demonstrably contain GPS before
checking GPS/private EXIF/TIFF removal and a single image in PNG/JPEG output. Fractional redaction tests
sample outward-aligned edges/corners and unchanged pixels outside the region; alpha tests exercise both
formats. Reimport both formats under neutral filenames to verify content-based decoding and preserved bytes.

Live-canvas regressions compare actual shape/fill/text/pixelation pixels with the full-resolution renderer,
including crop clipping, transparent replacement and preview-cache invalidation. Typography cases cover
wrapping, alignment, selected traits, short editable boxes and history preservation.

Temporary-storage tests use isolated roots: prior-session purge, repeated preparation/live ownership,
private permissions/backup marker, visible preparation failures, symlink rejection and unowned-path cleanup
boundaries. They must preserve unrelated/original files and permissions. For forced termination, create a
synthetic real export, SIGKILL only the verified test app, observe the abandoned file, then launch normally
and verify only owned roots were purged. Host/simulator success does not verify locked-headset protection,
backups, immediate post-kill deletion or physical secure erasure. See [the recovery evidence](../Documentation/Validation/force-quit-cleanup.json).

## Simulator service checks

`EditorIntegrationChecks` is compiled only in Debug and runs only under explicit testing arguments.
The historical smoke route exercises the same export, clipboard and Photos service owners used by the UI.
It decodes PNG/JPEG at expected dimensions, reads system pasteboard data and standard UIImage representation,
and creates new Photos assets with add-only authorization. A real pasteboard round-trip proves those
representations are usable locally; it does not prove a recipient application accepts them.

The editor iteration adds saved-state/dirty undo, stale save rejection, failed/cancelled replacement,
typography transactions and duplicate/order/mode-retention checks. Only Files/Photos completion marks a
matching source/edit snapshot saved; Copy/Share does not.

Inspect the current argument handling in `EditorView` before invoking fixture/smoke mode. Never leave
these arguments on an ordinary hardware install or present fixture data as a user's image.

## Experimental lifecycle host check

The production `CaptureLifecycleQueue` is independent of ScreenCaptureKit and can be compiled with the
standalone deterministic verifier. This exercises serialization and stale-request/frame ownership on
the host; it does not simulate system consent, actual streams or hardware capture:

```sh
swiftc -swift-version 6 CaptureProbe/CaptureCapabilityProbe.swift Tools/VerifyCaptureLifecycle.swift \
  -o /tmp/GlassImageTools-capture-lifecycle-check
/tmp/GlassImageTools-capture-lifecycle-check
```

Read its exit status and record the actual checks. Device SDK build and physical lifecycle verification
remain separate requirements.

## Native build and static inspection

Build the native main app after UI/service changes and regenerate XcodeGen after target/settings changes.
Compile the device-only probe separately when its lifecycle changes. Release validation checks test fixture
and smoke code exclusion and permission scope. Build/analyze can find compile/static issues; it does not
establish absence of runtime, decoder, numeric, resource or async lifecycle defects.

## UI automation

`UITests/GlassImageToolsUITests.swift` exercises the real native app and explicit Debug fixtures.
Canvas identity must remain stable in Crop and Annotate mode while crop handle children remain accessible.
Tests should change numeric dimensions through actual typing, commit the inspector, undo once, and verify
the original dimensions/copy result. Drawing tests must hit the actual canvas and observe selection/delete
or undo state rather than merely finding a toolbar button.

Exercise text replacement and font-size typing through the native text field and selection menu; typing
`64` must survive the incomplete `6` intermediate and undo as one transaction. For handle drags, prefer
native element-to-element targets that remain inside the source. Assert source-pixel accessibility values
change, unrelated endpoints stay fixed, and Undo restores them. A coordinate drag beyond a source boundary
cannot establish a resize failure. visionOS ornament frames use a separate space; do not compare their raw
frames to canvas frames or treat a clipped app-element capture as full-window visual evidence.

Check crop-axis labels after exact-dimension edits, Undo/Redo and zoom; values must remain source pixels.
Compare the filename/details' leading edges within their shared title surface. Text tests should reopen
controls with an ordinary object tap, then use a native object hold for its context menu and verify a hold
on empty canvas exposes no selected-object actions. Menu previews must reuse the complete redaction-safe
composition; never draw an unredacted original beneath a separate overlay.

For the build 7 plain-window layout, put image drag/tap gestures on the visible `VectorImageLayer`;
a clear sibling layer is not interchangeable for actual event delivery. Debug-only
`EditorCanvasTestTargets` provide native scene-local start/end elements, pass hit testing through and
run only with `--ui-testing`. They route synthesized input through the production gestures rather than
creating annotations directly. Verify that the target definitions and call sites are both excluded from
Release. Keep the canvas's stable identity, crop handles and object-specific menus accessible.

Round floating geometry safely for whole-pixel display after validation, rather than truncating a value
such as 299.999… to 299 when the intended width is 300. Safe bounded rounding and an actual simulator
model/service regression now verify a fractional-origin annotation with typed width 300 and exact whole-object
Undo. Test the inspector's displayed width and stored geometry as well. Do not weaken a 300-pixel
assertion merely to accept a conversion artifact.

Appearance tests should drag the actual native slider knobs, read observable percentages, dismiss/reopen
and relaunch to prove persistence, then reset to Opacity 0%/Glass 100%. Inspect the real accessibility tree
for the read-only Material row; query the observed combined `Material, System Glass` label rather than
assuming a separate value element. Verify the
gear remains available with no image, appearance does not add history or change crop-axis values, and
the Reduce Transparency source policy forces an opaque resolved background while disabling sliders/reset.
That override was source-inspected but not toggled in simulator or on hardware during build 7 verification.
Compare the native top title and bottom magnifier/zoom placement visually within their own ornament coordinate
spaces. A clipped app-element screenshot cannot prove the complete window appearance.

Build 7's earlier QA runs are retained as defect evidence. The initial 11-case UI run finished five
passes/six failures, and the first
focused rerun had three failing tests/seven assertions. Native settings drags observed Opacity 0% → 4%
and Glass 100% → 0%. A mistaken Material accessibility assertion failed; the test continued and its later
persistence/reset assertions passed, while the overall case remained failed. After moving canvas gestures
onto the visible image layer, a focused **two-case** run produced **one text pass** (27.093 seconds) and
**one rectangle failure**: its only failing assertion was an intended 300-pixel width displayed as 299.
The rectangle gesture itself succeeded. Its assertions completed before diagnostic collection stalled;
only that invocation was stopped, with command exit -15. Do not describe it as a successful command or
confuse stalled diagnostics with the completed assertions. Subsequent final runs completed normally.

After bounded display rounding, the full **11-case UI suite passed with zero failures in 277.766 seconds,
exit 0**. A later caption-only `fixedSize` adjustment kept the native slider minimum/maximum labels on one
line; the focused appearance case passed **one/zero in 32.615 seconds, exit 0**. Accessibility frames for
Transparent, Opaque, No Glass and Full Glass were each one line and 14.5 points high; the captured app image
remained clipped and is not full-window visual proof. All **15 actual simulator model/service checks passed**,
including fractional-origin width 300/exact Undo and real PNG/JPEG export, pasteboard and Photos operations.

Signed Release build/analyze, separate unsigned probe SDK compilation and Release boundaries passed:
Debug symbols, canvas marker strings and test arguments were absent; only add-only Photos usage was present,
and the compiled layered AppIcon was verified. Applied source exactly matched tested hashes. Core source
and test hashes were unchanged from the prior **42-test** baseline, so that suite was not rerun. Release
**1.0 build 7** installed/launched normally on physical visionOS 27.2, with identity/process readback.
New physical interaction/icon behavior remains unobserved; the source-inspected Reduce Transparency policy
has not been toggled. [The task record](261015_editor-polish-and-glass-icon-plan.md) and
[sanitized iteration evidence](../Documentation/Validation/window-appearance-and-icon.json) retain final
results alongside the failed-run history. No required assertion was waived.

Use a concrete simulator destination with `xcodebuild test`. Only one event-driving UI suite should run
at a time on the chosen simulator. Preserve assertions and exit status; an Xcode result-finalization stall
is distinct from a completed passing/failing suite. Build-for-testing proves compilation only.
Use app-element captures where supported; simulator workspace captures remain private temporary material.


## Foreground layering checks — build 8

Test native appearance at all three states: Opacity/Glass **0/1**, **1/1** and **0/0**. Preserve exact
crop values and Undo history across slider changes; create a rectangle above an opaque background, then
create/re-edit/undo text above a clear background. Drive real slider knobs and native selection menus,
including relaunch persistence/reset. Do not replace retained pixel/history assertions with loose success
checks when event synchronization fails.

A forward-offset foreground first produced one pass/three failures/five assertions. Leaving it at the
normal interaction depth and moving only the background rearward corrected those input regressions.
The rear-only four-case run passed crop/copy/export, endpoint movement/Undo and object text context;
its appearance case failed three assertions because the new crop-width-1200 setup typed before the
native selection menu was ready. Waiting for actual Cut/Select All fixed the test synchronization while
retaining every 1200-pixel, history, slider-extreme and input assertion. The final appearance retry passed
**one/zero in 113.651 seconds, exit 0**. Together these runs verify **four unique UI cases**; production
source did not change between the rear-only run and focused retry. The full eleven-case suite was not rerun.

Visual testing is separate from accessibility/input assertions. Manual XCUIScreen screenshots were
unsupported and their attachments prove no foreground ordering. Settled native `simctl` compositor
captures used the synthetic fixture at three states through temporary Foundation argument-domain
preference overrides. Actual slider endpoints and persistence were independently exercised by UI tests;
the preference overrides do not substitute for those interactions. Keep raw workspace captures private
and publish sanitized comparison metrics only.

Seven sampled opaque color interiors were pixel-identical across all states. Over the measured
**1,031,318-pixel** image region, glass versus opaque was identical. Clear differed in **2.63%** of pixels
with maximum channel difference **18** and mean **0.0987**, limited to small rendered-edge differences in
the observed comparison. This supports the measured foreground check, not full-scene bit identity, source
alpha flattening or physical-headset visual acceptance. Native text/buttons remained visible with their
ornament styling. Retain the failure history and measured limits in
[foreground evidence](../Documentation/Validation/foreground-layering.json).

Signed Release build/analyze, separate unsigned probe SDK compilation and Debug/permission boundaries
passed. Applied hashes exactly match tested source. The core 42-test and native model/service 15-check
baselines remain unchanged by source hashes and were not rerun. Physical installation/build-8 identity
passed. Two normal-launch SDK commands timed out after 40 and 30 seconds; a completed process query after
the first found no matching process. Normal launch remains unverified and no timeout cause is established.
Physical foreground appearance and a toggled Reduce Transparency override remain unobserved. The source,
focused UI and compositor verification is complete; hardware launch/appearance is a separate limit.

## Physical acceptance

For any hardware claim, record app version/build, OS/SDK scope, exact user action and observed result in
sanitized form. Test screenshot selection, zoom/pan/crop precision, annotation editing, undo/redo, copy/paste
into the actual recipient, share to claimed recipients, Photos/Files saving, original preservation and
large-image responsiveness/resource usage. Launch alone is not acceptance. Eye/hand behavior and maximum
safe memory require physical measurement.

For capture, test system consent/source choice, cancellation/revocation, complete-frame freeze, direct editor
handoff, repeated start/stop, background/close/interruption and each claimed content scope separately.
Capture tests stay outside the main editor's acceptance. Unsupported API declarations and no observations
are different outcomes; keep both explicit in [the matrix](../Documentation/CAPTURE_CAPABILITIES.md).

## Native UX and accessibility checks

UITests/AccessibilityAuditTests.swift runs native app audits with .all and ignores no issue. Standard
cases cover empty/import, canvas/ornaments, all forms, selected color/style, text, PNG/JPEG output, close
and malformed paste recovery. The largest-text case requests the native accessibilityXXXL category and
asserts stacked dimensions; also run with simctl content_size accessibility-extra-extra-extra-large and
increase_contrast enabled, saving/restoring prior settings. Runtime audits cannot replace VoiceOver/Voice
Control/Switch Control speech/focus or hardware keyboard/eye-hand acceptance. Apple's color service
rejects performAccessibilityAudit with -902; test actual RGB/readback/color/Undo through its native UI
without launching that service. Keep this tool restriction explicit; do not suppress app audit findings.

The 15-case functional suite includes actual zoom 225% crop drags with Pan/Undo, native Paste Cancel/Discard
and empty-window replacement, same-row dimensions, Add at Center and real cancellation. Query native
toggles by their actual accessibility role rather than assuming Button. Debug canvas gesture markers
have real 60-point accessible surfaces while passing input through to production gestures.

The build 10 Debug service smoke expected 24 checks with Photos saving: actual PNG/JPEG NSItemProviders, malformed
providers, Progress cancellation/late completion, closed-document rejection, transferred-copy cleanup,
shared Files import, all non-freehand insertion/style/Undo, original bytes, export/clipboard and Photos.
A native compositor check is required for large-text ornament/crop-label occlusion because those surfaces
have separate coordinate spaces. Failed assertions and stopped result-finalization remain distinct from
passing cases/commands. [The audit](../Documentation/ACCESSIBILITY_AUDIT.md) records actual coverage/limits.

## HIG follow-up verification — build 11

Core now has 57 test definitions/three suites. New cases cover one-pixel proxy resize/opposite anchors,
coincident/short/clipped endpoints, narrow finite fallbacks and recentering at existing zoom. Debug native
smoke expects 30 checks with Photos: six added outcomes cover contextual kind precedence, prepared text,
pixelation units, persistent inspector/gesture/Undo boundaries, reveal invariance and real native PNG
Transferable bytes. After Undo/Redo of creation, explicitly select the restored object before testing
reveal; Redo does not imply reselection. Preserve failed fixture results separately from product defects.

`UITests/HIGPolishTests.swift` adds six functional/layout cases. Debug-only minimum-window/long-title flags
feed synthetic images through actual import; Release excludes these fixture flags/types. Match the
content window and ornament hosts by their controls, assert visible bounds and select actual menu command
names, including Pixelate. Accessibility existence/hittability alone cannot prove compositor visibility.
Use actual native compositor captures for title/crop occlusion, panel visibility and readable captions.
Raw room/window images stay private. App `.all` audits ignore no findings; no hardware certification follows.

Use an isolated simulator so other windows and consent prompts cannot confound image/interaction evidence.
For save regressions, pregrant only add-only Photos on that simulator with `simctl privacy "$SIMULATOR_ID"
grant photos-add "$APP_BUNDLE_ID"`. This is test setup, not evidence of first-run consent tapping. Keep the
manual consent gap explicit. Save/restore Increase Contrast and launch the app normally without fixture
arguments afterward. Do not change another simulator or the unavailable headset.

Record command exit status, case/suite outcomes, source hashes and finalization separately. The broad
25-case build-11 run passed 24 cases; corrected compact-menu/largest-text checks passed two/zero with exit 0.
All 25 cases passed across recorded runs, not in a clean full-suite command. Failed command finalization
was bounded/stopped after summaries; no missing failure lines were used as proof. The later Debug-only
service-fixture correction was rebuilt/installed and all 30 actual checks passed; no production UI changed.
[Evidence](../Documentation/Validation/hig-fixes.json) preserves failures, correction and exact scopes.

## Native Glass follow-up — build 12

Reuse the existing HIG/layout, shape, crop/Pan, appearance and native audit cases. The largest-text HIG
case now asserts actual toolbar-host width against the content window and opens Edit Text through the
compact overflow menu before auditing its panel. A native audit passed the first 802/720 overhang;
compositor/hierarchy review exposed it. Final native width is 715.5/720. Keep the original observation
and correction; do not reinterpret initial passing assertions as complete layout acceptance.

Thirteen unique cases passed across three clean commands; core/model/service owners were unchanged and
57/30 baselines were not rerun. Final source hashes match the focused final UI and signed product. Run
normal glass previews with normal contrast; separately test largest text with Increase Contrast and
restore it. Earlier contrast-enabled images do not isolate code-driven material changes. Keep raw
compositor frames private and restore normal app launch after synthetic preview.
[Validation](../Documentation/Validation/native-glass-chrome.json).

## Sidebar and image-description checks — build 14

Use the shared XCUIApplication.showToolOptions action to ensure the automatic right pane is shown;
blindly tapping its new sidebar toggle would close it. Existing tool/color/text/crop/Undo assertions remain.
The new HIG case exercises automatic presentation, hide/show values, a real caption or explicit failure,
retry, actual main-column text/canvas bounds and removal on close. Largest text checks native toolbar/
panel all-issue accessibility plus caption bounds and usable canvas height. Inspect compositor pixels
before calling a reduced-scale visual concern a defect: the initial horizontal-overflow concern was
not confirmed by pixel-crop inspection. Full text is retained for native help/accessibility/selection.

Final app source passes ten distinct cases across the broad nine-pass/one-palette-presentation-failure
command (native exit 65) and a focused color retry (one/zero, exit 0). No assertion was weakened. The added
palette compositor checkpoint computes presentation success before its delay. Its capture shows the
editor panel, not palette composition; actual native RGB controls/live update/Undo are the evidence.
The initial failure's cause is unknown. Preserve its three assertions and the failed native command.
Private helper scripts must propagate xcodebuild status; read the native result JSON as well as the outer
wrapper status. A successful wrapper alone is not test success.

Real FoundationModels generation is availability-dependent, not a deterministic expected sentence.
The exact production service in a temporary signed native check app generated nonempty text from a
synthetic image on physical Vision Pro, with actual model/vision capability. The check app was removed.
This proves the API path; it does not establish semantic accuracy or physical editor gaze/appearance.
No controlled mid-inference replacement or peak-memory experiment is claimed. Core/model/render/export
owners are unchanged; the existing 57/30 baseline is retained rather than counted as a new run.

## Drawing/panel/caption checks — build 15

Use deterministic Debug-only long/unavailable descriptions for native layout and quiet-state tests; these are not real model-generation evidence. Query the adaptive caption by identifier across element types: ViewThatFits exposes a ScrollView at constrained/largest sizes. Swipe the actual native scroll view and prove text moves while the canvas remains usable. Native scene gestures use actual handle-to-handle element targets; assert dimensions changed before Undo restores them. Repeat strokes with the pen selected, verify no handles, switch Select and prove retained vector resize and independent Undo/Redo. Preserve all audit issues; no ignored app finding.

Nine distinct cases pass across broad seven/nine and focused four/four (native exit 0); initial failures and reporting limits stay in [validation](../Documentation/Validation/drawing-and-sliding-tools.json). Signed/applied/native app hashes match. Hardware motion/input/assistive technology and semantic accuracy remain separate.

## Natural caption sizing — build 16

Native geometry measures the padded content and sizes the existing ScrollView to its actual height up to the safety ceiling. Verify a short caption leaves only modest margins, then open Tool Options in a compact window and assert actual height growth as text wraps. Observed 52.5 → 72.5 points. Long/largest captions must still scroll with usable image area; unavailable states remain absent. Four cases and a strengthened compact repeat pass; [validation](../Documentation/Validation/caption-natural-height.json). The earlier build-15 ViewThatFits accessibility-type behavior above is historical; build 16 consistently uses a native ScrollView.

## Native left sidebar — build 17

Query the stable annotation-panel identifier across native accessibility types: the formal sidebar exposes a CollectionView. Keep native sidebar content declared while visibility hides it, and verify Done survives reopening Text and actual system color return. Verify actual RGB/Undo and field transactions, not only presence. Test compact/largest window expansion and foreground caption heading/text, because the native scroll-container AX frame can span more than its visible content. Keep actual scroll movement, usable canvas, minimum-toolbar and all-issue app audits. [Validation](../Documentation/Validation/native-left-sidebar.json) distinguishes early failures, final five-case pass and prior editor successes; hardware assistive/input/material acceptance remains separate.

## Rotation and native split defaults — build 18

Check all quarter-turns, source-corner anchor/delta mapping at zoom/pan, EXIF composition, original bytes, actual PNG/JPEG pixels/metadata and translucent redaction. Native model checks must cover exact visible dimensions and decoded clipboard pixels. Native UI must exercise real rotated handle drags, Undo/Redo, retained text targeting, native sidebar lifecycle/color return, menu Paste replacement and compact toolbar bounds. Match native number formatting. Invoke a menu action only after opening its menu; do not leave a menu open while querying unrelated controls. Caption text-selection accessibility insets require 16-point margins at the loaded window edge. Default item availability/compilation does not establish runtime rendering. [Evidence](../Documentation/Validation/sidebar-defaults-and-rotation.json).


## Document navigation and right inspector — build 19

Use actual native List selection, new-image Paste, per-document Undo/Redo and close Cancel/Discard,
then reopen a recent and clear it. Test both visibility toggles independently and keep New Image
reachable with navigation hidden. Property Forms now live to the right: scroll the identified
annotation-panel/crop-panel collection, not the first collection (which is the Images sidebar).
Unnecessary identifiers on a container can forward onto child native elements and mask semantic
identities; inspect the real accessibility tree. Assert filename/details alignment and largest-text
canvas/toolbar/caption bounds. Use proven native field selection or preset actions; repeated backspaces
on a formatted numeric binding may restore/clamp each intermediate value instead of replacing text.

Native service checks exercise encoded flattened recent reopening, stable-ID save rejection, independent
model/history/viewport, count/storage rejection and actual private-file removal after Clear Recents.
Core image/render/metadata tests remain required. Physical input, resource profiling, recipient and
capture acceptance remain independent of simulator results.

## Native grouped controls and sidebar disclosures — build 20

ControlGroup can promote Buttons into native toolbar items while retaining labels and dropping SwiftUI identifiers. Resolve the real visible/spoken label as a fallback and exercise the actual command. Put panel identifiers on the Form before safeAreaInset so they cannot mask header Done. Assert metadata/Close/Done membership through native navigation-bar ancestry; avoid cross-surface ornament coordinates. Exercise Section disclosures, collapsed Recents/reopening, in-pane confirmation, immediate Shapes tap, independent columns and actual new-window acquisition/picker return. In the observed two-window layout, both duplicate controls reported hittable with identical scene-local frames. The fixed second-control picker test failed; selecting the first hittable hierarchy control and exercising both real picker cancellations passed. Do not infer physical visibility from those hints alone. Completed assertions and Xcode result-finalization exit status remain separate. [Evidence](../Documentation/Validation/sidebar-and-toolbar-refinement.json).


## Transparent workspace regression

Exercise actual Opacity/Glass endpoint gestures, persistence/reset and both visible side panels; inspect
full compositor screenshots because application captures omit native ornaments. Assert actual edits,
Undo and native palette outcomes across appearance extremes. Navigation-container absence catches the
extra material owner but does not itself prove pixel transparency. In plain native Forms a fully visible
row may report a nonhittable point to XCTest: stop reveal-scrolling at a contained viewport row, then keep
the real tap and resulting selection/edit assertions. Scope Done to its sheet/pane identity. Native
numeric replacement uses tap/word selection; retain exact field and output-pixel assertions. These are
simulator automation observations, not physical gaze or assistive-technology certification.
[Task](261019_transparency-regression.md).


## Color gamut, rotated fields and ornament clearance — build 23

`Tests/VisionSnipCoreTests/ColorGamutTests.swift` converts an actual Display P3 color, renders it, and
reads exported pixels back in Display P3; a P3 PNG source must keep vivid green through export and
pixelation (an sRGB-only pipeline yields about `[117, 251, 76]`). sRGB inputs must still export sRGB, and
unbounded or nonfinite colors must still be rejected. Keep an `ExportedImage` alive while reading its
decoded pixels: its owner deletes the file and ImageIO decodes lazily.

Native service checks cover a real `Color(.displayP3, …)` through `EditorModel`, rotated annotation
fields (use a value that differs from the inserted size), Undo/Redo availability with a pending inspector
edit, and zoom anchoring checked through `CanvasTransform`. UI cases assert rotated Width/Height values,
Undo enabled before Done, quiet caption retry via `--ui-test-busy-description`, and caption text ending at
least the clearance above the content window. Ornament overlap itself needs a compositor capture.

Inspector reveal and edit-menu helpers live in `UITests/EditorTestActions.swift`
(`revealInInspector`, `editMenuAction`); reuse them rather than per-suite copies, which drifted after
build 21 (hittability-only reveal, buttons-only "Select All"). Native toggles are switches/other elements,
and Recents starts collapsed. Repeat a system-palette case several times when its binding changes:
one passing run did not reveal the intermittent dropped selection fixed in build 23.


## Toolbar actions, + menu and keyboard commands — build 24

Shapes are created with the real canvas drag (`drawShape` in `UITests/EditorTestActions.swift`); Text and
Pixelate are toolbar actions that place a selected object without a canvas tap. Import, Paste and New
Window are reached through `openNewImageMenu()` (`new-image-menu`). Inspector titles are asserted through
`inspectorTitle` (`inspector-title`): the object name, "New …" for a tool's style, or "No Selection".

Synthesized swipes are origin-sensitive in the visionOS simulator. A swipe that begins on a color well,
slider or toggle row may leave a Form unscrolled, and `swipeUp()` on the Form starts at its center. After
a drawn rectangle, that center is the Fill toggle; build 23 never reached this because it created shapes
with Add at Center. `revealInInspector` therefore tries the Form, then each visible row from the bottom
up, until the rows move. Do not reintroduce per-suite reveal copies or a single fixed swipe origin.

Drag selection handles element-to-element (`handle.press(forDuration:thenDragTo: element)`). A
coordinate press-drag from the same handle reaches the canvas move gesture instead, moving the object
without resizing; builds 23 and 24 behave identically. A drawn shape's top-left corner is
`canvas-test-start`, and Text/Pixelate sit at the crop center (with a 30-point hit margin), so choose
"empty canvas" and drag destinations relative to where the object actually is.

Hardware-keyboard commands can be exercised with
`app.typeKey(XCUIKeyboardKey(rawValue: "n"), modifierFlags: .command)`. In `--ui-testing` windows count
canvases, not acquisition buttons, because a new window loads the fixture. Scene `EditorCommands` own ⌘N
and ⌘,; control shortcuts inside a closed Menu or toolbar ornament were observed not to register, and
`PasteButton` did not honor ⌘V, so image paste by keyboard is not claimed. "Copy does not block editing"
is a native service check: `copying` toggles while `busy` stays false and the pasteboard receives PNG.
[Task](261021_toolbar-sidebar-and-inspector.md).

## Grouped title-bar tools — build 25

`assertDocumentToolsGrouped()` in `UITests/EditorTestActions.swift` checks that Copy, Share and the
inspector toggle are inside `editor-tool-group`, that Undo/Export are there directly or behind its
`editor-actions-menu` overflow, and that Close Image is outside the group, after it and at the title bar's
trailing edge. The document-workspace and compact long-title (normal and largest text) cases call it.
Judge ControlGroup styles from compositor captures, not frames: the automatic style reports normal button
frames while drawing near-invisible icons. [Task](261022_titlebar-tool-group.md).


## Website screenshots and site checks — build 26

Site screenshots come from the real app, never from mockups. A scratch-only UI test (`SiteScreenshotTour`,
kept out of the repository) launches the app **without** `--ui-testing`, so no fixture or canvas gesture
targets appear. The test runner writes a demo PNG to `UIPasteboard.general` and taps **+ › Paste**; the host
script captures `xcrun simctl io <sim> screenshot` at each `PROBE_READY|name` line. Use a fresh simulator
so no other app's window sits behind the editor. Lessons from six iterations:

- **Type crop Width/Height before Left/Top**; a position typed while the crop is full-width clamps to 0.
- **The first drag after switching to Annotate can be lost**; draw a shape first that is safe to redo,
  or draw after another canvas action. Start every drag on empty image area, not on an existing object.
- **Inspector Form rows are lazy**: reveal a field by scrolling before checking it exists.
- **Reading the pasteboard from the test runner shows a system paste banner** in later captures; read
  the copied PNG last. The paste banner after **Paste** also lasts several seconds; wait before capturing.
- Tap empty canvas beside the image to clear a selection before a "clean" shot.
- The exported/copied PNG saved by the runner is real app output, usable as an honest "after" image.

Site checks: `python3 scripts/build_site.py` (exit 0), a local link and anchor check of `_site/`, no
horizontal overflow at 390 px, alt text on every image, and Lighthouse accessibility in light and dark.
[Task](261022_website-icon-and-license.md).

## Sidebar rows, the + and a screenshot retake — build 27

The sidebar's own rows keep every identifier the suite uses (`open-document-*`, `recent-document-*`,
`clear-recents`, `document-sidebar`); the section headers are still buttons named "Open Images" and
"Recents", so the disclosure assertions and all-issue audits passed unchanged (37/37). Rows carry
`isSelected` explicitly now that no List supplies it.

Retaking the site screenshots after a UI change: copy the stage, add `SiteScreenshotTour.swift` to
`UITests` and run `xcodegen generate` (the only project difference is that file), `build-for-testing`, then
run the tour through the capture script with `TEST_RUNNER_TOUR_DEMO_DIR` pointing at a folder holding the
demo PNGs (the runner writes the copied output there). With the window unmoved, the build-26 crops of the
3840 × 2160 captures still frame correctly: hero 2200 × 1320 at (820, 560) → 1800 wide; + menu and two
images 2040 × 1230 at (900, 600) → 1400 wide; inspector shots 1460 × 1170 at (1440, 630) → 1200 wide.

Owner-reported hardware results are recorded with their date and quoted wording, and with what wasn't
specified (build, shortcuts, apps); tooling doesn't observe them. On October 23 the owner reported a
hardware keyboard, Photos/Files saving and pasting into apps other than ChatGPT.

## Round picture icon — build 28

An icon-only change is checked through the generator, the catalog and the simulator rather than the UI
suite: the generator's layer checks (Back opaque; Middle inside radius 490; Front clear inside 450 and
opaque from 462 to the edge), `actool` for `xros` with warnings and notices on, `assetutil` on the
Release `Assets.car` (SolidImageStack, three 1024-pixel vision layers), and the masked composite compared
with the approved proof. The simulator's Home View shows the system's rendering: install a Debug build and
capture with `simctl io … screenshot` once the install animation is over (a capture taken during it shows
the icon dimmed). Lighting, emboss and layer movement when looked at need the headset.

## Site builder and footer — October 24, 2026

Change the builder separately from the layout, then prove it: build with the old builder and the new one
against the same layout and compare `_site/` byte for byte (26 of 26 files identical). Then change the layout
and confirm each page differs only by the intended lines. Exercise the edge cases in a scratch copy: no
`PRIVACY.md` with pandoc off `PATH`, `PRIVACY.md` without pandoc, a `.DS_Store` in `site/static/`, and a
Markdown test document with titled, folder, anchored, footnote, autolink and inline-code links. Build with
macOS's `/usr/bin/python3` (3.9) as well as Homebrew's. Lint the workflow with `actionlint` and check each
pinned commit against its tag with `gh api`. [Task](261024_autopaper-footer-and-builder.md).

## Privacy manifest and listing — build 29

When app Swift sources are hash-identical and the change is a resource or an Info.plist key, check the
product instead of rerunning the UI suite:
- `swift test`, a Debug simulator build and the signed Release build/analyze;
- in the Release bundle, the Info.plist values (`CFBundleVersion`, `ITSAppUsesNonExemptEncryption`);
- the manifest at the bundle root, byte-identical to the source and passing `plutil -lint`, with no
  framework manifest;
- the required-reason symbol scan ([build and deployment](build-deployment.md#privacy-manifest-and-export-compliance));
- a simulator install and launch, to confirm the bundle starts.

Check listing fields against App Store Connect's limits: name and subtitle 30; promotional text 170; keywords
100, with none from the name or subtitle; description and review notes 4,000.
[Task](261025_app-store-preparation.md).

## About in Settings — build 31

A change to the Settings sheet reruns the four UI tests that open it:
`AccessibilityAuditTests/testNativeAccessibilityAuditForEditorSheetsAndText`, `…AtLargestTextAndIncreasedContrast`,
`GlassImageToolsUITests/testAppearanceSettingsPersistAndReset` and `HIGPolishTests/testPanFeedbackAndReadableAppearanceEndpoints`.
Both audits open About (`settings-about`), compare `about-version` with the UI test bundle's own
`CFBundleShortVersionString` and `CFBundleVersion` (the project sets both for every target), find the three
links and audit the page. Don't tap the links: they leave the app for Safari.

Look at a sheet in the simulator before calling a layout done. The first About link, a last row in the
form, passed its test (the helper scrolls to it) but sat below the fold, where nobody would find it.
For a single retaken site picture, a short scratch tour (open a pasted image, Annotate, the inspector, then
the sheet) takes about 80 seconds instead of the full tour; crop inspector shots at 1460 × 1170 from
(1440, 630), then `-resize 1200x -strip -interlace JPEG -quality 80`. [Task](261026_about-settings.md).

## Current site and Apple packet — October 31, build 36

Metadata validation distinguishes character limits from UTF-8 byte limits (keywords 100 bytes, review notes 4,000 bytes). Standard-library tests include multi-byte text, malformed/alpha PNGs, stale build/media hashes and real opaque RGB image fixtures. The validator performs no upload/network access and does not certify Apple acceptance or physical accessibility.

Marketing frames use normal app startup, no `--ui-testing` fixtures/gesture markers. Use an isolated simulator; `xcrun simctl io "$MEDIA_SIM_ID" screenConfig geometry 3840x2160` configures a supported native display mode. Capture the full frame for Apple, convert to opaque 8-bit sRGB PNG without resizing/repainting and strip metadata. Website crops may resize those same frames. Retain source SVGs, final hashes and actual clipboard output for reproducibility. Wait out the system paste notification before accepting sidebar media; it can outlast a six-second wait. Stop only the task simulator afterward.

The accepted normal-startup tour covers import, exact crop, pixelate, editable text, clean selection, actual Copy PNG dimensions, Export/Settings and document switching. Extra coordinate-based shape drags in this harness did not create objects; do not claim fresh shape-input acceptance. Rejected captures/assertions remain private. Native Select is a Toggle: query across element types, not only Buttons. Existing app/core regression and hardware evidence stay separate.

Site checks: build six pages, check every local file/anchor and image dimensions/alt text, inspect fresh desktop/dark and mobile/light renders, verify no horizontal overflow. Home Lighthouse snapshot 100s cover accessibility, best practices and SEO, not performance or all-page certification. Keep public/live URL checks dated separately from local checks.

## Image-link Paste regressions — build 37

New transport/provider tests extend the existing serialized RendererTests suite, preventing shared import-root assertions racing other image imports. The standard `swift test` command passes 78 tests/five suites. Deterministic URLProtocol fixtures exercise exact byte/crop output, HTML/malformed/404 rejection, announced/chunked byte caps, HTTPS/unsafe/loop redirects, no cookie/auth/referrer headers, cancellation and partial-file deletion. Whole-string provider parsing prefers original plain text over Foundation’s auto-converted public.url. Native URL/text Paste error cases are present in repository source; no Git commit was made. Two private live HTTPS tests exercised actual menu/Command V download and PNG Copy. Do not turn that into physical browser consent/recipient acceptance. Normal-startup screenshots contain no Debug fixture UI.

## November 4 evidence retention

The memory refresh reuses the recorded 78-core/five-suite and eight-case native results; it does not rerun tests or start a simulator. Source/build-input hashes and packet checksum were checked read-only. Keep document-link/public-safety checks separate from runtime acceptance, and mark build-37 headset URL/clipboard consent checks pending until delivery and actual observation.

## Mac verification

MacTests checks production EditorModel transactions/rotation, actual NSPasteboard image round-trip,
image-over-link priority, editable text/Undo, PNG/JPEG dimensions/metadata/original bytes and saved flattened
Recents. MacUITests opens deterministic synthetic files through native panels and checks real controls,
keyboard editing, crop/Copy, annotation styling, close/quit recovery, Save As, optional actual HTTPS Paste
and pointer cropping at zoom. Set `TEST_RUNNER_MAC_IMAGE_URL` to a real public HTTPS image for that integration
case; otherwise it explicitly skips. The test app can use a separate VISIONSNIP_BUNDLE_ID so it does not
replace the owner's running editor. Do not treat test-injected root-read access as the production sandbox.
A normal signed Debug probe verifies denial separately. Release excludes both test fixtures and the probe.


## Headless Mac GUI checks — owner instruction, November 5

Run interactive Mac checks in an isolated Tart guest. The local driver path, selected VM and key belong
in ignored operational configuration; avoid embedding machine names, addresses or credentials here.
Build on the host without launching tests, transfer only the app and synthetic input, then use the
configured driver's `ssh`, `gui` and `tool` commands in the guest's Aqua session. Keep host graphics,
audio and clipboard sharing off. Check native state after every tool transition before a pointer action;
AXPress can return before SwiftUI redraws. Refresh the guest helper from the read-only tools share if
an old snapshot lacks a documented command. Use `set -e` in guest command sequences and inspect exit codes.

Assert named/enabled controls and bounds inside the actual window. Native minimum widths/display-edge
clamping vary by OS; a requested size is not proof of the final size. Verify actual clipboard dimensions
and pixels and source-file bytes, not only labels. Full guest Xcode would be needed for XCTest; this
guest's CLT/AX/pointer checks retain their own evidence category. Never claim host GUI tests ran in the
VM. The optional capture notice was rejected by auto-review; no Allow action or policy bypass occurred.
Stop only the task-owned guest after validation, leaving shared VMs alone. [Toolbar record](261105_mac-markup-toolbar.md).

