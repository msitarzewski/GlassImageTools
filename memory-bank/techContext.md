# Technology context

Updated November 5, 2026 for the native Mac extension; see the current task for exact new verification.

## Platform and targets

| Component | Configuration |
|---|---|
| Headset app | GlassImageTools, native visionOS 26.0 minimum, Swift 6, complete strict concurrency |
| Current app versions | Mac 1.0 (44), visionOS 1.0 (38); Mac-only toolbar override. Last confirmed headset identity remains 1.0 (36), October 31; build 37 delivery was blocked before install. |
| Mac app | GlassImageToolsMac, native macOS 26 minimum, App Sandbox/hardened runtime, shared VisionSnipCore module via VisionSnipCoreMac framework target |
| Mac tests | GlassImageToolsMacTests and GlassImageToolsMacUITests, native My Mac destination |
| License | MIT (`LICENSE`), chosen by the owner October 22, 2026 |
| Website | Static `site/`, Python 3.9+ build (`scripts/build_site.py`; pandoc renders PRIVACY.md), GitHub Pages via Actions pinned to release commits; no JavaScript, cookies or external loads |
| App Store | Privacy manifest `App/PrivacyInfo.xcprivacy` (user defaults `CA92.1` only); `ITSAppUsesNonExemptEncryption` NO; listing and answers in `Documentation/AppStore/`; nothing uploaded |
| Capture experiment | Separate GlassImageToolsCaptureProbe, visionOS 27.0 minimum |
| Project generation | Checked-in GlassImageTools.xcodeproj, project.yml source, XcodeGen 2.42.0 or later after settings/membership changes |
| Core package | Local VisionSnipCore, macOS 14 / visionOS 2 package baseline; app deployment target remains 26 |
| UI automation | Separate GlassImageToolsUITests bundle |
| Recorded build toolchain | Build 37 on November 3: Xcode 27.2 (27B52), standard installation selected explicitly; native checks on visionOS 27.2 simulator. October beta-toolchain observations below are historical. |

The October 19 default developer selection and beta override are historical. Build 37 explicitly used the standard Xcode installation without changing the global selection. Inspect current tools before a future rebuild; this November 4 documentation pass performs no fresh toolchain or SDK check.
[Build/deployment](build-deployment.md) owns reproducible commands and private signing boundaries.

## Current presentation

The identified plain WindowGroup and per-window EditorWindow own independent native minimum sizes.
EditorView composes a leading plain Images List with native category Buttons and conditional child rows, metadata/actions header, image workspace and
optional trailing Crop/annotation Form. Native controls and system modal surfaces remain; persistent
NavigationSplitView/NavigationStack containers were removed in build 21 because their extra material
prevented clear appearance settings. These are plain SwiftUI columns, not a claimed native inspector API
or draggable split-column implementation. The bottom system toolbar owns mode/tools/zoom/Pan/Settings.

One rear ImageWindowBackground owns native glass and black paint, continuous 46-point corners, depth/index
−1. Foreground stays at the interaction plane, index +1 and full view opacity. AppStorage Opacity/Glass
are independent, default 0/1, clamped to 0–1 with detents. Reduce Transparency resolves both to 1 without
rewriting preferences and disables appearance changes; hardware toggling remains a manual check.

The Images sidebar is 360 points (380 at accessibility sizes); the inspector is 380 (440). A 640-point
canvas minimum and visible columns determine window minimum width, with a 720-point floor. Minimum height
is 540, or 600 at accessibility sizes. Headers are 92 points; local content spacing replaces the old
whole-window inset wrapper. Native List/Form scroll backgrounds are hidden without clearing control/row
selection materials. Menu-style preset/font pickers work without a navigation stack.

A 32-point bottom-ornament clearance keeps the canvas, caption and scroll content above the system bottom
toolbar (build 23). Build 22's 65% black crop mask shares the image Canvas viewport clip; crop controls and labels remain
outside that clip in reserved margin space. It is a preview selection aid, never source/edit/export data.
The observed SDK 27.2 declarations mark inspector/navigationSubtitle and several navigation-background/
toolbar-spacing APIs unavailable on visionOS; source uses supported composition instead.
[Presentation ownership](systemPatterns.md), [release notes](../Documentation/RELEASE_NOTES.md).

## Frameworks and resource boundaries

SwiftUI supplies scenes, controls, Forms, sheets and system sharing. PhotosUI/CoreTransferable handle
selection/provider transfer; Photos requests add-only saving. UIKit supplies the pasteboard.
Foundation, ImageIO, Core Graphics and CoreText own local files, decoding, transforms and rendering.
No third-party runtime dependencies, backend, accounts or telemetry. Build 37 introduces explicit direct-HTTPS image-link downloads through ephemeral URLSession, with cookies/cache/credentials disabled; all edit/render work remains local.

FoundationModels supplies optional original-image captions, gated to visionOS 27 and real model/vision
capability. Only the bounded upright preview is attached; the service uses SystemLanguageModel without
an external-model fallback and permits one inference at a time. It generated real text for synthetic
pixels in the recorded physical service check; that is not editor appearance/semantic certification.
Caption state stays view-local and outside exports/history. No model is initialized by empty startup.

Rendering uses Display P3 for wide-gamut sources or annotation colors and sRGB otherwise, always 8-bit SDR.
Annotation colors are extended-range sRGB bounded to −2…2. Previews have a 2048-pixel maximum dimension. Shared serial import owns transfers before decoding and
checks a 256 MiB encoded-input cap; import limits are 100,000 per axis and 200 MP, export 100 MP.
Full-resolution exports are serialized off the main actor; canvas vectors remain live at display scale
with a bounded pixelation cache. Workspace retention is at most eight open/eight recent images and a
512 MiB unique source/preview budget. These are bounds, not physical peak-memory guarantees.
[Data model](data-model.md), [security](security.md).

## Signing and icon authoring

Config/Identity.xcconfig is public; optional Identity.local.xcconfig stays ignored. Developers provide
local team/bundle values. The main editor needs no special capture/enterprise entitlement; the recorded
Release requests only add-only Photos usage. Development signing is not distribution/archive evidence.
Debug fixtures/integration hooks require both Debug compilation and explicit testing arguments.

Tools/Icon contains editable layered SVG masters and the generation recipe. Local rsvg-convert is an
authoring tool, not an app dependency. Build 28 replaced the toolbox with the round picture icon: frame in
front, sun and hills in the middle, red glass behind, no drawn-in highlights; see the
[icon README](../Tools/Icon/README.md). Native
catalog/static proofs and earlier foreground-area measurements do not certify installed lighting/parallax.

## Historical technical references

Earlier top ornaments, inset framing, navigation-container property panes and left Tool Options were
superseded. Their actual results/failures remain in [builds 5–8](261015_editor-polish-and-glass-icon-plan.md),
[build 11](261016_apple-hig-fixes.md), [build 20](261018_sidebar-and-toolbar-refinement.md),
[build 21](261019_transparency-regression.md) and [build 22](261019_crop-dimming.md).
[Verified status](../Documentation/STATUS.md) owns current versus retained validation scopes.

## October 31 deployment tool observation

Installed Xcode reports 27.2 (27B52) at the standard application path. Deployment explicitly selected that toolchain; the earlier beta application path is absent. Existing signed build 35 was installed and launched without rebuilding; October 30 build/UI evidence retains its original toolchain and date.

Build 36 uses the October 31 installed Xcode 27.2 (27B52) for signed Release and native UI checks. The earlier beta-path build-35 toolchain evidence remains historical.

## Website and store authoring — October 31

The native app remains 1.0 (36). Canonical English listing fields are plain UTF-8 files under Documentation/AppStore/metadata; TestFlight copy is separate. Eight full-frame native RGB PNGs, owned SVG demo inputs and a screenshot provenance manifest are under that packet. `scripts/validate_store.py` uses only Python's standard library to check field budgets, PNG chunks/CRC, dimensions/alpha, hashes and candidate version. Seven developer-tool tests live under scripts/tests; they are not Swift core tests or runtime dependencies. Site media is derived from real normal-startup UI and actual copied output, using existing ImageMagick/rsvg authoring tools. The site's existing static builder is unchanged.

## Mac GUI test environment

Owner instruction, November 5: use the headless Mac VM for interactive testing, following the established
local Tart/SSH/Aqua driver. The verified guest is macOS 26.6.2 with Command Line Tools and an already
trusted AX helper. It runs the exact signed Release; no signing keys/profiles or whole source tree are
copied. A separate clean-template clone isolates this task from the existing shared VM; host graphics,
audio and clipboard sharing are disabled. Private driver/VM selectors and raw captures stay in `.brain`.
No full Xcode is installed in this guest; AX/pointer/clipboard checks are not XCTest runs. Native minimum
window width differed from the macOS 27 host, so layout assertions honor actual native constraints.
