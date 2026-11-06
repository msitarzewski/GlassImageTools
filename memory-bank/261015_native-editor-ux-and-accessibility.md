# 2026-10-15 — Native editor UX, accessibility and image paste

## Task contract and checkpoint

**State: all five workstreams implemented, audited, tested and applied; Release 1.0 (10) installed and identity-verified; normal launch verification awaits headset unlock.**
The owner explicitly directed all queued work to start, superseding the initial hold for feedback.

**Objective:** native forms, accessible controls, explicit image paste and native color feedback; correct
zoomed crop editing while preserving immutable sources, source-pixel geometry and retained annotations.

**Authorization:** local implementation, tests/docs and signing/install/normal launch on the same physical
headset are already authorized. No Git initialization, commit or publication is authorized.

**Owners and reuse:** existing EditorView/AppearanceSettings/ExportView own native controls; ImageCanvas
and CanvasTransform own display/geometry; EditorModel and ImageImportService own shared validated import,
source lifetime and history. Independent staged source work is complete; root owns UI checks/audit,
reviewed application, aggregate notes and deployment. No duplicated import/render pipeline was introduced.

## Focused validation feedback — single shape chooser

- [x] Remove the separate dropdown-arrow shape menu. Preserve the existing native shape button: a normal
  tap activates the last selected shape; pinch-and-hold opens its choices. The owner's follow-up explicitly
  requested this change, satisfying the earlier wait condition for this focused work.

`App/EditorView.swift` removes only the redundant chevron Menu. The existing UI selection helper now
holds `shapes-primary` and verifies the duplicate control is absent. The existing triangle test also
selects the Select tool, taps the shape button again, draws and resizes the retained triangle, and checks
its continued availability across Crop/Annotate modes. The rectangle test retains edit/Undo coverage.

**Native simulator build and two focused UI cases passed: zero failures, 57.576 seconds, command exit 0**
on visionOS Simulator 27.2. Core/model-service sources were unchanged and their suites were not rerun.
No new test case was added for this small change; the existing cases exercise the actual retained menu
interaction. The focused source was reviewed/applied after conflict checks. At this initial simulator
checkpoint the change was not yet deployed and no device actions had been performed. The subsequent
requested build 9 installation and normal launch are recorded below. See [sanitized evidence](../Documentation/Validation/single-shape-chooser.json).

## Requested work — implemented; acceptance limits below

- [x] **Zoomed crop editing — blocking defect.** The owner reports crops cannot be edited while zoomed.
  The clipped-corner/Pan-overlay defect was reproduced and corrected with source-preserving
  reachable proxies and frozen transforms. Support moving/resizing the crop at non-default zoom and pan with accurate source
  pixels, live axis dimensions and coherent Undo/Redo. Do not require Fit to edit a crop.
- [x] **Native modal UX.** Review every sheet/popover/inspector. Use Apple default grouped Forms, clear
  titles, native field/control types and standard dismissal/confirmation actions. Put Width and Height
  on the same row at normal sizes, with explicit units and native numeric formatting/validation.
  Accommodate larger text and available space without clipping fields or obscuring actions; check focus,
  keyboard presentation, scrolling, cancellation and one-operation Undo behavior.
- [x] **Full accessibility audit.** Cover empty/import, crop, zoom/pan, annotation selection/handles,
  text editing, color/style controls, every modal, Copy/export/save, close/replacement and error recovery.
  Labels, values, hints, traits, adjustable actions, larger text, contrast and color-independent cues
  were source-inspected and exercised where supported. The audit records remediation, actual automation,
  severity and explicit manual coverage gaps for focus/speech, VoiceOver, Voice Control/Switch Control,
  hardware keyboard navigation, Reduce Transparency and Reduce Motion. Passing automation does not
  establish full headset accessibility acceptance.
- [x] **Paste Image.** Add an explicit native paste action, reusing validated image import, resource limits,
  cancellation and source ownership. Preserve unsaved-image replacement handling; handle incompatible
  clipboard content visibly. No background clipboard inspection or app clipboard history. Native provider/
  clipboard/replacement checks passed; headset Paste Image ingestion and source-app combinations remain
  explicitly unverified manual acceptance.
- [x] **Visible selected color.** Show the current annotation stroke/text color in the actual native
  palette/picker or swatch where supported. Keep selection and displayed color synchronized, with an
  accessible label/value so color is not the only cue. Verify contrast across appearance settings.

## Acceptance and next action

53 core tests, 24 actual native service checks, 15 functional UI cases and four accessibility/UI cases passed across recorded runs. The final three standard audit cases and largest-text/Increase Contrast case passed with zero app audit issues; no findings were ignored. The native palette RGB/selection/live-color/one-Undo check passed. Signed Release build/analyze, strict signature, Debug exclusion, add-only Photos scope and separate probe SDK compilation passed. Reviewed source matches the tested staging hashes, with no concurrent-edit conflicts.

Actual VoiceOver/Voice Control/Switch Control speech, focus and hardware keyboard/eye-hand acceptance
remain unobserved. Apple’s system color-picker host rejects automated auditing with error -902; its real
controls and RGB/edit/Undo behavior were verified instead. Tiny/offscreen annotation handles retain the
native geometry inspector and named-action alternatives. New Paste ingestion/gesture acceptance, Reduce
Transparency and resource profiling on hardware remain separate from simulator evidence. The owner’s
approximately ten successful Photos → crop → Copy → ChatGPT uses remain confirmed; do not request that
baseline again. No physical capture path is confirmed.

The normal launch request timed out after 35 seconds; the completed subsequent process query found no matching app. A subsequent lock-state query reports passcode required, so unlock the headset before resuming launch verification. The earlier client option-order error occurred before a remote request and is retained separately.

Resume normal launch/physical observation when device state changes; installation/identity are confirmed.
The earlier export presets, solid redaction, magnified positioning and OCR remain proposals outside this
iteration. The initial hold/shape-menu/build 9 records below are historical and remain for provenance.

See [current context](activeContext.md), [progress](progress.md),
[the monthly index](tasks/2026-10/README.md) and
[the delivered editor record](261015_editor-polish-and-glass-icon-plan.md).

## Initial installation attempt — build 9 prepared, connection unavailable

The owner explicitly requested installation. Fresh Release 1.0 (9) build and strict signature passed;
Debug fixtures are excluded and only add-only Photos usage is present. The build-number-only project
regeneration was reviewed/applied; application source matches the two passing simulator UI cases.
Installation failed before transfer with CoreDevice error 4016 (required device-services, trusted-
connectivity and power assertions unavailable). Rediscovery confirmed the same paired physical headset
unavailable and developer services inactive, with Developer Mode enabled. No approval rejection occurred.

Wake/unlock/reconnection availability was requested. Installation and normal launch were pending at that
checkpoint; the successful subsequent retry is recorded below.

## Requested installation completed — Release 1.0 build 9

After the owner reported the headset present and requested installation, the same verified signed
product installed successfully in 5.210 seconds. Actual installed metadata read back **Glass Image Tools /
1.0 / build 9**. Normal bundle-identifier launch succeeded in 1.749 seconds without testing arguments;
a subsequent completed process query found exactly one matching application executable.

An optional installation-returned persistent identifier failed CLI base64 validation (exit 64, before
any remote launch). Standard bundle-identifier launch then succeeded. This and the initial CoreDevice
4016 installation failure remain in [physical evidence](../Documentation/Validation/physical-deployment.json),
which preserves build 8's previous installed/launch record and the owner's earlier primary-workflow report.
No rebuild or new permission was needed for the successful retry. Physical shape-menu, foreground/icon
appearance and broader product acceptance remain owner observations; broader UX work remains queued.

## Full iteration started — owner explicitly requests all queued work now

The latest instruction supersedes the earlier validation wait. Scope is all five queued workstreams:
zoomed crop editing, native forms/fields and paired dimensions, full accessibility audit, Paste Image,
and visible selected color. Existing build 9 remains the delivered baseline until the next tested release.
Independent staging ownership: canvas/geometry and its tests; modal/native controls; paste import/model
and service checks. Root owns integration/UI tests, audit findings, reviewed application, docs and physical
deployment. Reuse existing import, coordinate, history, renderer and export owners; no backend or new broad
Photos permission. Validate actual pixels/geometry/history/provider behavior, native forms/large text,
accessibility controls/actions and same-device install identity/normal launch. SDK/source, automation,
manual assistive-technology and physical evidence remain distinct.


## Full iteration checkpoint — implementation staged, QA in progress

The zoom defect came from offscreen crop corners and Pan disabling the crop overlay. Display-only corner
proxies now stay reachable and separated; frozen source transforms prevent a jump when dragging a proxy.
Pan changes only the viewport, with corners still editing the source-pixel crop. Native Forms now pair
labeled dimensions at normal text sizes and adapt for large text; native color wells expose RGB/opacity.
Explicit Paste uses native PasteButton and the existing unsaved-image lifecycle. Provider copies have
validated cleanup ownership before decoding, a 256 MiB encoded-input cap and one serial preview worker.
Cancellation, named source-pixel actions, accessible creation and completion announcements are implemented.

53 core tests passed. Signed Release build/analyze and separate probe SDK compilation passed after the
current production changes. Native UI QA remains in progress. Initial failures identified obsolete test
queries for native toggle roles, a nonresponsive empty-view Paste placement and two Debug-only gesture
markers with 8-point accessibility frames. Queries and placement were corrected; marker surfaces are now
60 points without changing their gesture centers. No accessibility issue is suppressed by the audit.
A failed run completed assertions but stalled in result finalization; only that task runner was stopped,
retaining its failed assertions and actual termination status. Final native/service/large-text results and
physical deployment are pending. Installed baseline remains build 9; no new hardware behavior is claimed.


## Final full-iteration outcome — build 10

The full queued iteration is implemented: reachable source-preserving crop controls at zoom/Pan,
native grouped forms and adaptive labeled dimensions, explicit Paste Image, selected native color wells,
and accessibility remediation/audit. Add at Center and named pixel adjustments provide alternatives to
precision drags; processing can be cancelled and completion messages use public accessibility announcements.
The largest-text title now sits above the window so it cannot cover crop-axis dimensions.

53 core tests, 24 actual native service checks, 15 functional UI cases and four accessibility/UI cases passed across recorded runs. The final three standard audit cases and largest-text/Increase Contrast case passed with zero app audit issues; no findings were ignored. The native palette RGB/selection/live-color/one-Undo check passed. Signed Release build/analyze, strict signature, Debug exclusion, add-only Photos scope and separate probe SDK compilation passed. Reviewed source matches the tested staging hashes, with no concurrent-edit conflicts.

The normal launch request timed out after 35 seconds; the completed subsequent process query found no matching app. A subsequent lock-state query reports passcode required, so unlock the headset before resuming launch verification. The earlier client option-order error occurred before a remote request and is retained separately.

Provider imports retain validated owned copies before decoding, preserve encoded PNG/JPEG bytes and
reject files above 256 MiB before/after copying. One cancellation-aware preview worker serves Photos,
Files and Paste; synchronous file copy/ImageIO calls finish before cancellation returns. The provider
may materialize data before the cap can be checked. No background clipboard inspection/history or new
Photos read permission is introduced. Files/Photos save semantics and flattened-close choice are retained.

Native audits ignore no app findings. The separate system palette cannot be audited by that API (-902),
but actual RGB/control/color selection/live object changes/Undo passed. At largest text, paired dimensions
stack and forms scroll; the native compositor exposed/fixed title overlap beyond the automated audit.
The earlier result-finalization stalls and failed assertions are retained in the sanitized evidence.
Manual speech/focus/assisted input and physical new-feature behavior remain explicitly unverified.

[Audit](../Documentation/ACCESSIBILITY_AUDIT.md), [validation](../Documentation/Validation/native-ux-and-accessibility.json)
and [physical record](../Documentation/Validation/physical-deployment.json) own detailed evidence.
