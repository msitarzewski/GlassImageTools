# Build and deployment

## Current delivery handoff — refreshed November 4, 2026

Build 37 is the successful signed local product; its November 3 core/native/Release evidence is in [the task](261103_paste-image-links.md) and [verified status](../Documentation/STATUS.md). The current source still matches the recorded build-input hashes, and the product remains present. This refresh did not rebuild or revalidate the signature.

The November 3 pre-install lock-state query failed with CoreDevice 4016; a subsequent inventory showed the target paired but its developer tunnel unavailable. Installation and normal launch were never attempted. This was a device-connectivity failure, not an approval rejection. Build 36, verified October 31, remains the last confirmed installed identity. No fresh device query was made November 4.

The owner uses the Mac remotely; a working terminal session does not establish an available paired developer connection. When delivery resumes, use the existing authorized route and `.brain/image-link-stage.local.json`: check current connectivity and tested-source/product identity, install the successful product, then read back version/build, normal launch and one running process. Do not request installation permission again. Capture probes, distribution archives, App Store uploads and publication keep their separate evidence/authorization boundaries.

The current 39-entry portable Apple data/media packet is for 1.0 (37), with eight native screenshots and the HTTPS download privacy updates. Its extracted validation passed November 3; its checksum still matches at this refresh. Older build-36 packet is historical. No distribution archive/upload is claimed.

The dated sections below preserve earlier checkpoints; they are not current-device observations.

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

## Historical recorded product — build 34, October 29, 2026

Installed identity 1.0 (34); normal launch waits for device unlock. Five focused UI cases pass, exit 0 (157 s), on the final signed source. Signed Release/analyze/signature/boundaries pass; final applied source matches UI/release inputs. Core unchanged (69/5 baseline). The task-owned simulator is stopped. [Sidebar task](261029_sidebar-hierarchy.md), [evidence](../Documentation/Validation/sidebar-hierarchy.json).

## Previous recorded product — build 33, October 29, 2026

Installed and normally launched on the headset; identity 1.0 (33), exactly one running app process, all commands exit 0. Native start/sidebar and whole-well Paste: [task](261029_native-start-and-sidebar.md). Signed Release build/analyze and strict signature pass; source hashes match applied source. Core 69/5; 5 focused UI cases pass across two runs on identical final production source; corrected-selector follow-up native exit 0 (127 s); synthetic drag skipped because the gesture never started a system drag. Build 32 was installed and normally launched before the owner's follow-up. The standalone capture target compiles with final build-33 source; this does not establish capture capability. The task-owned simulator is shut down after testing.
[Evidence](../Documentation/Validation/native-start-and-sidebar.json).

## Previous recorded product — build 31, launch verified October 29, 2026

Project/source is **1.0 (31)**: Settings → About ([task](261026_about-settings.md)). Signed Release
build/analyze exit 0 (73 s): strict signature, `com.glassimagetools` 1.0 (31), framework
`com.glassimagetools.core`, add-only Photos, the manifest, encryption key false, no Debug markers, the About
image in `Assets.car`. Installation October 26 exited 0 (1 s), identity 1.0 (31). Initial launch and
October 28 retry timed out while the headset required its passcode. On October 29 the owner reported it
available: lockState exit 0/no passcode, identity exit 0 (0.513 s), normal launch exit 0 (1.375 s),
independent process query exit 0 (1.756 s), exactly one app process. **Installed and verified running.**
No rebuild, reinstall, forced termination or test arguments. [Launch follow-up](261029_build31-launch.md).
This does not certify Settings/About physical appearance or input. The owner removed build 29 (`com.glasspowertools.visionsnip`); no app answers to that identifier.

A locked headset accepts an install but not a launch; check `passcodeRequired` in `lockState` first and bound
the launch with a timeout.

Build 30 (October 25): bundle identifier `com.glassimagetools` (set in `Config/Identity.xcconfig`; it
was `com.glasspowertools.visionsnip`). Signed Release build/analyze exit 0: strict signature, framework
`com.glassimagetools.core`, add-only Photos, the manifest, encryption key false, no Debug markers. lockState
exit 0; install exit 0; identity 1.0 (30); normal launch exit 0. **Installed and launched.** A new identifier
is a new app, so it installed beside build 29 until the owner removed that copy.
[Build 30 section](#the-bundle-identifier--build-30).

Build 29 (October 25): the signed Release build/analyze passed: strict signature, add-only Photos, the
privacy manifest at the bundle root, `ITSAppUsesNonExemptEncryption` false and no Debug markers. A simulator
install and launch passed. `lockState` and one bounded install attempt first returned CoreDevice error 4016
(unreachable); once the owner woke the headset: lockState exit 0 (no passcode required), install exit 0,
identity 1.0 (29), normal launch exit 0, one running process. **Installed and launched**; build 30 joined it
under the new identifier.
[Build 29 section](#app-store-preparation--build-29).

Build 28 (October 24) was **installed and launched**; build 29 replaced it. The signed Release build/analyze passed (49 s,
strict signature, add-only Photos, no Debug markers). `devicectl device info lockState` first failed with
CoreDevice error 4016 (device unreachable), as it had for build 27 on October 23; once the owner woke the
headset: install exit 0 (7 s), identity 1.0 (28), normal launch exit 0, one running process. [Build 28 section](#round-picture-icon--build-28),
[physical evidence](../Documentation/Validation/physical-deployment.json).

Build 26: the signed Release product was installed: the first attempt reported a
dropped device connection (exit 1) after the transfer, though the app list already read 1.0 (26); the
retry exited 0 (1 s). Identity read back as Glass Image Tools 1.0 (26). The headset required its passcode,
so normal launch and the running process are pending unlock. Builds 21–26 selected the installed Xcode
27.2 beta with `DEVELOPER_DIR`; the global selection was not changed. The private pointer is
`.brain/current-deployment.local.json`. [Build 26 section](#website-icon-colors-and-license--build-26).

[Release notes](../Documentation/RELEASE_NOTES.md) distinguish development Release configuration from
unverified archive/distribution signing, TestFlight/App Store submission and publication. Older product/
launch sections below are historical. Raw product/target/output stays ignored; only sanitized results
belong in [physical evidence](../Documentation/Validation/physical-deployment.json).


## Prerequisites and inspection

Use Xcode with the required visionOS SDK installed. The initial observed toolchain was Xcode 27.2 and
visionOS SDK 27.2. Inspect current tools rather than assuming a newly selected Xcode matches that setup:

```sh
xcodebuild -version
xcodebuild -showsdks
xcrun --sdk xros --show-sdk-path
xcrun simctl list devices available
xcrun devicectl list devices
```

Device/account listing output contains private details. Keep raw output out of the repository and publish
only a sanitized outcome when needed. A paired/unlocked headset with developer access is required for
physical installation. Tool/sandbox access and the app's entitlements are separate concerns.

## Project and simulator

Open the checked-in `GlassImageTools.xcodeproj`; choose `GlassImageTools`. `project.yml` is the source
for generation. Use XcodeGen 2.42.0 or newer only after target membership/settings change:

```sh
xcodegen generate
swift test
xcodebuild -project GlassImageTools.xcodeproj -scheme GlassImageTools   -destination 'generic/platform=visionOS Simulator' -derivedDataPath /tmp/GlassImageTools-build build
```

Read command exit status and inspect warnings. Use the selected simulator's real identifier locally to
install/run if needed; never add its identifier, data-container path or screenshots of surrounding apps
to tracked notes. Native UI tests require a concrete simulator destination, not a generic destination.

## Local signing configuration

Create ignored `Config/Identity.local.xcconfig` for your own team and unique bundle identifier. The keys
are `DEVELOPMENT_TEAM` and `VISIONSNIP_BUNDLE_ID`; fill them using your local Xcode account. The public
base configuration must contain no personal signing team. Automatic signing creates the needed local
profiles; do not commit profiles, certificates, keys, Xcode account exports or signed app bundles.

The main editor needs no capture, camera, microphone or enterprise entitlement. Do not add one to solve
a shell/account-access error. Photos saving requests add-only access at the operation.

## Authorized physical deployment

The owner has authorized signing, building, installing and launching on their Vision Pro. Use supported
approved device/signing execution where needed. This authorization persists; do not ask again merely
because a session restarted. Publishing or installing on an unrelated person's device is a separate action.

Build into fresh derived data and install only after the signed build succeeds. Locally set
`VISION_PRO_DEVICE_ID` from device discovery; it is a shell variable, never a tracked value:

```sh
xcodebuild -project GlassImageTools.xcodeproj -scheme GlassImageTools -configuration Release   -destination 'generic/platform=visionOS' -derivedDataPath /tmp/GlassImageTools-device   -allowProvisioningUpdates build analyze
APP=/tmp/GlassImageTools-device/Build/Products/Release-xros/GlassImageTools.app
codesign --verify --deep --strict "$APP"
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Info.plist")
xcrun devicectl device install app --device "$VISION_PRO_DEVICE_ID" "$APP"
xcrun devicectl device info apps --device "$VISION_PRO_DEVICE_ID" --bundle-id "$BUNDLE_ID"
xcrun devicectl device info lockState --device "$VISION_PRO_DEVICE_ID"
# Launch only when lockState reports passcodeRequired false:
xcrun devicectl device process launch --device "$VISION_PRO_DEVICE_ID" --terminate-existing "$BUNDLE_ID"
xcrun devicectl device info processes --device "$VISION_PRO_DEVICE_ID"
```

Builds 21–25 prefixed these commands with `DEVELOPER_DIR` set to the installed Xcode beta. Before
installing, also confirm the product is the new build: read its short version and build with PlistBuddy,
then scan it with `strings` for Debug-only test markers, which must be absent. Read back the installed
display name, short version and build, and record a sanitized summary of the build, signature, install,
launch and identity results. Do not treat an old derived-data product as the new build or use test launch
arguments for ordinary user deployment.

Installing terminates a running copy of the app, so any open, unsaved image in it is lost. Build 25
replaced the owner's running build 24 this way. Mention it in the report. A locked headset is recorded as
"launch pending" and is not retried.

Installation/launch does not prove eye/hand precision, Photos/Files editing/saving, ChatGPT paste, recipient
share extensions, resource behavior or capture. Record those as separate hardware acceptance checks.

## Experimental capture target

Choose `GlassImageToolsCaptureProbe`, deployment visionOS 27, only for explicitly scoped capture research.
The installed simulator SDK lacks ScreenCaptureKit; a simulator limitation view is expected. A device build
proves API compilation, not permitted sources or stream delivery. Use [the capability matrix](../Documentation/CAPTURE_CAPABILITIES.md)
and record actual consent, selection, frame, interruption/background and lifecycle results on hardware.

## Idle paired connection versus launch verification

A paired headset can list its tunnel as disconnected while idle. Match the previously authorized identity,
then let the supported installation command establish its own connection with a bounded timeout. Build 8
installed and read back successfully through that route; disconnected listing alone was not a blocker.
Normal launch is a separate operation: its 40/30-second timeouts and missing process readback were retained
rather than inferred successful from installation. Check awake/unlocked state when launch cannot complete;
do not re-request deployment permission already granted or alter unrelated device configuration.

At the historical build 8 handoff, developer mode/services were available but the timeout cause was not established.
Retry normal launch and process readback when the headset is available; the signed build and installed
identity are already verified. Do not rebuild, re-sign or reinstall unchanged code as a substitute for
that check. A later successful result must update [active context](activeContext.md),
[verified status](../Documentation/STATUS.md) and [physical evidence](../Documentation/Validation/physical-deployment.json).

## Historical build 10 deployment

Build10 is installed and identity-verified; normal launch verification awaits headset unlock. The normal launch request timed out after 35 seconds; the completed subsequent process query found no matching app. A subsequent lock-state query reports passcode required, so unlock the headset before resuming launch verification. The earlier client option-order error occurred before a remote request and is retained separately.
The command line accepts app arguments after the bundle identifier, so put all devicectl launch options
before that positional value. A client option-order error is not a remote application launch. Use normal
bundle launch without testing arguments; do not reuse the earlier invalid optional persistent identifier.
Installed identity and any later successful process observation must update the current status/evidence.
Raw target/product/output remains ignored. [Physical record](../Documentation/Validation/physical-deployment.json).

## Historical prepared build 11 — HIG follow-up

Reviewed source/test/project changes are applied; development-signed Release 1.0 (11) passed build/analyze,
strict signature and Release/permission boundaries. The exact prepared product path remains in ignored
`.brain/hig-fixes-stage.local.json`. No physical-device call occurred while the owner was unavailable.
Build 10 remains the verified installed identity; its launch/unlock history above remains historical.
When available, install the prepared build 11 and verify normal launch, installed name/version/build and
process state under the existing authorization. Preparation must not be reported as installation.

Only development-signing application/team identifiers and `get-task-allow` are present; this is not an
App Store distribution product. No new permission or capture entitlement was introduced. Isolated native
save regressions pregranted only add-only Photos; first-run user consent still needs manual validation.
The isolated simulator's original contrast and normal launch were restored. Commands/limits are recorded
in [validation](../Documentation/Validation/hig-fixes.json); never publish raw signing or device output.

## Build 12 implementation preparation checkpoint

Four reviewed source/test/project files are applied. Final development-signed Release 1.0 (12) passed
build/analyze, strict signature and Release/privacy boundaries. Exact prepared product is referenced by
ignored `.brain/native-chrome-stage.local.json`. No device call occurred; build 10 remains verified
installed. When the owner/headset is available, install the prepared build 12 under existing authorization
and verify normal launch/identity/process. Do not install build 11 merely because its older product exists.
The isolated simulator was restored to original contrast and normal launch after synthetic preview.
[Current task](261016_native-glass-chrome.md), [validation](../Documentation/Validation/native-glass-chrome.json).

## Previous physical deployment — build 12

Owner-requested installation/normal launch is complete. Reused prepared signed Release 1.0 (12) after
current-source/product identity checks and fresh strict signature verification. Installation passed in
2.851 seconds; actual installed name/version/build readback passed. Normal bundle launch without test
arguments passed in 1.238 seconds; independent process readback found exactly one matching executable.
All commands exited 0. This supersedes the old build-10 unlock wait. No unchanged rebuild/reinstall or
additional permission is needed. Exact target/output remains ignored; [physical evidence](../Documentation/Validation/physical-deployment.json)
owns the sanitized result/history. Hardware interaction/material/recipient/resource checks remain separate.

## Previous physical deployment — build 13

The menu-caret follow-up is applied and installed under existing authorization. Final UI/Release/applied
source hashes match; signed build/analyze and fresh strict signature passed. Actual installed Glass Image
Tools 1.0 (13) identity readback passed. Installation took 2.819 seconds; normal launch without test arguments
took 0.521 seconds; an independent process query found exactly one matching executable. All exited 0.
Exact product/target/raw output remains ignored in `.brain/menu-indicator-stage.local.json` and the current
deployment pointer. No further unchanged install or unlock wait is pending. [Caret validation](../Documentation/Validation/menu-indicators.json)
and [physical history](../Documentation/Validation/physical-deployment.json) preserve scope and earlier results.

## Previous physical deployment — build 14

The reviewed sidebar/Shapes/caption update is applied and installed under existing same-headset
authorization. Final UI/Release/applied app hashes match; build/analyze and fresh strict signature pass.
Installation (4.164 seconds), actual Glass Image Tools 1.0 (14) identity (0.452 seconds), normal launch
without fixture arguments (0.966 seconds) and independent exactly-one-process readback (0.700 seconds)
passed, exit 0. Exact target/product remains in ignored `.brain/sidebar-caption-stage.local.json` and
the current deployment pointer. No further unchanged install/unlock wait remains.

A temporary separately signed native check app ran the exact caption service against synthetic pixels
on Vision Pro: model available/vision-capable, real nonempty caption generated in 2.56392825 seconds.
Result readback and removal passed; the main editor was not replaced by that test. This proves the local
API path, not physical editor gaze/appearance or caption semantic accuracy. [Task](261017_tool-sidebar-and-image-caption.md),
[validation](../Documentation/Validation/sidebar-and-caption.json), [physical history](../Documentation/Validation/physical-deployment.json).

## Previous physical deployment — build 15

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

Exact local pointers: `.brain/drawing-panel-stage.local.json` and the current deployment pointer. [Validation](../Documentation/Validation/drawing-and-sliding-tools.json), [physical history](../Documentation/Validation/physical-deployment.json).

## Previous physical deployment — build 16

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

Exact private pointer: `.brain/caption-sizing-stage.local.json`. [Validation](../Documentation/Validation/caption-natural-height.json); [physical history](../Documentation/Validation/physical-deployment.json).

## Previous physical deployment — build 17

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

Exact private pointer: `.brain/left-sidebar-stage.local.json`. [Validation](../Documentation/Validation/native-left-sidebar.json).

## Previous physical deployment — build 18

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

[Task](261017_sidebar-defaults-and-rotation.md). Private checkpoint: `.brain/sidebar-defaults-stage.local.json`.


## Previous physical deployment — build 19

Release 1.0 (19) is installed and identity verified; normal launch/process verification awaits headset unlock. Unlock the headset, then verify normal launch/process without rebuilding or reinstalling.

Final signed Release/native/services/applied source identity is checked before installation. Read back
actual display name, version/build and normal launch/process state; no test arguments on hardware.
Raw target/product/deployment output stays in ignored local storage.
[Task](261018_document-sidebar-and-inspector.md), [physical evidence](../Documentation/Validation/physical-deployment.json).

## Sidebar/titlebar refinement — build 20

Release 1.0 (20) is installed, identity verified and launched normally; the running app process was read back. Installation used the signed successful product and no fixture arguments. Source identity matches the native UI/services and signed product. [Task](261018_sidebar-and-toolbar-refinement.md), [deployment](../Documentation/Validation/physical-deployment.json).


## Transparency restoration — build 21

Release 1.0 (21) is installed and identity verified; normal launch/process verification awaits headset unlock. Final UI/services/signed/applied App/Core source identity agrees. The installed beta Xcode is explicitly selected through DEVELOPER_DIR for this task; global selection remains untouched. Raw product/target/output stays private. [Task](261019_transparency-regression.md), [physical evidence](../Documentation/Validation/physical-deployment.json).


## Crop-area dimming — build 22

Release 1.0 (22) is installed and identity verified; normal launch/process verification awaits headset unlock. Final UI/signed/applied source identity and strict signature/privacy checks pass; no test arguments are used for physical launch. Existing appearance preferences remain. [Task](261019_crop-dimming.md), [physical evidence](../Documentation/Validation/physical-deployment.json).


## Review fixes — build 23

Release 1.0 (23) is installed, identity verified, normally launched and verified running. Final UI,
signed and applied sources agree; strict signature, add-only Photos usage and Debug exclusion pass.
[Task](261021_review-fixes-and-caption-clearance.md), [physical evidence](../Documentation/Validation/physical-deployment.json).


## Toolbar, sidebar and inspector — build 24

Release 1.0 (24) is installed and identity verified; the headset required unlock, so normal launch and
the running process were not verified by tooling. The owner's October 22 screenshot later showed it running. Final UI, signed and applied sources agree; strict signature, add-only
Photos usage and Debug exclusion pass. Check `devicectl device info lockState` before launching; a
locked headset is recorded as launch pending rather than retried.
[Task](261021_toolbar-sidebar-and-inspector.md), [physical evidence](../Documentation/Validation/physical-deployment.json).


## Title-bar tool group — build 25

Release 1.0 (25) is installed, identity verified, normally launched without test arguments and verified
running (headset unlocked; exactly one process). Final UI, signed and applied sources agree; strict
signature, add-only Photos usage and Debug exclusion pass. Installing replaces a running copy of the app,
so an open unsaved image there is lost. [Task](261022_titlebar-tool-group.md),
[physical evidence](../Documentation/Validation/physical-deployment.json).


## Website, icon colors and license — build 26

Release 1.0 (26) carries the AudioPaper-matched icon; App Swift sources equal build 25. Installed and
identity verified; launch pending unlock. An install that reports a dropped connection after transfer is
re-run once and judged by the retry and the identity readback, not by the first exit code.
[Task](261022_website-icon-and-license.md), [physical evidence](../Documentation/Validation/physical-deployment.json).

## Round picture icon — build 28

Release 1.0 (28) changes the app icon only: new SVG masters, the regenerated `AppIcon.solidimagestack`
PNGs and the generator's layer checks; app Swift sources, tests, core and the capture probe are
hash-identical to build 27. Regenerate with `swift Tools/GenerateIcon.swift` and compile-check with
`actool` ([icon guide](../Tools/Icon/README.md)). To see the system's rendering, install a Debug build in
the visionOS simulator and capture the Home View after the install animation finishes. Installed and
launched on October 24 once the headset was awake. [Task](261024_round-picture-icon.md).

## Sidebar rows and a plain + — build 27

Release 1.0 (27) changes `DocumentSidebar` and the title-bar + only; core, tests and the capture probe are
hash-identical to build 26. Built and verified October 23 but never installed (CoreDevice 4016 is
"unreachable": usually asleep or off the network, not a signing problem; retry when the owner has it awake
and unlocked); build 28 carried these changes to the headset. [Task](261023_sidebar-rows-and-plus-menu.md).

## App Store preparation — build 29

Release 1.0 (29) adds `App/PrivacyInfo.xcprivacy` and `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO`; app
Swift sources, tests, core and the capture probe are hash-identical to build 28. Built, signed and checked
October 25; a simulator install and launch passed; installed and launched on the headset once the owner
woke it (the first attempt returned CoreDevice 4016). The manifest and key are
described [below](#privacy-manifest-and-export-compliance). [Task](261025_app-store-preparation.md).

**Uploads need a released Xcode.** App Store Connect refused a Glass Power Tools upload built by an Xcode
beta ("Unsupported SDK or Xcode version", October 18, 2026). Day-to-day builds here use the 27.2 beta; on
October 25 the released Xcode 27.1 (SDK 27.0) also built signed Release 1.0 (29), exit 0 in 51 s. Archive
for App Store Connect with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`, the Mac's default.
[Before the first upload](../Documentation/AppStore/SUBMISSION.md#account-only-steps-still-required).

## The bundle identifier — build 30

Release 1.0 (30) changes only the bundle identifier, `com.glassimagetools` (the owner's choice; Glass Power
Tools uses `com.glasspowertools`), and the build number. The framework, capture probe and UI tests follow it
(`.core`, `.captureprobe`, `.uitests`). Development builds still sign with the team's wildcard profile, so
nothing was registered in the developer account: the App ID is registered when the app is first signed for
distribution or its App Store Connect record is created. Contributors set their own identifier in
`Config/Identity.local.xcconfig`, which overrides this default. [Task](261025_app-store-preparation.md#build-30-the-bundle-identifier).

## The website (GitHub Pages)

`site/` holds page fragments (`site/pages/*.html`, each with a `<!-- title/description -->` header), one
`site/layout.html` and `site/static/` (stylesheet, icons, social card, screenshots). Build and preview:

```sh
python3 scripts/build_site.py              # Python 3.9+, pandoc for PRIVACY.md; writes the ignored _site/
python3 -m http.server -d _site 8090       # http://localhost:8090
```

The builder links only pages it built (nav and sitemap), renders `PRIVACY.md` only when it exists (so pandoc
is needed only then), rewrites links only in real anchors and skips `.DS_Store`. The footer adds Help,
Privacy and an "Also by" row for the author's other projects; keep that row in step with the README's Other
projects. Both follow AutoPaper's site ([task](261024_autopaper-footer-and-builder.md)).

`.github/workflows/pages.yml` builds and deploys on push to `main` when `site/`, `PRIVACY.md`, the script
or the workflow change. Only the deploy job has `pages: write` and `id-token: write`. Each action is pinned
to a release commit with its version in a comment; to update one, look up the tag's commit
(`gh api repos/actions/<name>/git/ref/tags/<tag>`, following an annotated tag to its commit) and change the
commit and the comment together. There is no `configure-pages` step, so deploys fail until Pages is set up.
Before the first deploy, the owner sets **Settings → Pages → Source: GitHub
Actions** and enables **private vulnerability reporting** (used by `SECURITY.md`). `REPO` and `BASE_URL`
in the script, the layout's canonical/Open Graph URLs, `robots.txt` and README assume
`msitarzewski/GlassImageTools`. Screenshots are regenerated by the scratch-only tour described in
[testing patterns](testing-patterns.md#website-screenshots-and-site-checks--build-26); never use a real
screenshot of someone's screen. Nothing has been published.

## Privacy manifest and export compliance

`App/PrivacyInfo.xcprivacy` is the app's privacy manifest; XcodeGen copies it into the app (and the capture
probe) as a resource. It declares no tracking and no collected data, and one required reason: user defaults
(`CA92.1`), for the window's appearance settings. Apple requires a manifest in the bundle of "each executable
or dynamic library in an app that uses a required reason API". After changing app or core code, scan both
Release binaries for the APIs on [Apple's list](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api):

```sh
APP=/tmp/GlassImageTools-device/Build/Products/Release-xros/GlassImageTools.app
for B in "$APP/GlassImageTools" "$APP/Frameworks/VisionSnipCore.framework/VisionSnipCore"; do
  echo "== ${B##*/}"
  xcrun nm -u "$B" | grep -E -i 'NSUserDefaults|^_(f|l)?stat(at|v?fs)?$|getattrlist|mach_absolute_time|systemUptime|ModificationDate|CreationDate|FileSystem(Free)?Size|VolumeAvailableCapacity|VolumeTotalCapacity|activeInputModes'
  xcrun otool -v -s __TEXT __objc_methname "$B" | grep -E -i 'modificationDate|creationDate|systemUptime|activeInputModes|standardUserDefaults|attributesOfFileSystem'
done
plutil -lint "$APP/PrivacyInfo.xcprivacy"
```

Build 29 found only `NSUserDefaults`, through `AppStorage`, in the app, and nothing in `VisionSnipCore`. The
core's `attributesOfItem` reads sizes, types and permissions, which aren't listed. A new hit needs a reason in
the manifest; a hit in the framework needs a manifest of its own. `ITSAppUsesNonExemptEncryption` is `NO`
because the app has no encryption of its own (the system's file protection doesn't count); revisit it if that
changes. The listing, App Store Connect answers and the steps before the first upload are in
[the App Store folder](../Documentation/AppStore/README.md).

## Local Apple packet and site preparation — October 31

Build 36 stays installed/running; content preparation creates no new app version. [Packet](../Documentation/AppStore/README.md), [entry guide](../Documentation/AppStore/SUBMISSION.md).

```sh
python3 scripts/validate_store.py --report Documentation/AppStore/validation.json
python3 -m unittest discover -s scripts/tests -v
python3 scripts/build_site.py
```

These validate local material only. Current public URLs return HTTP 404. Publish the reviewed source/site before Apple review; use an actual distribution archive/Organizer privacy report and verify Apple's processed version/build after an explicitly authorized upload. Existing development signing/physical launch is not distribution evidence. Account-only contact/trader/territory values are not stored publicly.

## Build 37 — November 3

Direct image-link Paste uses the standard Xcode 27.2 (27B52) toolchain. Core 78/5, eight focused native UI cases and signed generic-device Release/analyze/strict signature pass. Final project excludes the private live-network UI harness; persistent tests use reserved-domain URLProtocol fixtures. No ATS exception/new permission is added. Installation did not start: the paired headset’s developer tunnel is unavailable; the pre-install lock-state request failed with CoreDevice 4016. Last verified installed/normal-launch checkpoint remains 1.0 (36), October 31. Signed build 37 is ready for the already-authorized installation when the headset reconnects.

## Native Mac app

Choose `GlassImageToolsMac` / My Mac with the existing ignored signing override. Mac UI minimum is 26;
the core package's macOS 14 baseline remains. The Mac app ID is `$(VISIONSNIP_BUNDLE_ID).mac`; headset
identity stays unchanged. Development Release is not a notarized or App Store distribution build.

```sh
xcodebuild -project GlassImageTools.xcodeproj -scheme GlassImageToolsMac \
  -configuration Release -destination 'platform=macOS' -derivedDataPath build build analyze
codesign --verify --deep --strict build/Build/Products/Release/GlassImageToolsMac.app
codesign -d --entitlements - build/Build/Products/Release/GlassImageToolsMac.app
open build/Build/Products/Release/GlassImageToolsMac.app
```

The four Mac entitlements are in `Mac/GlassImageToolsMac.entitlements`. A normal signed Debug build can
run `--sandbox-probe --sandbox-probe-report-only` with `SANDBOX_UNSELECTED_FILE` set to a controlled existing
file outside its container. The Debug-only probe checks denied reading and allowed private storage,
logs only Boolean/error-code results, then exits. Use `open -n --env ... --stderr <private-log> <app> --args ...`.
Never use a product re-signed by `xcodebuild test` for sandbox enforcement proof; Xcode injects broad test-only read access.


### Mac-only build versions and VM review

Mac build 40 overrides CURRENT_PROJECT_VERSION in the Mac target; the visionOS/global build remains 38
and its Apple packet stays 38. GUI validation uses the owner's headless Mac VM; compiling on the host is
allowed, but do not execute interactive host tests. Transfer only a signed app and synthetic fixture to
an isolated guest. The toolbar preview is retained locally for the owner to open; do not relaunch or
close the owner's current app as part of testing. [Current record](261105_mac-markup-toolbar.md).


## Mac Applications install — November 5, 2026

Owner requested a fresh build/install. Canonical Mac `com.glassimagetools.mac` 1.0 (40) is installed at
`/Applications/Glass Image Tools.app`; prior preview IDs are separate development artifacts. Build from
current source, verify the strict signature/four production sandbox grants, copy through a staging
bundle in the destination volume, and verify exact installed contents/version/identity. Do not close
running editor windows or execute host GUI tests as part of installation. Read-only running-app inventory
can identify an older copy; the owner saves/quits it before opening the installed version. No distribution
or notarization claim. [Evidence](../Documentation/Validation/mac-applications-install.json).


## Mac Developer ID distribution

Use [the Mac release guide](../Documentation/MAC_RELEASE.md) and `scripts/release_mac.py` with a local
team, matching Developer ID certificate and existing notarytool Keychain profile. No signing identity
or profile name is committed. The minimal route archives universal Release, exports Developer ID,
checks four production permissions/hardened runtime/manifest, notarizes and staples app and DMG,
checks Gatekeeper and writes checksums. It prepares artifacts only; publish assets before site links.
Build 45 packaging passes; external publication status belongs to the [release task](261106_mac-release.md).

November 6: Mac 45 installation, public artifact hashes, source and live Pages are verified in the
[release record](261106_mac-release.md). Existing Pages workflow uses official pandoc 3.13 with pinned
SHA-256 and bounded install/build durations; hosting and deployment permissions are unchanged.
