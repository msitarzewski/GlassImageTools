# Contributing to Glass Image Tools

Thanks for considering a contribution. Glass Image Tools is small and deliberately native. The bar for landing a change is: it matches the patterns already here, keeps the tests green, doesn't add a dependency, and doesn't widen what the app can see or send.

## TL;DR

1. Fork the repo and create a topic branch off `main`.
2. Make your change. Keep it small and focused.
3. Run `swift test` and build the app for the visionOS simulator (see below). For interface changes, run the UI tests too.
4. Open a PR with a short description of what changed and why. For visual changes, include a simulator screenshot of synthetic content, never a real screenshot of anyone's screen.

**No CLA. No rights assignment.** Your contributions remain yours, licensed under [MIT](./LICENSE) to match the project. By opening a PR you confirm you wrote the change or have the right to contribute it under that license.

## Dev setup

Prereqs:

- A Mac with Xcode 27 and the visionOS SDK (the project is developed with Xcode 27.2). The app runs on visionOS 26 or later.
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) 2.42 or later, only if you change targets or build settings: `brew install xcodegen`

Loop:

```sh
git clone https://github.com/<your-fork>/GlassImageTools
cd GlassImageTools
swift test                               # the image core: geometry, import, rendering, metadata (67 tests)
open GlassImageTools.xcodeproj           # run the GlassImageTools scheme on a visionOS simulator
```

The Xcode project is generated from `project.yml` and checked in. After adding or removing files, or changing settings, run `xcodegen generate` and include the regenerated project.

### Signing

Simulator builds need no signing. For a headset, create `Config/Identity.local.xcconfig` (ignored by Git) with your own team and a bundle identifier nobody else uses:

```
DEVELOPMENT_TEAM = YOURTEAMID
VISIONSNIP_BUNDLE_ID = com.yourname.glassimagetools
```

The public `Config/Identity.xcconfig` contains no signing team; keep it that way. Never commit provisioning profiles, certificates or anything from your Xcode account.

### Tests

- **Core** (`Tests/VisionSnipCoreTests`): `swift test`. Pure Swift, runs on the Mac, no simulator needed.
- **Interface** (`UITests`): `xcodebuild test -project GlassImageTools.xcodeproj -scheme GlassImageTools -destination 'platform=visionOS Simulator,name=Apple Vision Pro'`. About twenty minutes for all 37 cases. Launched with `--ui-testing`, Debug builds load a synthetic image and show small gesture targets on the canvas; nothing test-only is compiled into Release.
- **Services**: a Debug build launched with `--ui-testing --integration-smoke` runs the clipboard, export and Photos checks and writes the results to `Documents/VisionSnipSmokeResults.json` in the app's container.

Test fixtures are synthetic: drawn in code, or built from text you wrote. Don't add real screenshots, photos or anything with someone's details.

## Where things live

| Path | What it owns |
|---|---|
| `Sources/VisionSnipCore` | The image model, crop geometry, import (with its size limits and private working copies) and rendering, including Pixelate and metadata-free export. No UI |
| `App/EditorModel.swift` | One image's edits, Undo history and tools |
| `App/DocumentWorkspace.swift`, `DocumentSidebar.swift` | The images open in a window, and Recents |
| `App/EditorView.swift`, `ImageCanvas.swift`, `AnnotationInspector.swift` | The window, canvas, gestures and inspectors |
| `App/ExportView.swift`, `ExportService.swift` | Copy, Share, Save to Files and add-only Save to Photos |
| `App/ImageDescriptionService.swift` | The on-device description (Foundation Models, visionOS 27) |
| `CaptureProbe` | A separate, unconfirmed screen-capture experiment. Not part of the app |
| `Tools/Icon`, `Tools/GenerateIcon.swift` | The icon's SVG layers and the generator for its visionOS image stack |
| `site/`, `scripts/build_site.py` | This project's website |
| `App/PrivacyInfo.xcprivacy`, `Documentation/AppStore` | The privacy manifest Apple requires, and the App Store listing and answers |

## Rules that keep the app what it says it is

- **The original is never modified.** Edits are values applied at render time; every output is a new image. Crop from the full-resolution source; draw annotations after the crop; keep preview and export on the same geometry.
- **Coordinates are source pixels.** Exact fields, annotation sizes and block sizes all mean pixels of the original image.
- **No networking, accounts, analytics or new permissions.** The app's privacy page says its source contains no networking code, and anyone can check. A change that would make that untrue needs a discussion first, and an update to [PRIVACY.md](./PRIVACY.md) in the same PR.
- **Keep the privacy manifest true.** Using one of Apple's [required-reason APIs](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api) (user defaults, file timestamps, disk space, boot time, active keyboards) means declaring it in `App/PrivacyInfo.xcprivacy`; in the core framework it would need a manifest of its own. [Build and deployment](memory-bank/build-deployment.md#privacy-manifest-and-export-compliance) has the check.
- **Pixelate must remove detail**, not hide it: the new image must not contain the original pixels under a pixelated area, including through transparency.
- **Image work stays off the main actor** and is cancellable; check sizes are finite and bounded before allocating.

## Code style

- Swift 6 language mode with strict concurrency.
- Apple frameworks only. Don't add dependencies.
- Apple's standard visionOS controls: windows, toolbars, menus, forms, sheets, the share sheet.
- Match the surrounding code: small types, comments on non-obvious decisions, no commented-out code.

## Accessibility

For any interface change:

- Every control has a spoken name that makes sense on its own (`Label` for icon-only buttons; `.accessibilityLabel` where the visible text isn't enough).
- Check the largest accessibility text size, Reduce Transparency, and Apple's automated audit (`performAccessibilityAudit()` in a UI test).
- Website changes: run Lighthouse's accessibility audit in light and dark mode.

## The website

`site/` holds hand-written page fragments, one layout and one stylesheet; `PRIVACY.md` is rendered into the site so the two can't disagree. Preview with `python3 scripts/build_site.py && python3 -m http.server -d _site 8090` (Python 3.9 or later; pandoc renders `PRIVACY.md`). It deploys to GitHub Pages on push to `main`. The workflow's actions are pinned to release commits: when updating one, change the commit and its version comment together. The footer's "Also by" row matches the README's Other projects.

## Working with an AI assistant

[AGENTS.md](./AGENTS.md) and the [memory bank](./memory-bank/toc.md) are how this project has been built with AI coding assistants: the working rules, the architecture, and a dated record of every change and its evidence. If you use an assistant, point it there first. Keep the public-repository rules in AGENTS.md: no device identifiers, machine names, home paths, network addresses, signing details or personal images in anything committed.

## Reporting bugs

Open an issue with your visionOS version, the build or commit, what you did, what you expected and what happened. Crop or pixelate anything private before attaching a screenshot. For security issues, follow [SECURITY.md](./SECURITY.md) instead of opening a public issue.
