# Document sidebar and contextual inspector

State: reviewed, tested and applied. Release 1.0 (19) is installed and identity verified; normal launch/process verification awaits headset unlock.

## Contract

Replace the leading Tool Options column with actual document navigation. New Image opens Photos,
Files or an explicitly pasted image without replacing an edited document. A separate trailing
contextual inspector follows the selected document, using Apple's macOS inspector example for
sectioned property editing and native visionOS Forms/controls. Keep original pixels, vectors,
per-document history/viewport, opaque foreground and normal native window behavior.

Reuse EditorModel per open document, existing AnnotationInspector/CropInspector fields and protected
ImageSource ownership. A new per-window DocumentWorkspace owns only document selection and lifetimes.
Session Recents contain original discarded pixels or the last saved flattened copy; reopening creates
a clean editor. No persistent screenshot catalog. Eight open documents, eight recents and a 512 MiB
working budget bound aggregate retained source/preview storage. Clear Recents releases their ownership.
Import/export cancellation and close/save callbacks must target stable document identities.

Local staging, edits, tests, docs and same-headset signing/install/launch remain authorized. No Git or
publication. No delegation. Baseline build 18 is installed; previous launch awaits headset unlock.

Acceptance: native independent navigation/inspector toggles; header metadata; actual multi-document
switching with independent Undo/viewport; save/discard/cancel; clean flattened recent reopening;
Photos/Files/Paste recovery; native accessibility audits and compact/largest-text geometry. Run core
suite, real native service checks/UI, signed build/analyze and separate probe compile. Physical install
and normal launch are separate from actual headset input/recipient/capture acceptance.

## Platform evidence

Installed visionOS 27.2 SwiftUI declares inspector and inspectorColumnWidth unavailable on visionOS;
UIKit's inspector split-view column is also explicitly unavailable. Use supported SwiftUI composition
for a right in-window native Form, not an unsupported modifier. Apple's [inspector example](https://developer.apple.com/videos/play/wwdc2023/10161/)
places contextual Forms beside main content and controls visibility independently of navigation.

## Historical implementation and QA checkpoint

Implemented independent leading Images navigation and trailing contextual Crop/annotation Forms,
per-document edit/Undo/viewport ownership, native +/chevron acquisition, leading image metadata,
compact native Image Actions overflow and protected session Recents. Export completion retains the
actual successful artifact against stable document/source/edit identities. Existing source-pixel
rendering, opaque foreground and core image services remain.

62 core definitions/four suites pass (command 17.225 seconds, exit 0). Current signed Release build/
analyze passes (12.136 seconds, exit 0), strict signature/privacy passes; one expected AppIntents
metadata-skip warning examined. Separate device probe compile passes (4.081 seconds, exit 0); this
is compilation only. Final source application, services, focused UI completion and deployment remain.

Initial compile exposed throwing boolean syntax, corrected before native execution. Early UI runs
retained: 2 cases/1 pass/1 fail (two assertions); 4 cases/2 pass/2 fail (six assertions); 6 cases/3 pass/
3 fail (three assertions). Their completed assertions were preserved; result finalization stalled,
so only these task runners were interrupted after the documented 90-second finalization wait.
Native color RGB/live edits/Undo, Forms/all-issue audit, rotated text and natural captions passed at
their tested stages. No aggregate clean suite or final-source acceptance is inferred from those.

Corrections: remove ancestor identifiers masking native form/title identities; use a real preset to
create the document test's edit rather than a delete/type sequence on a formatted numeric binding;
wait for actual close/Recents completion. The large-text navigation principal lost the filename under
action pressure, so metadata now sits leading above the canvas, with compact secondary-action overflow.
A native toolbar Menu wrapper reports nonhittable after column reparenting although its actual Files
menu/picker/Cancel path works. Final tests require the real path rather than that misleading hint.
Focused final-source collapsed layout, largest text, document lifecycle and service checks are pending.



The focused collapsed-window reproduction confirms the + menu really opens Files and returns via Cancel
while both panes are hidden, despite its outer accessibility wrapper reporting nonhittable. The native
tree/compositor verifies the control is visible. Final regressions therefore assert the actual menu and
picker outcome. The responsive leading metadata header separately restores the large-text filename;
compact secondary actions use a real native overflow menu. No custom menu hit-testing workaround added.


Largest-text native observation found a 126.5-point accessible canvas after the new header; accessibility
windows now use a 600-point minimum height (normal minimum stays 540). Keep the 140-point usability
assertion. Caption text can legitimately span canvas padding: its boundary assertion uses the actual
right inspector edge rather than the narrower canvas interaction frame. Native trees and compositor
show the text remains in the main pane; retain actual scrolling and all-issue audits.


Close ownership is consolidated in DocumentWorkspace. A saved export can exceed the input cap or become
unavailable; failure to make an optional recent must not trap a successfully saved/discarded document open.
The close path reports a visible warning and closes without a broken recent. Cancellation instead keeps
the image open. Native regressions deliberately remove a synthetic saved output and cancel a close task;
normal save/flatten/reopen still uses the actual queued export artifact. Final verification pending.


## Delivered outcome

Release 1.0 (19) is installed and identity verified; normal launch/process verification awaits headset unlock.

A native leading Images sidebar now navigates open images and session Recents. New Image (+/chevron)
opens Photos, Files or explicit Paste as another document, preserving existing edits. Each image keeps
its own Undo, selection and viewport. An independent right contextual Form provides Crop or annotation
properties, following Apple's Mac inspector example with supported visionOS composition. SwiftUI
.inspector and UIKit's inspector column remain unavailable in the installed SDK. Metadata is leading
above the canvas; narrow layouts use native Image Actions overflow. Accessibility windows have a
600-point minimum height, normal windows 540. Native materials and opaque foreground remain.

Closed images reopen as last-saved flattened pixels, or originals when never saved and edits discarded.
Recents are window/session-only with Clear Recents, count and source/preview retention limits. Actual
saved artifacts are matched to document/source/edit identities. Failed optional Recent copying cannot
trap close; a visible warning explains omission. Cancelled close retains the source/model. No durable
catalog, new permissions, networking, dependencies or Git/publication.

62 core tests/four suites pass (command 17.225 seconds). All 42 actual native
model/service checks pass, including flattened reopening, independent history/viewport, stale saves,
resource rejection, private-file cleanup and close failure/cancellation. The nine native UI cases completed with zero failures (suite 339.727 seconds); Xcode result finalization stalled, so the task runner was interrupted (native exit -15, command 458.791 seconds). No clean nine-case command is claimed.
After only the close-recovery/announcement ownership refinement, The final close-path cases completed with zero failures; result finalization was interrupted (native exit -15, command 222.04 seconds). Final native,
service, signed and applied App/Core sources agree. Native all-issue app audits ignore no finding;
actual palette RGB/live color/Undo, Files/Cancel, Photos save-before-close, copy/export, editable rotated
text and natural/scrolling captions are exercised. Earlier failures and result-finalization limits remain
recorded; no full-suite or current-source nine-case rerun is claimed.

Final signed Release build/analyze passes (12.044 seconds), strict signature/privacy passes,
and separate device probe compilation passes (3.946 seconds). Expected AppIntents metadata skip
examined. Native numeric selection emitted a UIKit portal-view hosting warning; this app contains no
UIHostingController/UIViewController/UIViewRepresentable owner, and actual edit/Undo/export completed.
That runtime observation remains recorded, not suppressed or claimed fixed. Physical input, assistive
technology/focus, materials, resource profiling, wider recipients and actual capture remain separate.

Unlock the headset, then verify normal launch/process without rebuilding or reinstalling. Same-headset signing/install/normal launch remain authorized.
[Sanitized evidence](../Documentation/Validation/document-sidebar-and-inspector.json).

Final application: 14 implementation/test/project files and 20 documentation/evidence files applied without baseline conflicts. Public text scan: 98 files, zero private-content issues; changed document links and application hashes have zero issues. Simulator restored without test arguments. No Git initialization/publication.
