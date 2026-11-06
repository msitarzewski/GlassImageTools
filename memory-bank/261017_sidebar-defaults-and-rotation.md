# Native sidebar defaults and image rotation

## Contract — October 17, 2026

**State:** Reviewed/tested/applied; build 18 installed and identity verified; normal launch/process verification awaits headset unlock.

**Objective / authorization:** Owner reports a dark rim after the native split view, wants Apple's default sidebar-toggle placement/layout, removal of the blue title control, and working image rotation in Crop. The supplied hardware screenshot shows the blue control is Paste Image, while Copy is gray. Move native Paste into Import and retain command-V; preserve quick Copy. Local implementation/tests/docs and same-headset signing/install/launch remain authorized. No Git/publication or delegation.

**Reuse / owners:** EditorView owns split layout, existing import/menu and native toolbar. The former circular arrow is Reset Crop, not rotation. Add a distinct Rotate Left, retain Reset with an unambiguous icon. Extend EditState value history, CanvasTransform and existing CGContext composition for quarter-turns without rewriting source files or allocating another full-resolution image. Keep source annotations/crop coordinates stable; transform their display and output together. Existing pixelation/composition/privacy boundaries remain.

**Acceptance:** One default native sidebar toggle, no exposed padded backplate rim, actual hide/show/text/color lifecycle, crop after rotation at zoom, correct output dimensions/pixels/EXIF/annotations and Undo/Redo, unchanged source bytes. Native Paste remains explicit through Import/keyboard. Test geometry/rendering with swift test, native model/UI/audits, actual compositor, signed Release/signature/privacy and conflict-free application. Physical observations and recipient/capture/resource coverage stay separate.

**Risk / next:** Native column materials/default toggle can differ from custom controls. SDK containerBackground navigation placements are unavailable on visionOS, so no unsupported background API. Verify the simple outer-padding correction in compositor. Rotated handles must resize the correct source corner, and hit regions/axis labels/export dimensions must agree. Inspect current owners before changes; retain all prior failures in evidence.

## Validation checkpoint

The first core test attempt could not access compiler caches under the workspace sandbox. Supported normal host compilation then exposed a nested Testing macro in the new fixture; corrected without changing production logic. All 62 core tests/four suites now pass, native exit 0. Rotation composes with all eight EXIF orientations, crop pixels/retained annotations, PNG/JPEG metadata stripping, translucent redaction and value history. First signed Release build/analyze and strict signature/privacy checks pass.

The first native run passed two of six cases, with 18 assertions across four failing cases: no system sidebar toggle after the dynamic default-removal modifier, native grouped-number labels differing from the test strings, and a short coordinate drag that did not establish a crop Undo step. Actual rotated text remains editable. No failure waived. Use the SDK-supported DefaultToolbarItem for the sidebar rather than dynamic suppression; native number grouping is accepted, and the proven handle-to-handle gesture is used. Reset moved into Crop Preset so Rotate occupies its previous toolbar slot. Focused UI rerun precedes final signing/application.

## Default-item diagnostic checkpoint

The explicitly requested SDK DefaultToolbarItem(sidebarToggle) compiled but still emitted no visible/accessible control in the actual visionOS layout. Apple documents automatic sidebar items only on some platforms. Two distinct supported approaches produced no toggle; do not claim a system-generated control. Use one ordinary SwiftUI Button in the split detail navigation ToolbarItem(.navigation), letting the native toolbar own its placement/material. No title-ornament duplicate or custom surface. Preserve the actual visibility, native form lifetime and all failed evidence.

## Corrective validation and final run

Second UI command: five cases, one passed, seven assertions across four failures, native exit 65. The zoom/Pan crop regression passes. The updated native Rotate/Undo/exact-field/zoomed-handle/reset checks pass until the missing toggle. A real largest-text Crop toolbar overhang (792.5 / 720) is fixed by putting exact dimensions into Crop Preset at compact/accessibility sizes; Reset is also in that menu. The Paste test had left the Import menu open while attempting unrelated crop controls; now it opens the real menu only at Paste invocation. No production permission/clipboard workaround. A standard native navigation ToolbarItem with one sidebar Button replaces the non-emitting default item.

Call-site review found the research target still used the earlier EditorView initializer. Extract the existing per-window EditorWindow into one shared owner and use it for the main and capture windows. This preserves per-window minimum behavior and repairs the actual probe call site; it introduces no capture capability. Final nine-case UI run, signed Release and separate probe compilation precede application.

## Native layout boundary correction

The ordinary native navigation button fixes actual hide/show and system color return; the compact toolbar, real Paste replacement, crop/copy/export, rotated dimensions/handles/Undo and largest text now pass. One native caption check exposed its selectable-text accessibility rectangle extending four points past the window after outer padding removal: native text selection adds 16-point horizontal interaction insets around glyph bounds, while the caption margin was 12. Increase the modest margin to 16, preserving intrinsic height/quiet states and the strict window-edge assertion. Use topBarLeading explicitly: the generic navigation placement rendered the button at the trailing edge on visionOS. Verify actual leading geometry, source snapshots, final native checks and signature before applying.

## Final applied outcome

Release 1.0 (18) is installed and identity verified; normal launch/process verification awaits headset unlock. The loaded native split view reaches the window edges,
removing the exposed padded rim. One sidebar button uses the native leading navigation toolbar;
automatic/default-item attempts did not emit a control in this visionOS layout. The blue standalone
Paste action moves into Import; quick Copy keeps system styling. Rotate Left is a real nondestructive
quarter-turn, with Undo/Redo, rotated crop handles/fields/presets/axis dimensions, retained editable
annotations and correct export. Reset stays separate in Crop Preset; compact exact controls use that menu.
Caption margin is 16 points to contain native text-selection interaction bounds; height stays intrinsic.
A shared per-window EditorWindow also repairs the research target's editor call site.

62 core tests/four suites pass (command 4.622 seconds); all 31 actual native service/model
checks pass. Final five UI cases pass, exit 0 (160.307 seconds); ten distinct cases pass across stages,
with initial failures retained and no clean ten-case command claimed. Final native/signed/applied source
identity agrees. Signed Release build/analyze (13.310 seconds), strict signature/privacy and isolated
probe compilation (4.224 seconds) pass. Expected AppIntents metadata skip examined. Simulator
restored without fixture arguments. No new permissions/dependencies/network or Git actions.

Physical input/VoiceOver/motion/material preference/resource, wider recipient and capture acceptance
remain separate. Native command-V binding is retained; hardware keyboard/focus is not newly certified.

[Sanitized validation](../Documentation/Validation/sidebar-defaults-and-rotation.json).

## Platform references and deployment handoff

[Apple split views](https://developer.apple.com/design/human-interface-guidelines/split-views), [NavigationSplitView](https://developer.apple.com/documentation/swiftui/navigationsplitview) and [toolbar placement](https://developer.apple.com/documentation/swiftui/toolbaritemplacement/topbarleading) informed the native layout. Actual SDK declarations and simulator observations determine availability/behavior.

Build 18 installation and installed identity pass; the supported lock-state query reports passcode required. No launch was attempted through that gate, and no running-state claim is made. Unlock then run the ignored stage resume-launch-verification helper using the current private deployment pointer; it checks lock, launches without fixtures and reads the running process without reinstalling. Update the current record in place after actual evidence; do not rerun the full record-generation helper and duplicate history.
