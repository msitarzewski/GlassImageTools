# 2026-10-16 — Native Glass chrome refinement

## Task contract

**State: Complete — original refinement delivered as build 12; native menu-caret follow-up delivered as
Release 1.0 (13), installed, normally launched and verified running.** The owner approved simplifying custom chrome and explicitly asked
for comparison with Glass Power Tools' visionOS implementation. Local edits/builds/tests/docs are authorized;
existing signing/deployment authorization persists. Headset validation remains deferred while unavailable.
No Git initialization, publication, external service or reference-project changes are authorized.

**Reuse and ownership:** Root owns EditorView, native UI integration, staging/application and aggregate
notes. A read-only reference explorer verified Glass Power Tools' `GlassNativeWindowFrame` separates
controls directly in `ToolbarItemGroup(.bottomOrnament)` and uses a capsule title surface. Its visionOS
window backplate already matches this app's plain window, single native glass, 46-point corner and
22/34/26-point insets. Its embedded panels avoid redundant material. macOS-only Liquid Glass/window APIs
are excluded from this comparison. Extend existing owners; no dependency on the sibling checkout.

**Implementation:** Give bottom controls directly to the native toolbar; remove hand-spaced enclosing
stacks, forced icon label sizes/styles and unselected tint overrides. Retain native compact tool commands,
mode toggle, single Shapes tap/hold, explicit zoom value, metadata/actions and appearance preferences.
Use the family's capsule title treatment and remove extra glass around the native annotation Form.
Image pixels/controls remain opaque on the normal interaction plane; only the rear glass/paint fades.

**Acceptance:** Native build, actual compact/default/largest-text toolbar and title compositor checks,
real Shapes/text/crop/Pan/settings/Share interaction and native accessibility audits as appropriate.
Preserve source/core/model hashes and immutable image/export/history behavior. Review baseline conflicts
before applying. Signed Release/Debug-exclusion/permission checks precede a prepared build claim.

**Risks/next step:** Actual native host width/commands, visible native panel, editing and accessibility
passed within simulator scope. Prepared build 12 can be installed when the owner/headset is available;
verify actual installed identity and normal launch then. No physical call occurred in this task.
Core/model/export/settings owners are byte-identical; no unrelated suite rerun or new acceptance claim.

## Implementation checkpoints (historical)

- Read-only family comparison confirms per-control ToolbarItemGroup and native capsule title; existing
  46-point rear glass and 22/34/26-point insets already match. macOS-only glass implementations were excluded.
- First four native UI cases passed, zero failures, 99.932 seconds, command exit 0; real Shapes resize/Undo,
  compact menu/title, largest text and contextual panel worked. Actual native compositor views inspected.
- Compositor/hierarchy inspection exposed a remaining largest-text overhang: 802-point toolbar against a
  720-point window. The first largest-text audit passed but did not assert width. Native Options now moves
  into Drawing Tools only for compact/accessibility text; native control size is preserved. Strengthened
  the existing largest-text test to assert actual toolbar width and use that menu's text options/panel.
- A separate native interaction/accessibility run is continuing on the first compiled variant. Final
  focused size/overflow verification and refreshed signed build remain pending. Core/model/export/settings
  owners remain byte-identical; their existing 57/30-check baseline is retained, not rerun.

## Applied outcome and reference comparison

Four reviewed files applied without baseline conflicts: `App/EditorView.swift`, the strengthened existing
`UITests/HIGPolishTests.swift`, `project.yml` and generated project build number. Applied hashes match final
UI/Release staging. Config/signing, image canvas, model, core/tests, annotation inspector, export services
and appearance settings remain byte-identical to the build-11 baseline. No reference-project edits,
new runtime file/framework/dependency, permission, Git operation or publication occurred.

| Area | Applied family pattern | Deliberate retained behavior |
|---|---|---|
| Bottom toolbar | Individual controls in native ToolbarItemGroup; no enclosing HStack, custom toolbar spacing, fixed label frames or forced icon-only style | Bottom Crop/Annotate, single Shapes tap/hold, native selected tools, zoom/value, Settings and compact tool commands |
| Title | Native glass capsule with family 20/10-point padding | Responsive original filename/dimensions/type and document actions remain app-composed in the ornament |
| Embedded panel | Native Form/NavigationStack provides its own surface; redundant outer glass removed | Visible canvas, contextual controls, exact fields and separate style/gesture Undo |
| Main surface | Existing plain window and one native rear glass already match family | 46-point continuous corners, 22/34/26-point insets, Opacity/Glass preferences and opaque foreground/image |

Reference provenance is a read-only visionOS source comparison, not a dependency: Glass Power Tools'
`GlassNativeWindowFrame` lines 15–17/55–68 requires separate toolbar controls; lines 49–54 uses a capsule
for its title. `DesktopSessionView` lines 525–529 avoids explicit icon-only labels on visionOS.
`GlassSpatialWindowGlass` lines 112–140 and `GlassWindowShape` lines 28–38 own the matching rear glass and
geometry. Embedded `GlassLayeredPanel` does not add material. macOS-only GlassWindowChrome and
non-visionOS glassEffect branches were excluded. The portable implementation stays self-contained here.

The largest-text visual defect found after passing initial assertions was corrected: native toolbar width
is now **715.5 points within a 720-point window**, versus the first variant's 802. Options moves into
Drawing Tools only at compact/accessibility text. The actual menu opens Edit Text and the panel; native
sizes are preserved. This behavior extends the existing owner rather than adding a second toolbar.

## Validation

- **13 distinct selected UI cases passed across three clean commands**, no failures/finalization stops.
  Initial four: 99.932 seconds, command exit 0; eight editing/accessibility regressions: 289.666 seconds,
  command exit 0; final three compact/largest checks: 87.067 seconds, command exit 0.
- All four standard/largest native accessibility cases passed; compact-largest toolbar and panel also
  pass `.all`, with no ignored app issue. Actual native palette RGB/live-color/one-Undo passed. Its prior
  separate system-host audit -902 restriction remains, rather than being described as audited successfully.
- Native Shapes draw/resize/Undo, 225% crop/Pan/Undo, appearance extremes/persistence/reset, direct Share,
  contextual panel and one-pixel reveal/drag/separate Undo passed. No full 25-case suite rerun is claimed.
- Actual native compositor captures inspected at normal/minimum window sizes, normal/largest text, with
  compact menus, visible panel, selected crop/object, Pan, Appearance and sharing. Final synthetic preview
  captured from the final Debug product with normal contrast; simulator then normally launched without
  fixture arguments. Original disabled Increase Contrast restored, all relevant commands exit 0.
- Final development-signed Release **1.0 (12)** build/analyze passed, exit 0, 14.854 seconds; strict signature,
  family 7, add-only Photos usage and Debug/probe exclusion pass. Only ordinary development signing keys
  are present, including `get-task-allow`; this is not an App Store distribution artifact.
- Separate capture-probe device SDK compilation passed, exit 0, 17.255 seconds, verifying shared editor
  integration only. Expected AppIntents metadata extraction warnings were examined; no capture is inferred.
- The **57 core / 30 native service** baseline is retained by unchanged source/test/owner hashes, not rerun
  or counted as newly executed. No image bytes, rendering, export/history or storage boundary changed.

Earlier build-11 audit captures had Increase Contrast enabled. The normal-contrast preview looks more
translucent; those images are not a controlled comparison attributing all material differences to code.
The actual structural toolbar/material changes are independently source-verified and interaction-tested.
Raw captures/logs and exact product/target paths remain ignored. [Sanitized evidence](../Documentation/Validation/native-glass-chrome.json).

## Historical build-12 implementation handoff and limits

Build 12 is applied/prepared locally, not installed. The last verified physical installation remains
build 10 with its recorded normal-launch/unlock limit. No device calls occurred while the owner was
unavailable. Same-headset signing/install/launch authorization persists; use the prepared product in
ignored `.brain/native-chrome-stage.local.json`, then verify actual identity/process when available.

The image/editing affordances remain intentionally custom, and the responsive metadata/actions are still
composed in a native title ornament. This is closer to the verified family pattern, not a claim that every
layout is a system-provided title bar. Hardware speech/focus/gaze/hold/keyboard, physical Reduce
Transparency, icon behavior, first Photos consent tapping, recipients and resource profiling remain open.
The owner's prior repeated Photos → crop → Copy → ChatGPT use stays valid; no physical capture path is
confirmed. [Status](../Documentation/STATUS.md) and [audit](../Documentation/ACCESSIBILITY_AUDIT.md) own scope.

## Owner-requested physical deployment follow-up

The owner explicitly requested deployment after the implementation handoff. Reused the prepared signed
Release product: current source/applied hashes and name/version/build matched, strict signature passed
again immediately before installation. No source change, rebuild, new signing permission or fixture
argument was needed.

Installation passed, exit 0, **2.851 seconds**. Actual installed identity readback passed, exit 0,
0.986 seconds: **Glass Image Tools 1.0 (12)**. Normal launch passed, exit 0, **1.238 seconds**, without test
arguments. Independent subsequent process query passed, exit 0, 0.373 seconds, with exactly one matching
application executable. This supersedes the build-10 installed identity and current unlock/launch wait;
those older results remain historical. [Physical record](../Documentation/Validation/physical-deployment.json).

This verifies deployment and running state. Physical material/gaze/hold/keyboard/assistive-technology,
recipient/export/resource and capture acceptance remain separate. Raw target/output stays ignored.

## Native menu indicator follow-up

**State: reviewed/tested/applied; Release 1.0 (13) installed, normally launched and verified running.**
The owner requested Apple's menu caret. No new attachment
identified an individual control; after asking for clarification, the stated working scope is the five
existing menus: Import, Crop Preset, Drawing Tools, Zoom and Shapes. Root owns the focused EditorView
change and records. Keep the single Shapes primary action (tap to draw, hold for choices), menu contents,
accessible names, source geometry and appearance behavior. Local edits/builds/tests/docs are authorized;
same-headset deployment authorization was reused without a new permission request.

The installed visionOS SDK declares the modifier; [Apple's documentation](https://developer.apple.com/documentation/swiftui/view/menuindicator(_:))
describes overriding the system indicator visibility. Actual SDK 27.2 simulator captures showed no caret
from `.menuIndicator(.visible)`, despite five passing UI cases (114.522 suite seconds, command exit 0).
That visibility-only experiment was not accepted as the completed feature.

The final implementation retains native Menu/button/material and uses Apple's `chevron.down` SF Symbol
in one shared `menuLabel` helper. `.menuIndicator(.hidden)` prevents a duplicate if the system style
changes. The glyph is decorative and hidden from accessibility. At compact window/accessibility text
sizes it is omitted to retain full-size controls and all commands. The first visible-caret variant passed
Shapes draw/resize/Undo and normal compact interaction, but failed the largest-text width check: 805.5
points against 720. This was corrected before application; no failed check was waived.

The final two compact/large-text UI cases passed, zero failures, **56.687 suite seconds / 66.044 command
seconds, exit 0**. Toolbar and annotation-panel `.all` accessibility audits ignore no app issue. Actual
final compositor views confirm normal caret visibility and fitting controls at largest text. No new
test definition was needed. The unchanged 57-core/30-service baseline is retained, not rerun; the probe
target was not separately recompiled for this label-only follow-up.

Final signed Release **1.0 (13)** build/analyze passed, exit 0, **11.972 seconds**; strict signature,
family 7, add-only Photos usage and Debug/probe exclusion passed. The expected AppIntents extraction-skip
warning was examined. Three reviewed files applied without baseline conflicts; final UI, signed Release
and applied source hashes match. Core/model/render/export/settings/configuration and tests remain unchanged.
The isolated simulator was normally launched without testing arguments after checks; prior termination
reported no running process. No Git, publication, reference-project or permission change occurred.

Physical installation passed, exit 0, **2.819 seconds**. Actual installed name/version/build readback
passed (0.437 seconds): Glass Image Tools 1.0 (13). Normal launch without testing arguments passed
(0.521 seconds); independent process readback found exactly one matching executable (0.658 seconds).
All exited 0. Raw evidence remains ignored. [Caret validation](../Documentation/Validation/menu-indicators.json),
[physical history](../Documentation/Validation/physical-deployment.json).

Next: owner observation of the installed carets and hardware gestures/accessibility. Deployment proves
installed/running state; it does not establish hardware appearance, speech/focus, recipients, resource
profiling or capture. Prior owner-confirmed Photos → crop → Copy → ChatGPT use remains valid.
