# Active context

Updated November 6, 2026. Mac source **1.0 (45)**; visionOS **1.0 (38)**.
[Parity correction](261105_mac-toolbar-parity.md), [prior iteration](261105_mac-markup-toolbar.md),
[status](../Documentation/STATUS.md), [November index](tasks/2026-11/README.md).

## Current objective, authorization and verification

Owner accepted compact centered Mac toolbar and requested shipping plus site download/build support.
This explicitly authorizes release/source/site publication for this milestone, superseding prior
no-publication scope. Quit became the release blocker; the native ordering fix is verified in the
isolated guest. [Quit task](261106_mac-quit-hang.md), [release task](261106_mac-release.md).
Single agent; baseline-guarded staging; preserve unrelated files. No host app closure or GUI test.

Mac 45: native Quit confirmation before termination; Save runs with termination cancelled and advances
through edited windows before normal Quit. Guest Cancel/export cancellation/retry/Discard exit, actual
PNG Save/exit and two-window sequential save/exit pass; originals unchanged. Release and Debug test-source
builds pass, not an XCTest run. Four sandbox permissions/core editor unchanged. Developer ID universal
archive/export, app/DMG accepted notarization, validated staples and Gatekeeper pass. Existing Keychain
profile reused. GitHub owner lookup confirms proposed repo absent; prepare sanitized first publication.
Current state: reviewed source application/install, public assets/Pages and documentation remain.
Existing running owner build 44 is frozen waiting for termination; leave it untouched. New installation
cannot replace its loaded code. Last physical Vision Pro identity remains 36; source remains 38.

## Retained build-38 groundwork verification

78 core/five suites, six native Mac service cases and seven distinct UI cases pass across recorded runs;
broad UI command had one test-gesture failure, corrected focused mouse run exits 0. Actual native Open,
exact crop/PNG Copy/Undo, image and real HTTPS Paste, text/font editing, dirty image close, Quit Cancel,
Save As pixels and mouse crop at 150% are covered. Normal signed Debug app denies an unselected controlled
file (Cocoa 257) and can read/write its private container. Test-injected root read grants are excluded
from enforcement proof. Mac Release build/analyze/strict signature and four intended grants pass;
no debugger/test exceptions or Debug probe/flags. Existing visionOS app simulator-compiles with shared
platform seams; its runtime suite was not rerun. Core/image/source/metadata ownership stays shared.

## Earlier build-38 delivery and remaining manual acceptance

Source application is complete (67 reviewed files, exact hashes, no conflicts/private-data findings).
The normal Release preview is launched and independently verified at version 1.0 (38), exactly one
expected app/path. It uses a separate sandbox/container identity to preserve the earlier window.
Automatic approval review rejected quitting that earlier app because of possible unsaved edits; no quit
or force-termination occurred. The safe separate preview was built and launched instead. macOS 26 UI minimum; optional local captions need macOS 27/model support.
Actual Mac Photos authorization/save, Share recipients, VoiceOver/assistive technology and large-image
profiling remain. No new capture integration, notarization or store submission. The visionOS Apple
packet is reconciled to source candidate 38 with honest retained build-36/37 captures; no Mac store media.
Site/store local checks pass; no publication, new public URL verification or account mutation.

Last physical headset identity/normal launch is still **1.0 (36), October 31**. The November 3 build-37
installation did not start because the paired developer tunnel was unavailable (CoreDevice 4016).
The old signed artifact remains historical; source 38 has not been installed on the headset. The owner
may be using the headset remotely even while its paired developer connection is unavailable; do not
repeat wake/permission requests. Primary Photos → crop → Copy → ChatGPT owner acceptance remains valid.
Capture research is still isolated and unconfirmed on hardware.
