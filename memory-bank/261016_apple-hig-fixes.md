# 2026-10-16 — Apple HIG fixes

## Task contract

**State: Complete locally — reviewed, tested and applied; signed Release 1.0 (11) prepared, not installed.**

**Objective:** Implement all eight findings from [the HIG review](../Documentation/HIG_REVIEW.md):
adaptive title/actions and toolbar, contextual annotation options, persistent Pan feedback, a native
annotation panel beside the visible canvas, reachable tiny/offscreen object controls, readable Appearance
endpoints, and prominent Copy/direct native PNG sharing.

**Authorization:** The owner said “Proceed with all of them.” Local implementation, builds/tests and
documentation are authorized. Prior signing/deployment authorization persists; the owner is unavailable
for headset validation, so this task can prepare a signed product without repeated device requests.
Git initialization, commits and publication remain outside scope.

**Owners and reuse:** Root owns EditorView, export transfer, native UI checks, integration/application and
aggregate docs. Independent staged owners handle AnnotationInspector/EditorModel/native integration
checks; ImageCanvas/shared control geometry/core regressions; and AppearanceSettings. Reuse existing
queued rendering, source-pixel transforms, history, native controls and system sharing. Preserve colleagues'
changes and private signing configuration. No backend or new dependency/permission.

**Constraints:** Preserve the single tap/hold Shapes chooser, leading title/source metadata, bottom mode
toggle and magnifier/current zoom, opaque foreground above adjustable glass, and editable vectors until
flattened saving. Proxy placement/reveal/Pan must change no source pixels or history. Native panel edits
and direct canvas gestures must retain deliberate separate Undo operations.

**Acceptance:** Core geometry/privacy regressions; actual native model/transfer checks; native simulator
UI and accessibility checks; compositor verification at default/minimum sizes with short/long names and
largest text; signed Release/Debug-exclusion/privacy checks. Review staged diffs and conflict-check source
before application. Keep device acceptance and recipient interoperability separate.

**Risks and next action:** Native ornament sizing, panel/history ownership, object controls and share bytes
were verified within the recorded simulator/core scope. Headset validation waits for owner availability.
The newer cropped screenshot resembles native file-browser View/Group controls; intended editor behavior
remains an unanswered clarification. No multi-image browser was inferred or added.

## Early implementation checkpoints (historical)

- Inspected current source, memory and HIG findings; preserved source/configuration baseline in staging.
- Implementing native responsive title/toolbar composition, contextual in-window annotation editing,
  share transfer and separated source-preserving annotation controls. Validation remains in progress.
- Core geometry/privacy suite: 57 tests/three suites passed. Integrated native build-for-testing passed.
  First five-case HIG run had two incorrect test expectations (Draw identifier and source-pixel units);
  corrected without waiving assertions. Shared-simulator compositor captures included another app, so
  subsequent verification uses a dedicated local simulator.
- The broad 25-case run completed assertions but failed; a native two-row toolbar clips inside its fixed
  ornament height, so the proposal now uses one-row native controls with a compact Drawing Tools menu.
  New object/tool context resets the native Form scroll position. The fresh simulator's unhandled
  add-only Photos consent prompt persisted over later interaction tests, confounding their failures.
  Native consent handling and a clear-scene replay are required before attributing those to app behavior.
- Separate inspector, gesture and context-action Undo boundaries include subsequent edits after Undo/Redo.
  Geometry controls retain original pixels and source transforms; the selected object stays beside the panel.
  Production application, final UI results, native service checks and Release verification remain pending.

## Applied outcome — build 11

All eight approved findings are implemented. Reviewed staging transferred 16 changed/new source, test and
project files with no baseline conflicts; applied hashes match the tested staging. Local signing was
preserved. No Git initialization, publication or physical-device request occurred.

| Finding | Implementation owner and resulting behavior |
|---|---|
| HIG-01 | `EditorView.titleOrnament` uses actual window width, a single middle-truncated filename with full accessible/help name, leading original metadata and adaptive document actions. Native top placement keeps crop-axis labels visible. |
| HIG-02 | `editorToolbar` fits one native bottom row; compact Annotate uses one Drawing Tools menu while preserving mode, Shapes, Options, magnifier/zoom and Settings. Targets retain native sizing. |
| HIG-03 | Extracted `AnnotationInspector` resolves selected object → active tool → last shape. Text defaults can be prepared before insertion. Pixelate shows a 16–320 source-pixel target parameter and hides unused stroke/fill/color controls. |
| HIG-04 | Zoom/View retains magnifier/current zoom and adds a persistent hand cue, help and spoken Pan state. Pan affects viewport only. |
| HIG-05 | Native Form/NavigationStack sits beside the canvas in an in-window panel. Selected content is revealed; object/tool changes reset form context. Panel style edits, canvas gestures and context actions have separate Undo boundaries, including subsequent edits after Undo/Redo. |
| HIG-06 | Shared source-preserving geometry separates tiny/offscreen corners and endpoints. Offset markers/tethers/help explain proxy positions; Show Selection recenters at current zoom. Objects excluded by the crop are labeled truthfully. |
| HIG-07 | Appearance uses full-width native sliders with readable adaptive endpoint captions below; percentages, persistence, reset and background-only policy remain. |
| HIG-08 | Visible Copy is emphasized. Native ShareLink opens the system sheet directly for an immutable flattened PNG snapshot; Export retains PNG/JPEG/Files/Photos controls. No original thumbnail is supplied. |

The single tap/hold Shapes chooser, editable vectors, bottom mode toggle, immutable source, source-pixel
rendering and fully opaque foreground remain the product rules. Settings adds the standard Cmd+, shortcut.
The compact menu uses native text commands: symbol-bearing commands were incorrectly exposed as symbol
names by the actual menu host despite label-style/accessibility overrides. Pixelate now reads and selects
as Pixelate. This is verified by an actual menu interaction and compositor capture.

## Final validation and retained failures

- **57 core test definitions / three suites passed**, exit 0; 0.816 seconds after an 8.40-second build.
  Geometry covers tiny objects, separated/coincident endpoints, zoomed resize/Undo, clipping and reveal;
  existing encoded redaction, alpha, metadata, orientation and resource/cancellation regressions pass.
- **30 actual native model/service checks passed**, 3.155 seconds, launch/service command exit 0.
  Includes contextual/default controls, pixelation units, persistent-panel Undo, reveal invariance and
  the real Transferable's decoded 800 × 600 annotated PNG with original/private source bytes unchanged.
- **25 distinct UI cases passed across recorded runs**: 15 functional, four accessibility and six HIG.
  The broad run passed 24/25; its sole compact-menu failure and result-finalization stop are retained.
  Final compact-menu/largest-text run passed two/zero in 47.587 seconds; command exit 0, 57.271 wall seconds.
  The prior broad four accessibility cases and final compact-largest audit ignore no app issue.
- Inspected actual native compositor views of compact long titles/actions, compact/largest toolbars,
  text/pixelation beside the canvas, one-pixel proxies at 337%, Pan, Appearance and the system share sheet.
  Actual native palette RGB/live-color/one-Undo and add-only Photos save passed.
- Signed development Release **1.0 (11)** build/analyze passed, exit 0, 11.239 seconds; strict signature
  exit 0. Only add-only Photos usage is present; Debug fixtures/flags and capture-probe symbols are absent.
  Normal development signing includes `get-task-allow`; this is not an App Store distribution artifact.
  Separate capture-probe device SDK compilation passed, exit 0, 17.063 seconds; no capture is inferred.
- Isolated simulator contrast was restored to its original disabled value and the app normally launched
  without test arguments, both exit 0. No other simulator or headset setting was changed.

Earlier failures remain in [sanitized evidence](../Documentation/Validation/hig-fixes.json): incorrect
harness identifiers/units; native multi-row toolbar clipping; native form scroll/context; stale Photos
consent overlay; unsuccessful native consent tap; failed menu-label approaches; and initial 29/30 service
run whose reveal fixture had no selected object after Undo/Redo. The corrected fixture explicitly selects
the restored object. No failed check was waived. Failed command finalization was stopped only after suite
summaries, separately from assertion outcomes. Raw output/screenshots remain ignored local material.

## Remaining acceptance and handoff

Build 11 is applied/prepared locally; the headset still has verified installed build 10. No device calls
were made while the owner was unavailable. Same-headset install/normal launch authorization persists;
use the prepared signed product when available, then verify actual installed identity and running state.
The private prepared-product pointer is in ignored local configuration, never tracked documentation.

First-run Photos consent tapping remains manual: save regressions used only a pregranted add-only
permission on the isolated simulator. System-palette audit restriction -902 remains; functional native
palette assertions passed. Real VoiceOver/Voice Control/Switch Control, keyboard focus and gaze/hold
comfort, physical Reduce Transparency, icon parallax and large-image resource profiling remain open.
Native share sheet plus flattened bytes do not prove every recipient. Preserve the owner's prior
approximately ten successful Photos → crop → Copy → ChatGPT uses. No physical capture path is confirmed.

[Verified status](../Documentation/STATUS.md), [accessibility audit](../Documentation/ACCESSIBILITY_AUDIT.md)
and [monthly index](tasks/2026-10/README.md) link the result. Only the monthly index belongs under `tasks/`.
