# Apple HIG review — October 16, 2026

## Current presentation — documentation review October 21, 2026

The current build is 22: leading Images documents/Recents, a separate right contextual inspector,
standard controls in a header and bottom system toolbar, and one adjustable rear surface. Persistent
navigation-container/ornament layouts described in older checkpoints are superseded. The crop mask is
65% black outside the selection and clipped to the image Canvas viewport, leaving controls/margins
unaffected. Actual compositor review caught the prior zoomed margin spill despite passing interaction
assertions; final correction and two UI cases are recorded in [crop evidence](Validation/crop-dimming.json).

This update reconciles existing source/results; it is not a new HIG assessment or compliance certificate.
[Release notes](RELEASE_NOTES.md) and [status](STATUS.md) separate current/retained simulator evidence from
remaining hardware and distribution checks. The original findings and their fixes remain below.


The native foundation fits this image-editing workflow. The next improvements should address adaptive
layout and contextual editing controls. One reproducible layout defect can visually hide document
actions; several smaller issues add friction. These describe the original review checkpoint. The [implementation follow-up](#implementation-follow-up--build-11)
records the subsequently approved/applied fixes; neither checkpoint declares full HIG compliance.

## Scope and evidence

Reviewed current source, Apple's current official HIG, and 16 actual visionOS Simulator compositor views:
empty/import, Crop, zoom/Pan, exact dimensions, Annotate, Shapes, new text, selected pixelation, PNG/JPEG
export, unsaved-image recovery, Appearance, and compact/large-text variants. Two private observation
walkthroughs passed with zero failures in 137.774 seconds; the command exited 0. Those tests established
reachable states and captured observations, rather than asserting that every observed design was good.

The compact variant opened the existing 720 × 540 minimum window and imported a synthetic PNG with a
long neutral filename. A private Debug-only harness set initial size and fixture name; production UI,
layout, gestures and rendering remained unchanged. The largest-text variant used the system preferred
accessibility text category. Actual content-window and toolbar frames were read from their matching
accessibility hierarchy, not the first XR host window. Source inspection and compositor images were both
necessary: accessibility elements can remain present when their visible rendering is clipped.

All 32 baseline app/core/UI/configuration/project files checked against their starting hashes are
unchanged. No production test fixture or observation harness was applied. The previously tested simulator
product was restored and normally launched without observation arguments. No physical-device action was
attempted; installed Release 1.0 (10) retains its previously recorded launch limitation. Raw logs and
compositor frames remain private. [Sanitized evidence](Validation/hig-review.json) records measurements;
[the task record](../memory-bank/261016_apple-hig-review.md) records scope and handoff.

## What should remain

- Ordinary resizable window, image-first canvas, native glass and native bottom toolbar. Controls belong
  close to their content, without an immersive environment for routine editing.
  [Apple: Ornaments](https://developer.apple.com/design/human-interface-guidelines/ornaments),
  [Toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars).
- Native grouped Forms, paired labeled pixel fields, system color wells, numeric entry, visible Done,
  and Save a Copy / Discard Changes / Cancel recovery. These already support familiar editing and safe
  dismissal. The export form correctly reveals JPEG-specific options; scrolling itself is not a defect.
  [Apple: Modality](https://developer.apple.com/design/human-interface-guidelines/modality).
- Owner-approved single Shapes control: tap the last shape, hold for choices. Do not restore the removed
  duplicate dropdown arrow. The observed menu opens upward at default size without covering system
  window controls. Gaze discoverability and hold comfort still require hardware observation.
- Opaque image and foreground above adjustable rear glass. Keep the native default, Reset Appearance,
  and the source-inspected Reduce Transparency override. Background customization must not fade image
  pixels or controls. System material guidance does not invalidate this explicit product requirement.
  [Apple: Materials](https://developer.apple.com/design/human-interface-guidelines/materials).
- Three 1024 × 1024 icon planes in the native solid image stack. This matches Apple's visionOS layer
  format; installed mask, lighting and parallax remain unobserved.
  [Apple: App icons](https://developer.apple.com/design/human-interface-guidelines/app-icons).

## Prioritized findings

P1 means a visible primary-workflow defect; P2 means meaningful usability work; P3 means polish or an
optimization. Priorities are this project's review judgment. Each proposed fix requires its own validation.

### HIG-01 — P1: long titles can hide document actions

**Observed:** At 720 × 540, the long filename clips vertically in the title ornament. At the largest
accessibility text size, the document-action row and original dimensions/type are not visible in the
compositor capture, although accessibility still reports their elements. The earlier short-name
largest-text check remains valid within its narrower scope.

**Owner:** `App/EditorView.swift:167` (`titleOrnament`) and `:198` (`documentTitle`), plus the minimum
window in `App/GlassImageToolsApp.swift:8`. The title permits unbounded vertical text within a 400-point
maximum width; the ornament uses a 900-point maximum independently of available window width.

**Proposed:** Bound the visible filename with middle truncation, preserving the full name for accessibility
and native help. Adapt the ornament to the actual window and protect Close, Copy, Undo/export and source
metadata when text grows. Keep filename/details leading-aligned. Verify the hosting height as well as the
Text view; a truncation modifier alone is not proof of a complete fix.

**Acceptance:** Short and long valid filenames, default/minimum widths, normal/largest text: visible and
usable primary actions, readable original metadata, no title clipping or crop-axis occlusion. Include a
real compositor check alongside accessibility assertions.
[Apple: Layout](https://developer.apple.com/design/human-interface-guidelines/layout),
[Typography](https://developer.apple.com/design/human-interface-guidelines/typography).

### HIG-02 — P2: annotation toolbar outgrows the compact window

**Observed:** At 720 × 540, the annotation toolbar is 910.5 × 68 points and visibly overhangs the window.
Its controls remain available; this observation does not establish missing or clipped commands.

**Owner:** `App/EditorView.swift:228` (`editorToolbar`) and `:271` (`annotationTools`).

**Proposed:** Adapt native toolbar grouping and the visible command set to available width, or establish
an appropriate minimum for its real contents. Preserve the mode toggle, single Shapes chooser, magnifier
with current zoom and Settings. Avoid solving crowding by shrinking interaction targets. Apple's ornament
guidance keeps ornament width within the window, and toolbar guidance discusses fitting controls and
resizing. [Apple: Ornaments](https://developer.apple.com/design/human-interface-guidelines/ornaments),
[Toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars).

**Acceptance:** Crop and Annotate at supported widths/text sizes fit without overlapping, losing commands
or reducing usable targets. Check native labels on gaze later. Apple's caution about toolbar pull-downs
also warrants checking every menu against system window controls; the captured Shapes menu was clear.

### HIG-03 — P2: annotation options do not consistently describe the active tool

**Observed:** Choosing Text before inserting an object shows Stroke Color, Stroke Width and Fill, with
no typography controls. Selected Pixelate offers Stroke Color, although that color is unused by rendering.
Its Stroke Width value controls pixelation granularity: `ImageRenderer.swift:317` and `:444` use
`max(16, annotation.lineWidth * 4)`, so the shown 4 px corresponds to a 16-source-pixel block-size parameter.
The 1–80 slider corresponds to a 16–320 parameter range, with 1–4 producing the same minimum.

**Owner:** `AnnotationInspector` in `App/EditorView.swift:452`; shared renderer in
`Sources/VisionSnipCore/ImageRenderer.swift`. The inspector keys visibility from the selected object and
falls back to the last shape, overlooking the active annotation tool when selection is empty.

**Proposed:** Resolve context from selected object, then active annotation tool, then last shape. Show
relevant controls only: text defaults before insertion; shape stroke/fill; meaningful pixelation size
instead of unused color and a misleading stroke label. Preserve current rendering/privacy guarantees and
live edits grouped into one Undo transaction.

**Acceptance:** Controls and labels match each selected/active kind; text defaults affect new text;
pixelation units match the renderer's effective granularity; encoded pixel/privacy regressions still pass.
[Apple: Menus](https://developer.apple.com/design/human-interface-guidelines/menus),
[Sliders](https://developer.apple.com/design/human-interface-guidelines/sliders).

### HIG-04 — P2: Pan has no persistent visible state

**Observed:** At 225% zoom with Pan enabled, the closed toolbar control shows only the magnifier and zoom.
Reopening the menu reveals the checked Pan toggle. A drag changes meaning with no persistent visible cue.

**Owner:** Zoom/View menu in `App/EditorView.swift:249`; crop drag routing in `App/ImageCanvas.swift:443`.

**Proposed:** Keep the requested magnifier/current zoom and add a native selected/hand cue plus spoken Pan
state when enabled. Make returning to crop movement obvious.

**Acceptance:** Pan state remains visible and accessible after menu dismissal; toggling it changes only
viewport gesture routing, corners still resize, and view changes do not add edit-history entries.
[Apple: Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons).

### HIG-05 — P2: the large annotation popover obscures the object being edited

**Observed:** The selected-pixelation view's property form covers a substantial portion of the selected
region. Styling, geometry and arrangement share an ideal 540 × 660 popover. Users need to see live vector
changes while editing, especially when obscuring sensitive content.

**Owner:** `App/EditorView.swift:308` and `AnnotationInspector` at `:452–523`.

**Proposed:** First reduce the form to relevant controls. Then compare a smaller contextual popover with
a standard in-window panel or supported native presentation that leaves the selection visible. Do not
assume SwiftUI `.inspector` is available on visionOS. Retain native ColorPicker; its separate system host
was functionally tested previously and is not itself evidence of an unsupported design.

**Acceptance:** The selected object remains visible enough to judge live style/size changes; dismissal
commits one undoable transaction; text, native palette and geometry remain reachable at large text sizes.
Apple recommends keeping popovers focused and avoiding essential-content obstruction.
[Apple: Popovers](https://developer.apple.com/design/human-interface-guidelines/popovers).

### HIG-06 — P2: tiny/offscreen annotation controls need the crop controls' safeguards

**Source finding, not newly reproduced on hardware:** Annotation corners/endpoints can coincide for tiny
objects and clip outside the canvas when zoomed. Their 60-point view frames do not prove separated gaze
targets. The existing geometry inspector and named pixel actions mitigate this but do not make the direct
controls equivalent to the recently improved crop proxies.

**Owner:** `App/ImageCanvas.swift:337–392`; canvas clipping at `:17`.

**Proposed:** Reuse the separated display-proxy approach where appropriate, and provide a native reveal
action for an offscreen selection within the crop. Preserve source coordinates and the distinction
between an offscreen object and one excluded by the export crop. Review object hover feedback separately:
`annotationTarget` at `:90` lacks an explicit hover effect, but its native context menu may supply system
feedback; absence of gaze feedback has not been observed.

**Acceptance:** One-pixel objects, short lines and crop-edge selections remain operable at zoom; proxy
placement changes no pixels/history by itself; dragging/Undo restores exact geometry. Verify actual
gaze, hover and focus with a headset when available.
[Apple: Spatial layout](https://developer.apple.com/design/human-interface-guidelines/spatial-layout),
[Eyes](https://developer.apple.com/design/human-interface-guidelines/eyes).

### HIG-07 — P3: Appearance slider endpoint labels fragment

**Observed:** At the default window/text size, Transparent breaks into several short fragments and Opaque
breaks across lines beside the native slider. The percentages remain clear.

**Owner:** `appearanceSlider` in `App/AppearanceSettings.swift:89–103`; endpoint captions permit narrow
wrapping with vertical fixed size.

**Proposed:** Keep native horizontal sliders; place readable endpoints outside the compressed slider
label slots, or use meaningful native symbols plus accessible endpoint descriptions. Keep the percentage
and reset behavior. Check both normal and largest text rather than forcing a tiny font.

**Acceptance:** Endpoint meaning stays readable without word fragments at supported presentation sizes;
native accessibility values and background-only behavior remain correct.
[Apple: Sliders](https://developer.apple.com/design/human-interface-guidelines/sliders),
[Typography](https://developer.apple.com/design/human-interface-guidelines/typography).

### HIG-08 — P3: emphasize Copy and consider faster Share access

**Source and walkthrough judgment:** Copy is an icon among several equally weighted title actions.
Sharing requires Export, then Share in the native form. Both work in the inspected interface; this is a
workflow optimization, not a categorical violation. Apple's share symbol also represents share-related
activities, so the current export icon is not inherently wrong.

**Proposed:** Evaluate a visible Copy label/primary emphasis and a direct default-PNG Share action while
keeping format/quality/Files/Photos options available through Export. Coordinate with HIG-01/02 so extra
controls do not worsen crowding. Test actual recipient behavior separately.
[Apple: Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons).

## Suggested implementation order and remaining checks

1. HIG-01/02: protect document actions and make both ornaments fit their supported window/text sizes.
2. HIG-03/05: contextual annotation controls with a less obstructive native presentation.
3. HIG-04/06: visible Pan mode and forgiving direct annotation manipulation.
4. HIG-07/08: readable settings and primary-action polish.

This review does not repeat the prior accessibility audit or claim new pixel/export/clipboard acceptance.
No new core suite was needed because production code is unchanged. Preserve the earlier
[accessibility results and limits](ACCESSIBILITY_AUDIT.md). Later manual checks include VoiceOver/Voice
Control/Switch Control, keyboard focus/shortcuts, real gaze/hold precision, Reduce Transparency, Home View
icon rendering, and fatigue/legibility at comfortable window distances. The owner's repeated successful
Photos → crop → Copy → ChatGPT use remains confirmed; it is not replaced by simulator observation.

## Implementation follow-up — build 11

The owner approved all eight findings. Their implementation is applied locally in prepared build 11;
original observations/source line numbers above remain historical. Use current symbols for navigation.

| Finding | Current owner | Validation |
|---|---|---|
| HIG-01 | `EditorView.titleOrnament`, `documentTitle`, `titleActions` | Long neutral filename at 720 × 540, default/largest text; native actions/metadata assertions and actual compositor views |
| HIG-02 | `EditorView.editorToolbar`, `drawingToolsMenu` | One-row compact host bounds/usable commands; actual Pixelate menu selection; largest-text audit |
| HIG-03 | `AnnotationInspector`, `EditorModel.effectiveAnnotationKind`, `pixelationSize` | Contextual UI/defaults, native model/history checks and unchanged core encoded privacy regressions |
| HIG-04 | `EditorView.viewOptions`, viewport gesture routing | Persistent Pan cue/value; actual zoomed crop/Pan resize/Undo; view changes add no history |
| HIG-05 | `EditorView.workspace`, `AnnotationInspector`, model transaction boundaries | Panel lies beside canvas; text/pixelation native forms, palette live color, tiny-object style/drag/independent Undo |
| HIG-06 | `CanvasTransform.reachableControlRect`, `endpointControls`, `centeringDelta`; `ImageCanvas` selection overlay | One-pixel/short/clipped core cases; 337% native reveal/drag/Undo; source coordinates preserved |
| HIG-07 | `AppearanceSettings.appearanceSlider`, `endpointLabels` | Actual native slider limits/persistence/reset, readable compositor captions, large-text audit |
| HIG-08 | `EditorView.copyAction`, `quickShareAction`; `EditedImageTransfer` | Native sheet opens directly; real decoded 800 × 600 PNG includes annotation and preserves original bytes |

57 core tests, 30 native service checks and 25 unique UI cases passed across runs. The final compact-menu/
largest-text command exits 0; a clean full 25-case invocation is not claimed. Native menu bridging required
plain text commands to expose Pixelate correctly; no custom menu surface was introduced. Failed attempts
and stopped result finalization remain in [validation](Validation/hig-fixes.json).

Build 11 is prepared, not installed; there were no physical calls. Hardware gaze/focus/speech/comfort,
first-run Photos consent tapping, recipient interoperability and resource profiling remain open.
[The implementation task](../memory-bank/261016_apple-hig-fixes.md) records applied files and handoff.

## Native Glass refinement — build 12

The owner's subsequent styling feedback approved the family visionOS comparison. Separate native
ToolbarItemGroup controls replace the assembled toolbar; capsule title and panel-owned surface reduce
container styling. Actual largest-text review found a native 802/720 overhang despite an audit pass;
Options overflow and strengthened width/menu checks now verify 715.5/720. Thirteen selected UI cases pass
across three clean commands. Core/model/export owners and their baselines are unchanged. Build 12 is
prepared locally, not installed; no device call occurred. [Task](../memory-bank/261016_native-glass-chrome.md),
[evidence](Validation/native-glass-chrome.json). Earlier contrast-enabled captures are not a controlled
material comparison with the new normal-contrast preview.


## October 18 document/inspector refinement

Owner approved ordinary leading document navigation and a separate right property inspector. Use Apple's
[macOS inspector example](https://developer.apple.com/videos/play/wwdc2023/10161/) for sectioned contextual
Forms and independent visibility, with supported native visionOS layout. SwiftUI .inspector and UIKit's
inspector column are explicitly unavailable in the installed SDK. The leading Images List, native toolbar
New Image menu/metadata/actions and right grouped Forms preserve the window/canvas and bottom direct tools.
Recents have an explicit session lifetime and Clear action. New imports preserve other open edits.
Current verification belongs in [the task](../memory-bank/261018_document-sidebar-and-inspector.md) and
[status](STATUS.md); hardware gesture/focus/material acceptance remains separate.

## Native sidebar/titlebar refinement — build 20

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


## Window transparency restoration — build 21

Persistent workspace columns now follow the Glass-family plain-window model with system controls and one adjustable rear surface. Native List disclosures/selection and Forms hide scroll backgrounds; native modal navigation/bottom toolbar remain. This replaces the navigation-container material that prevented clear settings. Largest-text, both-panel, actual editing/palette and acquisition regressions retain their scopes; no HIG compliance certification. [Task](../memory-bank/261019_transparency-regression.md), [evidence](Validation/window-transparency-restoration.json).
