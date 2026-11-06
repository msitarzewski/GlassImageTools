# Native Mac toolbar layout — November 5, 2026

State: DOCS — applied, VM verified and installed. Owner approved the Preview-style main/Markup toolbar proposal after the native-pattern review.

Objective: Open Image beside sidebar and before title; separate history from document actions; Settings
and Inspector trailing; show/hide editing row with native controls and matching menu commands.
Reuse MacEditorView, MacEditorActions/MacEditorCommands, EditorModel and native SwiftUI toolbar/spacers.
Source-pixel geometry, shared/core and visionOS behavior stay unchanged. Mac 42; visionOS remains 38.
Local edits/builds/docs, headless VM-only GUI checks and updating the Applications installation are
already authorized. Preserve host windows/unsaved work and other VMs. No host GUI execution, new capture
or permission grants, source/signing-data transfer to VM, delegation, publication or account actions.

Acceptance: actual native order/groups, empty/image layouts, show/hide via toolbar and View menu,
menu tools reveal hidden row, crop/annotation functionality and real PNG Copy; Release build/signature,
four sandbox grants, test-source compile. Store only sanitized evidence. Apply guarded staged diff,
install exact verified product without quitting/relaunching host app; stop only task VM and update docs.

## Implemented and verified

MacEditorView reuses native leading navigation placement and three trailing action groups with standard
fixed spacers. Only open images show the Markup toggle; empty windows retain Settings/Inspector and Open.
The image-only accessory row is hideable. MacEditorCommands owns the View visibility/shortcut/Pan and
Image commands; existing EditorModel methods and EditedImageTransfer own edits and sharing. Text/shapes
selected from menus reveal hidden editing controls. Source-pixel rendering and image lifetime unchanged.

Release and test-source build-for-testing pass; tests were compiled, not executed on the host or guest.
The initial menu-container compile issue was corrected by applying disabled state to its view contents.
Exact signed Release passes strict signature, four intended grants, no test/debug exceptions and matching
privacy manifest. Native guest checks cover leading order, two 8-point system group gaps at 1256-point
window width, Open choices, hide/show via toggle/View, focused ⌘⇧M, menu-inserted editable Text, Ellipse
selection, Crop Dimensions, rotation to 300 × 400, annotated 400 × 300 PNG clipboard and save/discard close
protection. The first shortcut attempt targeted an unfocused window; refocusing and repeating verified
both directions. No code change was needed. Guest has CLT only; these are AX/pointer/keyboard/clipboard
checks, not XCTest. No host GUI or new capture/permission action. Prior core/full-suite evidence retained.

[Scoped evidence](../Documentation/Validation/mac-native-toolbar.json). Applied 17 reviewed files with no
baseline conflicts, private findings or broken relative links. Canonical 1.0 (42) is installed at
`/Applications/Glass Image Tools.app`; strict signature, production grants and exact built/installed tree
readback pass. Prior bundle preserved, no host app closure/launch; task-owned guest stopped. Next: owner
saves current work and reopens the installed app when convenient. No publication or headset action.

## Platform references

- [Apple ToolbarSpacer](https://developer.apple.com/documentation/swiftui/toolbarspacer)
- [Apple navigation placement](https://developer.apple.com/documentation/swiftui/toolbaritemplacement/navigation)
- [Preview Markup toolbar](https://support.apple.com/en-ie/guide/preview/prvw11580/mac)

## Preview Markup reference follow-up — build 43

State: DOCS — applied, guest verified and installed. Owner supplied the actual Preview toolbar after build 42. Its borderless icon controls,
menu indicators and separators are the visual reference. The former accessoryBar button style narrowed
controls into scope-bar sizing. Replace that style with native borderless controls, large control size,
semantic symbol size and standard menu styling; separate mode, contextual tools and view options with
native Dividers inside the system accessory placement. Retain the shared tool order and behavior,
main toolbar and its hide/show/menu/shortcut paths. No new editing capability, shared/core change,
permission or capture. Mac-only 43; visionOS stays 38. Existing local/VM/install authorization applies.
Acceptance: actual target/icon geometry improves without clipping; native shape choices and selection,
editable annotation/export, crop actions, hide/show recovery and empty-row removal remain functional.
Build/signature/grants and test-source compilation required. Preserve host windows; no host GUI test.

### Build-43 implementation and validation

MacEditorView keeps the system accessory placement and its mode/contextual/view groups, replacing
compact scope styling with native borderless controls and two standard Dividers. A shared markupLabel
sets semantic symbol styling and a 32-point minimum target. MacMarkupMenu is a focused AppKit adapter
for Shapes/Crop Preset/Zoom: NSPopUpButton, native arrow, 20-point image from the first pull-down item,
standard control target/action dispatch through its retained coordinator, explicit enabled/checked
states and native accessibility. It owns presentation only; existing model methods own every action.

The first native SwiftUI sizing attempts left menu labels compact. NSPopUpButton preserved the target;
the initial per-item action approach failed functional QA and was replaced by the documented control
target/action route. Final actual selection changes Ellipse and draws it, demonstrating callback dispatch.
One test-guest interruption occurred during rebuilding; final checks were repeated after restarting.
No cause is asserted. Task guest was stopped for subsequent main rebuilds to limit concurrent resource use.

Final Release and existing test sources compile (no XCTest execution); strict signature/four production
grants/manifest pass. Native guest observations confirm 32-point targets, three working popups, seven
shape choices, editable Ellipse/Text, hide/show recreation, 150% Zoom, 640-square preset and annotated
400 × 300 PNG Copy, then discard/empty recovery. No new capture/permission or host GUI action. Existing
core/full-suite/hardware acceptance scopes remain. Exact compositor matching to Preview is not claimed.
[Evidence](../Documentation/Validation/mac-markup-reference.json). Applied 17 reviewed files without
baseline conflicts/private findings/broken links. Canonical build 43 is installed at
`/Applications/Glass Image Tools.app`, with strict signature, four production grants and exact product-tree
readback verified. Prior bundle and running host windows preserved; no host app closure/launch. Task guest
stopped. Next: owner saves current work and reopens the installed app for appearance acceptance.

[AppKit popup action reference](https://developer.apple.com/documentation/appkit/nspopupbutton/init(popupmenu:target:action:)).
