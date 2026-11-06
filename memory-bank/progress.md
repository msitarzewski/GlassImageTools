# Progress

## November 6 — Mac Quit correction and distribution preparation

Mac 45 fixes the pending-termination save question and post-sheet close timing. Native guest Cancel,
export cancellation/retry, Discard process exit, PNG Save/exit and sequential two-window saves pass;
original fixture bytes unchanged. Release and Debug test-source compilation pass. Developer ID universal
archive/export, unchanged four grants, hardened runtime, accepted/stapled app/DMG and Gatekeeper pass.
Application/install and first public source/release/site completion are still pending at this checkpoint.
No host window closure, core/full-suite rerun or headset action. [Quit](261106_mac-quit-hang.md), [release](261106_mac-release.md).

## Smaller centered Mac Markup — 1.0 (44), November 6, 2026

Owner prefers older Preview proportions. Body-sized symbols and 14-point native menu images replace
the large treatment, with 28-point targets, a smaller segmented mode control and shorter Dividers.
An expanding SwiftUI row centers the existing controls inside the system accessory bar; menu arrows
use edge placement. The native menu coordinator is explicitly MainActor. Model/rendering, main toolbar,
inspector and existing menu/shortcut behavior stay intact; visionOS remains 38.

Final signed Release verified in the isolated macOS 26.6.2 guest: native bounds stay within 3 points of
the available bar center across Crop/Annotate, 1100/1400-point windows and inspector transitions, with
no control overflow. Shapes/ellipse drawing, text edit, hide/show recreation, 150% Zoom, square crop,
annotated 400 × 300 PNG Copy and empty recovery pass. Release/test-source compile, signature/four grants
and manifest pass; actor warning resolved. No host GUI test, new permission/capture or core/full-suite
rerun. Existing VMs were preserved; capacity freed externally before QA. Canonical 44 is installed in
`/Applications`, signature/exact tree read back; prior bundle and host windows preserved. Task guest
stopped, with no other VM stopped by this task. [Evidence](../Documentation/Validation/mac-compact-centered-markup.json).


## Preview-reference Mac Markup row — 1.0 (43), November 5, 2026

The owner supplied Preview's actual Markup toolbar. Mac removes compact scope-button styling, using
native borderless controls with 32-point targets, semantic symbols and standard Dividers. Shapes,
Crop Preset and Zoom use standard AppKit NSPopUpButton controls with 20-point symbols, native arrows
and normal target/action dispatch because SwiftUI toolbar synthesis ignored menu-label sizing.
Existing tool order, editing model, main toolbar, hide/show commands and inspector stay intact.

Exact signed Release checked in the headless macOS 26.6.2 VM: all targets measured; seven Shapes,
selected/drawn editable Ellipse, text editing, hide/show recreation, native Zoom to 150%, square crop,
actual annotated 400 × 300 PNG Copy and empty-state recovery pass. Release/test-source compilation,
strict signature, four unchanged grants and privacy manifest pass. No host GUI test, new permissions,
capture, core/full-suite rerun or headset action. This is a native-control implementation following the
reference, with no pixel-identical Preview claim. Canonical 43 is installed in `/Applications`, with
signature/exact tree readback verified. Prior bundle and host windows preserved; task guest stopped.
VisionOS remains 38. [Evidence](../Documentation/Validation/mac-markup-reference.json).

## Native Mac toolbar layout — 1.0 (42), November 5, 2026

Open Image now sits between sidebar toggle and document title. Native fixed toolbar spacers separate
Undo/Redo, document actions and Markup/Settings/Inspector. The Preview-style editing row retains the
Vision Pro tool order; a native Markup toggle, View command and ⌘⇧M hide/show it. Image menu commands
mirror mode, crop presets/dimensions/reset/rotation, Select, Shapes, Drawing, Text and Pixelation; View
adds Pan and File exposes system Share. Commands reuse the existing focused editor and export path.

Exact signed Release checked in the headless macOS 26.6.2 VM: native order/gaps, Open choices, toolbar
and menu visibility, focused keyboard shortcut, hidden-row recovery through editable Text/Ellipse,
rotation, actual annotated 400 × 300 PNG Copy and unsaved-close protection pass. Release and compile-only
test build pass, as do strict signature/four production grants/privacy manifest. No core/full-suite,
host GUI or headset execution; no new permission or capture. Canonical build 42 is installed in
`/Applications`, with signature/product-tree verification and prior bundle preserved. Host windows
remain open; task-owned VM stopped. VisionOS remains 38. [Evidence](../Documentation/Validation/mac-native-toolbar.json).

## Mac Settings toolbar — 1.0 (41), November 5, 2026

At the owner's screenshot request, Settings is now a standard main-toolbar button directly before
Inspector. The editing accessory row is omitted without an image, so no Settings-only row or residual
blank space remains. Existing SettingsLink behavior and all image-editing controls are preserved.

The exact signed Release was checked in the headless macOS 26.6.2 VM: Settings is named/enabled beside
Inspector, the row appears with an image and disappears after close, empty-content vertical positioning
returns exactly, and the gear opens the native General settings window. Release build/strict signature,
four unchanged sandbox grants and compile-only test-source check pass. No host GUI test, app closure,
new capture/permission request or core/full-suite rerun. Canonical build 41 is installed in `/Applications`,
with signature and exact product-tree readback verified; prior bundle and running windows preserved.
Task-owned VM stopped. VisionOS stays 38. [Evidence](../Documentation/Validation/mac-settings-toolbar.json).

## Mac toolbar parity correction — 1.0 (40), November 5, 2026

Build 39 flattened the shape menu; that was the agent's interpretation, not the requested Vision Pro
layout. The owner clarified the toolbar should match. Mac now follows the actual visionOS EditorView:
Editing mode → contextual controls → Zoom and View → Settings. Annotate uses Select → Shapes → Draw →
Text → Pixelate. Shapes has the same seven geometric choices and current-shape symbol; text/pixelation
retain immediate editable insertion. Crop shows Preset → Dimensions → Rotate Left. Document actions
stay in the native title toolbar. Mac uses its accessory row; visionOS uses its spatial bottom ornament.

Verified entirely through the headless macOS 26.6.2 guest's native controls/pointer/clipboard: both orders,
seven-choice menu/ellipse drawing, text edit, pixelation, rotation, actual 400 × 300 PNG copy, 150% zoom
and the Settings gear opening its native window. Release build/analyze/signature and four unchanged
sandbox grants pass; test source compiles without executing host GUI tests. No new permission/capture
requests, core/full suite rerun, headset action or publication. [Task](261105_mac-toolbar-parity.md),
[evidence](../Documentation/Validation/mac-toolbar-parity.json).

## Mac markup toolbar — 1.0 (39), November 5, 2026

All ten object tools and Select are directly visible in Apple's native accessory toolbar below the main
Mac title/toolbar. Shape/freehand tools use native toggled selection; Text and Pixelation keep immediate
editable-object insertion. Crop and the empty workspace hide the row. The existing model/inspector and
visionOS presentation are unchanged; visionOS remains build 38.

The owner requested VM GUI testing. A separate headless macOS 26.6.2 clone ran the exact signed Release
with host graphics/audio/clipboard sharing disabled. Actual guest checks confirm eleven named/enabled
controls in one row, native constrained-window fit, shape/freehand vectors, text/font editing,
Pixelation insertion, Crop visibility, a decoded 480 × 320 clipboard PNG with 2,280 annotation-red pixels,
Undo restoring 960 × 640, and unchanged source bytes. This OS constrained the requested 1,000-point
window to 1,256 points; no smaller layout is claimed. Initial clean toolbar capture was inspected.

Two focused host Xcode cases passed before the steering. The new host toolbar harness had incorrect
IDs/value types and fixed-width expectations; its source now honors native constraints, but no final
host/full XCTest run is claimed. The guest has Command Line Tools, so guest checks used native AX,
pointer and clipboard observations, not XCTest. Release build/analyze/signature and four unchanged
sandbox grants pass; core/full suites were not rerun. Photos/recipients/assistive/resource limits remain.

Automatic approval review rejected accepting the guest's screen-capture Allow notice. It stayed
unapproved; existing guest controls supplied remaining functional evidence. No additional host GUI
checks or host preview launch occurred after the owner's instruction. [Task](261105_mac-markup-toolbar.md),
[evidence](../Documentation/Validation/mac-markup-toolbar.json).

## Native sandboxed Mac preview — build 38, November 5, 2026

Owner-authorized native Mac app uses the shared source-pixel canvas/model, editable vectors, crop/rotation,
undo and image pipeline. Native NavigationSplitView sidebar, inspector, toolbar/menu bar, Open/Save panels,
Settings and Save/Discard/Cancel close/quit flow. Cmd A/C/V/O/S retain their native context; optional local
captions require macOS 27/model support. Welcome controls align and an empty inspector stays hidden.

78 core tests/five suites, six Mac service tests and seven distinct native Mac UI cases pass across the
recorded runs. The broad final run passed six UI cases and failed the mouse case's test selector/gesture;
the corrected native-mouse retry passed, exit 0. No clean all-seven command is claimed. Checks include
native Open, exact crop/actual PNG Copy/Undo, HTTPS Paste, editable text/size, image-close and Quit Cancel,
Save As/output pixels and mouse resizing at 150%. Normal signed Debug sandbox denies an unselected
controlled file (Cocoa 257) and permits its private container. Xcode test injection's root-read exception
is explicitly excluded from that proof. Release build/analyze/strict signature pass with only the four
intended grants and no debugger/test exceptions or Debug probe/flags. VisionOS simulator compilation
passes; no new headset/simulator runtime test or device deployment occurred.

Photos consent/save, Share recipients, assistive technology and resource profiling on Mac remain manual
acceptance. Development signing is not distribution/notarization. The owner supplied screenshots of the
initial running Mac editor/import and welcome view. [Task](261105_native-sandboxed-mac.md),
[evidence ](../Documentation/Validation/native-sandboxed-mac.json). Last verified physical headset identity remains 1.0 (36);
the old signed build-37 artifact is retained, not evidence of headset build 38 delivery.

## November 4, 2026 — memory-bank handoff refresh

Build 37's direct HTTPS image-link Paste is implemented and applied. Retained November 3 evidence is **78 core tests/five suites, eight focused native UI cases, signed Release/analyze and strict signature passing**. Current source hashes still match the recorded signed-build inputs; the build-37 product is present and the prepared 39-entry Apple packet matches its recorded checksum. No tests, builds, simulator/device operations or publication were performed for this documentation refresh.

Deployment remains pending: the last recorded attempt failed before installation with CoreDevice 4016 and an unavailable paired developer tunnel. Build 36, verified October 31, remains the last confirmed headset identity. The owner uses the Mac remotely; terminal access and the paired headset developer connection are separate. Resume installation under existing authorization when the connection is available, then validate the owner's actual browser URL Paste. Public release/account steps and unconfirmed capture research retain their separate scope. [Detailed checkpoint](261103_paste-image-links.md#november-4-memory-bank-refresh), [current context](activeContext.md).

## Direct image-link Paste — build 37, November 3, 2026

Explicit Paste now opens one direct HTTPS image URL, including a URL copied as plain text. The native + menu and empty-workspace tap/Command V use the same flow. Image representations take priority; image-only Drop and text-field editing remain. A focused ephemeral downloader streams into the existing protected import ownership, bounded to 256 MiB, five HTTPS redirects, 20-second inactivity/60-second transfer timeouts. No cookies, shared credentials, persistent cache, URL history, uploads, backend or telemetry. Webpages, insecure/credentialed links, HTTP errors, malformed images and oversize transfers fail with recovery guidance; Cancel preserves current work. The owner explicitly authorized this acquisition networking; prior no-network claims are updated.

**Verification:** standard `swift test` passes **78 tests / five suites**, exit 0 (20.251 s; test run 2.399 s). Eight native UI cases pass, exit 0 (276.843 s; cases 144.063 s), including real public HTTPS downloads through URL-menu and text/keyboard Paste, actual PNG Copy, failure preservation, ordinary image paste, Cancel and all-issue largest-text accessibility. Signed Release build/analyze and strict deep signature pass (21.646 s), correct 1.0 (37), matching manifest/add-only Photos, no ATS exception and Debug fixtures excluded. Existing metadata-skip/test-fixture/system diagnostics are retained and scoped in the task; full UI/native service/capture suites were not rerun. Task simulator is stopped.

**Physical:** Installation did not start: the paired headset’s developer tunnel is unavailable; the pre-install lock-state request failed with CoreDevice 4016. Last verified installed/normal-launch checkpoint remains 1.0 (36), October 31. Signed build 37 is ready for the already-authorized installation when the headset reconnects.

Privacy/README/site/listing/review/TestFlight and architecture/security notes now disclose the explicit image-host request and local editing. The updated eight-image store packet retains seven honest unchanged build-36 captures plus a fresh normal-startup 4K opening screen from build 37. Local field/media validation, seven utility tests and six-page build pass. Site/repository publication, account fields, distribution archive/privacy report, upload and Apple review remain separate; nothing was published or submitted.

[Task](261103_paste-image-links.md), [evidence](../Documentation/Validation/paste-image-links.json), [release guide](../Documentation/AppStore/README.md).

## Site and Apple store data — October 31, 2026

Current app remains installed/running **1.0 (36)**; App/Core/production test source and project configuration are unchanged. Site and README show the current native sidebar and Photos/Files/Drop/Paste workflow. Eleven website pictures are refreshed from real app UI, with original fictional inputs and a before/after comparison from the actual copied 2060 × 1390 PNG.

The local Apple packet includes current listing/review text, TestFlight description/What to Test/feedback email, source-backed entry guidance and eight ordered opaque **3840 × 2160** PNGs with provenance/hashes. Field/media validation passes; seven validator tests pass. The focused normal-startup crop/pixelate/text/copy/export tour and separate clean-sidebar capture pass. Earlier coordinate-gesture harness failures are retained; no new shape-drag certification is claimed. The isolated simulator is shut down.

The site builds six pages. Local links/anchors and responsive checks pass; all six pages fit 390-point width with no missing alt text or unloaded images. Home-page Lighthouse snapshot scores are 100 for accessibility, best practices and SEO in mobile/light and desktop/dark; performance is not audited. Final assets are visually inspected.

**Not submitted:** proposed marketing/support/privacy/source URLs return HTTP 404. Public site/repository publication, private App Store contact/trader/territory fields, distribution archive/privacy report, upload and Apple review remain separate. No account mutation, Git, publication or upload occurred. Core/full UI/native service suites were not rerun for this content-only task.
[Task](261031_site-and-store-readiness.md), [Apple packet](../Documentation/AppStore/README.md), [evidence](../Documentation/Validation/site-and-store-readiness.json).

## Default native List styling — build 36, October 31, 2026

Installed identity 1.0 (36), normally launched without test arguments and independently verified one running app process.

Removed the category-only borderless Button style and rounded-rectangle border-shape overrides. Categories now inherit automatic native List Button styling alongside the compact image rows. List still owns selection; no custom background, selection or hover renderer was added. Category labels/counts, disclosure state, document callbacks, Dynamic Type, source pixels and window transparency remain.

Four existing focused UI cases pass, exit 0 (248 s): real category expand/collapse, document switching/independent Undo/close/Recents, clear/opaque/default glass, and compact long filenames at largest text, including native accessibility audits. Populated/empty and largest-text compositor inspected. Signed Release build/analyze passes (18.364 s), strict signature and privacy/Debug boundaries pass. The two AppIntents metadata-extraction skip warnings were inspected. Core and UI test source are unchanged; core 69-test/5-suite baseline, full UI suite and native services were not rerun. Hardware gaze/hover still needs owner observation. The task simulator is stopped.
[Task](261031_default-list-styling.md), [evidence](../Documentation/Validation/default-list-styling.json).

## Compact sidebar image rows — build 35, October 30, 2026

Build 35 was installed October 31, with identity 1.0 (35) verified, normal launch without test arguments and exactly one running app process. The October 30 attempt was blocked by CoreDevice 4016; its evidence remains in the deployment history.

Image entries in Open Images and Recents now use a small SF image symbol and one filename line instead of thumbnails and a second metadata line. A small dot marks unsaved edits; image type and Edited status remain spoken accessibility values. Native List selection, category rows/counts, indentation and the growing 60-point visionOS target minimum remain.

Three existing focused UI cases pass, exit 0 (183 s): document switching/independent Undo/close/Recents, clear/opaque/default glass, and compact long filenames at largest text, including native accessibility audits. Populated compositor reviewed. Signed Release build/analyze passes (26.384 s); strict signature, add-only Photos, privacy manifest, encryption key and Debug exclusion pass. The two metadata warnings are the existing AppIntents extraction skip, once each during build and analyze. Core/tests, services and UI test source are unchanged; the 69-test/5-suite core baseline and full UI/service suites were not rerun. The task simulator is stopped. Physical gaze/hand and assistive technology remain separate.
[Task](261030_compact-sidebar-rows.md), [evidence](../Documentation/Validation/compact-sidebar-rows.json).

The [verified status](../Documentation/STATUS.md) is the authoritative detailed evidence record.
This page summarizes delivery state and must not turn implementation into acceptance.

## Sidebar hierarchy — build 34, October 29, 2026

Installed identity 1.0 (34); normal launch waits for device unlock. The owner rejected the bare expandable headers and asked for Notes/Safari/Files hierarchy. The sidebar now has tinted photo-stack/clock symbols, counts, full native category rows with disclosure chevrons, indented images and empty states, and a quieter heading. Open Images starts expanded; Recents starts collapsed. Standard plain List and borderless Button surfaces replace the grouped-card candidate; List still owns document selection.

Five focused UI cases pass, exit 0 (157 s), on the final signed source. Coverage: real document switching/Undo/close/cancel/Recents, native target sizing and all-issue empty-state audit, largest text, clear/opaque/default glass and ⌘V after sidebar interaction. Core unchanged from build 33 (69 tests/5 suites); not rerun. Signed Release/analyze, strict signature, add-only Photos/manifest/encryption and Debug exclusion pass. Full UI/service suites were not rerun. Hardware appearance, gaze/hand and assistive technology remain scoped owner checks.
[Task](261029_sidebar-hierarchy.md), [evidence](../Documentation/Validation/sidebar-hierarchy.json), [physical](../Documentation/Validation/physical-deployment.json).

## Native start screen and sidebar — build 33, October 29, 2026

Installed and normally launched on the headset; identity 1.0 (33), exactly one running app process, all commands exit 0. Build 32 was installed and launched first; the owner's follow-up requested a whole-well tap or Command V in place of its blue Paste button.

- Larger native Photos/Files wells and a gray native drop/Paste well; no separate blue Paste button.
- Tap the well or press ⌘V in the empty workspace to open a copied image. Clipboard providers are requested only by that action; text fields keep their native responder.
- System List rows/disclosures/selection; Open Images expanded, Recents collapsed; one accessible item per document.
- Existing rear-glass transparency, original pixels, per-document Undo and protected provider import remain.

Core: **69 tests/5 suites, exit 0**; actual file/data provider byte and ownership checks included. 5 focused UI cases pass across two runs on identical final production source; corrected-selector follow-up native exit 0 (127 s); synthetic drag skipped because the gesture never started a system drag. Signed Release build/analyze and strict signature pass; add-only Photos, manifest and encryption answer intact, Debug-only fixtures excluded. The full UI suite/native service smoke were not rerun. Cross-app physical Drop, clipboard consent, keyboard and assistive technology remain scoped owner checks.
[Task](261029_native-start-and-sidebar.md), [evidence](../Documentation/Validation/native-start-and-sidebar.json), [physical](../Documentation/Validation/physical-deployment.json).

## Previous checkpoint — build 31, launch verified October 29, 2026

**Release 1.0 (31) is installed and verified running on the headset.** Installation was October 26;
normal launch and exactly one running process were verified October 29 after unlock, without rebuilding
or reinstalling. Earlier locked launch timeouts remain recorded. At the owner's request Settings has an About page modeled on AutoPaper's, opened by an ⓘ button
in the sheet's title bar: icon, name, version, what the app is for and who made it, Website · Privacy · Help,
and the MIT line. The UI tests that open Settings pass, with About in both accessibility audits.
[Task](261026_about-settings.md), [evidence](../Documentation/Validation/about-settings.json).

## Build 30 — the bundle identifier, October 25, 2026

**Release 1.0 (30) was built, signed, installed and launched on the headset.** The owner rejected the old
bundle identifier ("definitely not this: com.glasspowertools.visionsnip") and chose `com.glassimagetools`, like
Glass Power Tools' `com.glasspowertools`. To visionOS a new identifier is a new app, so build 30 installed
beside build 29, which kept the old identifier until the owner removed it (by October 26).
Nothing else changed. [Build 30](261025_app-store-preparation.md#build-30-the-bundle-identifier).

## Build 29 — App Store preparation, October 25, 2026

**Release 1.0 (29) was built, signed, verified, applied, installed and launched on the headset** (October 25,
once the owner woke it; the first attempt found it unreachable). The app reaches people through TestFlight and the App Store,
so build 29 brings over Glass Power Tools' preparation: a privacy manifest (user defaults only, `CA92.1`),
`ITSAppUsesNonExemptEncryption` `NO`, a PRIVACY.md section on what TestFlight and the App Store pass to the
author, and `Documentation/AppStore/` with the listing and App Store Connect answers. App code is unchanged.
[Task](261025_app-store-preparation.md), [evidence](../Documentation/Validation/app-store-preparation.json).

## Build 28 and the website, October 24, 2026

**Release 1.0 (28) was built, verified, applied, installed and launched on the headset (October 24).** At the
owner's request the icon is a round picture (a white sun and hills on red glass in a silver frame that
fills the icon), layered for visionOS with the frame in front, the sun and hills in the middle and the
glass behind. The generator checks that layering; `actool` compiles cleanly; the simulator Home View
renders it as designed; signed Release passes; the website's icons and social card use it. App code is
unchanged from build 27. Softened toolboxes, a Vision Pro headset and a wrench-peak mountain were drawn and
set aside. [Task](261024_round-picture-icon.md), [evidence](../Documentation/Validation/round-picture-icon.json).

**Website, October 24 (no app change):** the footer and builder follow AutoPaper's site (Help, Privacy and an
"Also by" row; only built pages linked; links rewritten only in anchors) and the Pages workflow gives only the
deploy job publishing rights, with pinned actions. Builder output is byte-identical before the footer change;
site and Lighthouse checks pass. [Task](261024_autopaper-footer-and-builder.md).

## Historical milestones

The build sections below preserve their recorded dates, scope and failures; their pending/prepared
statements do not override the current checkpoint.

## Sidebar rows, a plain + and owner checks — build 27

**Release 1.0 (27) is built, tested and applied; it is not installed (headset unreachable).** At the
owner's request the title-bar + is a round menu button with no chevron, the Images sidebar's rows are
compact buttons measured like the Glass Power Tools Vision Pro terminal sidebar instead of List rows,
and the home page no longer carries a testing section. The full 37-case UI suite passes (exit 0,
1,138 s); signed Release passes; the website screenshots were retaken from build 27. The owner reported a
hardware keyboard, Photos/Files saving and pasting into apps other than ChatGPT working on the headset
(October 23; build/apps not specified).
[Task](261023_sidebar-rows-and-plus-menu.md), [evidence](../Documentation/Validation/sidebar-rows-and-plus-menu.json).

## Website, icon colors and license — build 26

**Release 1.0 (26) is installed and identity verified; normal launch is pending headset unlock.** At the
owner's request the project gained a public website like AutoPaper's, built from AudioPaper's (`site/`, built by
`scripts/build_site.py`, deployed by a GitHub Pages workflow once pushed; BEDROCK-style home page, Help,
Reference, Privacy, Credits), an MIT license, `PRIVACY.md`, `SECURITY.md`, `CONTRIBUTING.md` and a public
README, with screenshots taken from the real app in the simulator. The icon now uses AudioPaper's rendered
red and silver. App Swift sources are unchanged from build 25. Core 67/5, site link/width/Lighthouse checks
and the signed Release pass; the privacy scan of every publishable file is clean. **Nothing is published.**
[Task](261022_website-icon-and-license.md), [evidence](../Documentation/Validation/website-icon-and-license.json).

## Title-bar tool group — build 25

Release 1.0 (25) was installed, identity verified, normally launched and verified running on October 22
(headset unlocked; exactly one process). At the owner's request, Undo, Redo, Copy, Share, Export and the inspector
toggle share one glass title-bar capsule, and Close Image moved from a row above the canvas to the
upper-right corner. Core 67/5, 50 native checks and the full 37-case UI suite (exit 0, 1,223 s) pass on
the applied source; signed Release/privacy and probe compile pass.
[Task](261022_titlebar-tool-group.md), [evidence](../Documentation/Validation/titlebar-tool-group.json).

## Toolbar, sidebar and inspector — build 24

Release 1.0 (24) was installed and identity verified while the headset was locked; the owner's October 22
screenshot shows it running. Owner
requests: toolbar Copy now matches Share › Copy (no blocking overlay; the same clipboard item, so
Universal Clipboard applies); one + menu (New Window, Photos, Files, Paste); Text and Pixelate place a
selected object at the crop center; inspector panes have one title, content before style, stroke width
on one row and a No Selection state; the sidebar is 360 points with text-height previews. ⌘N and ⌘, are
scene commands; ⌘V image paste is not available.

Core 67/5, 50 native service checks and the full 37-case UI suite (exit 0, 1,173 s) pass on the final
applied source. QA fixed a largest-text sidebar row layout loop and three test-harness issues, each
compared against build 23. Signed Release build/analyze/signature/privacy and probe compile pass.
[Task](261021_toolbar-sidebar-and-inspector.md), [evidence](../Documentation/Validation/toolbar-sidebar-and-inspector.json).

## Review fixes and caption clearance — build 23

Release 1.0 (23) was installed, identity verified, normally launched and verified running (headset
unlocked; exactly one process). It fixes every October 21 review finding and the caption hidden behind
the bottom toolbar: extended-range/Display P3 colors and wide-gamut output, rotated annotation fields,
quiet caption retry, pending-edit Undo, anchored zoom, one ⌘V owner (build-24 testing found ⌘V image
paste not working), 32-point ornament clearance and cleanups. QA also restored paired inspector dimension fields (regressed in build 19) and fixed a
color-well binding regression introduced during the work.

Core 67 tests/5 suites, 48 native service checks and the full 37-case UI suite (exit 0, 1,254 s) pass on
the final applied source — the first clean full-suite command recorded since builds 19–22, which ran
focused cases only. Seven earlier failures were reproduced on unchanged build 22 before being fixed.
Signed Release build/analyze/signature/privacy and probe compile pass.
[Task](261021_review-fixes-and-caption-clearance.md), [evidence](../Documentation/Validation/review-fixes.json).

The October 21 [documentation reconciliation](261021_memory-and-release-docs.md) preceded this build.

## Crop-area dimming — build 22

Release 1.0 (22) is installed and identity verified; normal launch/process verification awaits headset unlock.

Crop mode now darkens image content outside the selection with 65% black instead of 50%. The existing
image-bounded even-odd mask is retained and clipped to the image Canvas viewport: selected pixels, bright controls, window appearance, source
bytes, vectors/history and export are unaffected. Baseline compositor observation showed the prior mask
working; zoomed observation found the separate mask spilling into the reserved margin. Only the mask now shares the image Canvas clip; controls keep their generous targets. No renderer change.

The focused native UI cases exercise a centered 800×600 crop, reachable zoomed handles, rotation,
undimmed Annotate, actual 600×800 Copy and two-step Undo to the full image, plus actual zoomed corner dragging with Pan enabled. Fit/zoom/rotation/Annotate/
reset compositor views are inspected. This is visual observation, not automated pixel-equivalence testing.
Both final UI cases complete with zero failures; Xcode result finalization was interrupted (native exit -15, command 135.929 seconds). No clean UI command is claimed.
Signed Release build/analyze and strict signature/permissions/Debug-exclusion checks pass. Final UI,
signed and applied App/Core sources agree. Core, model, service and export implementations and core tests are
unchanged; the prior 62-core/42-native-service baseline was not rerun. Physical visual/input acceptance
remains separate from installation/launch. No new permission, dependency, network or capture capability.

[Task](261019_crop-dimming.md), [evidence](../Documentation/Validation/crop-dimming.json). Earlier sections are historical.

## Window transparency restoration — build 21

Release 1.0 (21) is installed and identity verified; normal launch/process verification awaits headset unlock.

The sidebar rebuild introduced persistent navigation-container material above the unchanged adjustable
backplate. Build 20 reproduces a grey plate at Opacity/Glass 0/0. The editor now follows Glass-family
plain SwiftUI columns with one rear native glass/paint surface. Native List/DisclosureGroup selection,
Forms, Buttons, Menus, ControlGroups, system modal presentation and bottom toolbar remain. Native header
controls retain leading image metadata, grouped document actions, separate sidebar toggles and in-pane
Done. Appearance preferences, opaque foreground and source/render/history owners are unchanged.

Six distinct UI cases pass on the final app source across stages: exact clear/opaque/glass with both
panels, largest-text title/caption, appearance persistence/reset and real crop/text/drawing/Undo,
document switching/Recents and system picker return, native color palette/audits, and separate-window
acquisition. Earlier failed assertions, test-query corrections and result-finalization limits remain
recorded; no clean full six-case suite or full UI suite is claimed. All-issue app audits ignore no finding.
The final four-case command exits 0 (392.085 seconds).
All 42 native service/model checks pass. Signed Release build/analyze, strict signature/privacy/debug
exclusion and isolated device-SDK probe compilation pass. Final UI/services/signed/applied App/Core
sources agree. Core source/tests are unchanged; the prior 62-test/four-suite baseline was not rerun.
Compositor views show the clear room, black opaque paint and native glass while image/controls remain
full-strength; this is visual observation, not an automated pixel-equivalence test.

Hardware appearance/gaze/hand/assistive/focus/keyboard, motion/Reduce Transparency and resource/recipient
acceptance remain separate. No new capture capability, permissions, dependencies or networking.

[Task](261019_transparency-regression.md), [evidence](../Documentation/Validation/window-transparency-restoration.json). Earlier sections are historical.

## Sidebar and toolbar refinement — build 20

Release 1.0 (20) is installed, identity verified and launched normally; the running app process was read back.

The wider Images sidebar uses native disclosures: Open Images starts expanded, Recents collapsed.
The + opens a separate window with explicit Paste, Photos and Files; its adjacent caret imports into
this window. Source filename/dimensions/type are leading in the native title bar. Native document
ControlGroups remain separate from the inspector toggle. Done is inside each property pane; a circular
Close Image sits in the editor with existing save/discard/cancel. Shapes opens immediately on tap.

All 42 native service/model checks pass. Seven distinct final UI cases pass their assertions,
including disclosures and reopening, close cancellation/discard, independent panels, real picker return,
new-window acquisition, system palette/live color/Undo, immediate Shapes/resize/crop, editable rotated
text, and largest-text title/caption layout. Native all-issue audits ignore no app finding. The final six-case command exits 0; the separate new-window command also exits 0. Earlier failed iterations and their interrupted result finalization remain historical. No
full UI suite is claimed. Core source/tests are unchanged, retaining the build-19 62-test/four-suite baseline;
the core suite was not rerun. Signed Release build/analyze, strict signature/privacy/debug exclusion and
separate device-SDK probe compilation pass. Final UI, services, signed and applied App/Core sources agree.

[Task](261018_sidebar-and-toolbar-refinement.md), [evidence](../Documentation/Validation/sidebar-and-toolbar-refinement.json).

## Document sidebar and contextual inspector — build 19

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

[Task](261018_document-sidebar-and-inspector.md), [evidence](../Documentation/Validation/document-sidebar-and-inspector.json).

Earlier sections retain historical checkpoints; the current release is listed at the top.

## Native sidebar defaults and rotation — build 18

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

[Task](261017_sidebar-defaults-and-rotation.md), [evidence](../Documentation/Validation/sidebar-defaults-and-rotation.json).

At that checkpoint, build 18 was current.

## Native left sidebar — build 17 installed; launch pending unlock

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

[Task](261017_native-left-sidebar.md), [validation](../Documentation/Validation/native-left-sidebar.json).

Earlier sections retain historical checkpoints; the current release is listed at the top.

## Natural caption height — build 16 installed and running

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

[Task](261017_drawing-and-sliding-tools.md#owner-feedback-follow-up--intrinsic-caption-sizing), [validation](../Documentation/Validation/caption-natural-height.json).

Earlier sections retain historical checkpoints; the current release is listed at the top.

## Drawing and sliding tools — build 15 installed and running

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

[Task](261017_drawing-and-sliding-tools.md); [validation](../Documentation/Validation/drawing-and-sliding-tools.json).

Earlier sections retain historical checkpoints; the current release is listed at the top.

## Tool sidebar and image caption — build 14 installed and running

Removed the extra Shapes checkmark; retained current symbol and tap/hold. Tool Options opens with
Annotate as a right native Form, with its sidebar toggle in top document actions. An original-image
caption uses Apple's local model when visionOS 27/model/vision support is available; caption is below
the canvas and excluded from image Copy/Share/save, metadata and history. Unsupported states remain visible.

Ten distinct UI cases passed across a broad nine-pass/one-palette-failure run (native exit 65) and a focused
color retry (one/zero, 43.863 suite seconds, exit 0). Actual RGB/live-color/Undo assertions retained; no
clean full ten-case run or cause for the first host failure is claimed. Native editor/forms/caption/
sidebar/largest audits ignore no app issue. Final compositor and bounds checks pass. Signed build/analyze/
signature/privacy, separate probe compile and exact nine-file conflict-free application passed. Unchanged
57-core/30-service baseline not rerun. The exact caption service generated real text on physical Vision Pro
from a synthetic image; the temporary check app was removed. Installed 1.0 (14) identity, normal launch
and independent running-process readback all passed. Hardware pane/caption appearance, assistive technology,
recipients/resources and capture remain separate. [Task](261017_tool-sidebar-and-image-caption.md), [evidence](../Documentation/Validation/sidebar-and-caption.json).

Earlier build sections below are historical checkpoints; build 16 above is the current installed release.

## Previous menu-caret checkpoint — build 13

Apple's chevron SF Symbol labels the existing native Import/Crop Preset/Drawing Tools/Zoom/Shapes menus.
Single Shapes tap/hold remains; decorative carets are omitted only in compact/accessibility text layouts.
Actual captures found the visibility-only modifier ineffective here; corrected an intermediate largest
toolbar overhang before application. Final two compact/largest UI cases and all-issue toolbar/panel audits
passed, exit 0, 56.687 suite seconds. Signed Release build/analyze/signature/privacy and exact three-file
application passed. Installation (2.819 seconds), actual identity, normal launch (0.521 seconds) and
independent exactly-one-process observation passed, exit 0. Build 13 supersedes build 12. Hardware caret/
gesture/accessibility and recipient/resource observations remain separate. [Follow-up](261016_native-glass-chrome.md#native-menu-indicator-follow-up),
[evidence](../Documentation/Validation/menu-indicators.json).

## Previous physical deployment — build 12

Owner-requested deployment completed using the verified prepared signed product, without rebuilding.
Installation (2.851 seconds), actual Glass Image Tools 1.0 (12) identity readback, normal launch without
fixture arguments (1.238 seconds) and independent exactly-one-process observation all passed, exit 0.
This supersedes the build-10 installed identity/unlock wait. Native Glass/HIG implementation and test
scopes remain as recorded; physical material/input/assistive-technology, recipients and profiling are
separate. [Physical record](../Documentation/Validation/physical-deployment.json),
[task follow-up](261016_native-glass-chrome.md#owner-requested-physical-deployment-follow-up).

## Native Glass implementation checkpoint — build 12

Owner-approved family comparison/refinement is applied. Separate native toolbar items replace the
hand-spaced bar; native capsule title and the panel's own surface replace extra container styling.
Rear glass, Opacity/Glass settings, opaque foreground/image and editing/source owners are preserved.
At compact/largest text, Options stays reachable in Drawing Tools and the native toolbar fits 715.5/720.

13 distinct UI cases passed across three commands, all exit 0, including all four native accessibility
cases and compact-largest toolbar/panel audits. Signed Release build/analyze/signature, privacy/Debug
boundaries and probe SDK compile pass. Four files applied with exact hashes/no conflicts. The unchanged
57 core/30 service baseline was not rerun. Simulator contrast/normal launch restored; no physical calls.
Build 12 is prepared, not installed; hardware/recipient/resource limits remain in
[task](261016_native-glass-chrome.md), [status](../Documentation/STATUS.md) and
[evidence](../Documentation/Validation/native-glass-chrome.json).

## Apple HIG implementation — build 11 prepared

All eight findings are implemented, reviewed and applied. Responsive native title/toolbar, contextual
annotation panel beside the canvas, separate style/gesture Undo, text defaults/pixelation units, persistent
Pan, separated tiny/offscreen controls/Show Selection, readable Appearance and direct flattened PNG Share
are delivered. 57 core tests, 30 native service checks and all 25 UI cases passed across recorded runs.
The broad run passed 24/25; final compact menu/largest-text command passed two/zero, exit 0. No clean full
25-case command is claimed. Native audits ignore no app issue; compositor/palette/Photos checks passed.

Signed development Release 1.0 (11) build/analyze, strict signature, Debug/permission boundaries and probe
SDK compile passed. Sixteen files applied with exact tested hashes/no baseline conflicts. The simulator
was restored to normal launch/contrast. Build 11 is prepared, not installed; no device call occurred while
the owner was unavailable. Headset/manual consent/recipient/resource limits remain in
[status](../Documentation/STATUS.md), [task](261016_apple-hig-fixes.md) and
[evidence](../Documentation/Validation/hig-fixes.json).

## Historical Apple HIG review — October 16

At that review checkpoint, [the report](../Documentation/HIG_REVIEW.md) recorded eight proposed fixes. Two simulator
walkthroughs passed, zero failures, 137.774 seconds, command exit 0; 16 actual compositor views were
inspected. Long filenames clip at minimum size and visually hide document actions at largest text;
the compact annotation toolbar exceeds content-window width. Contextual annotation controls, Pan feedback,
selected-object visibility, tiny/offscreen controls and Appearance labels need follow-up. Production
source was unchanged at that review checkpoint; its simulator product was restored. No new device action or deployment
occurred. Hardware checks wait for owner availability. [Task](261016_apple-hig-review.md),
[evidence](../Documentation/Validation/hig-review.json).

## Historical delivery checkpoint — build 10

**Release 1.0 build 10 is installed and identity-verified; normal launch verification awaits headset unlock.**
The normal launch request timed out after 35 seconds; the completed subsequent process query found no matching app. A subsequent lock-state query reports passcode required, so unlock the headset before resuming launch verification. The earlier client option-order error occurred before a remote request and is retained separately.

The full queued iteration is implemented: reachable source-preserving crop controls at zoom/Pan,
native grouped forms and adaptive labeled dimensions, explicit Paste Image, selected native color wells,
and accessibility remediation/audit. Add at Center and named pixel adjustments provide alternatives to
precision drags; processing can be cancelled and completion messages use public accessibility announcements.
The tested short-name largest-text title sits above the window without covering crop-axis dimensions;
the later HIG review documents the separate long-name clipping limit.

53 core tests, 24 actual native service checks, 15 functional UI cases and four accessibility/UI cases passed across recorded runs. The final three standard audit cases and largest-text/Increase Contrast case passed with zero app audit issues; no findings were ignored. The native palette RGB/selection/live-color/one-Undo check passed. Signed Release build/analyze, strict signature, Debug exclusion, add-only Photos scope and separate probe SDK compilation passed. Reviewed source matches the tested staging hashes, with no concurrent-edit conflicts.

The three final standard accessibility cases pass in 80.348 seconds, and the largest-text/contrast case
passes in 29.208 seconds; both commands exit 0. Native RGB color change and one-Undo restoration passed.
Earlier failed assertions, system-host audit restriction and result-finalization stops remain in
[sanitized evidence](../Documentation/Validation/native-ux-and-accessibility.json).

## Remaining validation

Actual VoiceOver/Voice Control/Switch Control speech, focus and hardware keyboard/eye-hand acceptance
remain unobserved. Apple’s system color-picker host rejects automated auditing with error -902; its real
controls and RGB/edit/Undo behavior were verified instead. Tiny/offscreen annotation handles retain the
native geometry inspector and named-action alternatives. New Paste ingestion/gesture acceptance, Reduce
Transparency and resource profiling on hardware remain separate from simulator evidence. The owner’s
approximately ten successful Photos → crop → Copy → ChatGPT uses remain confirmed; do not request that
baseline again. No physical capture path is confirmed.

[The full audit](../Documentation/ACCESSIBILITY_AUDIT.md) provides specific manual checks;
[the task](261015_native-editor-ux-and-accessibility.md) records implementation and deployment.

## Implemented baseline

Native visionOS Photos/Files editor; source-pixel crop presets and exact dimensions; zoom/pan;
nondestructive editable rectangle, ellipse, arrow, freehand, text and pixelation annotations; undo/redo;
PNG clipboard copy; PNG/JPEG share/file export; add-only Photos save; bounded previews and immutable sources.
The capture system-picker/stream-to-frame experiment is a separate target.

## Verified baseline

- Initial core suite: 17 test definitions passed, including all EXIF orientations, geometry/history,
  rendering/clipping, metadata/alpha and full-resolution output from an 8192 × 4096 source.
- Six simulator service checks passed across PNG/JPEG export, actual pasteboard round-trip and Photos saves.
- Native simulator build/run, unsigned device builds and Release fixture exclusion were checked.
- Physical Vision Pro installation, launch and continued process presence passed for **1.0 build 2**.
- Audit Release simulator build/analyze succeeded. Existing UI suite then ran: one passed, two failed;
  those failures identified inspector undo and unstable annotation canvas automation.

These are historical results, not post-remediation outcomes. Read [status](../Documentation/STATUS.md)
for test scope and finalization limitations.

## Remediation completed

All seven inspection findings are corrected in the applied code. Clipboard policy and import request
lifecycle duplication are consolidated. Inspector edits undo as a transaction; presets/selection restore;
preview/export share composition; alpha pixelation replaces original pixels; export work is serialized and
cancellation-aware. Experimental capture has serialized current-request/stream ownership.

- **34 core tests passed**, including privacy/cancellation/numeric regressions and 67 hostile inputs.
- **10 native simulator model/service checks passed**, including both output formats, clipboard and Photos.
- **Four native UI tests passed with zero failures** in the final full run.
- **Three production capture-queue host checks passed**; main/probe device SDK builds passed.
- Actual simulator force termination/next-launch cleanup passed; unowned temporary files survived.
- Encoded pixel tests cover fractional redaction boundaries; metadata tests prove source GPS exists and
  is absent from single-image PNG/JPEG outputs. Protected/private working files and ownership guards passed
  host/simulator checks; locked-device protection and backup behavior remain unverified on hardware.
- **Release 1.0 build 4** signed, installed, launched and verified running on physical Vision Pro.
- Full **AGENTS 2.1** project adaptation and **16 populated memory-bank notes** applied; public-data and
  relative-link checks passed. Local signing remains functional in an ignored override.

[The completed task](261015_security-remediation-and-memory-bank.md) and
[sanitized evidence](../Documentation/Validation/remediation.json) record scope. No Git initialization,
commit or publication occurred. License preference remains undecided.

## Remaining product acceptance

The owner reports approximately ten successful Photos → crop → Copy → ChatGPT uses on Vision Pro,
confirming the primary success criterion in real use. This is owner-reported hardware acceptance; the exact
build and optional annotation paths were not specified. Remaining coverage includes Files import, focused
crop/annotation cases, share-sheet recipients and large-image resource behavior. On October 23 the owner
reported Photos/Files saving, a hardware keyboard and pasting into other apps working.
No physical ScreenCaptureKit capture path is confirmed. Full Phase 1 acceptance extends beyond the primary
workflow; Phase 2 still requires hardware capture evidence. Phase 3 optimizations are future exploration.

## Editor/icon iteration completed

[The approved Glass icon/editor plan](261015_editor-polish-and-glass-icon-plan.md) is implemented and
applied: layered toolbox/crop/brush icon, document title/metadata, bottom mode control, close/save recovery,
annotations visible in Crop, live vector manipulation, grouped shapes and typography controls. The owner
chose flattened PNG/JPEG copies on close; objects remain editable during the open session.

**42 core tests/three suites, 15 simulator model/service checks and nine native UI tests passed**. Signed
Release build/analyze, separate probe SDK compile, native layered catalog and Release privacy/test-code
boundaries passed. **1.0 build 5** was installed, launched normally and verified running on the authorized
physical Vision Pro. Applied code matches the tested staging hashes; public-data and relative-link checks
passed. There are now 17 populated memory-bank files: 16 root notes and the monthly index under `tasks/`.

New physical eye/hand interactions and icon lighting/parallax remain unobserved; the owner's prior primary
workflow confirmation remains valid. [Iteration evidence](../Documentation/Validation/editor-polish.json)
records scope without implying full Phase 1 resource/export or Phase 2 capture acceptance.

## Crop/title/text-target follow-up delivered

Release **1.0 build 6** adds source-pixel crop-axis labels, leading filename/metadata alignment and native
object-scoped menus. Ordinary text taps reopen Edit Text. All ten UI cases passed across the full run's
nine passes and a focused context retry; the first context failure was a test querying before native
popover dismissal finished. No production workaround or assertion waiver was used. Signed build/analyze,
Release boundaries, exact applied hashes and physical install/normal launch/identity passed. Core/service
sources are unchanged from build 5's 42/15-check baseline.
[Follow-up evidence](../Documentation/Validation/crop-text-follow-up.json) preserves both test runs.

## Window appearance, toolbar and icon follow-up delivered

Release **1.0 build 7** is applied, signed, installed and normally launched with matching name/version/build
and running process read back. Zoom now appears beside the bottom magnifier; the lower-left footer is
removed while crop-axis dimensions remain. Glass-family services framing and native local Opacity/Glass
settings include persistence/reset and source-inspected Reduce Transparency behavior. Original layered
closed-toolbox artwork has corrected crop rulers and 38.86% more foreground area.

**Eleven UI tests passed**, then the caption-only appearance follow-up passed; **fifteen actual native
model/service checks passed**. Signed build/analyze, probe SDK compile, strict Release/icon/privacy bounds
and exact conflict-free source transfer passed. Tests exposed and corrected clear-surface canvas delivery,
fractional dimension display and native AX assumptions without waiving assertions. Core sources/tests
are unchanged from the 42-test baseline. Physical eye/hand appearance/gesture and icon lighting/motion
remain unobserved. [Sanitized evidence](../Documentation/Validation/window-appearance-and-icon.json)
retains failed-run history and scope. Only monthly indexes remain under `tasks/`.

## Opaque foreground follow-up — build 8 installed

The image workspace has full view opacity on the native interaction plane, above a separate rear glass/
tint plane; native buttons/text retain their surfaces and editing overlays remain above image pixels.
Four focused UI cases passed across runs, including expanded native appearance/persistence/input checks.
Actual simulator-composited color patches remain identical across appearance extrema. Signed build/analyze,
probe SDK compile, Release boundaries and exact source application passed. Core/model-service sources
are unchanged from the 42/15-check baseline; those suites were not rerun.
See [evidence](../Documentation/Validation/foreground-layering.json).

Physical installation and actual Glass Image Tools 1.0 (8) identity readback passed. Two normal launch
requests timed out; the completed process query after the first found none. Developer services are
available; headset awake/unlocked state was queried. Physical running/appearance remains unverified.

## Mac installed in Applications — November 5, 2026

Fresh canonical-ID development Release 1.0 (40) built and installed in `/Applications/Glass Image Tools.app`.
Strict signature, sandbox grants, privacy manifest and exact installed/built content pass. No source
change, host GUI test, app launch or closure. Prior VM verification retained. [Evidence](../Documentation/Validation/mac-applications-install.json).

