# Correct Mac toolbar parity — November 5, 2026

State: DOCS — corrected implementation applied and VM verified. Owner clarifies the Mac toolbar should be the same as Vision Pro. The prior eleven-icon
interpretation was incorrect. Match the actual EditorView editorToolbar: mode, contextual crop controls
or Select/Shapes/Draw/Text/Pixelate, zoom/view and Settings, in that order. Use native Mac accessory placement
rather than a spatial ornament; document actions stay in the main toolbar. Shapes are the existing seven
choices in one native menu; immediate text/pixelation insertion and model semantics stay unchanged.

Local edits/builds/docs and VM-only GUI verification authorized. Reuse MacEditorView/AnnotationKind and
EditorModel; no core/visionOS changes, delegation, permissions, account or publication. Preserve all
host windows and do not relaunch on the desktop. Use the existing task-owned headless guest and its
trusted AX/pointer helper, no new screen-capture grants or captures after the earlier rejection.
Check control order, shape menu/selection, drawing/text/pixelation, crop controls/rotation and real
clipboard dimensions. Mac build 40; visionOS/global build remains 38.

## Verified implementation

Mode is moved out of the Mac title controls into the editing row. Annotate exposes Select, one Shapes
menu with the seven choices from AnnotationKind.shapes, Draw, Text and Pixelate; zoom and Settings follow.
Crop substitutes preset/dimensions/rotation. Zoom percentage is visible and SettingsLink opens the
native app settings. Settings remains available without an image. Shapes uses lastShape's symbol and
existing chooseTool; Text/Pixelate reuse useTool. Core and visionOS files are untouched.

The exact signed Release ran in the existing task-owned headless macOS 26.6.2 guest. Native AX/pointer
and real clipboard checks confirm control order, menu choices/ellipse drawing, editable text, pixelation,
full-image rotation (640 × 960), crop to 400 × 300 with matching decoded PNG, 150% zoom and native Settings.
The guest has CLT; no XCTest run is claimed. No host GUI test, new capture request or permission action.
Release build/analyze/deep signature and four unchanged grants pass; test source build-for-testing exits
0 without executing it. Core/full suites were not rerun. [Evidence](../Documentation/Validation/mac-toolbar-parity.json).

## Applied delivery

19 reviewed files applied with exact hashes, no conflicts/private findings and valid relative links.
The signed Mac 1.0 (40) app is retained at ignored `build/Glass Image Tools Vision Toolbar.app` for owner
review. No host launch/test was performed. Only the task-owned VM was shut down. The previous flattened
layout is explicitly superseded in memory/release docs. VisionOS packet still validates at 38. No new
capture, permission grant, publication, upload or headset action. Core and broader manual limits remain.

## Applications installation — November 5

Owner explicitly requested a fresh build and installation in `/Applications`. Built the current Mac
Release again using canonical `com.glassimagetools.mac`, version 1.0 (40), then installed as
`/Applications/Glass Image Tools.app`. Build exits 0; deep strict signature, four intended grants,
no debugger/test exceptions, matching privacy manifest and exact installed/built tree checks pass.
No functional source change, host GUI test, app launch or app closure. Existing runtime windows are
preserved. Prior native VM acceptance remains the functional evidence. This is development signing,
not a notarized/store distribution. [Install evidence](../Documentation/Validation/mac-applications-install.json).


## Settings in main toolbar — build 41

Owner screenshot asks for the small Settings gear to join the main toolbar beside Inspector. This
explicitly refines the previous parity layout. Reuse SettingsLink, remove its accessory-bar-only style,
place it immediately before Inspector, and omit the whole accessory group when no image is open.
The standard Mac toolbar now owns the gear's size/glass/hover treatment. Source-pixel model and editing
controls remain unchanged. Mac-only version 41; visionOS stays 38.

Exact Release checked in the headless macOS 26.6.2 VM. Main-toolbar ancestry and adjacent enabled Settings
confirmed with no image and with an image. Opening/closing a synthetic image adds/removes editing tools;
empty-view offset returns to the same 456.5 points relative to its window, proving no leftover row.
Gear opens the native General settings window. Release build/deep signature/four grants and test-source
build-for-testing pass. No host GUI execution, new permission/capture, core/full suite or device action.
Applied 16 reviewed files without baseline conflicts; installed canonical 1.0 (41) under the existing
installation request. Installed signature, production grants and exact product-tree readback pass. Prior
bundle preserved, no host app launch/close, task-owned VM stopped. Owner can reopen when convenient.
[Scoped evidence](../Documentation/Validation/mac-settings-toolbar.json).

