# 2026-10-17 — Tool sidebar and image description

**Historical build-14 record.** The [drawing/sliding-tools follow-up](261017_drawing-and-sliding-tools.md) supersedes caption spacing/placeholders and panel motion; build 16 is now installed/running.

## Task contract

**State: reviewed/tested/applied; Release 1.0 (14) installed, normally launched and verified running.** The owner requested removing the redundant
Shapes checkmark, moving Tool Options to a right sidebar, and showing Apple's image description as a
caption in the main panel. Local edits/builds/tests/docs and same-headset deployment are authorized.
Root owns the existing EditorView/AnnotationInspector integration, caption responsibility, UI checks and
aggregate notes. No delegation, Git operation or publication is required.

**Reuse:** EditorView already has a conditional right column containing the native AnnotationInspector
Form/NavigationStack. Make it open with Annotate; retain its contextual controls, history boundaries and
hide/show behavior. Move its launcher from the bottom tools to a native sidebar symbol in document actions.
Remove only the custom Shapes button checkmark; retain the current-shape label, native selected traits,
tint and primary-action tap/hold. ImageCanvas/source-pixel/render/export owners remain unchanged.

**Caption scope:** A clarification asked whether the owner means an automatically generated description
or a saved Photos caption. Pending any correction, the stated working interpretation is automatic Apple
image description. The installed SDK exposes FoundationModels image attachments and the on-device
model's vision capability from visionOS 27. Use SystemLanguageModel only, check real availability and
capabilities, and explicitly report unsupported/disabled/not-ready states. No cloud model, upload,
library-read permission or third-party dependency. Caption uses only the bounded upright preview of the
original image and is labeled accordingly below the canvas; it is absent from edited/exported pixels,
metadata, edit history and storage. Closing/replacing the source cancels the view task and cannot publish
a stale caption. At most one real inference runs across windows; reject overlapping work visibly.

**Platform evidence:** The installed SDK explicitly marks SwiftUI `.inspector` unavailable on visionOS,
so reuse the in-window right Form rather than inventing navigation semantics or unsupported API calls.
[Apple's image prompting documentation](https://developer.apple.com/documentation/foundationmodels/analyzing-images-with-multimodal-prompting)
documents the local image-attachment route. SDK availability is not proof that a physical model is ready
or supports vision; validate actual runtime state separately.

**Acceptance:** Native build, final source/diff review, actual contextual side pane and main caption
composition at normal/minimum/largest sizes; real Shapes/crop/text/color/Undo controls, native accessibility
audits and caption close/retry/availability behavior. Preserve original/source/render/export/model
owners; do not rerun unchanged core/service suites without a reason. Signed Release/privacy checks and
installed identity/normal launch/process readback precede any deployment claim. Real generated caption
and hardware gestures remain distinct from a supported unavailability fallback.

**Original verification route (completed below):** Compile and run focused native checks, inspect compositor captures, verify the actual Apple
model capability with a synthetic image where hardware access permits, then apply/deploy reviewed work.

## Validation checkpoints

- First four native UI cases passed, zero failures, 202.866 suite seconds / 370.987 command seconds,
  command exit 0. Actual Shapes draw/resize/Undo, automatic sidebar/caption/retry/close lifecycle, largest
  text and contextual Text/Pixelate controls passed, including native all-issue accessibility audits.
- Initial reduced-scale visual review raised a concern about caption overflow beneath the right panel.
  Pixel-crop inspection confirmed the normal caption already ended before the divider; no horizontal
  overflow defect is claimed. Explicitly constrained the flexible main column and three visible native
  lines so longer/largest-text captions have a bounded footprint, with full text available to
  accessibility, selection and native help. Added actual generated-text bounds and usable canvas-height
  assertions. Final regression execution is running; normal caption bounds/lifecycle checks passed.
- A temporary, separately signed native capability-check app used the exact staged service and a
  synthetic image on physical Vision Pro. Build passed, exit 0, 20.097 seconds. Install/normal launch
  passed; the actual model reports available and vision support. A real nonempty 93-character caption
  was generated in 2.56392825 seconds. Result readback passed; the temporary check app was removed,
  exit 0, 3.810 seconds. The main editor's installed build 13 was not replaced by this check.
- Initial simulator generation failed and exercised the visible retry/failure path. Later real simulator
  responses generated captions, including at largest text. No cause for the first framework failure is
  claimed. AI descriptions are informational and may misidentify details; they never determine crop,
  annotation, redaction or export behavior. Raw model text, screenshots and device output remain private.

## Applied outcome

Nine reviewed files applied without baseline conflicts. EditorView reuses the native right Form, opens
it with Annotate and moves its launcher to the top document actions using the sidebar symbol. The bottom
and compact-menu Options duplicates are removed. The extra Shapes checkmark is removed; its current
symbol, selected traits/tint and primary-action tap/hold remain. Two focused new owners provide the local
caption service and source-keyed native caption; one shared UI-test action handles automatic pane opening.
Model/source/core/render/export/settings/signing configuration owners and core tests are unchanged.

Caption inference uses only SystemLanguageModel, checks actual visionOS 27/model/vision support, and
accepts the bounded upright preview. The actor permits one inference with visible busy recovery; the
view task checks cancellation and is replaced with source identity. Caption text is not cached or stored
by the app and never enters ImageSource/EditState/history/image Copy/Share/save. Three visible lines
bound layout; full text is retained for native accessibility/help and selection is enabled. Automatic
description is the communicated interpretation; retrieval of a saved Photos caption is not implemented.

## Final validation and deployment

- Ten distinct selected UI cases passed across commands on the final app source. The broad run passed
  nine/ten, with three assertions in one failed color-picker presentation case: 539.899 suite seconds,
  630.013 command seconds, native exit 65. Focused color retry passed one/zero in 43.863 suite seconds,
  87.209 command seconds, exit 0. No clean full ten-case run is claimed.
- All native palette assertions were retained: actual presentation, selected RGB values, Grid/black
  change, live color-well update and one-step Undo. Only a diagnostic capture checkpoint was added;
  presentation success is computed before its delay. No production change fixed the initial failure
  and no cause is established. System-host logs show empty accessibility content; raw evidence remains
  ignored. The checkpoint image shows the editor panel, so it is not visual proof of palette composition.
- App/editor/forms/caption/sidebar/largest `.all` audits pass with no ignored app issue. Zoomed crop,
  Shapes direct manipulation, text-object menus, contextual controls and independent tiny-object Undo
  pass. Actual final normal/compact/largest compositor images and caption bounds were inspected.
  The historical separate palette-host audit -902 limitation is retained, not newly reproduced.
- Final signed Release build/analyze passed, exit 0, 90.256 seconds. Strict signature, family 7,
  add-only Photos usage, ordinary development entitlements and Debug/probe exclusion passed. Expected
  AppIntents extraction skips were examined. Separate capture-probe SDK build passed, exit 0,
  110.011 seconds; no capture path is inferred. Final UI/Release/applied app hashes and the physically
  tested caption-service source match exactly. Existing 57-core/30-service baseline was not rerun.
- Release 1.0 (14) installation passed in 4.164 seconds; actual installed name/version/build readback
  passed in 0.452 seconds; normal launch without fixture arguments passed in 0.966 seconds; independent
  exactly-one-process observation passed in 0.700 seconds. All exited 0. No additional permission,
  library-read access, cloud service, Git or publication was introduced.

[Sanitized validation](../Documentation/Validation/sidebar-and-caption.json) and
[physical history](../Documentation/Validation/physical-deployment.json) own exact scope. Native physical
caption generation was tested with a synthetic image through the exact service; the new editor's physical
pane/caption appearance, gaze/hold/speech/focus and personal-image behavior remain owner validation.
No forced mid-inference source replacement, peak-memory experiment, new recipient acceptance or physical
capture is claimed. Prior owner-confirmed Photos → crop → Copy → ChatGPT use remains valid.

The owned simulator was Shutdown when restoration was first requested (native exit 149; no app launch).
Boot, boot-status and normal launch without testing arguments then passed, exit 0. No unrelated simulator
was changed. Next: owner observes installed build 14's new editor pane/caption/input; no deployment or
unlock wait remains. Git initialization/publication and unrelated external actions remain unauthorized.
