# First Mac public release — November 6, 2026

State: APPLY; Mac release published, Pages deployment in progress. Owner explicitly requested shipping the accepted compact Mac editor and updating the site
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

## Completed distribution checkpoint

Applied 23 reviewed task files with baseline guards/readback; final site wording and the root screenshot
ignore anchor were subsequently corrected. The root ignore rule now excludes only private root captures,
so sanitized Apple packet screenshots remain eligible on case-insensitive Macs. Isolated initial Git
copy uses the ignore engine, a 277-file public snapshot, GitHub noreply metadata and no private raw output.
Private home/team/host values and source-relative links scan clean; snapshot site/store build checks pass.
Legacy initial-import whitespace warnings were inspected; unrelated source formatting was preserved.

Mac Developer ID archive/export, four unchanged permissions, privacy manifest, universal executable,
hardened runtime, Apple accepted app/DMG submissions, validated staples and Gatekeeper pass. Notarized
canonical 45 installed in Applications; exact tree matches export, prior bundle and running host process
preserved. Dedicated guest stopped. Public source and Mac 1.0 release are live; all three unauthenticated
canonical artifact links return HTTP 200 and downloaded hashes/bytes match prepared artifacts. GitHub
draft releases required lookup by release ID before publication; no duplicate release was created.
Pages is configured for the existing workflow, currently installing pandoc. Six local pages, seven utility
tests, fresh public snapshot site/store checks and Markdown links pass. Narrow viewport has no horizontal
overflow or broken images; accessibility snapshot shows download/build/install actions. Optional browser
screenshot was rejected by automatic approval review under retained no-new-capture restriction; no bypass
or new capture/permission grant occurred. Final live Pages verification/documentation remains.

### Pages dependency correction

First Pages build stalled in apt's pandoc installation. Read-only job inspection confirmed the step;
partial logs were unavailable during execution. Replace only the dependency installer with official
pandoc 3.13 (matching local), pinned release URL/SHA-256, bounded download/install/job duration.
Official release API digest, actual downloaded archive hash/bin layout and shell syntax pass.
Cancel only this repository's stalled/queued deployment attempts; publish the correction and observe
fresh Actions build/deploy. Existing hosting, builder, permissions and action commit pins stay unchanged.
