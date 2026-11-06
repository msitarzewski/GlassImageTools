# Accessibility audit — native editor iteration

## Native automatic sidebar controls — build 36, October 31

Category-only button style/shape overrides are removed. Four existing focused UI cases pass with actual category actions, document navigation, largest text and native all-issue audits; final source matches signed Release. Physical gaze/hover appearance and assistive-technology acceptance remain scoped owner checks. [Evidence](Validation/default-list-styling.json).

## Compact image rows — October 30, build 35

Single-line bookmark-style entries retain one accessible item per image, type/edit status, native selection, Dynamic Type and growing 60-point minimum targets. Three focused native cases pass, including largest-text and populated-sidebar audits; physical gaze/hand and assistive-technology acceptance remain separate. [Evidence](Validation/compact-sidebar-rows.json).

## Sidebar hierarchy follow-up — build 34, October 29, 2026

Native category Buttons expose the category name, image count and expanded/collapsed state; full targets grow from 60 points. Child names/type remain combined; List owns document selection. Five focused UI cases pass, exit 0 (157 s), on the final signed source. The empty-state case requires actual native expand/collapse actions, minimum-sized enabled controls and an all-issue audit; largest-text audit includes the sidebar. The standalone isHittable predicate also fails on unchanged build 33 despite successful tap actions; it is retained as a baseline diagnostic, not asserted as hardware gaze proof. Earlier inline-disclosure and plain-button failures are preserved in [evidence](Validation/sidebar-hierarchy.json). Physical assistive technology, gaze/hand and visual taste remain owner checks.

## Current follow-up — build 33, October 29, 2026

The empty window uses large native image-import wells and a single gray drop/Paste button. Its whole surface is the tap target; the empty workspace handles standard keyboard Paste. The system sidebar List owns selection and expandable sections; each document explicitly combines name/type into one accessible item. 5 focused UI cases pass across two runs on identical final production source; corrected-selector follow-up native exit 0 (127 s); synthetic drag skipped because the gesture never started a system drag. The earlier normal/largest empty-screen audits passed before the final whole-well change; use the final focused record for current scope. Physical VoiceOver, Voice Control, keyboard focus, gaze/hand Drop and external clipboard consent remain separate.
[Evidence](Validation/native-start-and-sidebar.json).

## Previous release scope — build 28, October 24, 2026

Current source is build 28, which changes only the app icon; the interface is build 27's. The Images sidebar rows are plain Buttons rather than List rows: each keeps
its accessibility identifier, combines its name and detail, and carries the `isSelected` trait the List
used to supply; section headers are native DisclosureGroups whose button reports Expanded or Collapsed.
The + is a round menu button still named "New Image". The full 37-case suite, including the all-issue
native audits, passed on build 27 ([evidence](Validation/sidebar-rows-and-plus-menu.json)). Build 25
grouped the title-bar tools ([section](#grouped-title-bar-tools--build-25)). Build 23 fixed the review findings (wide-gamut colors, rotated fields, caption
clearance, paired fields) and first ran the full 37-case UI suite, including all-issue native app audits,
cleanly. Build 24 changes the toolbar, + menu, Text/Pixelate placement, inspector titles and sidebar
rows; the native audit cases were rerun on it ([toolbar actions section](#toolbar-actions-inspector-and-keyboard--build-24)).
[Release notes](RELEASE_NOTES.md) and [verified status](STATUS.md) own exact per-build results. Earlier
review sections retain their tested builds; VoiceOver/Voice Control/focus/keyboard, input, motion/Reduce
Transparency and physical materials remain manual acceptance.


Scope: the native visionOS editor, import/empty window, source-pixel crop and zoom/pan, retained annotations,
text/style/color controls, appearance, Copy/export/save, close/replacement, processing and error recovery.
This is an accessibility audit and remediation record. Simulator automation and source inspection do not
certify headset VoiceOver, Voice Control, Switch Control, keyboard focus or eye-and-hand behavior.
[Verified status](STATUS.md) and [sanitized evidence](Validation/native-ux-and-accessibility.json) own results.

The subsequent [Apple HIG review](HIG_REVIEW.md) reproduced long-filename/minimum-window clipping beyond
this original audit's short-name fixture. The follow-up below verifies its applied correction; earlier
passing audits retain their tested scope. No record certifies all physical assistive-technology behavior.

## Native Glass follow-up — build 12

Native per-control toolbar sizing/spacing replaces the assembled bar. Four standard/largest accessibility
cases pass; compact-largest toolbar and its overflow text panel also pass `.all`, ignoring no app issue.
Native palette RGB/live-color/one-Undo and selected-object manipulation remain functional. A passing audit
missed a visual 802/720 toolbar overhang; actual hierarchy/compositor checks led to native Options overflow
and a strengthened bounds/menu-action test. Final largest toolbar is 715.5 within 720.

Thirteen distinct selected UI cases passed across three commands, all exit 0; no full-suite or hardware
certification is inferred. Normal preview uses disabled Increase Contrast; final large-text checks use
enabled Contrast, then restore the original. The separate palette host's prior -902 audit restriction and
all manual speech/focus/gaze/keyboard, consent/recipient/resource limits remain.
[Evidence](Validation/native-glass-chrome.json), [task](../memory-bank/261016_native-glass-chrome.md).

## HIG follow-up — build 11

The approved follow-up is implemented/applied locally. Long filename/actions and bottom toolbar now adapt
to minimum width/largest text; full filenames remain accessible. Contextual controls use a native Form
beside the canvas. Tiny/offscreen annotation corners/endpoints now share separated source-preserving
proxies, markers/help and Show Selection, in addition to exact fields/named actions. Pan has a persistent
visible and spoken cue. Appearance endpoint words no longer fragment; compact menu commands expose their
actual tool names. Copy is labeled; native sharing exports only the flattened snapshot.

All four standard/largest-text native audit cases passed in this iteration, ignoring no app issue;
the final compact-long-name largest-text case also passed its `.all` audit. Actual palette RGB/live-color/
Undo, visible-panel interaction, tiny-object reveal/drag/separate Undo and compact menu selection passed.
Twenty-five UI cases passed across runs; the broad run's compact-menu failure and stopped finalization
remain recorded. Final compact-menu/largest-text command passed two/zero, exit 0.
[Sanitized evidence](Validation/hig-fixes.json) retains precise scopes and failed runs.

Apple's separate color service still rejects automated audit with -902; actual palette interaction is the
evidence. First-run add-only Photos consent tapping remains manual; save tests used pregranted add-only
access solely on an isolated simulator. Real headset assistive-technology speech/focus, keyboard traversal,
gaze/hold comfort and Reduce Transparency remain unobserved. No build 11 headset deployment occurred.

## Changes and evidence boundaries

| Finding | Severity | Remediation | Evidence route |
|---|---|---|---|
| Zoom can clip crop corners; Pan disables resizing | Major workflow | Source-preserving display proxies stay reachable, separated by 60 points; frozen source transforms; Pan is view-only; Show Crop recenters without changing edits | Geometry regressions and actual 225% corner drags/Undo with and without Pan |
| Fixed modal sizes and separate/unlabeled dimension fields | Moderate | Native grouped Forms, visible labels, numeric TextFields with spoken pixel units; paired Width/Height with adaptive vertical fallback | Real field editing/Undo, normal-row and largest-text geometry assertions; native audits |
| Tool state relies on tint | Moderate | Native selected toggles and a checkmark/selected trait for the shape button; single hold chooser retained | Source review and actual native toggle/menu/annotation interactions |
| Canvas work requires precision drags | Moderate | Named one-pixel crop/object/handle actions, zoom/pan actions, Text/Pixelate toolbar actions that place an object, the canvas action Add Annotation at Crop Center for other non-freehand kinds (build 24 replaces the inspector's Add at Center), native geometry inspector | Model checks for insertion/style/Undo; native Text/Pixelate placement (build 24) |
| Small or low-contrast custom handles | Moderate | 60-point custom targets; white crop border with dark outer keyline and handle keylines; display-only decorations hidden from accessibility | Source review, crop-control spacing regressions, native audit and runtime contrast checks |
| Colors lack spoken numeric context | Minor feedback | Native ColorPicker wells retain selected color; spoken RGB/opacity and visible text labels | Actual well/palette check, style-model and encoded rendering regressions |
| Work has no reachable cancellation | Moderate | Retained processing task, enabled Cancel outside disabled editor, actual provider/worker cancellation and honest Cancelling state | Native Cancel action plus provider cancellation/stale-result service checks |
| Repeated completion messages may be missed | Minor feedback | Public accessibility announcements on Copy/Files/Photos completion and cancellation request; native error alerts | Source/API compilation and native action/error tests; actual speech remains manual |
| Empty-view Paste did not accept input in simulator | Major workflow during QA | One explicit native Paste button in the persistent top ornament; same save/discard/cancel lifecycle | Actual PNG clipboard → Paste, dirty replacement Cancel/Discard and empty-window Paste |
| Test markers fail hit-region audit | Test-only | Debug gesture markers have real 60-point accessibility surfaces, preserving gesture centers/pass-through input | Native audit; all fixture definitions/call sites excluded from Release |

Source inspection also confirms native controls for Photos/Files selection and sharing, add-only Photos
saving, standard cancellation/confirmation actions, native text fields, menus and sliders. No audio-only
or timed interaction is introduced. The app adds no custom animation; it retains system transitions.
Appearance preferences affect the rear background only. Reduce Transparency forces an opaque resolved
background and disables its settings without overwriting preferences. Contrast and Reduce Transparency
are different settings and have separate evidence.

## Verified results

53 core tests and 24 actual native service checks passed. All 15 functional UI cases passed with zero
failures in 443.289 seconds. The final three standard accessibility/UI cases passed with zero issues in
80.348 seconds (command exit 0); the final largest-text/Increase Contrast case passed in 29.208 seconds
(command exit 0). Simulator settings were restored and ordinary startup has no test arguments.
Native palette RGB readback, real color selection, live well/object synchronization and one-operation Undo
passed. The signed Release build/analyze, strict signature, Debug exclusion and add-only Photos scope pass.

The first full runs retained failed assertions and later stalled in result finalization; only their own
invocations were stopped. The initial two small hit regions were Debug gesture markers, corrected to real
60-point surfaces. Apple's audit API rejects its separate color-picker service with error -902 (invalid
target); no service audit success is claimed. The final test audits the app normally and checks the
actual system palette's labeled controls, values and edits. No app audit findings are ignored.
A native compositor check also caught the largest-text title covering the crop width; its ornament now
attaches above the window at accessibility sizes, leaving the width label visible. Normal placement is
retained. The native audit and corrected compositor frame passed after that change.

## Automated coverage

The native suite uses `XCUIApplication.performAccessibilityAudit(for: .all)` with no ignored issues.
It audits import, canvas/ornaments, exact crop fields, appearance, annotation tools/style/arrangement,
text controls, PNG/JPEG export, unsaved-image actions, malformed-paste recovery and the native color well. The separate system palette is verified by actual control interaction and RGB/Undo readback.
A separate largest-text case checks stacked dimensions and scrollable text/style/export forms with
Increase Contrast enabled. Core and service tests verify geometry, source bytes, native providers,
cancellation, retained objects/history, encoded pixels and metadata; those tests do not establish speech
or focus order. Actual results, failed-run history and commands are recorded in the linked evidence.

## Manual headset coverage still required

| Area | Concrete check | Current evidence limit |
|---|---|---|
| VoiceOver | Traverse import, ornaments, canvas objects/actions and every sheet; verify speech, rotor/action discoverability, focus entry/return and repeated Copy announcements | Native AX audit/source inspected; real speech/focus unobserved |
| Voice Control/Switch Control | Select named controls, create via Text/Pixelate or the canvas Add Annotation at Crop Center action, adjust source-pixel geometry, save/cancel and recover from errors | Named actions/native controls implemented; hardware assisted input unobserved |
| Keyboard/pointer | Tab/focus traversal and escape/default actions; Cmd+N/,/C/Z, Shift+Cmd+Z and zoom shortcuts with a connected keyboard | Cmd+N/, observed with simulator key events (build 24); the owner reports using a hardware keyboard on the headset (October 23; shortcuts not recorded); Cmd+V image paste not available; keyboard-only traversal unobserved |
| Eye/hand precision | Resize/move zoomed crops, tiny/short annotations and offscreen selections; native inspector remains the exact-coordinate alternative | Simulator gesture outcomes and geometry tests; headset motor/target perception unobserved |
| Accessibility display | Largest text and Increase Contrast; Reduce Transparency on actual headset; confirm readable opaque foreground | Simulator/runtime/source results recorded separately; headset display acceptance unobserved |
| Freehand | Verify the supported assisted drawing path and practical editing with the owner's input configuration | Freehand remains a canvas path; the center-placement action does not fabricate a drawing |

Build 11 adds separated display proxies for tiny/offscreen annotation corners/endpoints and preserves
exact source-coordinate fields/named actions. Gaze precision is still a hardware check. A tiny crop's
interior movement surface can be small while its resize targets remain 60 points. Clean standard-screen
audits do not establish hardware motor/target perception.
Apple documents that VoiceOver and Voice Control are unavailable in Simulator; physical testing is
required for those paths. See [Apple accessibility testing guidance](https://developer.apple.com/documentation/accessibility/performing-accessibility-testing-for-your-app).

## References and reproduction

Follow [the testing guide](../memory-bank/testing-patterns.md) for core/service/UI commands and isolation.
Use a real local simulator identifier in `$SIMULATOR_ID`, never a tracked device identifier.

```sh
swift test
xcodebuild test -project GlassImageTools.xcodeproj -scheme GlassImageTools \
  -destination "id=$SIMULATOR_ID" -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO
```

Apple recommends 60-point visionOS interaction targets; app-defined crop/annotation handles use that size.
Native controls retain Apple's sizing. See [Human Interface Guidelines — Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility),
[visionOS accessibility support](https://developer.apple.com/documentation/visionos/improving-accessibility-support-in-your-app)
and [native audit guidance](https://developer.apple.com/documentation/accessibility/performing-accessibility-audits-for-your-app).
Paste uses the public [SwiftUI PasteButton](https://developer.apple.com/documentation/swiftui/pastebutton)
and reads providers only after the user acts. It adds no clipboard polling/history or Photos read permission.


## Document navigation and trailing property Form — build 19

Native leading List selection and independent inspector visibility, actual hidden-sidebar + menu → Files → Cancel, per-document Undo, close Cancel/Discard/Recents and Clear are exercised. Largest accessibility text keeps a one-line leading filename/details header and a usable canvas through a 600-point minimum height; caption text stays left of the actual property-pane edge and really scrolls. Normal minimum height remains 540. Compact secondary actions live in a native overflow menu. Native app audits use .all with no ignored issue; actual system palette RGB/live changes/Undo and contextual text controls pass at the recorded stages. A toolbar Menu wrapper's false nonhittable hint is distinguished from its successful real action; no custom hit-testing workaround added. A native UIKit portal hosting warning during numeric selection remains an observed runtime limit, despite successful editing/Undo/export and no app-owned hosting controller. Physical speech/focus/gaze/hand/material behavior remains unverified by these simulator checks. [Evidence](Validation/document-sidebar-and-inspector.json).

## Sidebar disclosures and in-pane confirmation — build 20

The wider Images sidebar uses native disclosures: Open Images starts expanded, Recents collapsed.
The + opens a separate window with explicit Paste, Photos and Files; its adjacent caret imports into
this window. Source filename/dimensions/type are leading in the native title bar. Native document
ControlGroups remain separate from the inspector toggle. Done is inside each property pane; a circular
Close Image sits in the editor with existing save/discard/cancel. Shapes opens immediately on tap.

All 42 native service/model checks pass. Seven distinct final UI cases pass their assertions,
including disclosures and reopening, close cancellation/discard, independent panels, real picker return,
new-window acquisition, system palette/live color/Undo, immediate Shapes/resize/crop, editable rotated
text, and largest-text title/caption layout. Native all-issue audits ignore no app finding. The final six-case command exits 0; the separate new-window command also exits 0. Earlier failed iterations and their interrupted result finalization remain historical. No
full UI suite is claimed. Core source/tests are unchanged, retaining the build-19 62-test/four-suite baseline;
the core suite was not rerun. Signed Release build/analyze, strict signature/privacy/debug exclusion and
separate device-SDK probe compilation pass. Final UI, services, signed and applied App/Core sources agree.

Physical gesture/assistive/focus/keyboard, appearance/motion and resource validation remain manual. No new recipient or capture capability is claimed.

[Task](../memory-bank/261018_sidebar-and-toolbar-refinement.md), [evidence](Validation/sidebar-and-toolbar-refinement.json).


## Transparent workspace follow-up — build 21

Native headings/accessible groups identify the Images column, filename and contextual pane. All-issue audits, actual palette/live color/Undo, numeric crop and clear-background editable text retain real interactions. One visible native Form row reports a false nonhittable hint in XCTest; the reveal helper checks full viewport containment before the real tap and state assertions. This does not certify hardware gaze, focus or assistive technology. [Task](../memory-bank/261019_transparency-regression.md), [evidence](Validation/window-transparency-restoration.json).


## Review fixes — build 23

Spoken annotation values, handle values and inspector fields now use the visible rotated axes, matching
crop values; previously a rotated object's spoken "width" was its on-screen height. Color wells describe
the nearest sRGB components and add "wide color" for Display P3 choices instead of misreporting them.
Undo is enabled as soon as an inspector edit is pending, so ⌘Z and the button agree with the visible
change. Caption text, scroll endings and the canvas stay
above the bottom toolbar ornament. Hardware keyboard shortcuts, speech and gaze remain manual checks.
[Task](../memory-bank/261021_review-fixes-and-caption-clearance.md).

## Toolbar actions, inspector and keyboard — build 24

Text and Pixelate are now buttons that add a selected object at the crop center, so creating either no
longer needs a precise canvas tap; shapes still use a drag, and the canvas keeps the named "Add
Annotation at Crop Center" accessibility action, which replaces the inspector's Add at Center row.
Inspector panes have one spoken title, and an explicit "No Selection" state. ⌘N and ⌘, are scene
commands and were exercised with simulator hardware-key events; ⌘V image paste was not observed working
and is not claimed. Copy no longer disables the window. All four native audit cases, including the largest
text category, pass in the final 37-case run. [Task](../memory-bank/261021_toolbar-sidebar-and-inspector.md).

## Grouped title-bar tools — build 25

The document tools form one accessibility container labeled "Image actions" (Undo, Redo, Copy, Share,
Export and the inspector toggle; the compact ⋯ menu keeps Undo/Redo/Export). Close Image is a separate
44-point circular button in the header's trailing corner and keeps Save a Copy/Discard/Cancel recovery.
In-capsule buttons keep 44-point frames. Native app audits rerun in the full suite; gaze/hand selection
within the capsule is a hardware observation. [Task](../memory-bank/261022_titlebar-tool-group.md).
