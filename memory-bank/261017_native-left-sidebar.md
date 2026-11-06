# Native left Tool Options sidebar

## Contract — October 17, 2026

**State:** Reviewed/tested/applied; build 17 installation/identity verified; launch pending unlock.

**Objective / authorization:** Owner requests a formal left sidebar, referencing a macOS navigation
sidebar, and asks whether that pattern is reserved for tabs. Local edits/builds/tests/docs and
same-owner Vision Pro signing/install/launch remain authorized. No Git/publication or unrelated devices.

**Reuse / owners:** EditorView owns presentation, AnnotationInspector owns existing native grouped Form
and transactions. Replace hand-composed right HStack/transition with NavigationSplitView leading column;
retain one document-action sidebar toggle and bottom primary toolbar. No new navigation hierarchy,
vertical icon rail or tab model. Source/model/core/render/export/inference and natural caption unchanged.

**Platform evidence:** Actual installed SDK 27.2 exposes NavigationSplitView, visibility binding,
column widths and balanced style on visionOS. SwiftUI inspector remains unavailable. [Apple sidebars](https://developer.apple.com/design/human-interface-guidelines/sidebars)
cover leading navigation; [split views](https://developer.apple.com/design/human-interface-guidelines/split-views)
allow supplementary content and prefer it to another visionOS window. Floating visionOS tab rails are
a distinct navigation component; [toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars)
advise against vertical toolbars. SDK compilation does not prove native column visibility/layout works.

**Acceptance:** Native leading Form, hide/show/Done/mode/text/close lifecycle, canvas/caption beside it,
minimum/largest text layout, actual vector gestures/Undo, crop and accessibility audit. Preserve opaque
image/controls, rear appearance, source-pixel precision and intrinsic caption height. Inspect compositor,
build/analyze/signature/privacy and exact applied hashes; then install and read back identity/normal launch.

**Risks / next:** Native split behavior/material/nav chrome/column visibility may differ from the old
HStack; inspect actual simulator before application. Real hardware gaze/focus/motion and recipient/resource
acceptance remain separate. No delegation or new dependencies/permissions.

## Initial native observation

Signed Release/SDK build and analyze pass. Actual simulator compositor confirms a leading native split
column, shared native column presentation, visible editor/caption and native window expansion to 819
points at largest text. First test failed because it queried only Other, while the sidebar is now a
native CollectionView carrying the correct annotation-panel identifier. Update the shared helper and
HIG tests to query the stable identifier across element types. No app change is needed for that query
correction; all geometry, visibility, native-control and audit assertions must still pass.

## Integration correction

The corrected-query run reproduced a real missing Done action after reopening for Text and after the
actual system color palette. Two cases completed with two failures; the remaining selected cases were
cancelled. Graceful interruption did not end Xcode reporting, so only this task's known command was
terminated; native exit -15, no passing full-suite claim. Raw evidence remains private.

AnnotationInspector now provides the existing Form directly; NavigationSplitView owns column navigation
instead of embedding a second NavigationStack. Model, form fields, typography/transaction callbacks,
canvas, caption and rendering are unchanged. Signed corrected build/analyze/signature pass. The two
failed native interaction/audit cases are being rerun before the remaining editor regressions.

### Diagnostic checkpoint and persistent column

Removing only the nested NavigationStack did not fix the two Done failures (two/zero passed, 74.689
suite seconds, native exit 65). Do not attribute the fix to that removal alone. The next correction
keeps the native sidebar's content mounted while visibility hides the column, instead of replacing
it with EmptyView. AnnotationInspector now receives explicit visibility to begin/end transactions and
finish font edits deterministically; hidden selection/type changes do not begin inspector history.
EditorView reveals selection when showing the column. Native split view owns navigation; form content
and source/model/render/inference remain reused. The corrected text/modal/export/audit path has passed;
actual color-return and remaining source/gesture/history regressions are required before deployment.

## Native sizing and foreground-caption validation

Persistent column ownership passes both previously failing text/modal and actual color-return/Undo
paths: two cases, zero failures, 84.485 suite seconds / 91.988 command seconds, native exit 0.

The subsequent nine-case editor run passed six cases (zoomed crop, text typing/typography, object text
menu, contextual controls, freehand resize/history and tiny-object independent Undo), but failed three
cases/eight assertions. Actual compositor shows caption glyphs correctly beside the sidebar, while the
native scroll container's AX frame spans the whole window and text's frame includes native insets.
Validation now checks the visible heading, text center/right extent, usable canvas and actual scroll
movement, rather than assuming a scroll-background frame equals foreground bounds. No app caption
change was made. The compact normal window also collapsed the sidebar; unlike the old HStack, native
split views may require more width. Let the system expand to a readable two-column minimum derived
from the 320/400-point sidebar, 480-point detail column and existing outer insets. Accessibility text
keeps compact primary toolbar controls even after window expansion. Caption height continues to follow
actual wrapping; a native expanded window may preserve its previous height.

At that checkpoint, final native modal/color/column/compact/largest checks and signed build were still running. The nine-case
runner needed report finalization interruption after completed assertions (native exit -15); failures
are retained. No source/model/core/render/export/caption/inference API changes; presentation owners and their native tests/configuration were the proposed scope; the final scene-minimum fix additionally changes App window ownership.

### Per-window minimum ownership

The next five-case run passed four but largest text exposed a real right-edge extent beyond the actual
window (839.5 vs 819 points). A minimum on the inner content did not update the outer scene constraint.
Keep this failure; do not relax the right-edge assertion. EditorWindow now owns a per-window minimum
binding at the WindowGroup content frame, updated by EditorView from sidebar presentation/text size.
The inner forced frame is removed. This lets windowResizability(contentMinSize) enlarge the real native
window; separate windows do not share a minimum. The final five-case native run/signature checks were rerun; passing results follow below.
The preceding five-case report stalled after completed assertions and was terminated (native exit -15).

## Final applied outcome

Tool Options uses a native leading NavigationSplitView column, reusing the existing grouped Form and
bottom primary tools. One sidebar-symbol toggle controls visibility. Sidebar content stays declared
while hidden; the split view owns navigation and explicit visibility starts/ends inspector sessions.
This fixes the reproduced missing Done after text/color interactions. Native minimum content widths
let visionOS expand the window when the column is shown; accessibility text retains compact tools.
Natural captions, source pixels, original bytes, vectors, model/core/render/export and local inference
remain. Native scroll-container AX bounds span more than foreground content; visible caption heading/
text bounds and actual scrolling/compositor are verified.

Final five native cases pass, zero failures, command exit 0 (162.337 seconds). Eleven distinct
cases pass across stages; six earlier editor successes predate only final sizing/toolbar adjustment.
Initial AX-query, toolbar-lifetime and compact-layout failures remain recorded; no clean eleven-case
command claimed. Actual palette RGB/live-color/Undo, native forms/export, typing, text menus, crop,
drawing and tiny-object independent history pass. Native all-issue app audits ignore no finding.
Signed Release build/analyze (12.603 seconds), strict signature/privacy and seven-file exact
application pass; final native/signed/applied sources match. Existing 57-core/30-service baseline retained,
not rerun. Expected AppIntents metadata skip examined; no new permission/dependency or Git.

Glass Image Tools 1.0 (17) installation (3.098 seconds) and actual
installed identity readback passed, exit 0. Initial normal launch timed out after 45.135 seconds. Default
process/lock queries hit CoreDevice initialization failure. A supported host lock check passed and
reported passcode required; the normal launch retry timed out after 30.149 seconds. No successful
running-process observation or build-17 launch is claimed. Await owner unlock to finish normal launch
and independent process verification; reinstallation is unnecessary. Existing authorization persists.
Physical gaze/focus/hand/VoiceOver/motion/material preference, resource, recipient and capture acceptance
remain separate.

[Sanitized validation](../Documentation/Validation/native-left-sidebar.json) and [physical history](../Documentation/Validation/physical-deployment.json) retain exact scope.
