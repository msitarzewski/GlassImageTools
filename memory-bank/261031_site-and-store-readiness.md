# Site and Apple store preparation — October 31, 2026

State: DOCS; content/media applied locally; app remains installed/running 1.0 (36).

Objective: Refresh the site, README and memory bank to the current native interface, and prepare accurate Apple App Store/TestFlight metadata and screenshots.

Authorization: Local content/media edits, screenshot automation, builds/checks and documentation are authorized. Same-headset deployment authorization persists but no new install is necessary. No Git, publication, Apple account changes, upload/submission, external messages or delegation is inferred from preparation.

Owners/reuse: Reuse site/pages and scripts/build_site.py, Documentation/AppStore's deliver-layout text files and current app/UI action helpers. App/Core/production test source remain unchanged. Capture actual app UI with synthetic source content in an isolated simulator; no user screenshots or private identity.

Acceptance: Current workflow and native sidebar shown and described consistently; listing/review/TestFlight text fits Apple's current byte/character limits; source-backed privacy/age/category answers and concrete account-only gaps; correct-size opaque screenshot assets with provenance; built site has sound links, responsive layout, readable light/dark presentation and alt text. Public-safe release/evidence and memory links record exactly what passed and remains.

Next: Native screenshot tour, local content edits, store/media validation and site QA, then reviewed application. No archive/distribution acceptance or live-site availability claim without evidence.

## Capture checkpoint

Native 3840 × 2160 geometry is supported by the simulator screenConfig command. First scratch tour failed on XCTest slider-adjust attributes; changed to the existing native knob-drag route. Second tour exits 0 and copies a real 2060 × 1390 PNG, but visual review found missing rectangle/arrow gestures and an uncleared selection, so those marketing shots are rejected. The next tour derives its input coordinates from actual selected-object handles and asserts four retained objects plus clean selection before capture. All failures/raw captures remain private; app production source is unchanged.

The proposed public marketing/support/privacy/source URLs return HTTP 404; publication is a real remaining step, not implied completed by local content preparation.

Third capture diagnostic: native annotation handles provide a valid source/display calibration, but XCTest rejects an application-root coordinate with a nil scene identifier on visionOS. The next attempt keeps that measured calibration and anchors gestures to the actual canvas, which owns the scene. This changes only the scratch capture harness, not the app. Rejected screenshots are not applied.

Fourth scratch attempt accepts canvas-scene coordinates, then stops because Select is a native Toggle rather than an XCUI Button. Query it across element types, as existing production UI tests do. Canvas focusing and a bounded first-gesture retry are paired with exact count increments; no failed drawing is skipped. Current mobile site checks pass on six pages with no overflow, missing alt text or unloaded images; Lighthouse mobile/light scores 100 in accessibility, best practices and SEO. Final media still requires its own visual acceptance.

## Revised capture contract after the diagnostic checkpoint

Canvas-coordinate drags remain unreliable in the scratch normal-scene XCTest harness despite valid frame/handle calibration. This is not evidence of a new physical-input defect, and no shape-gesture acceptance is claimed. The marketing storyboard is narrowed to the actual supported normal-app tour: import, exact crop, pixelate, editable text, clean selection, clipboard PNG dimensions, export, Settings and document switching. Native semantic controls and two retained objects are asserted. Hero copy/alt text now describes that exact two-object image; no missing arrow or rectangle is claimed or painted into a screenshot. Existing build-36 four-case regression evidence remains distinct. Final capture is rerun for this revised contract, with prior failures retained.

## Final applied result

Current app remains installed/running **1.0 (36)**; App/Core/production test source and project configuration are unchanged. Site and README show the current native sidebar and Photos/Files/Drop/Paste workflow. Eleven website pictures are refreshed from real app UI, with original fictional inputs and a before/after comparison from the actual copied 2060 × 1390 PNG.

The local Apple packet includes current listing/review text, TestFlight description/What to Test/feedback email, source-backed entry guidance and eight ordered opaque **3840 × 2160** PNGs with provenance/hashes. Field/media validation passes; seven validator tests pass. The focused normal-startup crop/pixelate/text/copy/export tour and separate clean-sidebar capture pass. Earlier coordinate-gesture harness failures are retained; no new shape-drag certification is claimed. The isolated simulator is shut down.

The site builds six pages. Local links/anchors and responsive checks pass; all six pages fit 390-point width with no missing alt text or unloaded images. Home-page Lighthouse snapshot scores are 100 for accessibility, best practices and SEO in mobile/light and desktop/dark; performance is not audited. Final assets are visually inspected.

**Not submitted:** proposed marketing/support/privacy/source URLs return HTTP 404. Public site/repository publication, private App Store contact/trader/territory fields, distribution archive/privacy report, upload and Apple review remain separate. No account mutation, Git, publication or upload occurred. Core/full UI/native service suites were not rerun for this content-only task.
[Apple packet](../Documentation/AppStore/README.md), [evidence](../Documentation/Validation/site-and-store-readiness.json).

Accepted focused capture command exits 0 (198.521 s; case Test Case '-[GlassImageToolsUITests.StoreMediaTour testCurrentInterface]' passed (169.386 seconds).). Separate sidebar retake exits 0 (87.896 s), removing the transient system paste banner before adoption. Source, original SVGs, output dimensions and final media hashes are checked. Public content/conflict/link checks pass before application.

An additional final mobile/browser recheck stalled and was terminated without a result. The earlier six-page responsive checks and both Lighthouse snapshots remain the recorded evidence; final desktop and adopted images were visually reviewed. No second final mobile result is claimed.

Next: review the packet and authorize publication/upload steps separately; current URLs are not live.

## Applied-content QA and handoff

All 52 reviewed content/media/documentation/validator files were transferred with baseline conflict guards and matching hashes. Root packet validation passes for eight screenshots, all seven utility tests pass (0.106 s, command exit 0), and the unchanged static builder produces six pages. Production app/core/tests/project hashes remain unchanged. The final mobile/browser wait was traced to lazy-loaded images; the corrected bounded eager-image check passes all six final pages without overflow, missing alt text or unloaded images. Both fresh home-page Lighthouse snapshots again score 100 for accessibility, best practices and SEO, with zero failed audits; mobile/light and desktop/dark renders are visually reviewed. No performance score is claimed. The earlier stalled check remains recorded, superseded by this completed check. Task browser tabs and loopback preview servers are closed.

A portable 39-entry local Apple handoff ZIP is prepared in ignored Screenshots storage (about 32.5 MB). CRC verification, local validation of all eight screenshot assets and all seven utility tests pass after extracting that ZIP into a fresh temporary directory. It contains only public metadata/media, source privacy/version validation inputs and MIT terms; no app binary, signing configuration, device/account details or raw capture logs. The task simulator and matching test clones were independently read back as Shutdown. App remains the unchanged build 36. Publication, account fields and distribution/upload/review gates remain as listed in the packet.
