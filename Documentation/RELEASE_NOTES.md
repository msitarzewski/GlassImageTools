# Glass Image Tools — release notes

Updated November 6, 2026. [Mac 1.0 downloads](https://github.com/msitarzewski/GlassImageTools/releases/tag/mac-v1.0) and the [website](https://msitarzewski.github.io/GlassImageTools/) are public; Vision Pro remains source-build only.

## Current builds: macOS 1.0 (45), visionOS 1.0 (38)

Native visionOS 26.0 or later and macOS 26.0 or later; Swift 6 and Apple frameworks. Mac build 45 is a universal Developer ID distribution, notarized and stapled, installed locally and published with DMG/ZIP/checksums. VisionOS build 38 was simulator-compiled; its previous signed build-37 product is retained. Installed identity 1.0 (36), normally launched without test arguments and independently verified one running app process. Earlier build 35 was installed and normally launched October 31 after its unreachable-device attempt October 30. Earlier build 31 was built and installed on October 26 (identity 1.0 (31));
it was normally launched and independently verified running on October 29 after unlock, without rebuild/reinstall. Build 30 was installed and normally launched on October 25.
Build 27 was never installed (the headset
was unreachable on October 23); its changes are in build 28.

### Latest changes

- **Mac build 45 — Quit and first Mac release:** native save confirmation precedes termination; Save runs through existing sheets before normal Quit. Cancel/retry, actual Save/Discard exit, sequential two-window PNG saves and original-byte preservation pass in the dedicated guest. Developer ID, universal sandboxed app, accepted/stapled app and DMG and Gatekeeper checks pass. Source/test builds and scoped limitations are in [the evidence](Validation/mac-quit-hang.json); [Mac release guide](MAC_RELEASE.md).

- **Mac build 44 — Smaller centered Markup:** older Preview proportions, native 28-point targets,
  compact symbols/Dividers and edge menu arrows. Row centering verified across modes, widths and
  inspector states, along with native actions and actual annotated PNG Copy.
  Installed in `/Applications/Glass Image Tools.app`; signature/tree readback verified. Prior bundle,
  host windows and other VMs preserved. [Evidence](Validation/mac-compact-centered-markup.json).

- **Mac build 43 — Preview Markup reference:** larger borderless controls, consistent 32-point targets,
  native menu arrows/20-point symbols and standard Dividers. Existing tool behavior and hide/show remain.
  Actual native guest actions, annotated 400 × 300 PNG Copy and signed builds verified.
  Installed in `/Applications/Glass Image Tools.app`; signature/tree readback verified, prior bundle and
  host windows preserved. [Evidence](Validation/mac-markup-reference.json).

- **Mac build 42 — Native toolbar layout:** Open Image before the title; standard grouped history,
  document and view actions; hideable Markup via toolbar, View menu and ⌘⇧M. Editing actions have native
  menu equivalents. Exact Release checked in the Mac VM, including annotated 400 × 300 PNG Copy.
  Installed in `/Applications/Glass Image Tools.app`; signature/exact tree verified, prior bundle and
  running host windows preserved. [Evidence](Validation/mac-native-toolbar.json).

- **Mac build 41 — Settings in the main toolbar:** native gear beside Inspector; no Settings-only
  accessory row when empty. Verified through native VM controls across image open/close and actual
  Settings opening. Installed in `/Applications/Glass Image Tools.app`, signature/product tree verified;
  no host app closure or launch. [Evidence](Validation/mac-settings-toolbar.json).

- **Mac build 40 installed:** freshly rebuilt canonical Mac app is at `/Applications/Glass Image Tools.app`.
  Signed contents/version/sandbox grants verified; existing windows preserved. [Install evidence](Validation/mac-applications-install.json).

- **Mac build 40 — match Vision Pro's editing toolbar:** mode/contextual tools/zoom/settings in the same
  order; Shapes is grouped, Draw/Text/Pixelate are separate, and Crop has preset/dimensions/rotation.
  Native Mac accessory placement. Verified in the headless VM with actual rotated crop PNG output.
  Corrects build 39's expanded-shape interpretation. [Evidence](Validation/mac-toolbar-parity.json).

- **Mac build 39 — direct markup toolbar:** native accessory row exposes Select, every shape, Drawing,
  Text and Pixelation; native selection and existing inspector/Undo/source-pixel behavior. Verified in
  a headless macOS 26.6.2 VM using the exact signed Release, native gestures/controls and actual PNG
  clipboard pixels. Core and visionOS source unchanged. Future Mac GUI checks use the VM. [Evidence](Validation/mac-markup-toolbar.json).

- **Build 38 — native Mac preview:** native sidebar/inspector, toolbar/menu/Settings, shared crop and editable annotations, image/HTTPS Paste, actual Mac clipboard, PNG/JPEG and native Save As. App Sandbox limits access to selected files, explicit outgoing requests and Photos operations. Unsaved image/window/quit flows offer Save/Discard/Cancel. 78 core, six Mac service and seven distinct Mac UI cases pass across recorded runs; Release/analyze/signature, normal sandbox denial and visionOS compilation pass. Mac Photos/Share/accessibility/performance and distribution remain separate. [Evidence](Validation/native-sandboxed-mac.json).

- **Build 37 — Paste an image link:** native Paste accepts a direct HTTPS image URL or one copied as text, downloads into protected local image ownership, then uses the existing full-resolution editor. Bounded transfer, cancellation and useful webpage/authentication failure recovery; privacy/site/store text updated for explicit acquisition networking. Core 78/5 and eight native cases pass, including actual HTTPS download/PNG Copy. Signed Release/analyze/signature pass. Installation did not start: the paired headset’s developer tunnel is unavailable; the pre-install lock-state request failed with CoreDevice 4016. Last verified installed/normal-launch checkpoint remains 1.0 (36), October 31. Signed build 37 is ready for the already-authorized installation when the headset reconnects. [Evidence](Validation/paste-image-links.json).

- **Website and Apple packet (content-only):** current native-interface pictures, empty Photos/Files/Paste well and compact sidebar documentation; new App Review/TestFlight text and eight native 4K store screenshots. Listing/media validation and seven utility tests pass; site checks pass. [Preparation and submission gaps](AppStore/README.md). No new app build, publication or upload.

- **Build 36 — Apple default List controls:** category buttons inherit automatic List styling; the category-only borderless/rounded-rectangle overrides are removed. Compact document rows and system selection remain. Four focused UI cases and signed Release pass. [Exact evidence](Validation/default-list-styling.json).

- **Build 35 — compact image rows:** single-line filenames and small image symbols replace thumbnail/metadata previews in Open Images and Recents; native selection and accessible type/edit status remain. Three focused UI cases and signed Release pass. [Exact evidence](Validation/compact-sidebar-rows.json).

- **Build 34 — sidebar hierarchy:**
  - Tinted photo-stack/clock symbols, counts, full disclosure rows and indented image entries replace bare section headers. Open Images starts expanded and Recents collapsed; the heading is quieter.
  - Uses a native plain List and borderless Buttons; no custom painted selection or extra window material. The initial inline DisclosureGroup candidate was rejected by runtime tests.
  - Installed identity 1.0 (34); normal launch waits for device unlock. Five focused UI cases pass, exit 0 (157 s), on the final signed source. [Exact results](Validation/sidebar-hierarchy.json). Physical appearance/input acceptance remains separate.

- **Builds 32–33 — native start screen and Images sidebar:**
  - Large native Photos and Files wells, plus an image drop well. The owner replaced build 32's blue Paste button with a full gray well: tap it or press ⌘V in the empty workspace to paste.
  - Standard List selection and expandable sections; Open Images starts expanded and Recents collapsed. Each document is one accessible item.
  - Protected file/data provider imports preserve original bytes, names and source pixels. Unnamed drops use Dropped Image. The existing glass background remains the only rear surface.
  - Installed and normally launched on the headset; identity 1.0 (33), exactly one running app process, all commands exit 0. Core 69/5; 5 focused UI cases pass across two runs on identical final production source; corrected-selector follow-up native exit 0 (127 s); synthetic drag skipped because the gesture never started a system drag. [Exact evidence and remaining checks](Validation/native-start-and-sidebar.json).

- **Build 31 — About:**
  - Settings has an About page, like AutoPaper's: the icon, the version, what the app is for, who made it
    and why, links to the website's home, privacy and help pages, and the MIT license.
  - An ⓘ button at the top of Settings opens it. The sheet is now called Settings rather than Appearance;
    the sliders are where they were.

- **Build 30 — the app's permanent ID:**
  - The bundle identifier is now `com.glassimagetools`, like Glass Power Tools' `com.glasspowertools`. It's
    the ID the App Store will know the app by, and it can't change once the App Store record exists.
  - To visionOS this is a new app: it installs beside earlier builds instead of replacing them, starts with
    the default Opacity and Glass settings, and asks again before saving to Photos. Delete the older copy.
  - Nothing else changed.

- **Build 29 — paperwork for TestFlight and the App Store:**
  - The app carries the privacy manifest Apple requires: no tracking and no data collected, and one
    declared reason, for the window's appearance settings.
  - It tells App Store Connect it has no encryption of its own, so uploads skip the export question.
  - The privacy page explains what Apple's TestFlight and App Store pass to the author: TestFlight's crash
    logs, usage information and feedback, with names unless you joined by public link; the App Store's
    crash data only if you share analytics with developers.
  - The App Store listing, review notes and App Store Connect answers are written
    ([App Store folder](AppStore/README.md)). Nothing is uploaded, and nothing changes on screen.

- **Build 28 — a new icon:**
  - The icon is a round picture: a white sun and hills on red glass, in a silver frame that fills the
    circle. It replaces the red toolbox, which the owner found sharp.
  - It's built for Vision Pro's layered icons: the frame is the nearest layer, the sun and hills float in
    the middle and the red glass sits behind, so the system's depth, shadows and highlights work on each
    part. The website's icons and sharing image use it too.
  - The app itself is unchanged from build 27.

- **Build 27 — a plain + and tighter sidebar rows:**
  - The + at the top left is a round button that opens the menu, with no chevron crowding the image name.
  - The Images sidebar's rows are compact, like the Glass Power Tools terminal sidebar on Vision Pro:
    a light tint on the image you're viewing and a highlight when you look at a row, instead of a large
    panel. Open Images and Recents still expand and collapse; Close Image is in each row's menu.
  - The website screenshots show the new design, and the home page no longer lists testing status;
    the README and [verified status](STATUS.md) keep it.
  - Owner-reported on October 23: a hardware keyboard, saving to Photos and Files, and pasting into apps
    other than ChatGPT work on the headset.

- **Build 26 — icon colors, license and website:**
  - The toolbox icon uses AudioPaper's red and silver, matching its sibling app.
  - The project is MIT-licensed and has a website for GitHub Pages (`site/`): Home, Help, Reference,
    Privacy and Credits, with screenshots taken from the app in the simulator. It is not published yet.
  - New `PRIVACY.md`, `SECURITY.md`, `CONTRIBUTING.md` and a public README. The app itself is unchanged.

- **Build 25 — one tool group:** Undo, Redo, Copy, Share, Export and the inspector button share one
  capsule at the top right, and the close button (×) moved to the upper-right corner, giving the image a
  little more room.

- **Build 24 — toolbar, sidebar and inspector:**
  - Copy works like Share › Copy: no blocking overlay, the same clipboard item, and Universal Clipboard
    can carry it to your other devices.
  - **+** is one menu: New Window, Choose from Photos…, Import from Files… and Paste. ⌘N opens a window
    and ⌘, opens Settings from a hardware keyboard.
  - **Text** and **Pixelate** add a new, selected object at the center of the crop; the inspector no
    longer has Add at Center.
  - The inspector has one title (the object, "New …" for a tool's style, or No Selection), content before
    style, and stroke width on one row.
  - The Images sidebar is wider (360 points) and previews are as tall as their two lines of text.
  - ⌘V does not paste an image; use **+ › Paste**.

- **Build 23 — review fixes and caption clearance:**
  - The caption, canvas status and inspector/sidebar scroll endings stay above the bottom toolbar, and
    the caption aligns with the canvas edge.
  - Vivid (Display P3) palette colors no longer break drawing or Copy/Export; wide-color screenshots and
    colors export as Display P3, everything else stays sRGB.
  - After Rotate Left, annotation fields and spoken values follow the rotated view.
  - Captions appear once a busy or still-preparing on-device model is ready.
  - Undo is available while an inspector edit is pending; pinch zoom stays under your fingers.
  - Width/Height and Left/Top share a row again in the inspector (labels above values).

- **Build 22 — crop-area dimming:** stronger 65% black outside-selection mask. The selected region,
  handles and labels stay bright. Only the mask shares the image Canvas viewport clip, preventing
  zoomed shading from covering reserved margins. Preview shading never enters exported pixels.
- **Build 21 — restored window transparency:** one rear native glass/paint surface controls Opacity
  and Glass across the workspace. Plain SwiftUI columns retain native Lists, disclosures, Forms,
  Buttons, Menus and ControlGroups; system modal surfaces and the bottom toolbar remain.
- **Builds 19–20 — documents and properties:** leading Images navigation with expanded Open Images
  and initially collapsed session Recents; separate trailing contextual inspector with in-pane Done.
  Each image retains its Undo/viewport. + opens another window with acquisition choices; the caret
  imports Photos, Files or explicit Paste into the current workspace. Circular Close Image keeps
  Save a Copy / Discard / Cancel recovery.

### Included editor workflow

Photos/Files/Paste → source-pixel crop → optional editable vector annotations → Copy, Share or save a
new PNG/JPEG. Zoom/Pan, crop presets and exact fields, rotation and Undo/Redo remain. Shapes, freehand,
editable text/typography, native color wells and pixelation stay editable during the open session.
Saved images reopen flattened; Recents is window/session-only. No durable editable project format.

The source filename, original dimensions/type and bottom zoom/mode controls remain visible. Available
original-image descriptions use Apple's on-device model on visionOS 27 with real capability checks;
no caption placeholder appears while unavailable/loading, and captions never enter edited output/history.
No backend, accounts, analytics or third-party runtime dependency is introduced.

## Recorded validation

| Scope | Last evidence | Result and limit |
|---|---|---|
| Build-31 physical launch | [Deployment record](Validation/physical-deployment.json) | October 29: unlocked, installed identity 1.0 (31), normal launch exit 0, independent process query finds exactly one app process. No rebuild/reinstall/test arguments. About-page appearance/input remain unobserved. |
| Build-26 icon, site and Release | [Website, icon, license](Validation/website-icon-and-license.json) | Core 67/5; icon catalog compiles; site links, 390 px width and Lighthouse 100s; privacy scan clean; signed Release 1.0 (26) passes. UI suite not rerun (app sources identical to build 25). |
| Build-26 physical | [Deployment record](Validation/physical-deployment.json) | Installed (retry exit 0), identity 1.0 (26); launch pending headset unlock. |
| Build-25 full UI suite | [Title-bar group](Validation/titlebar-tool-group.json) | 37 cases, 0 failures, exit 0 (1,223 s) on the final applied source; core 67/5 and 50 native checks pass. |
| Build-25 Release and physical | [Deployment record](Validation/physical-deployment.json) | Build/analyze/signature/privacy pass; installed, identity 1.0 (25), normal launch exit 0, exactly one process. |
| Build-24 full UI suite | [Toolbar/sidebar/inspector](Validation/toolbar-sidebar-and-inspector.json) | 37 cases, 0 failures, exit 0 (1,173 s) on the final applied source. Earlier runs' reveal-helper, row-layout and stale test-geometry failures fixed; gesture cases compared with build 23. |
| Build-24 core and services | [Toolbar/sidebar/inspector](Validation/toolbar-sidebar-and-inspector.json) | 67 core tests/5 suites (core unchanged); 50 native service checks including Text/Pixelate placement and non-blocking Copy. |
| Build-24 Release | [Toolbar/sidebar/inspector](Validation/toolbar-sidebar-and-inspector.json) | Build/analyze exit 0; strict signature; add-only Photos only; no Debug markers; probe compiles. |
| Build-24 physical | [Deployment record](Validation/physical-deployment.json) | Installed, identity 1.0 (24); headset locked, normal launch not yet observed. |
| Build-23 full UI suite | [Review fixes](Validation/review-fixes.json) | 37 cases, 0 failures, exit 0 (1,254 s), clean finalization, on the final applied source. Seven earlier failures reproduced on build 22 were fixed. |
| Build-23 core and services | [Review fixes](Validation/review-fixes.json) | 67 core tests/5 suites; 48 native service checks including P3 colors, rotated fields, pending Undo and zoom anchoring. |
| Build-23 Release | [Review fixes](Validation/review-fixes.json) | Build/analyze exit 0; strict signature; add-only Photos only; no Debug markers; probe compiles. |
| Build-23 physical | [Deployment record](Validation/physical-deployment.json) | Installed, identity 1.0 (23), normal launch exit 0, exactly one process. |
| Final build-22 crop UI | [Crop dimming](Validation/crop-dimming.json) | Two cases, zero assertion failures; crop fields, reachable controls, zoom/Pan drags, rotation, actual Copy and Undo. Xcode report finalization stalled; native exit −15 after completed assertions. No clean UI-command claim. |
| Build-22 Release build/analyze | [Crop dimming](Validation/crop-dimming.json) | Exit 0; strict signature, native device family, add-only Photos usage and Debug/probe exclusion pass. One expected AppIntents metadata skip. |
| Build-21 window/editor baseline | [Window transparency](Validation/window-transparency-restoration.json) | Six distinct final-source UI cases pass across stages; final four-case command exits 0. Native all-issue app audits retain their tested scope. No full-suite claim. |
| Native model/services | [Build-21 evidence](Validation/window-transparency-restoration.json) | 42 checks pass; unchanged owners retained for build 22, not rerun there. |
| Core geometry/rendering/history | [Build-19 evidence](Validation/document-sidebar-and-inspector.json) | 62 tests/four suites pass; unchanged core/tests retained through build 22, not rerun for presentation-only changes. |
| Physical installation | [Deployment record](Validation/physical-deployment.json) | Build 22 installed and identity verified; normal launch/process not observed. Earlier build-20 successful launch remains historical. |

Simulator compositor inspection confirms crop-mask alignment/clear margins and the prior clear, opaque
and native-glass window states. It is not automated pixel-equivalence proof or a physical-input audit.
The owner previously reported repeated Photos → crop → Copy → ChatGPT use; no compatible ChatGPT share
extension or broader recipient behavior is inferred.

## Known limits and release follow-up

- Observe Copy against Share › Copy (including
  Universal Clipboard), the + menu, Text/Pixelate placement, the inspector and sidebar previews, plus the
  build-23 items: ornament clearance, a vivid P3 palette pick, rotated fields and pinch-zoom anchoring.
- ⌘V image paste works in the empty workspace (build 33); use + › Paste when an image is already open. Physical keyboard/focus still need scoped headset acceptance.
- Observe the new icon's lighting, depth and movement in the Home View. On October 25 the owner's headset
  screenshot of build 29 showed the round +, the sidebar rows, the grouped title bar and close button, and
  a crop copied at 563 × 497: "Really nice."
- Complete hardware appearance/gaze/hand, VoiceOver/Voice Control/focus/keyboard-only navigation, Reduce
  Motion and Reduce Transparency checks. Exercise large screenshots/repeated work with resource profiling.
  The owner reported a hardware keyboard, Photos/Files saving and pasting into other apps working
  (October 23); output/privacy details of those saves were not separately recorded.
- Capture is an isolated experiment. Device-SDK compilation is recorded; no physical capture path,
  system-wide source, passthrough or automatic screenshot handoff is confirmed.
- No archive/distribution-signing validation, TestFlight/App Store submission or public release is
  recorded. Build 29 adds the privacy manifest, the encryption key and the listing
  ([App Store folder](AppStore/README.md)); the archive, the Organizer privacy report and the upload come next. Development `get-task-allow` is not distribution evidence. The license is MIT (owner
  decision, October 22). Git initialization, commits, publishing the website and TestFlight require
  their own instruction.

[Verified status](STATUS.md), [capture matrix](CAPTURE_CAPABILITIES.md),
[build/deployment](../memory-bank/build-deployment.md) and
[October task history](../memory-bank/tasks/2026-10/README.md) retain exact scope and prior outcomes.
