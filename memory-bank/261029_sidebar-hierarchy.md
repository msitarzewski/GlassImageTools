# Sidebar hierarchy — October 29, 2026

State: DOCS, build 34 applied and installed; normal launch awaiting unlock.

Objective: Owner's headset screenshot rejects the bare Open Images/Recents collapsible section headers as unlike Notes, Safari or Files. Replace that hierarchy with native icon-labeled expandable List rows, counts and indented image entries, with a quieter sidebar heading.

Authorization: Local edits/builds/tests/docs and same-headset signing/install/normal launch already authorized. No Git, publishing, external messages or delegation.

Owners/reuse: DocumentSidebar keeps native List selection and document/Recent callbacks, thumbnails and combined accessibility. Native List category Button rows replace expandable Section headers; EditorView changes only the sidebar title typography/alignment. DocumentWorkspace and acquisition/rendering models are unchanged.

Constraints: One adjustable rear glass surface and opaque foreground; no persistent navigation container, custom row drawing or custom disclosure/selection style; the category label may compose standard SF Symbols. Keep Open Images expanded and Recents collapsed initially. Preserve empty-workspace well tap/Command V.

Acceptance: Native symbols/disclosure rows with generous targets and hierarchy; meaningful empty children; accurate counts, one accessible item per image, independent document selection/Undo, close/cancel/reopen/Clear Recents, hide/show, compact/largest text and clear/opaque/default glass. Inspect actual empty and populated simulator compositors. Run focused UI/audits and signed Release; hardware launch does not certify appearance, gaze/hand or assistive technology.

Primary references: [Apple Sidebars HIG](https://developer.apple.com/design/human-interface-guidelines/sidebars), [Apple Lists and tables HIG](https://developer.apple.com/design/human-interface-guidelines/lists-and-tables), [DisclosureGroup](https://developer.apple.com/documentation/swiftui/disclosuregroup). Native runtime/API availability is checked separately from visual agreement with the user's examples.

## First runtime finding and correction

The first candidate used native DisclosureGroup rows, but this SDK/runtime laid expanded content beside the label within one cell. Labels wrapped, targets overlapped, nested tags stopped switching documents, and a category tap reopened a Recent unintentionally. The first UI command exits 65 (three cases fail, two pass). This was a real layout/selection regression, not a test waiver; it is not applied.

The correction keeps categories and conditional image children as direct List rows. A standard plain Button label composes Label, count and SF chevron; List owns row surfaces and selection. Child indentation is layout only. Expanded/Collapsed/count are explicit accessibility values, with native text, motion preference and growing 60-point targets. No custom DisclosureGroupStyle, hover drawing or selection background is introduced.

## Second runtime checkpoint

Direct List rows restore actual document switching/Undo/close/Recents (the lifecycle case passes). The simulator shows the `.sidebar` List style adding an inset grouped card around all rows, which still reads like a form. Category controls using plain Button style report non-hittable to native automation despite coordinate taps toggling them. The next candidate uses the standard plain List style without separators and standard borderless native Buttons with the system rounded-rectangle border shape; no painted row backgrounds or selection styles. Full target size remains a growing minimum, and all required checks are repeated.

## Third-run diagnostic checkpoint

The flat hierarchy and all document, transparency, largest-text and keyboard paths run correctly; empty category hit-target readiness remains the only failing case. The next focused reproduction disables List document selection when no document rows exist (an action-only list), while keeping selection for real images. Standard borderless controls use their intrinsic native sizing rather than adding a second label minimum; List retains the 60-point growing row minimum. This is a changed hypothesis based on the empty/nonempty difference; no failed assertion is waived and no candidate is applied.

## Baseline comparison and final verification contract

The private diagnostic built the unchanged installed build-33 App/Core sources. Both original category controls report isHittable=false and enabled=true, and bounded readiness predicates fail there too; the actual native Recents tap still reveals No Recent Images. This demonstrates that the new empty-state hit-report predicate is not a regression oracle on this simulator. The new regression instead requires enabled, minimum-sized controls and actual native taps that expand/collapse both groups, with observable child visibility and an all-issue accessibility audit. The reporting discrepancy remains documented; no physical gaze acceptance is inferred.

Disabling selection for an empty list did not change that discrepancy, so that experiment is removed. Final source retains the original selection binding, direct List rows and standard borderless controls with native body labels/intrinsic sizing. No production hit flag is faked or overridden, and no failed product action is ignored.

## Final compositor selection review

The action-based five-case run passed. Its populated compositor showed that the explicit clear row background suppressed the native visible document selection. Removed that override so the system paints selection; plain List style still owns the flat presentation. Repeat final validation against this source rather than carrying over the previous green run.

## Applied outcome

Installed identity 1.0 (34); normal launch waits for device unlock. Five focused UI cases pass, exit 0 (157 s), on the final signed source. Empty/populated/appearance/large-text compositor inspected. Core Sources/Tests unchanged from baseline 69/5; not rerun. No full UI/service rerun or hardware appearance/assistive-technology claim. Task simulator is stopped. Source/privacy/conflict/link checks complete before documentation application; no Git, publication or external messages.
