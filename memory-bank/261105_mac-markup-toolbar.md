# Native Mac markup toolbar — November 5, 2026

**Layout superseded by build 40:** the owner clarified exact Vision Pro toolbar parity. The eleven-icon
layout below was the agent's incorrect interpretation; its validation is historical. See
[the correction](261105_mac-toolbar-parity.md). VM-only testing and its evidence remain valid.

State: DOCS — applied; VM verified; local app retained.

Objective/authorization: Owner requests moving the screenshot's object/drawing menu into a toolbar like
visionOS. Local edits/build/tests/docs and launching a reviewable Mac preview are authorized. Preserve
running app state; a prior auto-review rejected closing the owner's app. Use a distinct container for
new preview delivery. No Git, delegation, publication, account mutation, permissions or capture changes.

Owners/reuse: MacEditorView owns presentation; existing EditorModel.useTool/chooseTool and AnnotationKind
own tool selection and object insertion. visionOS already has visible Select/Shapes/Draw/Text/Pixelate
controls. Mac's all-tools menu is the actual gap. Use native SwiftUI accessoryBar, confirmed in the
installed SDK (macOS 13+) and Apple's documentation, for a separate row below the main title/toolbar.
Expose each object tool directly with standard icon controls, native toggled selection, labels/help and
unchanged inspector/model behavior. Keep document/navigation tools in the main bar.

Acceptance: All ten annotation tools and Select are reachable without a dropdown while Annotate is active;
Crop/empty state hides the row. Shape/drawing choices remain drawing modes; Text/Pixelate add editable
objects immediately. Verify mouse drawing and text editing/Copy, exact crop regression, default and
narrow native layout, Release build/signature/sandbox and source application. Core logic is unchanged.

Risks/next step: Native accessory row's actual layout must be observed/tested; avoid a custom glass bar.
Toolbar-only Mac build version advances independently; preserve visionOS build/packet identity.

## Owner steering

The owner requests GUI testing in the Mac VM using Glass Power Tools’ setup. No further host GUI tests.
Read its native Tart/SSH/Aqua helper documentation; use an isolated clone, headless with audio and clipboard
sharing disabled. Preserve existing VMs and host image windows. VM checks are recorded separately from
host Xcode results. No reset of a shared VM, broad repo share or signing-key transfer.

## Implemented and verified

The all-tools dropdown is removed. Eleven native icon controls share one accessory row; drawing modes
are native toggles, while Text/Pixelation call the existing insertion actions. The inspector and core
are unchanged. Mac-only build 39 leaves visionOS and its packet at 38.

Before VM steering, two focused host UI cases passed. The new host toolbar test exposed harness-only
assumptions about raw IDs, numeric checkbox values and fixed resizing; its final source honors native
constraints but was not executed again on the host. Host-only compile-for-testing is separate evidence.
The complete remaining workflow was exercised in the requested VM, running macOS 26.6.2/CLT with the
exact signed Release. No XCTest guest run is claimed. All eleven named/enabled tools fit one row and
the native constrained 1256-point window. Seven shape controls, Drawing, Text and Pixelation are direct;
row removal/return in Crop/Annotate is verified. Actual rectangle/freehand/text/pixelation objects persist;
text/font edits read back; decoded copied PNG is 480 × 320 with 2280 annotation-red pixels. Original
fixture bytes match; two accessibility-confirmed field-operation Undos restore 960 × 640.

The clean guest initially had an older helper without drag; it was refreshed from the established
read-only tools share. Action observations prevent asynchronous AXPress/redraw races. Initial clean
full-screen capture was inspected. A later capture showed the optional SSH screen-capture notice.
Automatic review rejected pressing Allow. No permission was granted or bypassed; existing trusted
AX/pointer/clipboard access supplied remaining checks. No new captures were requested after rejection.
Host graphics/audio/clipboard sharing are disabled; no personal image, source tree, signing environment
or key was copied. The other VM and host app windows remain untouched.

Mac Release build/analyze/deep signature and four intended sandbox grants pass, with no debugger/test
exceptions and a matching privacy manifest. Existing core/full suites are retained, not rerun. The
visionOS packet still validates at 38. [Sanitized evidence](../Documentation/Validation/mac-markup-toolbar.json).
[Apple accessory bar API](https://developer.apple.com/documentation/swiftui/toolbaritemplacement/accessorybar(id:))
and [placement behavior](https://developer.apple.com/documentation/swiftui/toolbarplacement/accessorybar(id:))
confirm the native row below the window's main toolbar. No custom painted glass or floating panel.

## Applied handoff

19 reviewed files applied with exact hashes, no baseline conflicts/private-data findings and valid
changed relative documentation links. Final XCTest source compiles with `build-for-testing` (exit 0),
which did not execute or launch host UI tests. The development-signed Mac 1.0 (39) preview is retained in
ignored `build/Glass Image Tools Toolbar Preview.app`; copied product strict-signature verification passes.
It has not been opened on the host after the owner's VM instruction. The task-owned guest is stopped;
the original Glass Power Tools VM is independently confirmed still running. Its cloned disk remains
available for future headless checks. No host window/clipboard intervention, new permission grant,
publication, upload or headset action occurred after the VM steering. Future Mac GUI tests use the VM.
