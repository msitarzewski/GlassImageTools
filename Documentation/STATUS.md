# Verified implementation status

## Mac Quit correction — 1.0 (45), November 6, 2026

Native Quit asks Save/Discard/Cancel before entering termination. Save leaves termination cancelled
while the existing export flow saves edited windows, then quits normally. Confirmed window closure
waits for sheet detachment. Guest native-event/AX/pointer checks pass for Cancel, export cancellation
and retry, Discard exit, actual 400 × 300 PNG Save/exit and sequential two-window 400 × 300 / 500 × 250
Save/exit; original bytes unchanged. Release and Debug test-source compilation pass; UI regressions
are compiled, not run. No new host GUI, full-suite or headset claim. Developer ID universal archive,
four unchanged sandbox permissions, privacy manifest, hardened runtime, accepted app/DMG notarization,
stapled tickets and Gatekeeper assessments pass. [Evidence](Validation/mac-quit-hang.json),
[release route](MAC_RELEASE.md). Canonical Mac 45 installed in Applications; notarized product signature/ticket/Gatekeeper/exact tree verified. Prior bundle and owner process preserved. Publication is recorded in the release task.

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
stopped, with no other VM stopped by this task. [Evidence](Validation/mac-compact-centered-markup.json).

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
VisionOS remains 38. [Evidence](Validation/mac-markup-reference.json).

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
remain open; task-owned VM stopped. VisionOS remains 38. [Evidence](Validation/mac-native-toolbar.json).

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
Task-owned VM stopped. VisionOS stays 38. [Evidence](Validation/mac-settings-toolbar.json).

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
requests, core/full suite rerun, headset action or publication. [Task](../memory-bank/261105_mac-toolbar-parity.md),
[evidence](Validation/mac-toolbar-parity.json).

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
checks or host preview launch occurred after the owner's instruction. [Task](../memory-bank/261105_mac-markup-toolbar.md),
[evidence](Validation/mac-markup-toolbar.json).

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
initial running Mac editor/import and welcome view. [Task](../memory-bank/261105_native-sandboxed-mac.md),
[evidence](Validation/native-sandboxed-mac.json). Last verified physical headset identity remains 1.0 (36);
the old signed build-37 artifact is retained, not evidence of headset build 38 delivery.

## Direct image-link Paste — build 37, November 3, 2026

Explicit Paste now opens one direct HTTPS image URL, including a URL copied as plain text. The native + menu and empty-workspace tap/Command V use the same flow. Image representations take priority; image-only Drop and text-field editing remain. A focused ephemeral downloader streams into the existing protected import ownership, bounded to 256 MiB, five HTTPS redirects, 20-second inactivity/60-second transfer timeouts. No cookies, shared credentials, persistent cache, URL history, uploads, backend or telemetry. Webpages, insecure/credentialed links, HTTP errors, malformed images and oversize transfers fail with recovery guidance; Cancel preserves current work. The owner explicitly authorized this acquisition networking; prior no-network claims are updated.

**Verification:** standard `swift test` passes **78 tests / five suites**, exit 0 (20.251 s; test run 2.399 s). Eight native UI cases pass, exit 0 (276.843 s; cases 144.063 s), including real public HTTPS downloads through URL-menu and text/keyboard Paste, actual PNG Copy, failure preservation, ordinary image paste, Cancel and all-issue largest-text accessibility. Signed Release build/analyze and strict deep signature pass (21.646 s), correct 1.0 (37), matching manifest/add-only Photos, no ATS exception and Debug fixtures excluded. Existing metadata-skip/test-fixture/system diagnostics are retained and scoped in the task; full UI/native service/capture suites were not rerun. Task simulator is stopped.

**Physical:** Installation did not start: the paired headset’s developer tunnel is unavailable; the pre-install lock-state request failed with CoreDevice 4016. Last verified installed/normal-launch checkpoint remains 1.0 (36), October 31. Signed build 37 is ready for the already-authorized installation when the headset reconnects.

Privacy/README/site/listing/review/TestFlight and architecture/security notes now disclose the explicit image-host request and local editing. The updated eight-image store packet retains seven honest unchanged build-36 captures plus a fresh normal-startup 4K opening screen from build 37. Local field/media validation, seven utility tests and six-page build pass. Site/repository publication, account fields, distribution archive/privacy report, upload and Apple review remain separate; nothing was published or submitted.

[Task](../memory-bank/261103_paste-image-links.md), [evidence](Validation/paste-image-links.json), [release guide](AppStore/README.md).

## Site and Apple store data — October 31, 2026

Current app remains installed/running **1.0 (36)**; App/Core/production test source and project configuration are unchanged. Site and README show the current native sidebar and Photos/Files/Drop/Paste workflow. Eleven website pictures are refreshed from real app UI, with original fictional inputs and a before/after comparison from the actual copied 2060 × 1390 PNG.

The local Apple packet includes current listing/review text, TestFlight description/What to Test/feedback email, source-backed entry guidance and eight ordered opaque **3840 × 2160** PNGs with provenance/hashes. Field/media validation passes; seven validator tests pass. The focused normal-startup crop/pixelate/text/copy/export tour and separate clean-sidebar capture pass. Earlier coordinate-gesture harness failures are retained; no new shape-drag certification is claimed. The isolated simulator is shut down.

The site builds six pages. Local links/anchors and responsive checks pass; all six pages fit 390-point width with no missing alt text or unloaded images. Home-page Lighthouse snapshot scores are 100 for accessibility, best practices and SEO in mobile/light and desktop/dark; performance is not audited. Final assets are visually inspected.

**Not submitted:** proposed marketing/support/privacy/source URLs return HTTP 404. Public site/repository publication, private App Store contact/trader/territory fields, distribution archive/privacy report, upload and Apple review remain separate. No account mutation, Git, publication or upload occurred. Core/full UI/native service suites were not rerun for this content-only task.
[Task](../memory-bank/261031_site-and-store-readiness.md), [Apple packet](AppStore/README.md), [evidence](Validation/site-and-store-readiness.json).

## Default native List styling — build 36, October 31, 2026

Installed identity 1.0 (36), normally launched without test arguments and independently verified one running app process.

Removed the category-only borderless Button style and rounded-rectangle border-shape overrides. Categories now inherit automatic native List Button styling alongside the compact image rows. List still owns selection; no custom background, selection or hover renderer was added. Category labels/counts, disclosure state, document callbacks, Dynamic Type, source pixels and window transparency remain.

Four existing focused UI cases pass, exit 0 (248 s): real category expand/collapse, document switching/independent Undo/close/Recents, clear/opaque/default glass, and compact long filenames at largest text, including native accessibility audits. Populated/empty and largest-text compositor inspected. Signed Release build/analyze passes (18.364 s), strict signature and privacy/Debug boundaries pass. The two AppIntents metadata-extraction skip warnings were inspected. Core and UI test source are unchanged; core 69-test/5-suite baseline, full UI suite and native services were not rerun. Hardware gaze/hover still needs owner observation. The task simulator is stopped.
[Task](../memory-bank/261031_default-list-styling.md), [evidence](Validation/default-list-styling.json).

## Compact sidebar image rows — build 35, October 30, 2026

Build 35 was installed October 31, with identity 1.0 (35) verified, normal launch without test arguments and exactly one running app process. The October 30 attempt was blocked by CoreDevice 4016; its evidence remains in the deployment history.

Image entries in Open Images and Recents now use a small SF image symbol and one filename line instead of thumbnails and a second metadata line. A small dot marks unsaved edits; image type and Edited status remain spoken accessibility values. Native List selection, category rows/counts, indentation and the growing 60-point visionOS target minimum remain.

Three existing focused UI cases pass, exit 0 (183 s): document switching/independent Undo/close/Recents, clear/opaque/default glass, and compact long filenames at largest text, including native accessibility audits. Populated compositor reviewed. Signed Release build/analyze passes (26.384 s); strict signature, add-only Photos, privacy manifest, encryption key and Debug exclusion pass. The two metadata warnings are the existing AppIntents extraction skip, once each during build and analyze. Core/tests, services and UI test source are unchanged; the 69-test/5-suite core baseline and full UI/service suites were not rerun. The task simulator is stopped. Physical gaze/hand and assistive technology remain separate.
[Task](../memory-bank/261030_compact-sidebar-rows.md), [evidence](Validation/compact-sidebar-rows.json).

Earlier checkpoint: October 29, 2026 for build 34; earlier runtime evidence retains its recorded dates. This record separates baseline implementation, audit reproduction,
remediation work and actual acceptance. [The product contract](BUILD_BRIEF.md) defines completion;
[the memory bank](../memory-bank/toc.md) provides architecture and task continuity.

## Sidebar hierarchy — build 34, October 29, 2026

Installed identity 1.0 (34); normal launch waits for device unlock. The owner rejected the bare expandable headers and asked for Notes/Safari/Files hierarchy. The sidebar now has tinted photo-stack/clock symbols, counts, full native category rows with disclosure chevrons, indented images and empty states, and a quieter heading. Open Images starts expanded; Recents starts collapsed. Standard plain List and borderless Button surfaces replace the grouped-card candidate; List still owns document selection.

Five focused UI cases pass, exit 0 (157 s), on the final signed source. Coverage: real document switching/Undo/close/cancel/Recents, native target sizing and all-issue empty-state audit, largest text, clear/opaque/default glass and ⌘V after sidebar interaction. Core unchanged from build 33 (69 tests/5 suites); not rerun. Signed Release/analyze, strict signature, add-only Photos/manifest/encryption and Debug exclusion pass. Full UI/service suites were not rerun. Hardware appearance, gaze/hand and assistive technology remain scoped owner checks.
[Task](../memory-bank/261029_sidebar-hierarchy.md), [evidence](Validation/sidebar-hierarchy.json), [physical](Validation/physical-deployment.json).

## Native start screen and sidebar — build 33, October 29, 2026

Installed and normally launched on the headset; identity 1.0 (33), exactly one running app process, all commands exit 0. Build 32 was installed and launched first; the owner's follow-up requested a whole-well tap or Command V in place of its blue Paste button.

- Larger native Photos/Files wells and a gray native drop/Paste well; no separate blue Paste button.
- Tap the well or press ⌘V in the empty workspace to open a copied image. Clipboard providers are requested only by that action; text fields keep their native responder.
- System List rows/disclosures/selection; Open Images expanded, Recents collapsed; one accessible item per document.
- Existing rear-glass transparency, original pixels, per-document Undo and protected provider import remain.

Core: **69 tests/5 suites, exit 0**; actual file/data provider byte and ownership checks included. 5 focused UI cases pass across two runs on identical final production source; corrected-selector follow-up native exit 0 (127 s); synthetic drag skipped because the gesture never started a system drag. Signed Release build/analyze and strict signature pass; add-only Photos, manifest and encryption answer intact, Debug-only fixtures excluded. The full UI suite/native service smoke were not rerun. Cross-app physical Drop, clipboard consent, keyboard and assistive technology remain scoped owner checks.
[Task](../memory-bank/261029_native-start-and-sidebar.md), [evidence](Validation/native-start-and-sidebar.json), [physical](Validation/physical-deployment.json).

## Previous installed release — 1.0 (31)

Built, signed, verified and **installed** October 26, 2026; **normally launched and verified running**
October 29 after unlock. Installed identity and exactly one app process were read back; no rebuild or
reinstall. Earlier locked launch timeouts remain in the physical record. At the owner's request ("Use the AutoPaper version so users know
the who/where/why behind it"), Settings gains an About page like AutoPaper's: the icon, the name, the version
read from the bundle, what the app is for and who made it, Website · Privacy · Help, and the MIT license line.
An ⓘ button in Settings' title bar opens it; the sheet is now titled Settings. The owner removed build 29,
the copy under the old identifier, and the headset now has only `com.glassimagetools`.
[Task](../memory-bank/261026_about-settings.md).

| Evidence | Recorded result | Authority |
|---|---|---|
| UI tests | The four tests that open Settings pass, 4/4 (exit 0, 419 s), including both accessibility audits, which now open About at standard and largest text, check its version against the bundle's and its three links, and report no issues. An earlier run shared the machine with the tour, the Release build and the install, and two tests failed there (a slider drag stopping at 4%, then lost accessibility and app-termination errors); alone on a restarted simulator all four pass. The full suite wasn't rerun | [About in Settings](Validation/about-settings.json) |
| Signed Release | Build/analyze exit 0; strict signature; `com.glassimagetools` 1.0 (31); encryption key false; manifest matches source; add-only Photos; Debug excluded; About image compiled (256 px, vision 2x); no networking code | [About in Settings](Validation/about-settings.json) |
| Simulator look | Settings with ⓘ, Done and unchanged sliders; About as designed. Help's Settings picture retaken from the app | [About in Settings](Validation/about-settings.json) |
| Physical | Installed October 26, identity 1.0 (31). After the earlier locked timeouts, October 29 lockState reports no passcode; identity exit 0, normal launch exit 0 (1.375 s), independent process query exit 0 with exactly one app process. No rebuild/reinstall/test arguments. Physical About appearance/input remain separate | [Physical](Validation/physical-deployment.json) |

## Previous installed release — 1.0 (30)

Built, signed, installed and normally launched October 25, 2026. The only change is the bundle identifier,
now `com.glassimagetools` at the owner's choice (it was `com.glasspowertools.visionsnip`). visionOS treats a
new identifier as a new app, so build 30 installed beside build 29, which keeps the old identifier on the
headset until it is removed; Opacity and Glass settings and the Photos permission don't carry over.
[Task](../memory-bank/261025_app-store-preparation.md#build-30-the-bundle-identifier).

| Evidence | Recorded result | Authority |
|---|---|---|
| Sources | Swift sources, tests and core unchanged from build 29 (core and UI suites not rerun); only `Config/Identity.xcconfig` and the build number changed | [App Store preparation](Validation/app-store-preparation.json) |
| Signed Release | Build/analyze exit 0; strict signature; `com.glassimagetools` 1.0 (30), framework `com.glassimagetools.core`; encryption key false; manifest matches source; add-only Photos; Debug excluded | [App Store preparation](Validation/app-store-preparation.json) |
| Physical | lockState exit 0, no passcode; install exit 0; identity 1.0 (30); normal launch exit 0. Build 29 was still installed under the old identifier; the owner removed it before October 26 | [Physical](Validation/physical-deployment.json) |

## Earlier installed release — 1.0 (29)

Built, signed, verified, applied, **installed and normally launched** October 25, 2026, once the owner
woke the headset (the first attempt found it unreachable). At the owner's direction the app is prepared for TestFlight and
the App Store the way Glass Power Tools is: a privacy manifest, `ITSAppUsesNonExemptEncryption` `NO`,
PRIVACY.md's TestFlight and App Store section, and the listing in [the App Store folder](AppStore/README.md).
App Swift sources, tests and core are unchanged. [Task](../memory-bank/261025_app-store-preparation.md).

| Evidence | Recorded result | Authority |
|---|---|---|
| Core | 67 tests/5 suites, exit 0 | [App Store preparation](Validation/app-store-preparation.json) |
| UI suite | Not rerun; app Swift sources and UI tests hash-identical to build 28 (37/37 at build 27) | [Sidebar rows and +](Validation/sidebar-rows-and-plus-menu.json) |
| Signed Release | Build/analyze exit 0; strict signature; 1.0 (29); encryption key false; manifest at the bundle root, lint OK; Debug excluded | [App Store preparation](Validation/app-store-preparation.json) |
| Required-reason APIs | App: user defaults only (declared); core framework: none | [App Store preparation](Validation/app-store-preparation.json) |
| Simulator | Install and launch exit 0; one process | [App Store preparation](Validation/app-store-preparation.json) |
| Site | Only the privacy page changed; 0 link/anchor/alt problems; no overflow; Lighthouse 100s | [App Store preparation](Validation/app-store-preparation.json) |
| Physical | First attempt: CoreDevice 4016 (unreachable). After the owner woke the headset: install exit 0, identity 1.0 (29), normal launch exit 0, one process | [Physical](Validation/physical-deployment.json) |
| Owner observation | October 25 headset screenshot of build 29: round +, compact sidebar rows, grouped title bar and corner close button, a 563 × 497 crop of a 1,920 × 1,080 PNG with its Copy confirmation; "Really nice." The Home View icon wasn't shown | Owner; the screenshot isn't kept (personal content) |
| Distribution | No archive, distribution signing, privacy report, upload or App Store Connect record verified | [App Store folder](AppStore/README.md) |

## Earlier installed release — 1.0 (28)

Built, verified, applied, installed and normally launched October 24, 2026: identity read back as
1.0 (28) and one running process, once the headset was awake. At the owner's request the toolbox icon
is replaced by a round picture: a white sun and hills on red glass in a silver frame that fills the icon,
layered for visionOS with the frame in front, the sun and hills in the middle and the glass behind. App
Swift sources, tests and core are unchanged from build 27. [Task](../memory-bank/261024_round-picture-icon.md).

| Evidence | Recorded result | Authority |
|---|---|---|
| Icon | Generator layer checks pass (frame opaque to the edge and clear over the glass; sun and hills under the frame; Back opaque); xros catalog compiles with no warnings; three-layer SolidImageStack | [Round picture icon](Validation/round-picture-icon.json) |
| Simulator Home View | After the install animation the icon renders as designed: red glass, white sun and hills, silver frame | [Round picture icon](Validation/round-picture-icon.json) |
| UI suite and core | Not rerun; app Swift sources, UI tests and core hash-identical to build 27 (37/37) | [Sidebar rows and +](Validation/sidebar-rows-and-plus-menu.json) |
| Site | New icons, favicons and social card; 6 pages, 0 link/anchor/alt problems | [Round picture icon](Validation/round-picture-icon.json) |
| Signed Release | Build/analyze exit 0; strict signature; 1.0 (28); add-only Photos; Debug excluded | [Round picture icon](Validation/round-picture-icon.json) |
| Physical | Install exit 0; identity 1.0 (28); normal launch exit 0; one process | [Physical history](Validation/physical-deployment.json) |

**Website, October 24 (no app change).** At the owner's request the site's footer and builder follow
AutoPaper's: Help, Privacy and an "Also by" row in the footer; only built pages linked; links rewritten only
in anchors; publishing permissions only on the Pages deploy job, with actions pinned to release commits.
[Task](../memory-bank/261024_autopaper-footer-and-builder.md).

| Evidence | Recorded result | Authority |
|---|---|---|
| Builder | Old layout: 26 of 26 output files byte-identical to the old builder's; edge cases pass; builds on Python 3.9 and 3.15 | [AutoPaper footer and builder](Validation/autopaper-footer-and-builder.json) |
| Workflow | actionlint 0 problems; pinned commits match the v7/v5/v5 tags; not yet run (first push) | [AutoPaper footer and builder](Validation/autopaper-footer-and-builder.json) |
| Site | 6 pages, 0 link/anchor/alt problems; no overflow at 375 px; Lighthouse accessibility/best practices/SEO 100 | [AutoPaper footer and builder](Validation/autopaper-footer-and-builder.json) |

## Earlier recorded release — 1.0 (27)

Built, tested and applied October 23, 2026; **never installed**: the headset was unreachable
(CoreDevice 4016); its changes reached the headset in build 28. At the owner's request the title-bar
+ is a round menu button with no chevron, and the Images sidebar's rows are compact buttons measured
like the Glass Power Tools Vision Pro terminal sidebar instead of List rows.
[Task](../memory-bank/261023_sidebar-rows-and-plus-menu.md).

| Evidence | Recorded result | Authority |
|---|---|---|
| Full native UI suite | 37 cases, 0 failures, exit 0, 1,138 s (final applied source) | [Sidebar rows and +](Validation/sidebar-rows-and-plus-menu.json) |
| Core | Not rerun; Sources/Tests hash-identical to build 26 (67 tests/5 suites) | [Website, icon, license](Validation/website-icon-and-license.json) |
| Site | Screenshots retaken from build 27 (tour exit 0); testing section removed from Home (owner); 6 pages, 0 link/anchor/alt problems | [Sidebar rows and +](Validation/sidebar-rows-and-plus-menu.json) |
| Signed Release | Build/analyze exit 0; strict signature; 1.0 (27); add-only Photos; Debug excluded | [Sidebar rows and +](Validation/sidebar-rows-and-plus-menu.json) |
| Physical | Not installed; headset unreachable on October 23 | [Sidebar rows and +](Validation/sidebar-rows-and-plus-menu.json) |

**Owner-reported hardware checks, October 23, 2026:** a hardware keyboard with the app, saving to
Photos and to Files, and pasting into apps other than ChatGPT. The build, shortcuts, recipient apps,
format and permission prompts were not specified, and tooling observed none of it. VoiceOver, Voice
Control, Switch Control, keyboard-only navigation and very large images remain unchecked on a headset.

## Earlier installed release — 1.0 (26)

Built, applied and installed October 22, 2026. Release 1.0 (26) is installed and its identity read back;
the headset was locked, so **normal launch is pending unlock**. App Swift sources equal build 25; the
icon uses AudioPaper's rendered red and silver. The project gained an MIT license, a GitHub Pages site
(built and checked locally, **not published**) and public repository files.
[Task](../memory-bank/261022_website-icon-and-license.md).

| Evidence | Recorded result | Authority |
|---|---|---|
| Core | 67 tests/5 suites, exit 0 | [Website, icon, license](Validation/website-icon-and-license.json) |
| UI suite | Not rerun; App, UITests and Sources byte-identical to build 25 (37/37, exit 0) | [Title-bar group](Validation/titlebar-tool-group.json) |
| Icon | Three planes validated; xros catalog compiles; SolidImageStack | [Website, icon, license](Validation/website-icon-and-license.json) |
| Site | 6 pages; 0 local link/anchor problems; no overflow at 390 px; Lighthouse accessibility/best practices/SEO 100 | [Website, icon, license](Validation/website-icon-and-license.json) |
| Privacy scan | Every publishable file: no private identifiers; author credit only | [Website, icon, license](Validation/website-icon-and-license.json) |
| Signed Release | Build/analyze exit 0; strict signature; add-only Photos; Debug excluded; probe compiles | [Website, icon, license](Validation/website-icon-and-license.json) |
| Physical | Install retry exit 0 (first attempt: dropped connection after transfer); identity 1.0 (26); launch pending | [Physical history](Validation/physical-deployment.json) |

## Historical build checkpoints

The following sections retain their original observation dates and build scope. Pending launch or
prepared-product statements in them do not override the latest recorded release above.

## Title-bar tool group — build 25

Built, tested, applied and deployed October 22, 2026. Release 1.0 (25) was installed, its identity read
back, normally launched without test arguments and verified running (exactly one process; headset
unlocked). At the owner's request the title-bar tools (Undo, Redo, Copy, Share, Export, inspector toggle)
share one glass capsule and Close Image sits alone in the upper-right corner.
[Task](../memory-bank/261022_titlebar-tool-group.md).

| Evidence | Recorded result | Authority |
|---|---|---|
| Full native UI suite | 37 cases, 0 failures, exit 0, 1,223 s (final applied source) | [Title-bar group](Validation/titlebar-tool-group.json) |
| Core and services | 67 tests/5 suites; 50 native checks | [Title-bar group](Validation/titlebar-tool-group.json) |
| Signed Release | Build/analyze exit 0; strict signature; add-only Photos; Debug excluded; probe compiles | [Title-bar group](Validation/titlebar-tool-group.json) |
| Physical | Install exit 0; identity 1.0 (25); normal launch exit 0; one process | [Physical history](Validation/physical-deployment.json) |

## Toolbar, sidebar and inspector — build 24

Built, tested and applied October 21, 2026. Release 1.0 (24) was installed and its identity read back
while the headset was locked; the owner's October 22 screenshot shows it running. It makes
toolbar Copy match Share › Copy (no blocking overlay; same clipboard item and reach), adds one + menu,
makes Text and Pixelate place objects, restructures the inspector, and widens the sidebar with
text-height previews. [Task](../memory-bank/261021_toolbar-sidebar-and-inspector.md).

| Evidence | Recorded result | Authority |
|---|---|---|
| Full native UI suite | 37 cases, 0 failures, exit 0, 1,173 s (final applied source) | [Toolbar/sidebar/inspector](Validation/toolbar-sidebar-and-inspector.json) |
| Earlier runs | Reveal-helper origin, sidebar row loop, two stale test geometries found and fixed; build 23 compared | [Toolbar/sidebar/inspector](Validation/toolbar-sidebar-and-inspector.json) |
| Core | 67 tests/5 suites pass (core unchanged) | [Toolbar/sidebar/inspector](Validation/toolbar-sidebar-and-inspector.json) |
| Native services | 50 checks pass, including Text/Pixelate placement and non-blocking Copy | [Toolbar/sidebar/inspector](Validation/toolbar-sidebar-and-inspector.json) |
| Signed Release | Build/analyze exit 0; strict signature; add-only Photos; Debug excluded; probe compiles | [Toolbar/sidebar/inspector](Validation/toolbar-sidebar-and-inspector.json) |
| Physical | Install exit 0; identity 1.0 (24); launch pending unlock | [Physical history](Validation/physical-deployment.json) |

⌘N and ⌘, are scene commands observed with simulator key events. ⌘V image paste is not available (not
observed working in this or earlier builds); + › Paste is the route. Copy can now reach the owner's other
devices through Universal Clipboard, as Share › Copy does. Gaze/hand, hardware keyboard, Universal
Clipboard delivery and assistive technology remain owner observations.

## Review fixes and caption clearance — build 23

Built, tested, applied and deployed October 21, 2026. Release 1.0 (23) was installed, its identity read
back, normally launched without test arguments and verified running (exactly one process; headset
unlocked). It fixes all seven October 21 review findings and the owner-reported caption hidden behind the
bottom toolbar ornament. [Task](../memory-bank/261021_review-fixes-and-caption-clearance.md).

| Evidence | Recorded result | Authority |
|---|---|---|
| Full native UI suite | 37 cases, 0 failures, exit 0, 1,254 s, clean finalization (final applied source) | [Review fixes](Validation/review-fixes.json) |
| Baseline comparison | 7 failures in the first full run reproduced identically on build 22; fixed (stale helpers/queries, unpaired inspector dimensions) | [Review fixes](Validation/review-fixes.json) |
| Core | 67 tests/5 suites pass, including new color-gamut tests | [Review fixes](Validation/review-fixes.json) |
| Native services | 48 checks pass, including P3 color, rotated fields, pending Undo, zoom anchoring and Photos saves | [Review fixes](Validation/review-fixes.json) |
| Signed Release | Build/analyze exit 0; strict signature; add-only Photos; Debug excluded; probe compiles | [Review fixes](Validation/review-fixes.json) |
| Physical | Install exit 0; identity 1.0 (23); normal launch exit 0; one process | [Physical history](Validation/physical-deployment.json) |

Simulator compositor shows the caption fully above the toolbar ornament and paired inspector fields.
Physical ornament parallax, a real P3 palette pick on hardware, gaze/hand, keyboard and assistive
technology remain owner observations.

## Build-22 documentation review — October 21, 2026

Reviewed October 21, 2026 against unchanged build-22 App/Core sources and the recorded October 19
validation/deployment. No new runtime test or device query was performed. The installation record
verifies build 22; normal launch/process was not observed because the headset then required unlock.
Current lock/running state is unknown. [Release notes](RELEASE_NOTES.md) summarize behavior and follow-up.

The current workspace uses leading document navigation, an independent right contextual inspector and
native controls in plain SwiftUI columns over one adjustable rear surface. It preserves full-strength
foreground and the build-22 preview-only crop mask. Earlier navigation-container/left Tool Options
implementations below are historical, not the current architecture.

| Evidence | Recorded result | Authority |
|---|---|---|
| Build-22 final crop UI | Two cases, zero assertion failures; result finalization interrupted, native exit −15 | [Crop dimming](Validation/crop-dimming.json) |
| Build-22 signed Release build/analyze | Exit 0; signature/privacy/Debug exclusion pass; one expected metadata skip | [Crop dimming](Validation/crop-dimming.json) |
| Retained window/editor baseline | Build 21: six distinct UI cases across stages; final four-case command exit 0 | [Window transparency](Validation/window-transparency-restoration.json) |
| Retained native services | Build 21: 42 checks pass; not rerun for build 22 | [Window transparency](Validation/window-transparency-restoration.json) |
| Retained core | Build 19: 62 tests/four suites pass; unchanged through build 22, not rerun there | [Document workspace](Validation/document-sidebar-and-inspector.json) |
| Latest recorded installation | Build 22 installed/identity verified; launch/process unverified | [Physical history](Validation/physical-deployment.json) |

Primary crop/Copy/ChatGPT use has owner confirmation. Hardware accessibility/input/appearance, consent,
resources and broader recipient/export coverage remain separate acceptance work. No physical capture
path, distribution archive, TestFlight/App Store or public release is verified. Historical failures,
source scopes and finalization limits remain in the checkpoints and linked task/evidence records below.

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

[Task](../memory-bank/261019_crop-dimming.md), [evidence](Validation/crop-dimming.json). Earlier sections are historical.

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

[Task](../memory-bank/261019_transparency-regression.md), [evidence](Validation/window-transparency-restoration.json). Earlier sections are historical.

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

Physical gesture/assistive/focus/keyboard, appearance/motion and resource validation remain manual. No new recipient or capture capability is claimed.

[Task](../memory-bank/261018_sidebar-and-toolbar-refinement.md), [evidence](Validation/sidebar-and-toolbar-refinement.json). Earlier sections are historical.

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

[Task](../memory-bank/261018_document-sidebar-and-inspector.md), [evidence](Validation/document-sidebar-and-inspector.json). Earlier sections are historical.

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

[Task](../memory-bank/261017_sidebar-defaults-and-rotation.md), [evidence](Validation/sidebar-defaults-and-rotation.json).

Earlier sections retain historical checkpoints; the current release is listed at the top.

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

[Task](../memory-bank/261017_native-left-sidebar.md), [validation](Validation/native-left-sidebar.json).

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

[Task](../memory-bank/261017_drawing-and-sliding-tools.md#owner-feedback-follow-up--intrinsic-caption-sizing), [validation](Validation/caption-natural-height.json).

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

[Task](../memory-bank/261017_drawing-and-sliding-tools.md); [validation](Validation/drawing-and-sliding-tools.json).

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
recipients/resources and capture remain separate. [Task](../memory-bank/261017_tool-sidebar-and-image-caption.md), [evidence](Validation/sidebar-and-caption.json).

Installation passed in 4.164 seconds; actual identity readback in 0.452 seconds; normal launch without
fixture arguments in 0.966 seconds; independent exactly-one-process observation in 0.700 seconds. All
exited 0. Physical synthetic caption inference took 2.56392825 seconds and returned nonempty text with
model available/vision support. This is service execution evidence, not physical editor appearance or
semantic-accuracy certification. [Physical history](Validation/physical-deployment.json).

Earlier build sections below retain historical checkpoints and limitations; the latest release is recorded at the top.

## Previous menu-caret checkpoint — build 13

**Glass Image Tools 1.0 (13), Release, is installed, normally launched and verified running on Vision Pro.**
Import, Crop Preset, Drawing Tools, Zoom and Shapes retain native menus/buttons/material and add Apple's
chevron SF Symbol through one shared label helper. Shapes stays a single tap/hold control. Carets are
decorative and omitted only at compact/accessibility text sizes to keep full-size controls and commands.
SwiftUI's visibility modifier compiled but rendered no caret in actual SDK 27.2 simulator captures.

The first visible variant passed Shapes draw/resize/Undo but failed largest toolbar width (805.5/720).
Corrected before application. Final two compact/largest UI cases passed, zero failures, 56.687 suite
seconds, command exit 0; toolbar/panel all-issue audits ignore no app findings. Actual compositor views
confirm normal caret visibility and fitting largest controls. Signed Release build/analyze passed in
11.972 seconds, exit 0; strict signature, Release/privacy boundaries and three-file conflict-free exact
source application passed. Unchanged core/model/render/export/settings and tests retain the 57/30
baseline; no rerun or separate new probe compile is claimed. Simulator restored to normal launch.

Installation (2.819 seconds), actual installed name/version/build (0.437 seconds), normal launch without
test arguments (0.521 seconds) and independent exactly-one-process observation (0.658 seconds) all
passed, exit 0. Build 13 supersedes build 12. Hardware caret/material/gaze/hold/assistive-technology,
recipients, resources and capture remain separate. [Caret evidence](Validation/menu-indicators.json),
[physical history](Validation/physical-deployment.json), [task](../memory-bank/261016_native-glass-chrome.md#native-menu-indicator-follow-up).

## Previous physical deployment — build 12

**Glass Image Tools 1.0 (12), Release, is installed, normally launched and verified running on physical
Apple Vision Pro.** The owner requested deployment after the native Glass handoff. Reused the prepared
signed product after exact current-source/product identity and strict-signature verification; no rebuild.
Installation passed, exit 0, 2.851 seconds. Actual installed name/version/build readback passed, exit 0,
0.986 seconds. Normal launch passed, exit 0, 1.238 seconds, without testing arguments. Independent subsequent
process query passed, exit 0, 0.373 seconds, with exactly one matching application executable.

Build 12 supersedes build 10's installed identity and pending unlock/launch checkpoint. Historical failures
remain in [physical evidence](Validation/physical-deployment.json). Deployment proves installed/running
state; physical materials, gaze/hold/keyboard/assistive-technology and wider recipient/resource acceptance
remain separate. Source/UI/core/service validation scopes below are unchanged. No Git/publication occurred.

## Native Glass implementation checkpoint — build 12

**Reviewed changes are applied; development-signed Release 1.0 (12) is prepared locally, not installed.**
A read-only Glass Power Tools visionOS comparison established the family pattern: separate controls in
native ToolbarItemGroup, capsule title, one rear glass surface and no redundant embedded-panel material.
The editor now follows that toolbar/title/panel approach. Opacity/Glass, window geometry, opaque image/
foreground, single Shapes hold chooser and all editing/source/export owners remain preserved.

13 distinct selected UI cases passed across three clean commands (four/zero in 99.932 seconds, eight/zero
in 289.666, three/zero in 87.067; all exit 0). Four native accessibility cases and compact-largest toolbar/
panel `.all` audits ignore no app issue. Actual palette, native shape/crop/Pan/Undo, appearance, sharing
and panel/tiny-object interaction passed. Actual compositor inspection exposed the first variant's
802-point largest-text toolbar despite a passing audit; Options overflow and a strengthened test now
verify 715.5 points within 720. No full 25-case rerun is claimed.

Signed Release build/analyze passed, exit 0, 14.854 seconds; strict signature, family 7, add-only Photos
usage, development entitlements and Debug/probe exclusions passed. Separate probe SDK compile passed,
exit 0, 17.255 seconds. Four files applied without conflicts, matching final tested hashes. The unchanged
57-core/30-service source baseline is retained, not newly executed. Simulator contrast/normal launch
restored after final synthetic preview; earlier Increase Contrast captures are not a controlled material
comparison. No physical call occurred; build 10 remains the verified installed headset identity.

[Task](../memory-bank/261016_native-glass-chrome.md), [evidence](Validation/native-glass-chrome.json) and
[audit follow-up](ACCESSIBILITY_AUDIT.md#native-glass-follow-up--build-12) retain hardware/recipient/resource
and first-consent limits. Native document-title content and image editing affordances remain app-composed.

## Apple HIG implementation — build 11 prepared

**All eight approved findings are implemented, tested and applied; development-signed Release 1.0 (11)
is prepared locally, not installed on the headset.** Long titles/actions and the bottom native toolbar
adapt to actual width/text size. Contextual native annotation controls sit beside the canvas, with text
defaults, accurate pixelation units, separate gesture/style Undo, Show Selection and forgiving source-
preserving object controls. Pan remains visible. Appearance endpoints are readable; Copy is prominent and
native Share opens directly with a flattened PNG snapshot. [Implemented mapping](HIG_REVIEW.md#implementation-follow-up--build-11)
links each original finding to its owner and tests.

57 core definitions/three suites passed (exit 0, 0.816 seconds); 30 actual native service checks passed
(launch/service exit 0, 3.155 seconds). Twenty-five distinct UI cases passed across runs: 15 functional,
four accessibility, six HIG. The broad 25-case invocation passed 24 cases and failed compact Pixelate's
native symbol label; final menu/largest-text checks passed two/zero in 47.587 seconds, command exit 0.
A clean full 25-case command is not claimed. Native compositor and actual palette/Photos checks passed;
app audits ignore no issue. Failed assertions, corrected fixtures and result-finalization stops are retained.

Final signed Release build/analyze passed, exit 0, 11.239 seconds; strict signature, native family 7,
add-only Photos usage and Debug/probe exclusion passed. Development `get-task-allow` is present; this is
not an App Store distribution artifact. Separate device-SDK probe compilation passed, exit 0. Applied
16-file source/project/test hashes match reviewed staging; local signing was preserved. Simulator contrast
was restored and normal launch without fixture arguments passed. No physical-device calls occurred.

First-run Photos consent tapping, headset assistive technology/gaze/focus, physical Reduce Transparency,
icon parallax, large-image profiling and share recipients remain separate checks. The isolated simulator
save regression used only pregranted add-only access. The system palette's -902 audit restriction remains;
functional native palette RGB/edit/Undo passed. The last verified headset installation remains build 10.
[Evidence](Validation/hig-fixes.json), [task](../memory-bank/261016_apple-hig-fixes.md) and
[accessibility follow-up](ACCESSIBILITY_AUDIT.md#hig-follow-up--build-11) retain precise scope.

## Historical Apple HIG review — October 16, 2026

At the review checkpoint, [the report](HIG_REVIEW.md) recorded eight proposed fixes and production app
code was unchanged. The implementation above supersedes their proposed status. Two native simulator observation walkthroughs passed, zero failures, 137.774 seconds,
command exit 0; 16 actual compositor views were inspected. A long synthetic filename clips in the
720 × 540 minimum window and visually hides document actions at the largest text size. The annotation
toolbar measures 910.5 points against a 720-point content window. Contextual annotation controls, visible
Pan state, selected-content obstruction, tiny/offscreen annotation controls and Appearance captions have
specific follow-up acceptance. The earlier short-name accessibility result does not cover long names.

All 32 baseline app/core/UI/configuration/project hashes remain unchanged. The private observation harness
was not applied; the previously tested simulator app was restored and normally launched. No physical
device call, new deployment or new HIG-compliance claim occurred. Headset gaze/focus/speech/comfort checks
remain pending owner availability. [Sanitized evidence](Validation/hig-review.json) and
[task record](../memory-bank/261016_apple-hig-review.md) distinguish observations from recommendations.

## Native UX/accessibility iteration — build 10

**Glass Image Tools 1.0 (10), Release, is installed and identity-verified; normal launch verification awaits headset unlock.**
The normal launch request timed out after 35 seconds; the completed subsequent process query found no matching app. A subsequent lock-state query reports passcode required, so unlock the headset before resuming launch verification. The earlier client option-order error occurred before a remote request and is retained separately.

The full queued iteration is implemented: reachable source-preserving crop controls at zoom/Pan,
native grouped forms and adaptive labeled dimensions, explicit Paste Image, selected native color wells,
and accessibility remediation/audit. Add at Center and named pixel adjustments provide alternatives to
precision drags; processing can be cancelled and completion messages use public accessibility announcements.
For the tested short fixture name, the largest-text title sits above the window without covering crop-axis
dimensions; the later HIG review documents a separate long-name clipping limit.

53 core tests, 24 actual native service checks, 15 functional UI cases and four accessibility/UI cases passed across recorded runs. The final three standard audit cases and largest-text/Increase Contrast case passed with zero app audit issues; no findings were ignored. The native palette RGB/selection/live-color/one-Undo check passed. Signed Release build/analyze, strict signature, Debug exclusion, add-only Photos scope and separate probe SDK compilation passed. Reviewed source matches the tested staging hashes, with no concurrent-edit conflicts.

The functional 15-case suite passed in 443.289 seconds inside an 18-case invocation whose Debug-marker
audit still failed. That failed command stalled during result finalization and was stopped; its assertions
and termination status are retained. Corrected standard audits passed in 80.348 seconds (exit 0), and the
final largest-text/contrast check passed in 29.208 seconds (exit 0). A separate attempted system-host audit
failed with error -902; no system audit success is claimed. Native palette control/RGB/edit/Undo assertions
now verify that integration. Core and service checks include provider cancellation/stale completion,
unchanged bytes, owned-copy cleanup, encoded byte caps, clipping, transforms, pixels and metadata.

Actual VoiceOver/Voice Control/Switch Control speech, focus and hardware keyboard/eye-hand acceptance
remain unobserved. Apple’s system color-picker host rejects automated auditing with error -902; its real
controls and RGB/edit/Undo behavior were verified instead. Tiny/offscreen annotation handles retain the
native geometry inspector and named-action alternatives. New Paste ingestion/gesture acceptance, Reduce
Transparency and resource profiling on hardware remain separate from simulator evidence. The owner’s
approximately ten successful Photos → crop → Copy → ChatGPT uses remain confirmed; do not request that
baseline again. No physical capture path is confirmed.

[Full accessibility audit](ACCESSIBILITY_AUDIT.md), [sanitized validation](Validation/native-ux-and-accessibility.json),
[physical evidence](Validation/physical-deployment.json) and [task record](../memory-bank/261015_native-editor-ux-and-accessibility.md)
retain actual scope, failure history and remaining checks.

## Historical physical installation — shape-menu follow-up, build 9

**Glass Image Tools 1.0 (build 9), Release, is installed and normally launched on the physical Vision Pro.**
Actual installed name/version/build readback and a subsequent matching running-process query passed on
visionOS 27.2. Installation retry completed successfully in 5.210 seconds; normal launch succeeded in
1.749 seconds without testing arguments. This replaces the earlier installed build 8.

Fresh signed Release build with SDK 27.2 passed (exit 0, 10.048 seconds). Strict signature, Debug fixture
exclusion, add-only Photos permission scope and tested-source identity checks passed. Project regeneration
changed only the build number. Physical launch proves launch; the owner is continuing visual/eye-hand
validation of the menu, foreground appearance and icon. No new broad product acceptance is inferred.

The first installation failed before transfer with CoreDevice 4016 while device services/connectivity/
power assertions were unavailable. The owner's availability update permitted a successful retry using
the same signed product. An optional installation-provided persistent launch identifier was rejected by
the CLI as invalid base64 (exit 64, before a remote launch); standard bundle-identifier launch then passed.
[Physical evidence](Validation/physical-deployment.json) retains these attempts and historical build 8
installation/launch limits, which are superseded by this build 9 launch result.

## Focused shape-menu follow-up — implemented and deployed

Owner validation feedback requested removal of the duplicate dropdown arrow while retaining pinch-and-hold
on the shape button. `App/EditorView.swift` now has one native shape chooser: tap activates the selected
shape, hold opens choices. The existing UI helper uses that hold interaction, verifies the duplicate is
absent and exercises real rectangle/triangle creation, editing, resizing and Undo/mode retention.

Native simulator build and **two existing UI cases passed, zero failures, 57.576 seconds, exit 0**, on
visionOS Simulator 27.2. Core/model-service suites were not rerun; their source is unchanged. The subsequent
signed build 9 install/launch is recorded above. At that historical checkpoint, broader modal UX, accessibility, Paste Image, palette
feedback and zoomed-crop work remained queued; the build 10 iteration above supersedes that wait.
[Simulator evidence](Validation/single-shape-chooser.json) and
[the task record](../memory-bank/261015_native-editor-ux-and-accessibility.md) retain scope.

## Primary workflow — owner-confirmed on hardware

On October 15, 2026, the owner reported using the app approximately ten times for the described
Photos → crop → Copy → paste into ChatGPT workflow on Vision Pro. This confirms the product brief's
primary success criterion in real use. The evidence is the owner's report; the exact build used for those
sessions was not specified. Optional annotation coverage, other recipients, Files import, Photos saving,
export formats and large-image limits were not separately established by this report.

## Opaque foreground above appearance — build 8

The owner's foreground requirement is implemented: explicit rear glass/tint at spatial z = −1 and stacking
index −1, full-opacity image workspace at the native interaction plane z = 0 / index 1. Native title/toolbars
keep their own surfaces; crop handles and editable annotations remain above image pixels. Source alpha,
source bytes, source-pixel geometry and encoded output are unchanged.

Four unique native UI cases passed across completed runs: crop/undo/redo/zoom/copy/export, endpoint edit/
Undo, object text context, and expanded appearance verification. The appearance case passed with zero
failures in 113.651 seconds: actual slider extrema, relaunch persistence/reset, retained 1200 × 1000 crop/history,
opaque-background rectangle input and clear-background text creation/re-edit/Undo. The full eleven-case
suite was not repeated; 42 core tests and native 15 model/service checks source hashes remain unchanged from build 7.

Independent native compositor captures use a settled synthetic fixture at three appearance settings.
Opaque color interiors are identical in all three. The 1,031,318-pixel image region is identical between
glass and opaque backgrounds; clear shows small rendered-edge differences (max 18, mean 0.0987 channel units,
2.63% of pixels), so full-scene identity is not claimed. Native text/buttons remain visible with system
ornament styling. XCTest manual full-screen capture was unsupported; its attachments are not visual proof.
The actual `simctl` compositor frames remain private. Temporary preference launch arguments were used only
in the simulator and removed by normal relaunch.

Initial tests rejected forward displacement of interactive content. Moving only the background backward
restored those interactions. A new test setup waited for the actual native numeric selection menu before
typing 1200; the exact value/crop/history assertions remain. Signed final build/analyze, separate probe SDK
compile, strict Release/permission/test-code boundaries and conflict-free exact source transfer passed.
[Foreground evidence](Validation/foreground-layering.json) retains failed runs and scope. Installation/
identity succeeded; normal hardware launch timed out as recorded above. No failing requirement was waived.

## Toolbar, window appearance and larger toolbox — build 7

The bottom magnifier now includes the current zoom. The redundant lower-left crop/zoom footer is removed;
source-pixel labels remain on the crop axes and transient Copy feedback remains visible. The native plain
window matches the Glass-family services frame: continuous 46-point corners and side/top/bottom insets of
22/34/26 points, with Apple's glass edge and no drawn stroke. A native title ornament preserves leading
filename/source details and document actions.

The always-available Settings gear opens native Opacity/Glass sliders, Reset Appearance and read-only
System Glass. Defaults are 0%/100%; preferences persist locally and affect backgrounds only. Reduce
Transparency forces opaque resolved presentation and disables edits without overwriting saved preferences.
That accessibility override is source-inspected, not separately exercised on hardware. The larger original
layered toolbox has a closed pitched roof, metal handle and two broken crop rulers; foreground coverage
increases 38.86%, with static-mask/catalog checks passing. Home View lighting/motion remain unobserved.

**Eleven native UI tests passed with zero failures in 277.766 seconds.** A caption-only fixed-size label
adjustment then passed the focused appearance case in 32.615 seconds. Fifteen actual native model/service
checks passed, including fractionally positioned annotation dimension/Undo, PNG/JPEG full-resolution
export, clipboard representations and Photos saves. Signed Release build/analyze, separate probe SDK
compilation, strict signature, icon/permission/test-code boundaries and conflict-free exact source transfer
passed. Build 7 was installed, normally launched and read back with matching identity/running process.
Core sources/tests are unchanged from the prior 42-test baseline and were not unnecessarily rerun.

Initial UI failures were corrected: the new plain window required canvas gestures on the visible image
layer; a typed width could truncate from near-300 to 299; automation needed native slider knob targets and
the actual combined Material accessibility label. The same gesture inputs create objects after the canvas
fix, bounded nearest-pixel display preserves the 300-pixel expectation, and assertions remain intact.
[Sanitized evidence](Validation/window-appearance-and-icon.json) retains failed/focused run outcomes. Final
UI runs completed normally; one earlier failed focused run stalled during diagnostics after assertions
finished and only that invocation was stopped. No failed required test was waived.

## Crop axes, title alignment and text targeting — build 6

The owner reported centered title/detail lines and a context menu treating the whole canvas as its target.
The title now shares a leading edge. Width/height badges follow the crop's horizontal/vertical edges,
show pixel-aligned source dimensions and remain display-sized during zoom. They do not intercept drags.
Ordinary text taps open Edit Text. Context menus belong to individual path-aware annotation targets;
their cropped previews reuse the complete redaction-safe renderer. Empty canvas has no annotation menu.

Ten unique native UI cases passed across two completed runs: the full suite passed nine and initially
failed one context case when it queried the canvas before popover dismissal completed. An explicit native
existence wait corrected test synchronization; the focused context retry passed all assertions in 28.195
seconds. No production dismissal workaround or weakened assertion was added. Axis values/Undo/Redo/zoom,
title alignment, direct text tapping, native menu/Edit Text, blank-canvas holding, existing handles, Copy
and Photos-save-before-close were exercised. Signed Release build/analyze, strict signature, icon/test-code/
permission boundaries and applied source hashes passed. Build 6 was installed, normally launched and
verified running with matching name/version/build. Core/service source hashes are unchanged from build 5;
the prior 42 core and 15 service checks were not unnecessarily repeated.

[Sanitized follow-up evidence](Validation/crop-text-follow-up.json) preserves both test outcomes. New
physical eye/hand behavior remains separate from simulator checks and normal launch verification.

## Editor and Glass icon update — build 5, October 15, 2026

The approved iteration is implemented, reviewed and applied. The image name now occupies the title bar,
with original dimensions and decoded type underneath. Crop/Annotate is in the native bottom ornament.
Close Image offers Save a Copy, Discard Changes and Cancel. Successful Files/Photos saves create flattened
PNG/JPEG copies; cancelled/failed saves and replacement imports preserve the current document. Editable
objects remain available throughout the open session, including after Copy/export.

The live canvas shares ordered Core Graphics/CoreText composition with full-resolution export. Annotations
remain visible in Crop. Selecting retained objects supports move/resize, line/arrow endpoints, duplicate,
ordering and deletion. Shapes groups seven tools; line, rounded rectangle, triangle and speech bubble are
new. Text creation opens a native popover with content, font, size, bold/italic/underline, alignment and
color controls. Shape fills and source-pixel geometry controls are available there too.

The red/light toolbox icon has face-attached crop/brush silhouettes and three distinct 1024-pixel planes.
[Editable SVG masters and recipe](../Tools/Icon/README.md) are self-contained; cobalt/charcoal proofs are
authoring comparisons. The native compiled catalog contains AppIcon/SolidImageStack. Flat proofs and
layer geometry were inspected; installed Home View lighting, clipping and motion have not been observed.

| Check | Final result |
|---|---|
| Core | **42 tests, three suites passed**; new shape/fill/hit, typography, Crop visibility, live/export pixels and preview-cache checks; prior privacy/input regressions remain green |
| Simulator model/services | **15 checks passed**; saved baseline/stale saves, failed/cancelled replacement, typography/arrangement plus actual PNG/JPEG export, pasteboard round-trip and Photos saves |
| Native UI | **Nine tests, zero failures, 207.941 seconds**; includes direct corner/endpoint edits and Undo, text/content/style/Undo, mode retention and Close Image save/cancel/discard |
| Device SDK | Signed main Release build/analyze and separate capture-probe device compile passed |
| Icon/Release boundary | Native icon catalog compiled without errors/warnings; strict signature passed; Debug fixture/service and probe code symbols absent; only add-only Photos usage description |
| Apply/deployment | Baseline conflict check passed; transferred code hashes match tested staging; **1.0 build 5** installed, launched normally and verified running with matching name/version/build |

Testing exposed and corrected stale text-popover requests, a missing visible Cancel in the original native
confirmation presentation, and premature per-digit font-size clamping. Native element-to-element handle
drags verify changed source-pixel values, an unchanged opposite endpoint and Undo restoration; earlier
coordinate-offset attempts targeted beyond source bounds. Localized text and separate ornament-coordinate
assumptions were corrected in automation. No failed required test was waived.

[The completed task](../memory-bank/261015_editor-polish-and-glass-icon-plan.md) and
[sanitized iteration evidence](Validation/editor-polish.json) preserve the final scope. This deployment
does not establish physical pinch/hold precision, icon lighting/parallax or large-image resource limits.
Historical audit/remediation results below remain associated with their original builds.

## Code inspection baseline — October 15, 2026

Inspection covered the editor, core pipeline, export/clipboard/Photos services, experimental capture target,
project settings, tests and icon-generation tool. Source was preserved during the review; regressions ran
in a temporary audit copy. The owner then authorized correction of the findings and a public-ready memory bank.

| Finding | Audit evidence and effect | Remediation acceptance |
|---|---|---|
| **High: transparent-image pixelation leaks fine detail** | `ImageRenderer` composited pixelation with default alpha blending. A 50%-transparent two-pixel checkerboard retained alternating values inside one block: PNG gray 128/64, JPEG gray 191/127. Both output cases failed the regression. | Replace affected underlying pixels; test PNG/JPEG and matching preview semantics. |
| **Medium: superseded exports continue** | `ExportView` detached rendering without propagating cancellation. A cancelled parent still completed a real export with worker cancellation false; rapid quality changes could overlap full-resolution buffers. Hardware memory exhaustion was not induced. | Propagate/check cancellation, debounce replacement work and serialize expensive exports. |
| **Medium: preview/export grid and layer order differ** | Export clipped before constructing the pixelation grid; preview used the full annotation. A crop-crossing block showed preview gray 68 versus export white 255. Canvas grouped all pixelation before other annotations while export used insertion order. | Share source-anchored grid/composition order, then clip rendering. |
| **Medium: extreme annotation values can trap** | Inspector converted `CGFloat` to `Int` without a safe bound. `Int.max` rounds to 2^63 as `CGFloat`, making the next getter invalid. The audit reproduced the invalid range without intentionally crashing a headset. | Validate finite bounded values and use safe display conversions. |
| **Medium: inspector/preset undo is inconsistent** | UI typing 800 then one Undo copied 80 × 1000 rather than 1600 × 1000 because each digit committed. Crop preset was stored outside undoable state. | Commit one inspector transaction and restore geometry/constraint together. |
| **Medium: annotation canvas UI target is unstable** | The image-canvas identifier was inherited by crop handles, then the queried Other elements disappeared in Annotate mode. Drawing tests failed before drawing. | Stable accessible canvas in both modes while preserving crop children; run interaction tests. |
| **Medium, experiment only: capture lifecycle races** | Async stream start/stop/picker callbacks lacked current-request guards across awaits and could overwrite newer state. This was source inspection; no hardware race was executed. The probe is separate from the editor. | Serialize transitions, invalidate generations and preserve stream/cleanup ownership; compile device path and keep hardware evidence separate. |

Small duplication existed in clipboard representation writes and Photos/file import request/busy/error
lifecycle handling. No substantial cloned production blocks were found in the normalized six-line scan.
No unfinished-marker or empty-production-function implementations were found. The text shape branch has
no geometric path by design because CoreText renders it. Phase 3 features remain outside implementation.

### Audit security scope

No web view, HTML/JavaScript evaluator, network client/listener, subprocess execution, backend, credential
literals or third-party package dependencies were identified in the application. There is no identified
XSS execution surface. This is source inspection and bounded local adversarial testing, not a comprehensive
penetration test of visionOS or Apple's decoders. Source preservation and metadata stripping passed existing
tests. Release requested only add-only Photos access; pasteboard writes were local-only. Debug fixtures,
service checks and the experimental capture target were excluded from the main Release application.

### Audit validation

- Existing core suite: **17 test definitions passed** on unchanged sources.
- Six temporary regression definitions: four reproduced findings 1–4, including five failing cases because
  transparent pixelation exercised PNG and JPEG. The other two rejected **64 malformed files and three forged
  oversized/invalid PNG headers**, preserving originals. Existing tests continued to pass.
- Native Release simulator build/analyze: **succeeded**. Warnings concerned skipped AppIntents metadata
  extraction because no AppIntents dependency exists; this is not absence-of-runtime-defects evidence.
- Existing UI suite executed **three tests: one passed, two failed, three failure assertions**. Photos picker
  open/cancel passed. Crop/undo/copy exposed the 80 × 1000 result; annotation testing hit the unstable target.
  Xcode report finalization stalled after the assertions completed. A build-for-testing result is weaker
  than this execution evidence and is not substituted for it.

Raw audit logs and fixtures were temporary local evidence and are not public repository artifacts.
Synthetic reproducible regressions and sanitized summaries are the appropriate durable evidence.

## Remediation verified and applied — October 15, 2026

All seven findings are addressed in the corrected sources. Pixelation replaces underlying alpha pixels;
preview/export share the source-anchored grid and insertion-ordered composition. Exports are debounced,
serialized and observe caller cancellation at pipeline boundaries. Inspector values are bounded before
integer conversion. Inspector changes form one undo operation; crop presets and surviving selection restore
correctly. The canvas has a stable accessible container with usable child controls. Clipboard/import request
handling is consolidated in its existing owners.

Capture transitions now serialize cleanup/start/stop, invalidate superseded completion and reject frames
from an older stream. Cleanup runs independently of cancelled startup and another source is blocked until
shutdown succeeds. Host lifecycle checks and device SDK compilation verify this implementation scope;
actual ScreenCaptureKit consent, streams, interruption and background behavior still require hardware tests.
Synchronous Apple decoding/drawing/encoding calls cannot be interrupted inside those calls; cancellation
checks run before/after stages and between annotations, and only one full-resolution export runs at a time.

| Check | Post-fix result |
|---|---|
| Core regressions | **34 tests, two suites passed**; includes encoded PNG/JPEG redaction/metadata, fractional pixelation boundaries, temporary storage/ownership, safe geometry/history and cancelled queued export |
| Adversarial inputs | **67 malformed/forged files rejected**, originals preserved; included in the core suite |
| Simulator model/services | **10 checks passed**: four undo/input regressions plus PNG/JPEG export, actual pasteboard data/UIImage round-trip and new Photos assets |
| Native UI | **Four tests passed, zero failures, 85.23 seconds**: Photos picker, crop typing/undo/redo/copy/export, real annotation drawing/editing/undo, preset undo/redo |
| Forced termination | Actual simulator SIGKILL left an export; the next normal launch removed abandoned source/export files and preserved an unrelated temporary file |
| Experimental lifecycle | **Three deterministic host checks passed** using the production transition queue; no system stream simulated |
| Native device SDK | Main Release build/analyze and final signed Release build passed; separate capture-probe device build passed |
| Release scope | No Debug fixture/service-check or capture-probe symbols; only add-only Photos usage description |
| Physical editor | **1.0 build 4 signed, installed, launched and found running** on Vision Pro |
| Public preparation | Owner signing team moved to ignored local override; self-contained docs/config; private-data scan and relative-link validation passed |

The full **AGENTS 2.1 project adaptation** and **16 populated memory-bank notes** are applied. Architecture,
local model, native UX rules, security, testing, deployment, decisions, current context/progress and task
history are linked from [the index](../memory-bank/toc.md). This is a project guide using the actual 2.1
structure, not a claim about a separate AGENTS 2.2 standard. Git was not initialized; nothing was committed
or published. License selection was open at that time; the owner chose MIT on October 22, 2026.

[The task record](../memory-bank/261015_security-remediation-and-memory-bank.md) and
[remediation.json](Validation/remediation.json) preserve the verified scope. Historical audit failures
remain evidence of what was corrected, rather than current failing tests.

## Privacy follow-up — October 15, 2026

The owner emphasized privacy and data integrity. Additional adversarial checks reproduced a second
pixelation leak at fractional source-pixel boundaries: both quarter- and three-quarter-pixel cases retained
underlying fine detail along an edge. Pixelation now rounds outward to cover every intersected source pixel
in shared preview/export rendering. Encoded PNG regressions verify replaced boundary pixels and unchanged
pixels outside the aligned region. PNG/JPEG alpha regressions verify the earlier replacement fix.

Export metadata tests first prove the source fixture contains GPS coordinates, then inspect the actual
encoded PNG and JPEG. Each output contains one image, no source GPS dictionary, no private EXIF comment
and no source TIFF camera make. Output is flattened rendered pixels without an attached original/edit layer;
pixelation still retains coarse visual information and is not a guarantee against contextual inference.

Private temporary roots now initialize once per process, purge only previous-process import/export roots,
and preserve live owners across multiple windows/repeated preparation. Source filenames are neutral.
Directories/files use 0700/0600 permissions, request complete file protection on visionOS and exclude the
roots from backup. Storage failures surface through the existing error UI. Ownership validation rejects
unowned paths before cleanup and rejects symbolic links before copying/protecting/loading; tests preserve
original bytes, permissions and sibling files. PNG/JPEG exports reimport successfully under neutral names.

An actual simulator SIGKILL test observed the abandoned export, then verified removal of it and an orphan
source on the next normal launch while an unrelated file survived. [Sanitized evidence](Validation/force-quit-cleanup.json)
records this. Cleanup cannot execute after force termination; immediate deletion or secure physical erasure
is not guaranteed. Locked-device protection and backup behavior have not been verified on physical hardware.

Clipboard writes remain explicit, local-only and use Apple's normal lifetime. There is no app clipboard
history or automatic expiry; copied content can remain available after the editor closes. An optional
expiry preference was asked but has not been answered, so it was not invented. PhotosPicker selection
requires no broad library access; save requests add-only permission. No new networking, telemetry,
dependency or capture entitlement was added.

Confirmed redaction leakage is a privacy/security defect. Integer traps, excessive memory pressure and
cancellation overlap are robustness/resource defects; no arbitrary-code-execution exploit was found or
claimed. The bounded malformed-file tests do not establish decoder exploit resistance. The final core and
signed device build/analyze include the fractional-boundary fix; the passing UI/service runs exercise the
final UI/storage changes and preceded that renderer-only correction.

## Initial implementation evidence — historical baseline

Native visionOS editor: system windows/controls, Photos and Files import, source-pixel crops/presets,
zoom/pan/exact dimensions, undo/redo, editable shape/arrow/freehand/text/pixelation, PNG clipboard,
PNG/JPEG ShareLink/FileDocument export and add-only Photos saving. The source is separate from its
2048-pixel maximum preview. Export uses full-resolution input; history holds no image buffers.

The isolated capture target implements a compiled system-picker/authorized-stream experiment and direct
in-memory frame-to-editor path. It is research, not a confirmed capture feature. See
[the capability matrix](CAPTURE_CAPABILITIES.md).

| Check | Actual baseline result |
|---|---|
| Core Swift tests | 17 tests / two suites passed, including parameterized orientation/preset/zoom/corner cases |
| EXIF orientation | All eight orientations, including mirrors and cropped regions, passed exact upright pixel checks |
| Large image | 8192 × 4096 source, preview ≤2048, 451 × 327 full-resolution crop, original bytes unchanged |
| Geometry/history | Letterboxing, crop canvas, zoom/pan round-trip, presets/anchors/clipping, bounded move and undo branching passed; audit later exposed inspector/preset semantics above |
| Annotation rendering | Translation/clipping, region isolation, text and move/resize/source coordinates passed; audit later exposed alpha/grid/order cases above |
| Encoding | PNG/JPEG type/dimensions, source-metadata exclusion, PNG alpha and JPEG white backdrop passed |
| Native simulator | Debug build installed/launched; empty editor, populated workspace, Photos picker and export sheet inspected |
| Simulator clipboard | PNG/JPEG written/read as actual pasteboard data and UIImage, decoded at 800 × 600 |
| Simulator Photos | New PNG and JPEG assets created using add-only authorization |
| Simulator services | Six checks passed using the same export/clipboard/Photos services as the UI |
| Release device target | Unsigned Release compile/link succeeded for native XROS / device family 7 |
| Debug exclusion | Release symbols contained no fixture or service-smoke code |
| Capture device target | Unsigned device build succeeded against actual ScreenCaptureKit SDK declarations |
| Physical Vision Pro | Signed install/launch/process verification passed for 1.0 build 2; editing acceptance pending |
| ChatGPT paste / share recipients | Not tested; clipboard round-trip is not recipient interoperability |

Historical machine-readable summaries are in [Validation](Validation/). Test images are synthetic,
explicit Debug fixtures and never load in normal startup or Release. Workspace screenshots remain local.

## Toolchain and validation limits

Initial toolchain: Xcode 27.2 / 27B5019j and SDK 27.2. Main deployment is visionOS 26; capture experiment
is visionOS 27. Restricted test/device access affected early checks; later approved device commands enabled
the physical deployment. Audit UI assertions subsequently executed with the results above.

Some initial temporary builds used a command-only Swift macro sandbox override and dwarf debug information
because of the execution environment. No application security entitlement or persisted production build
setting was weakened. Those compile checks were not archive/App Store validation. Use current build
commands and actual exit status for the corrected source rather than treating environment workarounds as
application architecture.

## Remaining acceptance

1. Build 28 is installed, identity verified, normally launched and running (October 24). Observe caption/scroll clearance, P3 palette colors through Copy/Export, rotated fields and glass/panel/handle/pinch behavior,
   responsive window/text sizes and Home View icon lighting/parallax on the headset. Deployment is complete;
   physical interaction/accessibility acceptance remains separate.
2. Photos → crop → Copy → ChatGPT has owner-confirmed repeated use. Check Files import and focused
   crop corner/preset, zoom/pan, exact-dimension and undo/redo coverage where not already exercised.
3. Add/move/resize/recolor/delete/undo annotations; compare pixelation/text/order and clipped output visually.
4. ChatGPT clipboard paste is owner-confirmed; on October 23 the owner also reported pasting into other
   apps (not named). Share-sheet delivery to specific recipients is not separately recorded.
5. The owner reported saving to Photos and to Files on October 23 (format, prompts and output details not
   recorded). Profile large screenshots and repeated imports/exports on hardware.
6. Run the separate probe on physical visionOS 27 hardware; observe consent/sources/frames/interruptions and
   update the capability matrix before broader capture integration.

**The primary success criterion is owner-confirmed. Phase 1 retains export/annotation/resource acceptance
checks beyond that workflow. Phase 2 remains pending
physical capture results. Capture-dependent Phase 3 automation, newest-screenshot detection and automatic handoff remain unimplemented; explicit Paste and keyboard conveniences are already part of the editor.**

## Mac Applications installation — November 5, 2026

Fresh canonical-ID Mac Release 1.0 (40) successfully built and installed in `/Applications/Glass Image Tools.app`.
Deep strict signature, four production sandbox grants, no debugger/test exceptions, matching privacy
manifest and exact installed/built contents verified. No app launch/closure or host GUI test; prior VM
functional checks retained. [Evidence](Validation/mac-applications-install.json).

