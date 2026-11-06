# Mac distribution

Mac 1.0 (45) requires macOS 26 or later and includes Apple silicon and Intel code. The native editor
uses App Sandbox and hardened runtime. No updater, backend or third-party dependency is included.
Download the DMG or ZIP from the [Mac 1.0 release](https://github.com/msitarzewski/GlassImageTools/releases/tag/mac-v1.0).
Open the DMG and drag the app to Applications; saved images are independent of app installation.

## Reproduce the release

Use a released Xcode with the macOS SDK, the maintainer's local signing configuration, a matching
Developer ID Application certificate and an existing notarytool Keychain profile. Team/account values
belong only in ignored local configuration. Never commit signing output, credentials or raw notary logs.

```sh
python3 scripts/release_mac.py --version 1.0 --build 45 --dry-run
GLASS_IMAGE_NOTARY_PROFILE=YOUR_KEYCHAIN_PROFILE python3 scripts/release_mac.py --version 1.0 --build 45
```

Each invocation creates a new output directory; use `--output build/another-release` to retain previous
runs. Dry run archives, exports and validates only. Normal mode uses Apple's notary service, validates
and staples the app, checks Gatekeeper, creates a stapled-app ZIP and signed/stapled DMG, and writes
SHA256SUMS.txt. Public artifacts are under `build/mac-release/artifacts/`; archive, logs and intermediate
uploads are local only. The script does not publish source, create releases or change hosting.

The four sandbox permissions remain: sandbox, user-selected file read/write, outgoing network for
explicit HTTPS image-link Paste, and Photos operations. No debugger or temporary sandbox exceptions
are allowed in distribution. Photo saving requests add-only authorization; selection uses PhotosPicker.

## Validation boundaries

The Quit regression is recorded in [verified status](STATUS.md) and the [task](../memory-bank/261106_mac-quit-hang.md).
Core rendering and prior Mac editing evidence are retained; no new full-suite/headset acceptance is
implied by packaging. Mac Photos saving, recipient interoperability, VoiceOver and large-image profiling
remain owner acceptance items. Notarization is Apple's distribution malware/signature assessment,
not App Store review or proof of every editor workflow.

An older running app keeps its already-loaded code after installation. Save and quit it before reopening.
If the old Quit bug has already left it waiting, installing the fix cannot replace that process's code;
its owner must decide how to close it, with unsaved edits at risk from force termination.
