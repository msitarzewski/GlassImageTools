# Native sandboxed Mac app — November 5, 2026

State: DOCS — applied and locally launched.

Objective/authorization: Owner explicitly requests building and showing the native Mac version and asks for sandboxing. Local implementation, build/tests, code signing, launch and a local reviewable app are authorized. Prior visionOS deployment authorization persists but this task does not need a headset action. No Git, publication, distribution upload, account mutation or delegation.

Existing groundwork: VisionSnipCore supports macOS 14 and its 78 tests run on the Mac. No Mac app target or prior explicit Mac App Sandbox decision exists; ENABLE_USER_SCRIPT_SANDBOXING controls build scripts only. Use native SwiftUI/AppKit window/toolbar/sidebar/inspector and reuse source-pixel editing, ImageCanvas, EditorModel, document workspace, inspectors and export/import services. Mac UI targets macOS 26; shared core retains its existing lower baseline.

Constraints: Actual App Sandbox enabled; only user-selected read/write files, outgoing HTTPS for explicit link Paste, and Photos library access for the existing explicit save operation. No full disk/Pictures/Downloads grant, server, screen-capture entitlement, backend, telemetry or external dependency. App container owns private originals/previews; no URL/history persistence. Native file and save panels grant selected-file scope. Originals remain immutable, annotations editable until flattened export.

Acceptance: Native signed sandboxed Mac app launches with default Mac chrome/sidebar/inspector and family icon. Photos/Files/Paste/Drop acquire images, crop/zoom/pan/rotation and editable annotations share the same source-pixel model, Copy/Share/PNG/JPEG/save operate through Mac services. Standard menu/keyboard actions and native unsaved-close recovery preserve work. Check actual sandbox entitlements/container, selected file access, denied unselected access and URL download; core regressions and native visionOS compile guard platform branches. Separate actual runtime checks from compilation and any untested permissions/recipients.

Plan: Stage shared-platform seams and Mac shell/resources/target, compile early, exercise real native workflows with synthetic inputs, validate sandbox and signatures, review/apply without source drift, then launch a normal local product and reconcile release/memory/public platform/privacy docs. Capture remains isolated research.

## QA checkpoint

Core 78/five suites and six native Mac service checks pass. First UI runs exposed a missing native
Select All command (exact pixel fields appended/clamped instead of replacing) and a Text menu using
chooseTool instead of the existing useTool insertion entry point; both corrected. Native Mac selectors
use radio/menu buttons and the panel's PathTextField. Normal Debug sandbox probe confirms denied
unselected read (Cocoa 257), allowed private container read/write and actual container location. Xcode
injects a temporary root read exception into test apps, explaining earlier false denial results.
Final UI/Release verification and source application continue; raw artifacts remain private.


## Verified result

The shared source-pixel pipeline and service owners are reused; EditorFields extraction is unchanged
logic, with narrow platform keyboard/hover/sizing/context-menu adapters. MacPasteboard and the native
Mac shell are new platform responsibilities. A weak NSWindow reference avoids retaining closed sources;
close/quit failures cancel pending termination and keep work visible. Release disables automatic debugger
base entitlements. Native standard controls and the existing Glass picture icon are reused.

78 core/five suites, six Mac service and seven distinct native UI cases pass. The broad final command
passed six of seven UI cases (exit 65); the final native mouse-drag retry passed one/zero (exit 0).
Earlier tests are retained privately: initial compiler/API assumptions, missing Select All, wrong Text
entry point, Mac radio/menu/panel selectors, incorrect EXIF assertion (fresh codec dimensions are allowed),
test-injected root access, non-unique Zoom item and a touch gesture used instead of the SDK mouse API.
No failure was waived and no clean all-seven UI run is claimed. Exact scopes are in
[validation](../Documentation/Validation/native-sandboxed-mac.json).

Normal signed Debug sandbox: a controlled existing unselected file is denied with Cocoa 257, its private
container permits read/write and is the expected app container. The normal Release signature contains
only four intended grants, no get-task-allow or temporary test exceptions. Build/analyze/strict signature,
privacy-manifest match and Debug-probe exclusion pass. Mac icon output was visually inspected. visionOS
simulator compilation passes; no runtime/headset/probe research suite was rerun. Native inspection bridge
failed with ScreenCaptureKit -3811, so the owner's two screenshots and native Xcode UI tests provide the
observed UI evidence; no final compositor capture is claimed.

Store validation and seven utility tests pass; six site pages build. The visionOS packet moves to source
candidate 38 while keeping each image's actual capture build 36/37. No Mac store media/account record,
distribution archive, notarization, upload or publication. Actual Mac Photos permission/save, Share
recipients, assistive technology and large-image profiling remain separate acceptance. The existing
physical Vision Pro stays last-verified 1.0 (36); no device calls in this task.

## Applied delivery

67 reviewed files applied with exact SHA-256 matches and no baseline conflicts/private-data findings.
Changed Markdown relative links pass. Both the default-ID development Release and an independently
signed preview are retained in ignored `build/`; the preview is `Glass Image Tools Preview.app`.
Normal preview launch exited 0; independent app inventory confirms exactly one expected bundle/path,
version 1.0 (38), running without test arguments. The preview uses a separate app/container identity.

Automatic approval review rejected a proposed normal Quit of the earlier app because it might contain
unsaved image edits. No quit or force-termination was performed. A separate-ID preview is the safe
alternative: launching a second process with the old identity could otherwise share temporary-file
cleanup. The existing window and its image container were left alone. This local preview identity is
not a new store/account record. No capture bridge screenshot of the final Release is claimed.
