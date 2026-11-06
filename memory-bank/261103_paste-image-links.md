# Paste direct image links — November 3, 2026

State: DOCS. Build 1.0 (37) implemented, reviewed, tested and applied. Installation did not start: the paired headset’s developer tunnel is unavailable; the pre-install lock-state request failed with CoreDevice 4016. Last verified installed/normal-launch checkpoint remains 1.0 (36), October 31. Signed build 37 is ready for the already-authorized installation when the headset reconnects.

Objective: An explicit Paste of a copied direct HTTPS image URL opens the actual image in a new document, with original encoded bytes retained for full-resolution editing/export. Existing image-data paste takes priority.

Authorization: Owner explicitly requests fetching copied image links; this authorizes the required network client, local source/tests/docs/builds and prior same-headset signing/install/launch. No backend, upload, account, analytics, new runtime permission, publication, Git or delegation. Update prior no-network claims rather than retaining misleading privacy wording.

Owners/reuse: ImageImportService owns item-provider loading/cancellation and private source/preview ownership. Add a focused direct-link downloader responsibility that reuses OwnedImageImport and the serial preview loader. EditorView keeps native Paste controls and the empty workspace keeps its native Paste responder. Drop remains image-only.

Constraints: HTTPS only, credential-free requests, redirect scheme validation and bounded redirects, ephemeral session with cookies/cache/credential storage disabled, bounded bytes before/during transfer, timeout/cancellation and private protected working files. Accept supported image bytes, reject HTML/webpages and unsafe URL schemes. Never transmit an existing image or persist a URL/query/history. All edit/export operations remain local.

Acceptance: URL and plain-text URL providers import a real encoded PNG/JPEG; actual image providers win without network requests. Failure, non-image responses, excess length/chunks, insecure redirects and cancellation preserve current document and remove partial working files. Native menu and empty-workspace Paste accept links; no automatic clipboard inspection. Native UI/services compile and focused tests run; physical/network acceptance reported separately.

Initial plan (completed): implement downloader/provider fallback, transport/pixel/cleanup/cancellation tests, native UI checks, signed build and public/memory/store reconciliation. Current next action is the authorized physical installation when the paired developer connection becomes available, followed by owner browser URL acceptance.

## First QA checkpoint

Unchanged baseline 69 core tests passed with the new downloader compiled. The first expanded-suite compile exposed a throwing test-closure assertion, corrected without production changes. The next run executed 77 tests and exposed NSURL auto-conversion of ordinary NSString providers. Restrict the typed-URL branch to advertised URL representations; plain text must be parsed as the entire single trimmed URL. This preserves the no-link-scanning boundary. All failures remain in private logs.

Diagnostic checkpoint: NSString advertises both public.utf8-plain-text and public.url for two space-separated URLs, encoding their separator into a single NSURL. Merely requiring an advertised URL type was insufficient; the focused test retained that failure. Prefer the original plain-text representation when present, so whole-string parsing rejects a list or surrounding prose. Typed URL-only providers remain supported.

## Reviewed implementation and QA

Image-first explicit Paste now accepts typed and plain-text HTTPS image links through the native menu and empty workspace. A focused downloader streams to the existing protected importer with no cookies, credentials, cache or uploads. Existing source-pixel/render/Undo ownership and image-only Drop are preserved. Public privacy/site/listing/review/TestFlight wording is updated for the explicitly authorized acquisition networking. Seven editor screenshots retain honest build-36 provenance; the opening screen is a fresh normal-startup build-37 4K capture.

Standard swift test passes 78 tests in five suites, command exit 0 (20.251 s; test run 2.399 s). Network tests extend the existing serialized RendererTests suite so private-storage assertions cannot race local-image import tests. Eight native UI cases pass, command exit 0 (276.843 s; cases 144.063 s), including two real public HTTPS downloads through menu/keyboard, actual PNG Copy, URL failure preservation, ordinary image Paste, Cancel and the all-issue largest-text audit. Full UI/native service/capture suites were not rerun. Debug logs contain the existing test-only Bool interpolation deprecation, metadata-extraction skips and one system backlight XPC diagnostic; passing assertions/normal capture remain separate from those logs.

Signed Release build/analyze pass (21.646 s), strict deep signature exit 0, 1.0 (37) identity, matching privacy manifest, add-only Photos, no ATS exception and no Debug fixture strings. Two AppIntents metadata-extraction skip warnings were inspected; no AppIntents dependency is present. Local Apple field/media validation, seven validator tests and six-page static build pass. Normal startup is visually inspected; task simulator is stopped. Initial incompatible simulator-type selection failed before boot and was corrected from the runtime’s actual supportedDeviceTypes declaration. All failed compile/provider diagnostics remain private.

## Applied and physical checkpoint

36 reviewed files were applied with baseline guards, matching stage/Release hashes and no private-identifier findings. Installation did not start: the paired headset’s developer tunnel is unavailable; the pre-install lock-state request failed with CoreDevice 4016. Last verified installed/normal-launch checkpoint remains 1.0 (36), October 31. Signed build 37 is ready for the already-authorized installation when the headset reconnects. The availability query confirms the target is paired with tunnelState unavailable; it did not install or launch anything. This is a device-connection failure, not an approval-review rejection. An asynchronous readiness question was sent while independent documentation/packet checks continued.

Next: finish the authorized installation after reconnection, then owner exercises their actual copied image URL. Public source/site, account fields and distribution upload/submission remain outside this local task.

## Final local completion

The owner confirms remote terminal use; the missing paired developer tunnel, rather than installation permission, prevents delivery. Build 37 remains signed and ready. Current Home/Help/Privacy/Reference pages fit 390-point mobile width with no missing alt text or failed image loads; home mobile/light Lighthouse snapshot is 100 for accessibility, best practices and SEO, zero failed audits (performance excluded). Six-page static build and local file/anchor/alt checks pass. Only the task's preview tab/server were used and both are closed. Privacy/store fields explicitly describe image-host requests; the content-rights account answer is flagged for owner review rather than assuming ownership of remote images.

## November 4 memory-bank refresh

**Objective/authorization:** owner requested a memory-bank update. Reconcile current handoff and remove stale guidance using existing source, validation and private artifact records. This checkpoint is documentation only; no fresh build, runtime test, SDK/network/device check, installation, signing, Git, publication or upload is performed.

**Retained result:** build 37 is implemented/applied; November 3 evidence remains 78 core tests/five suites, eight native UI cases with actual HTTPS download and PNG Copy, and signed Release/analyze/strict signature passing. The local signed product remains present, current source hashes match its recorded build inputs, and the current 39-entry Apple packet checksum matches. Earlier private diagnostics and failed pre-install attempt remain preserved. No new physical capability or present-day connection state is inferred.

**Current handoff:** build 36, verified October 31, remains the last confirmed headset identity. The November 3 CoreDevice 4016/tunnel-unavailable result explains why build 37 has not been installed. The owner is using a remote terminal; no additional installation permission or blanket wake request is needed. Resume the existing tested-product delivery after confirming the paired connection is available. Then verify actual installed 1.0 (37), normal launch, process readback and the owner's browser image-link Paste.

**Clarification carried forward:** the experimental capture picker concerns capture sources; it is not a destination chooser for normal screenshots. No direct capture-to-editor path is verified on hardware. No further capture investigation was performed here.

**Documentation work:** current context, progress, navigation, November index, restart/build guidance, technology/toolchain summary and approved acquisition scope are reconciled. The obsolete build-31 current-checkpoint link, retired App Store before-the-first-upload anchor and initial implementation next-step wording are corrected. Network tests are described as present in source, not committed. Monthly summaries remain under tasks/2026-11; this detailed checkpoint remains at the memory-bank root. Relative links/public-data checks and production-source preservation are the verification for this refresh.
