# Drawing, sliding tools and caption spacing

**Latest delivery: build 16 installed/running.** Natural caption sizing follow-up below supersedes build 15 caption reservation/margins.

## Contract — October 17, 2026

**State:** Reviewed/tested/applied; Release 1.0 (15) installed, normally launched and verified running.

**Objective / authorization:** Owner requests unobstructed drawing, a sliding right tool panel, more
caption space and no missing-description placeholders. Local edits/builds/tests/docs and same-owner
Vision Pro signing/install/launch remain authorized. No Git/publication or unrelated device actions.

**Reuse / ownership:** Extend ImageCanvas selection presentation, EditorView's existing native right
AnnotationInspector Form, and ImageDescriptionCaption. Keep service/source/model/core/render/export
owners intact. No delegation. Caption continues the prior original-image/on-device interpretation.

**Implementation:** Show annotation handles only with Select and outside active drawing, preserving
editable vectors/undo. Animate the existing trailing tool Form with SwiftUI's standard transition and
animation; respect Reduce Motion. SwiftUI inspector remains explicitly unavailable in actual SDK 27.2.
Allow wrapped captions and bounded native scrolling, more spacing and callout text. Loading/failure
outcomes retain no visible caption, heading, spinner or retry placeholder, per owner request.

**Acceptance / risks:** Exercise actual draw/Select/resize/Undo, pane show/hide/contextual controls,
long and unavailable caption layouts and native accessibility at minimum/largest sizes. Keep canvas
usable and caption outside image/export. Meaningful synthetic caption fixtures stay Debug-only; also
retain an actual model-generation check. Verify signed Release and installed identity/normal launch.
Animation/gaze/assistive technology on hardware remain separate from native simulator assertions.

**Original verification route (completed below):** review staged edits, run native checks and inspect compositor.

## Diagnostic checkpoint

First five-case native run: automatic-caption check failed because an empty Group did not start the
attached task. A stable VStack fixes that lifecycle without showing an empty caption. Initial largest
and contextual/quiet-state checks passed; largest initially had no caption, so its passing result does
not establish long-caption layout. Strengthened final assertions to require the deterministic long
caption and actual native scrolling at largest text.

Drawing checks confirmed two editable strokes, no pen handles and Select restoring handles. The resize
Undo check then failed because the test dragged the corner to its existing start position; no resize
transaction existed. Corrected the test to move the handle by a nonzero display delta, assert changed
source dimensions, Undo and assert restored dimensions before independent stroke Undo/Redo. No model or
history change was made. Final source must pass the corrected test; initial failures remain evidence.

Signed build/analyze/signature initially passed but preceded final lifecycle/spacing adjustments. Only
the later hash-matched signed product may be deployed. Core/source/model/render/export/description-service
hashes match baseline; existing 57-core/30-service results are retained, not rerun for presentation edits.

## Platform references

The actual installed SwiftUI SDK marks inspector unavailable on visionOS. Standard supported transition
and animation APIs provide the requested motion around the existing native Form; this is composed
in-window presentation, not a platform inspector modifier. [Apple split-view guidance](https://developer.apple.com/design/human-interface-guidelines/split-views)
prefers adjacent supplementary content in visionOS. [Reduce Motion](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion)
suppresses the sliding transition's animation. Main image pixels and foreground controls remain opaque.

The subsequent broad nine-case run shows real captions and a native scrolling caption at largest text.
Largest assertions initially queried only `Other` accessibility elements and a child identifier that
SwiftUI overrides on the selected ViewThatFits branch. Actual hierarchy/compositor show the correct
ScrollView with the stable caption identifier. Corrected tests to query the caption by identifier across
element types and target the actual native scroll view. No layout/model/history assertion was removed;
the final retry must still prove actual scrolling, usable canvas, pane bounds and all-issue audit.
A separate default (non-caption-fixture) simulator view also produced real model text; semantic accuracy
is not asserted. No production change was needed for this accessibility-query diagnosis.

## Final applied outcome

Only Select shows vector bounds; drawing stays clear and retains editable annotations/Undo. Tool Options
slides from the right using the existing native Form and standard SwiftUI animation; Reduce Motion
suppresses the movement. Captions have callout text, padding, full wrapping and bounded native scrolling.
Loading/unavailable descriptions have no visible heading, spinner, error or retry placeholder, per owner.
Source/model/core/render/export/description-service owners remain unchanged.

Nine distinct native UI cases pass across the broad seven/nine and corrected focused four/four command
(exit 0). Initial and broad failures remain recorded; no clean nine-case command is claimed. The final
checks retain actual vector resize/dimensions/Undo/Redo, long-caption scrolling, pane/canvas bounds and
all-issue accessibility audits with no app issue ignored. Actual compositor inspected. Signed Release
build/analyze (12.468 seconds), strict signature/privacy and seven-file exact application
pass. Unchanged 57-core/30-service baseline retained, not rerun. Test caption fixtures are Debug-only;
a default simulator view also generated real text. Prior physical caption-service execution remains valid.

Glass Image Tools 1.0 (15) installation (5.347 seconds), installed
identity, normal launch without testing arguments (0.592 seconds) and
independent exactly-one-process readback passed, exit 0. Hardware gaze/hand/motion/assistive technology,
resources, wider recipients and capture remain separate. No additional permissions/dependencies or Git.

Final focused native command: 107.823 seconds, exit 0; completed case and suite results are in [validation](../Documentation/Validation/drawing-and-sliding-tools.json). The broad command retained four failed assertions in two cases. Both corrected cases pass finally with full assertions. Native app source matches signed Release and applied source; only the test file changed for the final accessibility/gesture correction. No forced model cancellation or physical motion preference test was added.

The owned simulator was already booted; normal launch without test or text-size arguments passed (native exit 0). Final public scan checked 34 source/documentation files: no private identifiers/home paths or broken local links; applied hashes still match. Raw compositor/device reports remain ignored. Prior stage pointers are marked superseded; current pointer selects build 15.

## Owner feedback follow-up — intrinsic caption sizing

**State: reviewed/tested/applied; build 16 installed, normally launched and verified running.** Owner's physical screenshot shows excessive
caption reservation. Give text modest margins and let its measured native content determine height,
with scrolling only for content exceeding the safety ceiling. Extend ImageDescriptionCaption and
Debug fixtures/tests; source/model/core/render/export/inference and sliding tools stay unchanged.
Acceptance: short captions shrink to actual content and grow with wrapping; long/largest captions
still scroll with usable canvas; no unavailable placeholders. Native UI/audit and signed build followed
by authorized same-headset installation and identity/launch checks. No personal screenshot copied.

### Follow-up outcome — build 16

Caption height now follows its actual native wrapped content with modest margins and default text
leading. A short synthetic caption uses 52.5 points and grows to 72.5 points when Tool Options narrows
the main column. It no longer reserves the allowed maximum height. Native scrolling handles overflow;
loading/unavailable descriptions remain invisible. Drawing, sliding tools, source/model/core/render/
export and inference-service owners remain unchanged.

Four caption UI/audit cases passed, zero failures, 92.776 suite seconds / 115.160 command
seconds, native exit 0. A strengthened compact-wrap repeat passed one/zero in 17.876 suite seconds /
23.179 command seconds, exit 0; it proves actual height growth and native accessibility.
Largest-text scrolling, usable canvas, sidebar bounds and no-placeholder checks remain. All-issue app
audits ignore no issue; actual compositor inspected. Signed Release build/analyze (24.241
seconds), strict signature/privacy and five-file conflict-free application pass; final hashes match.
Two expected AppIntents extraction skips examined. Unchanged 57-core/30-service baseline not rerun.

Release 1.0 (16) installation (5.105 seconds), actual installed identity,
normal launch without testing arguments (1.015 seconds), and independent
exactly-one-process readback passed, exit 0. Existing same-headset authorization reused. Hardware caption
appearance/gaze/motion/assistive technology, resources, wider recipients and capture remain separate.

The owned simulator had no running app to terminate (native exit 3); fresh normal launch without test arguments passed, exit 0. No unrelated device changed. [Validation](../Documentation/Validation/caption-natural-height.json) retains exact checks and limits. No personal screenshot was copied to source/evidence.

## Subsequent native sidebar follow-up

Build 17 supersedes the composed right panel with a native left split view. Caption sizing and clear drawing remain. [Current task](261017_native-left-sidebar.md).
