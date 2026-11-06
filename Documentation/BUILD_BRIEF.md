# Glass Image Tools product contract

## Approved Mac extension — November 5, 2026

The owner authorized a native, sandboxed Mac editor using the shared image/edit/export pipeline.
The Mac shell targets macOS 26 and uses native sidebar/inspector, menus, file panels and close/quit recovery.
The original headset success criterion and isolated visionOS capture research below remain unchanged.
Mac capture and distribution are not part of this implementation. [Implementation and limits](../memory-bank/261105_native-sandboxed-mac.md).


Source: the owner's build brief, supplied October 15, 2026. Local implementation and validation authorized.

## Purpose

Native Apple Vision Pro screenshot utility: **Capture → Crop → Annotate → Copy or Share**.
The primary success criterion is selecting an existing Vision Pro screenshot, cropping a relevant
region, and pasting the image into ChatGPT without leaving the headset. Preserve the original.

## Phase 1: native image editor

- Swift 6 and SwiftUI; ordinary resizable visionOS window; no iPad compatibility mode or immersive environment.
- PhotosPicker and system file import, with only operation-specific permissions.
- Aspect-fit image canvas with zoom/pan and forgiving, pixel-accurate crop handles.
- Freeform, 1:1, 16:9, 4:3 crops; reset and fit; live source-pixel dimensions; undo/redo.
- Editable rectangle, ellipse, arrow, freehand, text and blur or pixelation annotations. Adjustable color and width.
- Nondestructive state; annotations are rendered after cropping and clipped to the output.
- Copy image to clipboard; system sharing; save a new Photos asset; PNG/JPEG and file export.
- Show output dimensions and file size. Never overwrite the source.
- Downsample previews; retain full-resolution source for export. Correct all EXIF orientations and mirrored images.
- Test geometry, letterboxing, zoom/pan, clipping and annotation transforms; keep large screenshot work responsive.

## Phase 2: authorized capture research

Keep research separate from the editor. Inspect actual SDK declarations and official documentation;
validate each proposed capture path on physical Vision Pro before integrating it into the editor.
Investigate own-app, other-app/window, system-composited, immersive and passthrough content,
permissions/entitlements/consent, frames from authorized streams, and capture without saving to Photos.
Investigate Siri, Shortcuts and accessibility triggers. Do not infer permission from framework availability.

The probe must use system authorization/source selection, freeze a valid frame, hand it directly to
the editor, and report real errors/limitations. Deliver a capability matrix with separate documented,
compiled, simulator and physical-device evidence. Photos import remains the reliable fallback.

## Phase 3: faster permitted workflows

Explore one-action import, newest-screenshot detection, screenshot presets, notifications/shortcuts,
convenient persistent windows, keyboard/pointer commands, and interoperability with ChatGPT/other apps.
Do not assume another app exposes a share extension or accepts image paste. Test actual interoperability.

## Definition of done

A person wearing Vision Pro can select a screenshot, zoom/crop without losing source resolution,
optionally annotate, and paste/share/save the result without another device. PNG, JPEG and Photos saving
work. Originals remain unchanged and large screenshots do not cause crashes or severe stalls.
Physical-device tests and target-app interoperability are required before declaring this complete.
The stretch goal is authorized native capture that eliminates the intermediate screenshot.

## Constraints

Native Apple UX first; precision and low friction; local processing and privacy; fast startup.
No accounts, analytics, uploads, backend, authentication, external dependencies, AI features, or
immersive rendering without a demonstrated need. Prioritize working software over architectural ceremony.

## Owner-requested extension — October 17, 2026

Tool Options opens in a contextual right-hand native Form, with a native sidebar toggle in document
actions. Shapes shows its selected symbol without an extra control checkmark.
Show an Apple-generated original-image description below the main canvas using only the on-device model
when visionOS 27/model/vision support is available.
This requested AI feature adds no backend, cloud fallback, accounts, uploads or library-read permission.
It uses the bounded upright preview, cancels with the source, and never enters image Copy/Share/save,
metadata or edit history. It is informational and does not determine any crop/redaction/render decision.

Later owner requests refine this extension. Build 15: loading or unavailable descriptions show no
placeholder, heading, spinner or retry control. Build 20: a normal tap on Shapes opens its menu
immediately; the earlier tap-to-draw/hold-for-choices interaction is superseded. Build 23: a busy or
not-yet-ready on-device model is retried quietly while the image stays open, and the caption ends
above the system bottom toolbar.
