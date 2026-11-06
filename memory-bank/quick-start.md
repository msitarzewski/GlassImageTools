# Quick start for a resumed session

Updated November 4, 2026; documentation only. Current source/signed product is **1.0 (37)**. Last verified installed/normal-launch identity is **1.0 (36)** on October 31. The November 3 pre-install request failed with CoreDevice 4016; the paired developer tunnel was unavailable. No device state was rechecked for this refresh.

Read [current context](activeContext.md), [the image-link task](261103_paste-image-links.md), [November tasks](tasks/2026-11/README.md) and [verified status](../Documentation/STATUS.md). `.brain/image-link-stage.local.json` points to tested source, signed product, the current portable Apple packet and private verification/deployment evidence.

The next delivery step is to install the existing successful build when the paired connection is available, then verify installed identity, normal launch and one running process. Existing same-headset authorization persists; no new permission is needed. The owner's remote terminal can remain available while the developer tunnel is unavailable. Do not assume an active headset needs waking or initialize Git; inspect current device/source state before resuming. Use the current tested product rather than rebuilding solely because time passed; rebuild only if source/signing/product checks require it.

## Working sequence

1. Read [AGENTS.md](../AGENTS.md), [active context](activeContext.md), [progress](progress.md) and the
   [current monthly index](tasks/2026-11/README.md). Resume the recorded task and existing authorization.
2. Inspect changed files before editing. Do not assume uncommitted edits are the owner's or initialize Git.
   The workspace has no Git, so stage substantial work in a private scratch copy:
   - Copy the workspace as both a baseline and a stage, and record SHA-256 hashes of the baseline.
   - Edit and test only the stage, always by absolute path. One relative-path append once landed in the
     workspace; the hash check caught it.
   - Before applying, check the workspace files against the baseline hashes so owner edits are not overwritten.
   - Copy the changed files over, then verify that the workspace hashes match the stage and the tested source.
3. Open `GlassImageTools.xcodeproj`, select `GlassImageTools`, and choose a visionOS simulator or paired Vision Pro.
4. Run core tests for model/geometry/rendering edits and a native build for UI/services:

```sh
swift test
xcodebuild -project GlassImageTools.xcodeproj -scheme GlassImageTools   -destination 'generic/platform=visionOS Simulator' -derivedDataPath /tmp/GlassImageTools-quickstart build
```

Use a fresh task-specific derived-data path when validating installation identity. If configuration or
membership changed, regenerate with `xcodegen generate` first and inspect the generated project diff.

The main app deploys to visionOS 26; the capture experiment deploys to 27. Device signing uses an ignored
local identity override. [Build/deployment](build-deployment.md) gives complete commands and hardware
verification. [Testing patterns](testing-patterns.md) distinguishes unit, service, UI and headset evidence.

The normal application starts empty. Only explicit Debug testing arguments load synthetic fixtures or
service smoke checks. Do not use them for an ordinary user installation or acceptance demonstration.
Check [status](../Documentation/STATUS.md) before repeating a claim about hardware, capture or recipients.

## Native Mac preview

Read [Mac task](261105_native-sandboxed-mac.md). Select GlassImageToolsMac/My Mac in Xcode. Run `swift test`
for the shared core and the Mac scheme's native tests for UI/services. Keep the owner's normal app separate
from test launches with a test bundle-ID override. Sandbox verification needs a normal signed build,
not the product mutated by `xcodebuild test`. [Mac build steps](build-deployment.md#native-mac-app).

