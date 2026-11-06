# 2026-10-15 — Glass family icon and editor interaction plan

## Task contract and status

**Original plan: implemented, tested, applied and deployed as Release 1.0 build 5.** The owner approved
this plan and confirmed flattened PNG/JPEG saving on close; annotations stay editable during the open
session. The crop/title/text follow-up was delivered as build 6; build 7 delivered the larger icon and
native appearance settings with normal physical launch verified. **Current follow-up: foreground layering
implemented, validated and installed as signed Release 1.0 build 8.** Installed identity was read back on
physical visionOS 27.2; normal launch remains unverified after two SDK launch-command timeouts and no
matching process in the completed query after the first. The final sections retain failed-run history, actual validation and hardware observation limits;
earlier build 5/6/7 results remain historical.
The owner requested a plan covering the
Glass family toolbox icon, image title/metadata, bottom mode toggle, Close Image/save options, annotation
visibility in Crop, a Shapes menu, accessible text controls and direct vector-object editing.

The primary Photos → crop → Copy → ChatGPT workflow already has approximately ten owner-confirmed
headset uses. Preserve that working path and the audited export/privacy behavior. Native Apple UX remains
the default. Earlier hardware signing/install/launch authorization persists; implementation and its tests are now authorized. No capture, backend, dependency or public release work is included in this plan.

**Reuse analysis:** the existing remediation record owns completed audit history and should remain that
record. This separate root-level plan owns a new feature contract and implementation checkpoints.
Extend EditorView, EditorModel, ImageCanvas, AnnotationEngine, ImageSource and ExportView rather than
introducing a second editor, source-image model, renderer or export service. The current icon generator
already owns the three-plane asset output; retain that output contract while replacing its artwork input.

## Inspected baseline

| Source | Historical inspected behavior and implication |
|---|---|
| `App/EditorView.swift:23` | Image name is in the footer; the navigation title is the app name. |
| `App/EditorView.swift:54` | Crop/Annotate segmented Picker occupies the principal toolbar position. |
| `App/EditorView.swift:73` | Existing native bottom ornament can own the relocated mode Picker. |
| `App/EditorView.swift:121` | Replacement offers discard-only confirmation; no Close Image workflow. |
| `App/EditorView.swift:152` | Every annotation kind gets a toolbar button, including each shape. |
| `App/EditorView.swift:211` | Text content and size exist in a modal inspector, conditional on selection. Typography is limited. |
| `App/ImageCanvas.swift:17` | Crop deliberately omits edits from its preview request. |
| `App/ImageCanvas.swift:30` | Crop displays the raw preview; Annotate displays a composited bitmap. |
| `App/ImageCanvas.swift:52` | Selection has a dashed outline but no direct resize or endpoint handles. |
| `App/ImageCanvas.swift:96` | Hit testing uses inflated bounding boxes, which can select empty space. |
| `App/EditorModel.swift:69` | Mode changes clear selection and reset the viewport. |
| `Sources/VisionSnipCore/ImageDocument.swift:33` | Annotation geometry/text/style are already retained editable values. |
| `Sources/VisionSnipCore/ImageRenderer.swift:24` | Shared Core Graphics paths and CoreText rendering already exist. |
| `Sources/VisionSnipCore/ImageImportService.swift:19` | Source carries upright original dimensions/name, but no decoded source content type. |
| `App/ExportView.swift:41` | Existing native Files/Photos export can support save-before-close with explicit completion. |
| `Tools/GenerateIcon.swift:13` | Three 1024-pixel planes already generate a native visionOS icon stack. |

Local icon-lab guides, the layered Brew Browser pilot, and GlassPowerTools' latest icon history,
Composer manifest and production visionOS planes were inspected. The pilot contact sheet and actual
GlassPowerTools artwork were viewed. Those references inform the recipe below; the finished project
must carry its own portable artwork and build recipe, without requiring a sibling checkout.

## 1. Glass family toolbox icon

- Draw a classic handled toolbox in a simple three-quarter silhouette, with a crop emblem on the left
  side and a paintbrush emblem on the right. Use the family's clear forms, restrained face shading,
  generous negative space and recognizable small-size proportions.
- Author editable SVG geometry. Produce red and cobalt design comparisons using the inspected family
  palettes, neutral light/charcoal surroundings and gray/white secondary shapes. Proposed lead is red;
  both comparisons are design proofs, not a promise of an in-app alternate-icon picker.
- Preserve three meaningful 1024 × 1024 visionOS planes: opaque neutral Back; rear handle/interior on
  Middle; front toolbox faces with attached emblems on Front. Keep side emblems attached to their faces
  during parallax and extend hidden overlaps where needed. The stack order is Front, Middle, Back.
- Let visionOS apply the circular mask and platform effects. Do not bake a circular/square platform
  enclosure into the plane art. Keep actual visionOS validation separate from macOS appearance previews.
- Store source artwork and reproducible generation instructions in this project. Extend/replace the
  existing generator's drawing responsibility and retain the current asset catalog integration.
- Review separated planes, combined proofs at small sizes, actual compiled icon metadata/catalog and
  the installed Home View icon, including motion, clipping and lighting. Start with the design proof
  before polishing the geometry and finalizing the selected palette.

## 2. Document title and bottom toolbar

- Use the image name as the main title when an image is open; keep the app name in the empty state.
  Below it show the original upright source dimensions and actual decoded type, for example
  `3840 × 2160 pixels · PNG`. The footer can continue showing current crop/output size and zoom.
- Retain the content type from ImageIO/UTType during import; neutral `source.image` filenames are not
  evidence of file type. Do not read/retain extra private metadata for this display. Captured frames
  get a truthful source label rather than an invented encoded type.
- Move the existing Crop/Annotate segmented Picker into the native bottom toolbar, keeping its selected
  state and identity. Keep common navigation controls usable at the minimum window size; use grouped
  native menus/popovers for overflow instead of shrinking targets.
- The installed XROS 27.2 SwiftUI declarations mark `navigationSubtitle` unavailable on visionOS.
  Use a two-line native principal ToolbarItem once the mode Picker moves, with accessible title/metadata.

## 3. Live vector objects and visibility across modes

- Keep Annotation/EditState as the editable source of truth and extend their existing geometry/style
  helpers. Show annotations in both modes: Crop displays them across the full source beneath its dimming
  mask/handles; Annotate clips the editing viewport to the current crop. Cropping never deletes objects
  outside the crop, so expanding the crop restores their visibility.
- Draw retained shape/freehand paths and text directly in a live, ordered canvas using shared Core
  Graphics/CoreText geometry and source-pixel transforms. Avoid rerendering a flattened preview image
  through an async export-style pipeline on every drag. Cache the bounded source and expensive pixelation
  tiles, with current-request ownership, rather than flattening away editing interaction.
- Preserve source/annotation insertion order and blend-aware composition. Pixelation remains a raster
  effect with an editable vector region. Compose its replacement pixels with the underlying source in the
  same drawing pass; translucent tiles over a separately visible raw source would reintroduce the audited
  leakage. Keep outward pixel alignment, source-anchored blocks and all encoded privacy regressions.
- Selecting an object shows generous handles. Support move/resize; lines and arrows get endpoint handles;
  text gets a box that supports layout changes; freehand retains its editable path and bounding transforms.
  Use shape/path-aware hit testing with forgiving view-space tolerance and topmost-object selection.
- Expose duplicate/delete and front/back ordering through native contextual controls. Style controls apply
  to the selected object immediately; tool defaults apply when nothing is selected. Each gesture or
  committed control edit remains one undo step. Mode switching does not discard edits or unnecessarily
  reset the viewport; selection controls can hide during cropping without destroying object identity.
- PNG/JPEG exports render a fresh full-resolution flattened image using the same geometry/styles. Retained
  edit objects remain available in the open session after Copy/export.

## 4. Shapes menu and text controls

- Group Rectangle, Ellipse and Arrow with new Line, Rounded Rectangle, Triangle and Speech Bubble tools
  under Shapes. Keep Select, Draw, Text and Pixelate directly reachable. Add outline/fill controls where
  relevant; retain arrow endpoints and sensible text/shape defaults.
- Use a native Shapes menu, showing the current shape. A primary action can activate the last selected
  shape and the system secondary/pinch-and-hold action reveals the menu. Provide an explicit menu-opening
  affordance/accessibility action too. Verify the actual gesture on hardware rather than replacing it with
  a custom gesture recognizer.
- Creating text immediately exposes text editing; selecting existing text exposes its content and style.
  Use system text input/keyboard and a native anchored popover for font family, size, bold, italic,
  underline, alignment and color, keeping the canvas visible while changes apply.
- Extend the retained typography values and shared CoreText layout for multiline/wrapping/alignment;
  display and export must use the same metrics. Include visible Edit Text access so discovery does not
  depend on guessing a hidden gesture or first finding Annotation Options.
- The installed SDK marks SwiftUI `inspector` unavailable on visionOS; use supported native popovers and
  in-surface controls. Avoid another modal inspector that hides the image while typography changes.

## 5. Close Image and save-before-close

- Add a standard toolbar xmark button labeled/accessibly named Close Image. It closes the current image
  and returns to the empty editor, while the native window remains open.
- Track document changes against the initial/last durably saved edit snapshot; `history.canUndo` alone
  is not a dirty-state test. Undo back to the saved state becomes clean. Copy/share does not imply a
  durable save or silently discard pending edits.
- For modified content offer Save a Copy…, Discard Changes and Cancel using native confirmation UI.
  Proposed save behavior reuses PNG/JPEG Files/Photos output. Clear the document only after successful
  save completion for the same source/edit snapshot. Cancel, denied permission, encoding failure or a
  cancelled file picker keeps the image and edits open.
- Share this decision/lifecycle path with image replacement. A cancelled/failed new import preserves the
  old document. Invalidate stale import/export/preview completions when actually closing/replacing; retain
  sources until in-flight operations release ownership.
- The owner chose flattened PNG/JPEG saving when closed. Editable objects remain in the open session;
  no reopenable project format is part of this iteration.

## Implementation order and acceptance

1. Produce the layered icon design proof, then implement title/source metadata and bottom-toolbar layout.
2. Build the shared live vector canvas and direct manipulation; make annotations visible in Crop.
3. Add discoverable live text controls, new shapes and the Shapes menu on that foundation.
4. Implement the agreed Close Image/save/replacement lifecycle with robust completion/cancellation.
5. Finish icon integration, native builds/regressions and physical install/identity verification.

Core tests cover new paths/hit testing, transforms/handles, crop visibility preservation, text metrics,
undo transactions, source type and save/close state transitions. Keep existing malformed-image,
orientation, metadata, redaction and cancellation tests green. UI tests exercise the relocated toggle,
visible controls, real text editing/style, object drag/resize, mode switching, shape selection and
save/discard/cancel recovery. Compare full-resolution exported pixels to the live composition.

Build the native app, inspect the actual compiled icon and Release test-code exclusion, install under
existing authorization and read back identity. Headset checks focus on new pinch/hold/handle/popover and
icon behavior. Do not ask the owner to repeat the already confirmed crop/Copy/ChatGPT baseline as a gate.
Implementation was reviewed in an isolated staging copy, tested and transferred with baseline conflict
and exact file-hash checks. Build 5 replaces the installed build 4; verification is recorded below.

## References

- [System patterns](systemPatterns.md), [local model](data-model.md), [native UX rules](projectRules.md).
- [Testing](testing-patterns.md), [security](security.md), [verified status](../Documentation/STATUS.md).
- [Apple app-icon guidance](https://developer.apple.com/design/human-interface-guidelines/app-icons/)
  and [visionOS asset stacks](https://developer.apple.com/documentation/xcode/configuring-your-app-icon).
- [SwiftUI menu primary actions](https://developer.apple.com/documentation/swiftui/populating-swiftui-menus-with-adaptive-controls)
  and [system context-menu gestures](https://developer.apple.com/design/human-interface-guidelines/context-menus).

## Completed implementation and verification

The live vector canvas, generous source-space shape/endpoint handles, retained Crop annotations, native
typography popover, Shapes menu, source title/metadata, bottom mode control, close/save lifecycle and
layered toolbox artwork are implemented and applied. The icon has portable SVG masters and generation
instructions; red/light is the shipping palette and cobalt/charcoal are authoring comparisons.

| Verification | Final evidence |
|---|---|
| Core | 42 test definitions, three suites, zero failures; includes live/export shape/fill/text/pixelation and cache regressions |
| Native UI | Nine tests, zero failures, 207.941 seconds; actual text/content/style/Undo, direct corner/endpoint edits/Undo, mode retention, close/cancel/discard and Photos-save-before-close |
| Simulator model/services | 15 checks passed; saved-state/stale completion, cancelled/failed replacement, typography/arrangement, both export formats, system pasteboard data/UIImage and actual Photos assets |
| Native build | Signed Release build/analyze and separate probe device SDK compile passed; only the known skipped AppIntents extraction warning |
| Icon/Release | Three 1024-pixel planes, alpha/safe margins and flat proofs inspected; native actool compile without errors/warnings; compiled AppIcon/SolidImageStack; strict signature and Debug/probe symbol exclusion passed; only add-only Photos usage description |
| Apply | 28 changed and seven new files transferred initially with no baseline conflicts; all transferred hashes matched staged files; aggregate source digest verified before deployment |
| Physical | Release 1.0 build 5 installed, launched with normal arguments, name/version/build read back and matching process verified on the previously authorized physical Vision Pro |

Actual UI execution exposed stale text-request presentation, a missing visible Cancel in the first native
confirmation surface and premature per-digit font-size clamping. Guarded requests, a native alert and a
String draft with commit normalization corrected them. Final text entry `6 → 64` preserves 64 and one Undo
restores the original content/style. Native element-to-element handle drags verify changed source values
and preserved opposite endpoint/Undo; earlier coordinate-offset attempts went beyond source bounds.
Automation also corrected localized dimension strings and assumptions about separate ornament frames.
No required failing test was waived.

Final source/public-content and relative-link checks passed. The memory bank has 16 populated root notes
and one monthly index under `tasks/`. The authoring rasterizer is documented and adds no
application runtime dependency. No original images, permission scope, capture integration or public
repository lifecycle were changed beyond the approved scope.

[Sanitized iteration evidence](../Documentation/Validation/editor-polish.json),
[service results](../Documentation/Validation/simulator-smoke.json) and
[physical identity/launch evidence](../Documentation/Validation/physical-deployment.json) own the measured
outcomes. New headset eye/hand/pinch-and-hold interactions and installed icon lighting/clipping/parallax are
not yet observed. Large-image profiling, broader recipient/export acceptance and physical capture remain
separate product work; prior owner-confirmed Photos/crop/Copy/ChatGPT acceptance is preserved.

## Owner follow-up — crop axes, title alignment and text targeting

**State: delivered as signed Release build 6; installed and verified running.** The owner observed centered filename/source details and a pinch-and-hold menu treating the whole canvas as its target. The source confirms the principal VStack uses center alignment and contextMenu is attached to ImageCanvas. Extend those owners: leading title alignment; source-pixel width/height badges at horizontal/vertical crop edges; per-annotation native interaction/menu targets with ordinary text tap opening Edit Text. Shared vector paths, crop clipping and safe composition remain the authorities. Native UI checks must verify labels across edit/Undo/zoom, aligned text edges, direct text reopening and an object-specific context menu without blank-canvas actions. Physical signing/install/launch authorization persists.

Final follow-up verification: ten unique UI cases passed across the full run (nine passes; one initial dismissal-synchronization failure) and focused context retry (one pass, zero failures, 28.195 seconds). The test now waits for the native canvas to return after the popover dismisses; no production workaround or assertion waiver was introduced. Signed build/analyze, Release privacy/icon/test-code boundaries, conflict-free apply and exact source hashes passed. Installed 1.0 build 6, normal launch and running process were read back on the authorized headset. Core/service sources match the previously verified 42/15-check baseline. [Sanitized follow-up evidence](../Documentation/Validation/crop-text-follow-up.json) records scope.

## Build 7 follow-up — larger closed toolbox and crop emblem

**State: artwork validated, applied and installed in Release 1.0 build 7.** The owner
supplied a classic metal-toolbox reference and requested greater coverage, family comparison and a
recognizable crop emblem. The photograph informed shape only; no photo pixels, watermarks or traced
outlines enter the artwork. Original editable SVG masters retain the three-plane native output contract,
red/neutral/steel palette and restrained shading. The closed pitched roof and substantial handle replace
the crate-like top; two thick broken L-shaped rulers form the left-face crop emblem and the brush stays
on the right face. Emblems remain on their owner face plane with hidden overlap reducing parallax seams.

| Foreground union | Canvas occupancy | Inclusive bounds | Maximum pixel radius |
|---|---|---|---|
| Family reference | 21.96% | 537 × 569 | 360.82 |
| Earlier editor icon | 20.51% | 568 × 512 | 340.52 |
| Build 7 | 28.49% | 698 × 629 | 412.64 |

The revised foreground area is 38.86% larger than the earlier editor icon. The internal 440-pixel
radius guard passes, leaving a 99.36-pixel static radial margin inside a 512-pixel circle. This is an
authoring guard, not an Apple safe-area claim. Three distinct 1024-pixel planes, opaque Back, transparent
Front/Middle surroundings, small-size composites and static circular-mask proofs were inspected. Native
`actool` compilation reported zero errors/warnings; emitted metadata declares AppIcon and asset inspection
reports a SolidImageStack/1024-pixel vision rendition. [The icon guide](../Tools/Icon/README.md) owns the
portable recipe and measured comparisons. Installed lighting, clipping and motion remain hardware checks.

## Build 7 follow-up — toolbar and native window appearance

The owner requested current zoom beside the bottom magnifier, removal of the lower-left crop-size footer,
family service-window borders and a settings gear for appearance. Build 7 keeps source-pixel crop-axis
badges and the working crop/copy workflow. It implements a plain SwiftUI window with **one** native glass
backplate, continuous **46-point** outer radius and **22/34/26-point** side/top/bottom content insets. The
edge comes from the native glass surface without a drawn stroke. Removing the editor's root NavigationStack
avoids an extra root background; a native top title ornament retains leading filename/source details and
the separate capture probe's return action remains in the bottom toolbar. Sheet navigation stays native.

`App/AppearanceSettings.swift` owns app-local `@AppStorage` preferences and a system sheet/Form. Native
Opacity and Glass sliders default to **0%** and **100%**, with Reset Appearance and read-only **Material:
System Glass**. There is no selectable material weight. The source-inspected Reduce Transparency policy
resolves both strengths to 1 and disables appearance controls without replacing saved preferences. The
override was not toggled in simulator or on hardware during this iteration. Only background layers fade;
image pixels, text, controls, source coordinates and export rendering remain independent of preferences.
The magnifier/view menu displays the current zoom percentage and offers native view actions.

### Reuse and implementation boundaries

Extend EditorView, the app's WindowGroup and self-contained appearance settings; do not copy a family
window implementation or add a sibling dependency. Existing ImageCanvas/VectorImageLayer own image
interaction. Preserve native sheets/popovers, crop-axis labels, object menus, undo, source geometry and
all audited privacy/export behavior. The current input correction attaches drag/tap to the visible
VectorImageLayer instead of a clear sibling, so native scene input reaches actual production gestures.

Double-gated `EditorCanvasTestTargets` exist only in Debug with `--ui-testing`. The native elements mark
scene-local start/end positions, pass hit testing through, and guide synthesized input through the real
canvas gesture code; they do not inject objects. Release exclusion must cover both definitions and call
sites. No capture sources, permissions, backend, external dependency, source-image or export format changes
are part of this follow-up.

### Failed-run history and corrections

| Earlier check | Observed result | Resolution / evidence limit |
|---|---|---|
| Initial native UI run | 11 cases: five passed, six failed | Clear-sibling canvas gesture delivery and native slider automation assumptions corrected; final full suite rerun |
| First focused UI rerun | Three failing tests, seven assertion failures | Native slider input worked; canvas input and Material accessibility query still failed |
| Native appearance sliders | Opacity moved 0% → 4%; Glass moved 100% → 0%; later persistence/reset assertions passed despite the earlier Material assertion | Material query corrected; final appearance test passed |
| Visible-layer focused two-case run | One text case passed in 27.093 seconds; rectangle case failed its sole assertion because typed 300 displayed as 299 | Both gestures worked; bounded display rounding corrected without weakening assertions |
| Focused result finalization | Assertions completed, then diagnostics collection stalled; only that invocation stopped with command exit -15 | This was not a successful command exit; final runs completed normally with exit 0 |

Moving drag/tap onto the visible VectorImageLayer restored production gesture delivery using the same
native test input. Debug scene-local targets guide actual events rather than injecting objects. Safe
bounded nearest-pixel display rounding preserves retained geometry; an actual model/service regression
uses a fractionally positioned annotation, types width 300 and checks exact whole-object Undo. Native
Material accessibility inspection corrected the mistaken assumption of a separate value element. No required failing
assertion was waived.

### Final build 7 verification and deployment

| Check | Final observed result |
|---|---|
| Full native UI suite | **11 passed, zero failed, 277.766 seconds; command exit 0** |
| Caption-only final appearance check | Native slider minimum/maximum captions use horizontal `fixedSize`; focused appearance case **one passed, zero failed, 32.615 seconds; exit 0** |
| Caption accessibility | Transparent, Opaque, No Glass and Full Glass each occupied one line at 14.5 points high; app-element screenshot remained clipped and is not full-window appearance proof |
| Simulator model/services | **15 actual checks passed**, including fractional-origin typed width 300/exact Undo and real PNG/JPEG exports, pasteboard representations and Photos saving |
| Core | Source/test hashes unchanged from the prior **42-test** baseline; core suite was **not rerun** for this iteration |
| Native builds | Signed Release build/analyze and separate unsigned capture-probe device SDK compilation passed |
| Release boundaries | Debug target symbols, canvas marker strings and test arguments absent; only add-only Photos usage description; compiled layered AppIcon verified |
| Apply | Reviewed staging applied without baseline conflicts; exact tested source hashes matched the main workspace |
| Physical deployment | **Glass Image Tools 1.0 build 7** installed on physical visionOS 27.2, launched with normal arguments, installed identity and matching running process read back |

The full UI suite covers actual drawing/selection/Undo, text editing/object context, crop presets/copy,
line/shape handles, close/save recovery and appearance persistence/reset. The final focused check follows
only a caption layout adjustment; it does not imply a second full-suite run. Signed final Release validation
and exact source matching cover the delivered app. The separate probe compile is API/build evidence only.

[Sanitized build 7 evidence](../Documentation/Validation/window-appearance-and-icon.json),
[service results](../Documentation/Validation/simulator-smoke.json) and
[physical deployment evidence](../Documentation/Validation/physical-deployment.json) own measured outcomes.
The failed-run history remains above to distinguish corrected defects, test assumptions and diagnostic
finalization from the successful final runs.

### Remaining hardware observation and product scope

The owner-confirmed Photos → crop → Copy → ChatGPT path remains valid; it need not be repeated as a gate.
New eye/hand appearance/gesture behavior and installed icon lighting/clipping/parallax remain unobserved.
Reduce Transparency behavior is source-inspected and was not toggled in simulator or on hardware. A clipped
app-element screenshot cannot establish complete native window appearance. These limits are separate from
the verified build 7 installation, normal launch and running process.

Broader Files/annotation/Photos/export/resource coverage and physical capture remain separate product work.
No new capture source, permission, dependency, backend, publication, Git action or license choice is implied.

## Build 8 follow-up — opaque foreground above appearance

**State: implementation, source/UI/compositor QA and application complete; installed as Release 1.0
build 8 with normal launch unverified.** The owner requires images, buttons and text to stay opaque, with the image above the appearance
surface. Existing preferences already affect background views only; this follow-up makes native spatial
ordering explicit rather than relying on same-depth background placement.

The final glass/tint background sits at native depth **-1** and stacking index **-1**. The full-opacity
workspace remains at native interaction depth **0**, stacking index **1**, preserving normal hit delivery.
Crop/selection overlays and editable annotations stay above the image, and native title/toolbars keep
their system surfaces. Original image alpha, bytes and export rendering remain intact; foreground view
opacity 1 does not flatten transparent source pixels. Appearance never modifies retained edits. Native
defaults remain Opacity 0%/Glass 100%; Reduce Transparency remains source-inspected and was not toggled.

### Failed-run history and final UI scope

| Check | Observed result | Resolution / evidence boundary |
|---|---|---|
| Foreground +1 experiment | Four cases: one passed, three failed, five assertion failures | Moving the foreground forward missed native endpoint/control input; final code moves only the background rearward |
| Rear-only four-case run | Crop/copy/export, endpoint/Undo and text context passed; appearance failed three assertions | New crop-width-1200 setup typed before the native selection menu was ready; production interaction regressions were corrected |
| Final appearance retry | **One passed, zero failed, 113.651 seconds; exit 0** | Test waits for actual Cut/Select All; every exact-1200, crop/history, slider-extreme, persistence/reset and input assertion retained |

These runs establish **four unique UI cases passed**, not a full eleven-case suite rerun. Production
source stayed unchanged between the rear-only run and final focused appearance retry. Actual native slider
states 0/1, 1/1 and 0/0, persistence/reset, retained crop/Undo, opaque-background rectangle creation and
clear-background text creation/re-edit/Undo passed. No failed assertion was waived or loosened.

### Separate compositor verification

Manual XCUIScreen capture was unsupported; its attachments do not prove visibility or layering. Separate
native `simctl` compositor captures observed a settled synthetic fixture at glass, opaque and clear states.
Temporary Foundation argument-domain overrides set proof preferences only; actual native sliders and
persistence were independently exercised above. Raw workspace PNGs remain private. Publish only the
sanitized metrics in [foreground-layering.json](../Documentation/Validation/foreground-layering.json).

Seven sampled opaque color interiors were pixel-identical across all three states. The measured
**1,031,318-pixel image region** was identical glass versus opaque. The clear comparison changed **2.63%**
of pixels with maximum channel difference **18** and mean **0.0987**, showing small rendered-edge differences.
Native text/button glyphs remained visible with their ornament styling. This bounded comparison does not
claim whole-scene bit identity, original-alpha flattening or physical-headset appearance acceptance.

### Build, application and hardware evidence

| Check | Actual result |
|---|---|
| Core/model/services | Source/test hashes unchanged from build 7's **42 core / 15 model-service** baseline; those suites were **not rerun** |
| Native builds | Signed Release build/analyze and separate unsigned probe SDK compile passed |
| Release boundaries | Test fixtures/markers/arguments and capture-probe symbols absent; only add-only Photos permission |
| Apply | Reviewed files applied without baseline conflicts; exact main hashes matched tested staging |
| Device installation | **Succeeded**; installed metadata read back **Glass Image Tools / 1.0 / build 8** on physical visionOS 27.2 |
| Normal launch | Two SDK commands timed out after 40 and 30 seconds; a completed process query after the first found no matching process. Normal launch is unverified and the timeout cause is not established |
| Hardware foreground | Physical visual behavior unobserved; installation tooling cannot establish foreground visibility |

SDK compilation of the isolated capture experiment is build evidence, not authorized-frame delivery or
capture acceptance. Device installation/metadata readback is a different evidence level; launch/process
and actual headset appearance also remain separate. [Foreground evidence](../Documentation/Validation/foreground-layering.json)
and [physical deployment record](../Documentation/Validation/physical-deployment.json) own the sanitized
outcomes. Source and scoped UI/compositor verification are complete. Update hardware launch state only
from actual command/process evidence, not from the existence of a bundle or an assumed timeout cause.

The owner-confirmed Photos → crop → Copy → ChatGPT path remains valid. New foreground/eye/hand behavior,
icon lighting/clipping/parallax, toggled Reduce Transparency and broader image/export/resource/capture
acceptance remain separate observations. No backend, dependency, capture source, publication, Git action
or license choice is implied by this fix.

## Documentation handoff refresh — October 15, 2026

At the owner's request, the memory bank was reconciled with the delivered build 8 evidence. Active context
now separates the current installed build from historical build 4–7 launch results; the index, progress,
quick start and deployment guidance identify the remaining normal-launch/readback step. Source/UI/compositor
verification is complete, while hardware launch and foreground appearance remain unverified. This refresh
performed no builds, application tests or device actions and adds no new hardware acceptance claim.

Deployment authorization persists. A future launch retry needs actual device availability, not renewed
permission or a rebuild of unchanged source. The prior awake/unlocked question remains unanswered in the
record. Detailed task notes remain here in the memory-bank root; the monthly index records this refresh.
