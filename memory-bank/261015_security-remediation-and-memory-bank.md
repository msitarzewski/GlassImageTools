# 2026-10-15 — Audit remediation and public memory bank

## Task contract

**Objective:** Correct all seven inspection findings before further feature work, remove the identified
service/lifecycle duplication where appropriate, and build a complete AGENTS 2.1 project memory bank
for a planned public repository.

**Authorization:** The owner's explicit instruction authorizes necessary local code/config/tests/docs.
Previously granted physical Vision Pro signing, installation and launch authorization persists.
Git initialization, commits, publishing and new external services are not authorized.

**Constraints:** Swift 6, native visionOS/Apple default UX, Apple frameworks only, immutable original,
upright source-pixel editing, bounded preview, no image buffers in history, image work off the main actor,
no expanded permissions, isolated capture research, public-safe self-contained files.

**Reuse/ownership:** Extend the existing renderer/composition, model/inspector, canvas/accessibility,
clipboard/import service and capture probe owners. Documentation owns AGENTS, the memory bank, README,
status/capture prose and ignore rules; aggregate validation is recorded after the actual checks complete.
No second renderer, backend or new dependency is needed.

## Findings and acceptance

| Finding | Required observable result | Verification scope |
|---|---|---|
| Transparent pixelation leak | Pixelated PNG/JPEG no longer retain original within-block detail through alpha composition | Synthetic translucent checkerboard output pixels |
| Superseded exports continue | Cancelled/replaced work does not publish; expensive full-resolution jobs do not overlap | Cancellation/serialization regression and native export integration |
| Grid/layer mismatch | Crop does not shift source-anchored pixelation grid; annotation order agrees with preview/export semantics | Crop-boundary/order regressions and native preview integration |
| Extreme inspector dimensions | Finite bounded values and safe integer display conversion prevent traps | Adversarial numeric/model regression and native inspector checks |
| Undo semantics | One committed numeric edit undoes once; crop geometry and selected constraint restore together | History tests and real UI typing/undo/copy |
| Canvas test identity | Canvas stays addressable in both modes while crop children remain usable; drawing test reaches actual canvas | Accessibility/UI execution |
| Capture lifecycle race | Stop/background/replacement invalidates older async start/stop/callback completion | Lifecycle tests where testable, device SDK build; hardware result kept separate |
| Duplication | Pasteboard policy and import lifecycle each have one appropriate owner | Diff/source review and service regressions |
| Public memory bank | Full 2.1 structure, populated linked notes, no sibling requirement/private material | Link/content/private-data scan and build configuration review |

## Baseline evidence

The initial application passed 17 core tests and six simulator service checks. Physical 1.0 build 2
installation/launch/process checks passed. The audit preserved source and used temporary regressions:
four added definitions reproduced findings 1–4 (five cases due PNG/JPEG); malformed/forged input checks
rejected 67 inputs. Existing UI tests completed one pass/two failures, exposing undo/canvas defects.
A Release simulator build/analyze succeeded. These are baseline/audit results, not fixed-source validation.
The [status](../Documentation/STATUS.md) records exact scope and acceptance limits.

## Implementation and outcome

**State: Complete, DOCS.** All seven findings were corrected by extending the existing owners. Preview/export
now share ordered source-pixel composition and alpha replacement; export work is serial/cancellable;
inspectors validate and commit one undo transaction; presets/selection survive appropriate undo; canvas
accessibility is stable. Clipboard/import lifecycle handling is consolidated. Experimental capture transitions
serialize cleanup/start/stop, invalidate stale requests and reject older-stream frame callbacks.

The full eight-section AGENTS 2.1 project adaptation and 16 populated memory notes are applied. Apple UX
rules 14–15 are local. Public signing defaults omit the owner team, while ignored local overrides keep
signing functional. Existing user files were checked against staging hashes and preserved during transfer.

## Validation

The owner's privacy follow-up extended the same remediation: fractional pixelation boundaries reproduced
underlying-pixel leakage and now align outward; encoded output tests check boundary replacement and outside
pixels. Tests verify actual source GPS and its removal from single-image PNG/JPEG output. Working files now
have neutral source names, private permissions, requested visionOS complete protection/backup exclusion and
once-per-process next-launch orphan cleanup. Symlink/unowned-path guards preserve originals and siblings;
both exported formats reimport successfully. Clipboard remains local-only with Apple lifetime because no
expiry preference was received. Physical locked-device/backup behavior is not asserted.

| Check | Observed outcome |
|---|---|
| Core Swift suite | 34 test definitions in two suites passed; 67 malformed/forged inputs rejected without changing originals |
| Simulator model/services | 10 checks passed: transaction/preset/annotation/input checks plus PNG/JPEG export, clipboard round-trip and new Photos saves |
| Native UI final full run | Four passed, zero failures; actual typing, drawing, property/preset undo/redo, copy/export and Photos picker |
| Forced-quit recovery | Actual simulator SIGKILL left an export; next normal launch removed abandoned import/export files and preserved an unrelated temporary file |
| Capture lifecycle host verifier | Three deterministic checks passed against production CaptureLifecycleQueue |
| Device SDK | Main Release build/analyze and final signed Release build succeeded; isolated probe build succeeded |
| Release boundaries | Debug fixture/service/capture symbols absent; only add-only Photos permission description |
| Hardware deployment | Glass Image Tools 1.0 build 4 Release installed, launched and found running on physical Vision Pro |
| Public preparation | No private user/home/device/team/credential material in proposed public files; relative Markdown links valid |

Native UI final execution took 85.23 seconds. Early remediation UI failures exposed lazy Form scrolling and
native menu-label selectors; these were corrected, then the full suite passed. Test diagnostics collection
was disabled for the final runs to avoid the earlier runner's post-suite report-finalization stall.
Synchronous Apple image calls cannot be interrupted mid-call; cooperative cancellation brackets those
stages and serialization prevents concurrent full-resolution exports.
The final core tests and signed device build/analyze include the fractional-edge fix. UI/service checks
exercise the final UI/storage changes and preceded that renderer-only correction.

[Sanitized remediation evidence](../Documentation/Validation/remediation.json),
[physical deployment](../Documentation/Validation/physical-deployment.json),
[core summary](../Documentation/Validation/core-tests.txt) and
[simulator checks](../Documentation/Validation/simulator-smoke.json) preserve the results.
[Force-quit evidence](../Documentation/Validation/force-quit-cleanup.json) records next-launch recovery;
immediate post-kill cleanup or secure physical erasure is not guaranteed.

## Remaining product acceptance

No physical editing/recipient interoperability, maximum safe memory or capture capability was inferred from
the automated checks. Subsequently, the owner reported approximately ten successful Photos → crop → Copy
→ ChatGPT uses on Vision Pro, confirming the primary success criterion in real use. The exact build and
optional annotation coverage were not specified. Remaining checks cover Files import, focused annotation/
crop cases, export/Photos saving, other recipients, large-image performance and experimental capture.
The owner has not answered the license preference question. No Git initialization, commit or publication
was performed, and no license was selected without that decision.

## References

- [System patterns](systemPatterns.md), [local data model](data-model.md), [project rules](projectRules.md).
- [Security](security.md), [testing patterns](testing-patterns.md), [build/deployment](build-deployment.md).
- [Decisions](decisions.md), [capture matrix](../Documentation/CAPTURE_CAPABILITIES.md), [product contract](../Documentation/BUILD_BRIEF.md).
