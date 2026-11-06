# Compact sidebar image rows — October 30, 2026

State: DOCS; build 35 applied. Build 35 was installed October 31, with identity 1.0 (35) verified, normal launch without test arguments and exactly one running app process. The October 30 attempt was blocked by CoreDevice 4016; its evidence remains in the deployment history.

Objective: Owner finds individual image entries too large and requests Safari bookmark-style entries instead of image previews.

Authorization: Local edits, tests, documentation and same-headset signing/install/normal launch persist. No delegation, Git or publication.

Owners/reuse: Change only DocumentSidebar.DocumentRow and build identity. Keep the native List selection, category disclosure, indentation, callbacks, Recents and rear-glass ownership.

Acceptance: Single-line filename and small SF image symbol, no thumbnail or second metadata line, unobtrusive unsaved indicator and spoken type/edit status. Preserve native growing 60-point row minimum for eye/hand input and Dynamic Type. Verify document switching/Undo/close/Recents and accessibility, inspect populated compositor, build signed Release and read installed identity back. Core is unchanged; hardware gaze/hand acceptance remains separate.

## Outcome

Image entries in Open Images and Recents now use a small SF image symbol and one filename line instead of thumbnails and a second metadata line. A small dot marks unsaved edits; image type and Edited status remain spoken accessibility values. Native List selection, category rows/counts, indentation and the growing 60-point visionOS target minimum remain.

Three existing focused UI cases pass, exit 0 (183 s): document switching/independent Undo/close/Recents, clear/opaque/default glass, and compact long filenames at largest text, including native accessibility audits. Populated compositor reviewed. Signed Release build/analyze passes (26.384 s); strict signature, add-only Photos, privacy manifest, encryption key and Debug exclusion pass. The two metadata warnings are the existing AppIntents extraction skip, once each during build and analyze. Core/tests, services and UI test source are unchanged; the 69-test/5-suite core baseline and full UI/service suites were not rerun. The task simulator is stopped. Physical gaze/hand and assistive technology remain separate.

XcodeGen output matches the signed/tested project exactly. Applied files pass baseline conflict guards and signed/tested source hashes. No new permissions, dependencies, data flow or image-model changes. No Git/publication.

Next: owner visual/gaze/hand acceptance of the installed compact rows. Same-headset deployment authorization persists.
