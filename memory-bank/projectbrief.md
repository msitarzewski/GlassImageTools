# Project brief

Glass Image Tools is a native Apple Vision Pro image editor: **Capture → Crop → Annotate → Copy or Share**.
The owner renamed the initial VisionSnip working title to Glass Image Tools; internal `VisionSnipCore`
names remain implementation details. The [build brief](../Documentation/BUILD_BRIEF.md) is authoritative.

## Primary outcome

Someone wearing Vision Pro selects an existing screenshot, extracts a precise region, optionally
annotates it, and shares or pastes it into a compatible application without moving to another device.
The original remains unchanged and exported pixels come from the full-resolution source.

## Delivery boundaries

1. **Native editor:** Photos/Files/explicit Paste import, zoom/pan, crop presets/exact dimensions, rotation, undo/redo,
   editable annotation objects, PNG/JPEG, clipboard, system sharing and save-new-image operations.
2. **Capture research:** separate experimental target, actual SDK declarations and authorized physical
   hardware tests, with a capability matrix distinguishing each evidence level.
3. **Workflow optimization:** explore supported screenshot triggers, quicker import and recipient
   interoperability only after the reliable editor works and permissions/capabilities are proven.

Use Swift 6, SwiftUI and Apple frameworks. Keep processing local, startup quick and ordinary resizable
visionOS windows primary. No backend, accounts, telemetry, external packages or decorative immersion.

The owner requested a persistent contextual right Tool Options pane and an Apple image-description
caption on October 17. The caption describes the original preview through Apple's local model when
visionOS 27/model support permits; it is outside image Copy/Share/save and does not change the editor's
primary crop/share contract. [Approved extension and evidence](261017_tool-sidebar-and-image-caption.md).

## Acceptance

Phase 1 requires real screenshot import, accurate crop, editable annotations, copy/paste into a compatible
recipient, PNG/JPEG/files/Photos export, unchanged originals and acceptable large-image behavior on Vision Pro.
Compiled code, simulator checks and hardware launch each provide useful but narrower evidence.
See [status](../Documentation/STATUS.md) for what has actually been verified. Capture success is a separate
Phase 2 requirement and does not block editor remediation.

Current presentation separates a leading Images sidebar for open documents/session Recents from a
trailing contextual Crop/annotation inspector. One + menu offers New Window, Photos, Files and Paste;
imports open in the current workspace (build 24). Native controls sit in plain SwiftUI columns over one adjustable rear surface.
The build-22 outside-crop mask is preview-only; saved output remains a new flattened PNG/JPEG. This
supersedes build 17's left Tool Options placement. [Current release](../Documentation/RELEASE_NOTES.md),
[document model](data-model.md), [historical layout](261017_native-left-sidebar.md).

## Public release

The owner, who built it as a personal tool, chose to publish it in case others find it useful: MIT license,
a GitHub Pages site like AutoPaper's with a BEDROCK-style home page, and TestFlight later (October 22,
2026). Until TestFlight exists, people build it with Xcode. [Decision](decisions.md#2026-10-22--mit-license-and-a-public-website).

## Approved acquisition extension — November 3, 2026

The owner explicitly requested Paste of a copied web image URL. Build 37 therefore permits one user-initiated direct HTTPS image download through the existing Paste controls; typed URL and plain-text URL representations work, with image bytes taking priority. Protected import ownership, full-resolution source pixels and local editing/export remain. No backend, upload, account or analytics is added. Privacy/public/store claims disclose the image-host request. [Scope decision](decisions.md#2026-11-03--direct-https-image-link-paste), [implementation and evidence](261103_paste-image-links.md).

## Approved platform extension

On November 5 the owner requested a native Mac version with App Sandbox. It uses the same nondestructive
editor and local processing, with platform-native SwiftUI/AppKit presentation. macOS 26 UI / shared core
macOS 14; no Mac capture integration or distribution publication is implied. [Task](261105_native-sandboxed-mac.md).

