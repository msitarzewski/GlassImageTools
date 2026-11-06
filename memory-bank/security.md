# Security and public-repository boundary

## Scope

Glass Image Tools processes user-selected images locally. Since build 37, explicit Paste of a direct HTTPS image URL uses a bounded network client to fetch that image. The application has no web view, HTML/JavaScript execution, network listener, shell execution, backend, account or external package dependencies. No XSS execution surface was identified in the October 15 inspection. This is
source review and bounded adversarial testing of the app, not a comprehensive penetration test of visionOS
or Apple's image decoders. Reassess the threat model if URL loading, web content, networking or plugins appear.

The owner-requested build-14 caption adds an Apple on-device model boundary. Only the bounded upright
preview is attached; filenames, source URLs and metadata are not supplied. Use SystemLanguageModel only,
check real capability, reject overlapping inference and guard cancelled completions. The app persists no
caption/transcript and never includes it in image Copy/Share/save or metadata. The feature has no tools,
cloud fallback, upload client or new permission. Treat image text as untrusted content and generated
descriptions as informational; they never control redaction, geometry, exports or actions. System model
storage/behavior is platform-owned; no secure-erasure or semantic-accuracy guarantee is made.

## Relevant threats and controls

| Boundary | Risk | Required control / evidence |
|---|---|---|
| User-selected image | Malformed input, forged dimensions, decoder/large allocation pressure | Validate dimensions before decoding/allocation; reject invalid/oversized input; test originals survive failure |
| Numeric editing | NaN/infinity, rounding overflow, impossible geometry or colors | Finite bounded source values and safe display conversion; colors finite within −2…2, alpha 0–1; meaningful extreme-input regression |
| Pixelation | Alpha blending or fractional edges reintroduce original fine detail; preview/export mismatch | Replacement composition, outward pixel alignment, shared source-anchored grid/order and encoded pixel tests |
| Async work | Cancelled/stale result replaces current edit, overlapping full-resolution buffers | Cancellation propagation, serialized expensive export work, current-request guards and lifecycle tests |
| Capture research | Stale consent/start completion, unsupported source assumptions | Isolated target, public system picker/consent, generation/stream ownership, real hardware evidence |
| Export | Metadata/private original leaks, unintended overwrite | Fresh output metadata, flatten only rendered result, immutable source checks, new files/assets |
| Photos/file access | Permission expansion or access after provider lifetime ends | System picker, add-only save authorization, owned copy during security-scoped access |
| Clipboard/share | Unintended propagation or recipient assumption | Explicit Copy only, same scope as Share › Copy (Universal Clipboard may reach the owner's devices), explicit system sharing, actual target-app acceptance |
| Working files | Leftover screenshots, backup/name disclosure, cleanup escaping ownership | Private dedicated roots, neutral source names, requested complete protection/backup exclusion, next-launch purge, regular-file and owned-path checks |
| Public repository | Personal screenshots, identifiers, signing material or logs exposed | Synthetic fixtures, ignored local configuration/raw evidence, sanitized validation and full proposed-file scan |

Pixelation obscures detail; it is not encryption or a guarantee that contextual information cannot be inferred.
The fix criterion for the audited alpha bug is that original within-block fine detail is not blended back
into the exported pixelated region. Any claimed preview agreement must respect the 2048-pixel preview limit.

## Current audit and remediation

The [status record](../Documentation/STATUS.md) lists seven demonstrated/source-inspected issues and their
evidence. The owner authorized remediation; final results belong in the [current task](261015_security-remediation-and-memory-bank.md).
Do not claim findings fixed solely because implementation changed. Run regressions for the alpha leak,
clipped grid/order, numeric range, history transaction, accessibility identity and async ownership. No
physical-device decoder/resource crash or capture lifecycle race was induced during the initial audit.

The final core suite passes encoded PNG/JPEG alpha-redaction tests and fractional-boundary PNG tests.
Metadata tests prove GPS exists in the source before requiring no GPS/private EXIF/TIFF values and exactly
one image in each encoded output. Source originals are not embedded as layers. Pixelation retains coarse
information; do not describe it as cryptographic or guaranteed protection against contextual inference.
Redaction leaks are privacy defects. Numeric traps/memory pressure/cancellation overlap are robustness
defects, not demonstrated arbitrary-code execution. No code-execution exploit was found in this bounded review.

## Working files and clipboard lifetime

`ImageTemporaryStorage` in `ImageImportService.swift` prepares dedicated import/export roots once per
process. It removes prior-process artifacts on the next launch, preserves live files across windows and
repeated preparation, and surfaces failures. Directories are 0700; files 0600. visionOS complete file
protection and backup exclusion are requested. Source copies use `source.image`; friendly names stay in
memory. Only validated owned import paths enter cleanup ownership; symlinks/nonregular files are rejected
before copy/protection/load. Regressions check original bytes/permissions and sibling preservation.

An actual simulator SIGKILL/relaunch check confirms next-launch removal and unrelated-file preservation.
No cleanup code runs after force termination. Immediate deletion, secure physical erasure, locked-headset
protection or real backup behavior is not established. Normal owner release attempts deletion; interrupted
processes rely on next-launch purge/system storage management. [Evidence](../Documentation/Validation/force-quit-cleanup.json).

`ClipboardService` writes only on explicit Copy and keeps no app history. Since build 24 it matches the
system Share › Copy at the owner's request: no `.localOnly` option, so Universal Clipboard can carry the
image to the owner's other signed-in devices. Apple's normal lifetime remains in effect: the copied image
may remain after closing the editor. No automatic expiry or on-close clearing is implemented.
The clipboard is deliberately readable by the app into which the user pastes. Recipient interoperability
requires actual testing. System sharing/Photos/Files destinations retain files under their own policies.

## Repository hygiene

Keep real home paths, host/device identifiers, personal image pixels/names, signing team/account details,
credentials/tokens, certificates/private keys, provisioning profiles, raw device/build reports and generated
app/result bundles out of tracked files. Local identity overrides and `.brain/` are ignored. Broader ignored
patterns are defense against accidents, not proof that a file is safe; inspect the proposed tracked set.

Use relative repository links, neutral synthetic data and sanitized summaries. If useful evidence includes
private raw output, retain it only in ignored local storage and publish the capability/result rather than
the identifier. Scan both source and documentation before public preparation. Run pattern scans (network
addresses, device identifiers, home paths) as regular expressions. A fixed-string search for a pattern
such as an IPv4 regex matches nothing and reports a false "clean". No Git publication is
authorized by this task. The owner chose MIT on October 22, 2026 (`LICENSE`); publication still needs its
own instruction.

October 22, 2026 scan (build 26): private tokens (user/home path, computer/local/host names, headset and
simulator identifiers, signing team, owner email) were gathered locally and never printed, then searched
for with the patterns above across every publishable file, images included. No host or device token was
found; the owner's name appears only as the deliberate author credit. Site screenshots show a made-up page
(`example.com`) and this project's own source. `SECURITY.md` routes reports through GitHub private
vulnerability reporting, so no personal email is added. [Task](261022_website-icon-and-license.md).

October 25, 2026: at the owner's request ("use my gmail like my other apps") the owner's email is a
public contact in `SECURITY.md`, `PRIVACY.md`, Help and the App Store README, as in Glass Power Tools.
Privacy scans report it in those files by design; anywhere else it is still a finding.

## Explicit image paste and bounded preview imports

Native PasteButton supplies providers only through an explicit user action; the app never polls clipboard
content or stores paste history. The first supported image representation is imported as encoded bytes,
using the same validation/private-copy lifetime as Photos and Files. A 256 MiB encoded cap before/after copy
complements the 200 MP source/100 MP output caps. Provider/framework materialization may precede the cap.
OwnedImageImport validates deletion ownership before retaining cleanup responsibility, protecting original
files even if cancelled before preview decoding. Progress cancellation and generation checks reject late
providers/stale sources; one serial preview worker prevents overlapping app preview decodes. Synchronous
copy/ImageIO cannot stop midway, so cancellation is checked before/after and UI remains Cancelling until
the worker returns. Actual service/core regressions are linked in the native UX validation record.


## Session document navigation — build 19

Recents explicitly retain protected local image sources until clearing, eviction, window closure or quit;
they are not persistent history. The sidebar explains this policy and exposes Clear Recents. This extends
source lifetime beyond closing an image, without retaining closed vectors/history or reading the clipboard
automatically. Recent reopening never grants broader Photos access. The source/preview retention budget
and document/recent count limits preserve existing open edits on rejection; serialized exports remain
separate. A saved recent is reimported from the actual flattened output through existing validation and
protection. No new entitlements, permission strings, networking, dependencies or durable catalog.

## Documentation review — October 21, 2026

Build-22 code remains identical to its recorded signed source manifest; this documentation pass is not
a new security audit or penetration test. The outside-crop mask is a visual selection aid, not a privacy
redaction. Original pixels remain in the immutable source during editing; only flattened crop/annotation
output follows the export renderer. Window/session Recents and on-device captions retain the lifetimes
in [the data model](data-model.md). [Release notes](../Documentation/RELEASE_NOTES.md) record current scope;
locked-device protection, resource and recipient/privacy acceptance remain separate hardware work.

## Website build pipeline — October 24, 2026

The Pages workflow follows AutoPaper's security round: the build job, which runs `apt-get`, pandoc and the
builder, reads repository contents only; only the deploy job holds `pages: write` and `id-token: write`, so
a compromised build step can't mint the deploy token. Each action is pinned to a release commit, checked
against its tag. It runs on pushes to `main` and manual dispatch only, never on pull requests. The site
itself has no scripts and loads nothing from elsewhere; the footer's outside links are plain links.
[Task](261024_autopaper-footer-and-builder.md).

## Privacy manifest and Apple's reports — October 25, 2026

Build 29 adds a privacy manifest declaring no tracking, no tracking domains and no collected data, and one
required-reason API (user defaults, `CA92.1`). The Release binaries were scanned against Apple's list. The
app at build 29 had no networking, analytics or crash reporting of its own (build 37 later adds explicit HTTPS image acquisition). Once it ships through TestFlight or the
App Store, Apple's services add reports the app doesn't control:
- TestFlight sends crash logs and usage information automatically, with no opt-out.
- TestFlight also passes on any feedback, with the tester's name and email unless they joined through a
  public link.
- The App Store passes crash data and usage statistics only from people who share analytics with developers.

PRIVACY.md now says so, and warns that a screenshot attached to TestFlight feedback reaches the author.
`ITSAppUsesNonExemptEncryption` is `NO`. At build 29 only system file protection was involved; build 37 also uses system HTTPS for explicit downloads. Confirm the final distribution archive and current export-compliance questions.
[Task](261025_app-store-preparation.md).

## Explicit Drop and empty-workspace Paste — October 29, 2026

Image-only Drop providers and explicit well/keyboard Paste reuse the existing bounded owned-copy importer. The custom native well requests UIPasteboard.itemProviders only inside the user action; there is no clipboard polling on startup, rendering, focus, hover or enablement. Apple's cross-app paste consent may appear. The empty-only public UIKit responder handles standard Paste; image text fields keep their native responder. Real data/file provider tests verify independent copies, unchanged original/owned bytes, dimensions/type and correct names. No new permission/entitlement, networking, telemetry or persistent clipboard data. Cross-app consent/hand delivery and locked-device protection remain hardware checks.

## Explicit HTTPS image acquisition — build 37, November 3

The owner explicitly requested pasting a web image URL. Existing image bytes take priority. Only an explicit Paste can request one complete credential-free HTTPS link; no automatic clipboard reads/link scanning, HTML/JS processing, backend or uploads. The source and permitted HTTPS redirect hosts see the requested URL/query and IP address. An ephemeral URLSession disables cookies, URL cache and credential storage, strips redirect headers and rejects website/proxy authentication while preserving system TLS trust checks. No ATS exception or new permission is introduced.

Reject non-200 responses, HTML/non-image MIME, malformed image bytes, insecure/credentialed URLs/redirects, over five redirects and transfers over 256 MiB. Header length and streaming chunk totals are both bounded; request inactivity is 20 seconds and resource timeout 60. Delegate writes go directly into the existing protected private import directory; cancellation/error removes partial files and next-launch purge handles interruption. Whole URLs/queries are not added to source names/history or exported metadata. The serial preview worker retains its existing pixel/dimension limits. Deterministic tests use reserved-domain URLProtocol fixtures only. Public privacy/store wording now discloses that optional acquisition networking.

## Mac App Sandbox — November 5, 2026

Implemented by the owner's explicit Mac build instruction. Four production grants: App Sandbox,
user-selected read/write files, outgoing network client and Photos library capability. PhotoKit requests
`.addOnly`; no full-library authorization call was added. No broad folder/full-disk, server or capture grant.
A normal signed Debug probe denied an existing unselected controlled file (Cocoa 257) while private
container read/write succeeded. Xcode-injected test apps add a temporary root read exception and Mach
test services; those grants are test artifacts and must not appear in the shipped Release signature.
Raw diagnostics stay ignored. Release signature and effective entitlements must be checked independently.
Selected file operations, actual Photos consent and recipient handling retain their own evidence levels.

