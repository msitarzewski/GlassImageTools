# Capture capability matrix

Documentation reviewed October 21, 2026. SDK/official-source restrictions below retain their October 15
recorded scope: Xcode 27.2 / 27B5019j, device/simulator SDK 27.2. The latest isolated device-probe compile
is recorded with build 21 on October 19. Editor deployment is 26.0; capture experiment is 27.0.
No SDK/source research or hardware query was repeated during this documentation review.

**No physical-device capture path is confirmed working.** Device compilation proves compilation only.
The main editor's build-23 installation, identity and normal launch were verified October 21; that is not capture evidence.
Owner-confirmed Photos → crop → Copy → ChatGPT use and later simulator picker/service observations are
reconciled below. They do not establish cross-app capture, automatic handoff or a ChatGPT share extension.
[Current release](RELEASE_NOTES.md), [verified status](STATUS.md).

| Capability | SDK / official documentation | Simulator evidence | Physical Vision Pro | Decision |
|---|---|---|---|---|
| Photos import | PhotosPicker / file Transferable available in the recorded SDK | Picker presentation/return and native provider ownership exercised | Owner reports repeated Photos → crop → Copy → ChatGPT use | Reliable editor acquisition; no broad library-read permission |
| File import | Native SwiftUI fileImporter | Owned loader, full-resolution output and real Files picker/Cancel return exercised through build 21 | No separate physical Files acceptance recorded | Supported editor workflow; retain hardware acceptance gap |
| Clipboard image copy | UIPasteboard PNG/JPEG representations | Both formats written/read/decoded; build-22 UI actually copies the rotated 600 × 800 crop | Owner confirms repeated primary Copy → ChatGPT use; no separate JPEG-recipient claim | Primary clipboard workflow confirmed by owner; other recipients remain scoped tests |
| Photos saving | PHPhotoLibrary add-only authorization and asset creation | PNG/JPEG asset saves and save-before-close checks; test access pregranted where documented | No dedicated hardware save/first-consent acceptance recorded | Add-only implementation; consent/output coverage remains |
| ScreenCaptureKit framework | Device SDK exposes visionOS 27 APIs | Framework absent from simulator SDK | Not tested | Keep in separate probe target |
| System content picker | SCContentSharingPicker available on visionOS 27 | Cannot run with this simulator SDK | Consent/source choices unverified | Use Apple's picker; no custom arbitrary-window picker |
| Own-app capture selection | presentForCurrentApplication available on visionOS 27 | Cannot run | Not tested | Device probe button implemented and compiled |
| Authorized stream / freeze frame | SCStream and SCStreamOutput available on visionOS 27 | Cannot run | Not tested | Compiled probe requests one complete frame, then stops |
| Capture without Photos/file intermediate | CMSampleBuffer → CGImage → ImageSource is implemented | In-memory source-to-editor/export path tested with an explicit fixture | Actual captured buffer not tested | Supported data path; capture itself unconfirmed |
| Enumerate arbitrary apps/windows/displays | SCShareableContent, SCWindow, SCRunningApplication and SCDisplay unavailable on visionOS | Unavailable | No supported enumeration path identified | Do not implement macOS-style enumeration |
| Customize picker window/application modes | SCContentSharingPickerMode and allowedPickerModes unavailable on visionOS | Unavailable | Unavailable API | Do not assume arbitrary source selection |
| SCScreenshotManager | Class explicitly unavailable on visionOS in this SDK | Unavailable | Unavailable API | Freeze a permitted stream instead, if hardware allows |
| Configure stream size, region or pixel format | SCStreamConfiguration width, height, sourceRect and pixelFormat unavailable on visionOS | Unavailable | Unavailable API | Accept delivered frame dimensions; crop in editor |
| Other apps / system-composited view | The generic picker/stream APIs alone do not establish source scope | No evidence | Not tested | No claim of support; test consent and lifecycle on hardware |
| Immersive content / protected content | No hardware result; protection/redaction must be respected | No evidence | Not tested | Keep unconfirmed |
| Passthrough camera in capture | Apple's enterprise APIs describe restricted passthrough capture access | No evidence | No entitlement/license requested or tested | Excluded from consumer MVP |
| ReplayKit | RPScreenRecorder declarations exist; Apple now recommends ScreenCaptureKit for streaming | Recording path not tested | Not tested | Alternative research only, no working-path claim |
| Hardware buttons / Siri screenshot | Apple documents Digital Crown + top button, or Siri; result saves to Photos | Not applicable | Not tested here | User-controlled capture followed by Photos import |
| Shortcuts Take Screenshot / Get Clipboard | Apple documents these actions as unavailable on Vision Pro | Not tested here | Not tested here | Do not build the workflow around these actions |
| AssistiveTouch screenshot action | Apple documents a Take Screenshot action | Not tested here | Not tested here | Potential user-configured trigger; no automatic editor handoff assumed |
| Newest screenshot detection | Would require a distinct Photos read authorization/product decision | Not implemented | Not tested | Phase 3 exploration; never add read access implicitly |
| Share directly to ChatGPT | Recipient targets/clipboard behavior belong to the recipient | Native ShareLink provided; recipient delivery not tested | Clipboard paste owner-confirmed; share extension/delivery unverified | Distinguish Copy/paste from a compatible Share target |

## SDK evidence

Inspect the installed device SDK with `xcrun --sdk xros --show-sdk-path`. Under
`System/Library/Frameworks/ScreenCaptureKit.framework/Headers/`:

- `SCContentSharingPicker.h`: picker/observer visionOS 27 availability, `isAvailable`, `present`,
  `presentPickerForCurrentApplication`, and unavailable picker-mode customization.
- `SCShareableContent.h`: unavailable enumeration types; `.window` / `.display` style availability
  does not imply an authorized capture source exists.
- `SCStream.h`: stream/output APIs, complete-frame metadata, and unavailable visionOS configuration members.
- `SCScreenshotManager.h`: entire manager and screenshot-configuration API unavailable on visionOS.

These are the recorded 27.2 SDK declarations, not a fresh SDK check. The simulator SDK has no ScreenCaptureKit framework;
`canImport(ScreenCaptureKit)` selects an explicit limitation view there. Generic framework web
documentation is not sufficient evidence of each symbol's platform availability.

## Experimental target behavior

`CaptureCapabilityProbe` requests the system picker for either the current app or system-selected
content. It refuses to start when `isAvailable` is false. After authorization returns a filter it
starts a screen stream with audio disabled. Freeze Next Frame accepts only a complete, valid video
sample, renders it once, and passes an in-memory source into the same editor. It times out after
10 seconds without a frame. Errors and actual delivered dimensions appear in a local probe log.
The stream is intended to stop on completion, explicit Stop, window disappearance or backgrounding.
The audit identified stale asynchronous start/stop completion; the current remediation serializes
transitions, invalidates prior request generations and preserves cleanup ownership. Post-fix lifecycle
checks and device compilation are recorded separately in [status](STATUS.md); no hardware race result
or capture path is inferred from a host lifecycle test.

The target requests no camera, microphone, enterprise license, or passthrough entitlement. It is a
foreground research tool; it does not establish background capture support or cross-app capture.
It is not linked into the main editor and is not a shipped capture feature.

## Required hardware verification

1. Select the probe scheme and a paired Vision Pro running visionOS 27 or later. Resolve signing
   using your ignored local signing configuration; record the OS/build and granted capabilities in
   sanitized form without team/account/device identifiers.
2. Test both source buttons. Record the actual system consent UI, visible sources, cancellation,
   rejection and permission revocation behavior.
3. Freeze a frame from each permitted source. Record delivered dimensions, color/orientation,
   redaction, actual content scope and time to first frame. Export and inspect the real frame.
4. Test app/window closure, backgrounding and stream interruption. Investigate Apple's supported
   background execution mode only if cross-app capture is authorized and needed.
5. Test ordinary windows, immersive content and protected content separately. Never infer passthrough
   access from a successful ordinary stream. Do not request enterprise privileges for the consumer MVP.
6. Verify a headset screenshot can be picked, cropped, copied and pasted into the actual ChatGPT
   client; verify sharing to any claimed recipient and saving to Photos/Files on the headset.
7. Update this matrix only from observed results, distinguishing documented restrictions,
   unsupported APIs, simulator results and confirmed hardware behavior.

## Official sources

- [ScreenCaptureKit](https://developer.apple.com/documentation/screencapturekit): system picker,
  consent and stream model. Symbol-level availability is additionally checked in the installed SDK.
- [SCContentSharingPicker](https://developer.apple.com/documentation/screencapturekit/sccontentsharingpicker):
  use the system source selector.
- [Enterprise APIs for visionOS](https://developer.apple.com/documentation/visionos/building-spatial-experiences-for-business-apps-with-enterprise-apis):
  licensed entitlements and business-only distribution restrictions.
- [Capture your view on Apple Vision Pro](https://support.apple.com/en-au/guide/apple-vision-pro/tan1527c9e00/26/visionos/26):
  hardware/Siri capture and automatic saving to Photos.
- [Shortcuts on Vision Pro](https://support.apple.com/en-ca/guide/apple-vision-pro/tan86d877255/visionos):
  unavailable actions and automation restrictions.
- [AssistiveTouch on Vision Pro](https://support.apple.com/en-gb/guide/apple-vision-pro/tan4ddb28816/27/visionos/27):
  user-configured accessibility actions.
- [CoreTransferable file imports](https://developer.apple.com/documentation/coretransferable/filerepresentation/init%28contenttype%3Ashouldattempttoopeninplace%3Aexporting%3Aimporting%3A%29):
  copy a received file within the importing closure to retain it safely.
