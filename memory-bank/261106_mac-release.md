# First Mac public release — November 6, 2026

State: BUILD. Owner explicitly requested shipping the accepted compact Mac editor and updating the site
for Mac download and source builds. This supersedes earlier no-publication scope for this release.
Quit was reported as a blocker; [the focused fix](261106_mac-quit-hang.md) is verified in the dedicated VM.
Use sibling Glass Power Tools as a notarization workflow reference; independently implement a minimal
pipeline for this dependency-free MIT app. No updater, new entitlement, capture or account credential
setup. Existing notary Keychain profile and Developer ID identity are usable. No delegation.

Owners: existing native Quit services and regression tests; scripts/release_mac.py owns local packaging;
site/pages and layout remain the existing static GitHub Pages source; README and release records own
user installation/build guidance. All substantive work is staged with baseline guards. No Git worktree
exists locally; the authenticated owner's GitHub repository lookup/list confirms the proposed repository
is absent. First publication requires a sanitized source snapshot and release assets before site links.

Acceptance: universal Developer ID app, unchanged four grants, hardened runtime and privacy manifest;
Apple accepted/stapled app and DMG, Gatekeeper checks, checksum verification; actual public downloads,
source/build instructions and Pages/support/privacy URLs; no personal/private evidence in publication.
Keep raw archive/notary/account/VM logs ignored. Preserve the owner's frozen running app and all windows.
Native source is Mac 45 / visionOS 38; hardware/Photos/Share/accessibility/performance gaps remain.
