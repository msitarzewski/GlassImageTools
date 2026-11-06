# Default native List styling — October 31, 2026

State: DOCS; Installed identity 1.0 (36), normally launched without test arguments and independently verified one running app process.

Objective: Owner's build-35 screenshot shows category hover and selected image row with different widths, heights and shapes. The owner explicitly requires Apple default styling.

Authorization: Local implementation, QA/docs and same-headset signing/install/normal launch remain authorized. No delegation, Git or publication.

Reuse/root cause: DocumentSidebar already owns the native List and compact filename rows. Categories alone force borderless Button style and rounded-rectangle border shape, creating a separately styled control inside each List row. Remove those two overrides, leaving automatic native List Button styling; do not draw a replacement selection, hover effect or platter. Preserve native document selection, callbacks, category labels, growing targets, Dynamic Type and the single rear glass surface.

Acceptance: Categories and image entries use their containing List's native interaction styling; no custom background/hover/border drawing. Verify real expand/collapse, document selection/Undo/close/Recents, largest-text audit and glass endpoints. Inspect populated compositor, sign/build and deploy with exact identity readback. Hardware gaze/hover appearance still needs owner observation; do not infer it from an audit or static screenshot.

Reference: [Apple List row hover effects](https://developer.apple.com/documentation/swiftui/view/listrowhovereffect(_:)) documents built-in visionOS row hover feedback. No hover override is needed for this change.

Next: Focused existing UI cases and signed Release; apply reviewed source and install if available.

## Applied result

Removed the category-only borderless Button style and rounded-rectangle border-shape overrides. Categories now inherit automatic native List Button styling alongside the compact image rows. List still owns selection; no custom background, selection or hover renderer was added. Category labels/counts, disclosure state, document callbacks, Dynamic Type, source pixels and window transparency remain.

Four existing focused UI cases pass, exit 0 (248 s): real category expand/collapse, document switching/independent Undo/close/Recents, clear/opaque/default glass, and compact long filenames at largest text, including native accessibility audits. Populated/empty and largest-text compositor inspected. Signed Release build/analyze passes (18.364 s), strict signature and privacy/Debug boundaries pass. The two AppIntents metadata-extraction skip warnings were inspected. Core and UI test source are unchanged; core 69-test/5-suite baseline, full UI suite and native services were not rerun. Hardware gaze/hover still needs owner observation. The task simulator is stopped.

Baseline conflict/privacy guards pass; applied source hashes match signed and native-tested inputs. XcodeGen regenerated the versioned project. No new permissions, dependencies, backend, image data flow or Git/publication.

Next: Owner gaze/hover and row-alignment acceptance using the native automatic controls.
