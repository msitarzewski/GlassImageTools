# Compact, centered Mac Markup — November 6, 2026

State: DOCS — applied, native guest verified and installed. Owner prefers smaller, centered controls from older
Preview. Source/installed 43 was confirmed before this change. Candidate Mac 44 / visionOS 38 reuses
MacEditorView/MacMarkupMenu, existing native actions and source-pixel models. No new editing feature,
shared/core/visionOS change, capture, permission, dependency, account operation or publication.
Local edits/builds/docs and Applications update authorized; preserve host windows/unsaved work and
other VMs. Only the isolated guest is used for interactive checks. No delegation or Git changes.

## Implementation and diagnostic evidence

Use body/medium SwiftUI symbols, 14-point AppKit menu symbols, regular native controls with 28-point
targets, a small segmented mode control and standard 16-point Dividers. Menu dimensions are centralized
in MacMarkupMenu. arrowAtBottom moves arrows to the edge rather than over the label; native control
coordinator is MainActor, resolving the inspected isolation warning. The system accessory host remains.

Initial ToolbarSpacer centering compiled but did not expand in this accessory placement. Actual guest
bounds exposed this; one expanding SwiftUI row with symmetric spacers now centers the native controls.
No custom chrome/background, private API or image-processing change. Existing native window constraints
and inspector behavior remain authoritative. Exact compositor/pixel matching to Preview is not claimed.

## Verification

- Signed Release build exit 0; existing test-source build-for-testing exit 0. No XCTest execution claimed.
- Strict signature, four unchanged production grants, no test/debug exceptions and privacy-manifest match.
- MainActor warning resolved; only AppIntents metadata-extraction skips remain (no framework dependency).
- Native guest macOS 26.6.2, headless AX/pointer/clipboard checks: controls stay inside their bar, visible
  AX bounds within 3 points of center across Crop/Annotate, inspector hide/show and 1100/1400-point windows.
  Native mode insets account for the visible-bounds difference; the content row uses symmetric layout.
- 28-point action/menu heights, 20-point mode height, 376-point crop/448-point annotate visible row widths;
  tested available bar widths 852/1152 points. Source menu symbol configuration is 14 points.
- Actual native menu selection changes to Ellipse and drawing creates an editable object. Text edited;
  hide/show reconstructs functional menus; Zoom reaches 150%; square preset outputs 640 × 640.
- Actual PNG clipboard has 400 × 300 pixels and annotation-colored pixels. Discard returns to empty view
  with Settings and no Markup row. No host GUI test, new permission/capture, full-suite or core rerun.

Both VM slots were initially in use by existing work. No other VM was stopped; only this task's failed
startup/wait wrapper was cancelled. A slot freed externally, so isolated guest QA resumed without
requiring an owner choice or assuming an unanswered approval. [Scoped evidence](../Documentation/Validation/mac-compact-centered-markup.json).

## Delivery

Applied 16 reviewed files with exact tested-source hashes, no baseline conflicts/private findings or
broken relative links. Canonical 1.0 (44) is installed at `/Applications/Glass Image Tools.app`; strict
signature, production grants and exact built/installed tree readback pass. Prior bundle and running
host windows preserved; no host app closure/launch. Task-owned guest stopped; other VMs untouched.
Owner can save current work and reopen when convenient. Appearance acceptance remains with the owner;
prior core/hardware/Photos/share/assistive-tech limits retain scope. No publication or account action.

## Platform references

- [ToolbarSpacer](https://developer.apple.com/documentation/swiftui/toolbarspacer)
- [Native edge arrow placement](https://developer.apple.com/documentation/appkit/nspopupbuttoncell/arrowposition)
