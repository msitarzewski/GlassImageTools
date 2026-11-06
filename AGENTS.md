# AGENTS.md — Glass Image Tools

**Version: 2.1 — project adaptation (2026-10-15).** Compatible with tools that read AGENTS.md.
This guide adapts the eight-section AGENTS 2.1 workflow to this repository. The version identifies
this project guide; it does not claim an industry-wide AGENTS 2.2 standard or a machine-readable schema.

Glass Image Tools is a native visionOS and macOS image editor using Swift 6, SwiftUI and Apple frameworks.
The project is `GlassImageTools.xcodeproj`; schemes are `GlassImageTools` (visionOS) and `GlassImageToolsMac` (macOS).
Start with [the memory index](memory-bank/toc.md), [current context](memory-bank/activeContext.md),
[progress](memory-bank/progress.md), and [verified status](Documentation/STATUS.md).

## Contents

1. [Compliance and core rules](#1-compliance-and-core-rules)
2. [Session startup](#2-session-startup)
3. [Memory bank](#3-memory-bank)
4. [State machine](#4-state-machine)
5. [Task contract and budgets](#5-task-contract-and-budgets)
6. [Quality and documentation](#6-quality-and-documentation)
7. [Example workflow](#7-example-workflow)
8. [Troubleshooting](#8-troubleshooting)

## 1. Compliance and core rules

Read these instructions and the task-relevant memory before implementation. A short task-focused
acknowledgment is enough; do not repeat a compliance banner or ask the user to restate known context.

| Rule | Required practice | Evidence |
|---|---|---|
| Reuse before creation | Search behavior, equivalent names and call sites; extend its current owner or extract shared behavior. | Identify the implementation inspected and the actual gap. |
| Incremental changes | Preserve working behavior and unrelated edits; keep responsibilities and test seams clear. | Explain the change and any migration rather than rewriting working modules. |
| Evidence before claims | Separate source inspection, SDK availability, compilation, simulator execution and physical-device observation. | Cite current source, test output, repository evidence or official platform documentation. |
| Preserve architecture and native UX | Use Apple default platform surfaces and the existing source-pixel model. | Follow [project rules](memory-bank/projectRules.md) and [system patterns](memory-bank/systemPatterns.md). |

New files are appropriate for a new responsibility, focused tests or requested documentation.
Check existing owners first; do not duplicate a service or stretch an unrelated file to avoid creating one.
This memory bank is explicitly requested and its files have distinct roles defined in section 3.

### Authorization and workspace safety

- A request to implement, fix or document authorizes the necessary local edits, builds, tests and
  documentation within that scope. Authorization persists across turns; do not request it again.
- The owner has authorized physical Vision Pro builds, signing, installation and launch. Use supported,
  approved device/signing tooling when access is required. Do not bypass a tool approval rejection.
- Git initialization, commits, merges, publishing, external messages and changes to shared external
  services require their own instruction. A planned public repository does not authorize publication.
- Preserve existing user edits. Check the current diff and recorded work before attributing a change
  to someone. If Git is available, use an appropriate branch/worktree. If not, stage substantial work
  in a temporary copy, review its diff, then transfer the authorized result without initializing Git.
- Delegate only when the user or applicable instructions explicitly authorize delegation. When used,
  assign file ownership and require workers to preserve one another's edits.
- Use available purpose-built tools or standard local tools. A configuration file is not evidence that
  a server is connected. Start file searches with `rg` and `rg --files`.
- No production stubs, fake results, silent swallowed failures, hardcoded credentials or private
  infrastructure details. Explicit test fixtures belong only in tests or gated Debug test code.

### Public repository boundary

Tracked code, tests, notes, screenshots, logs and examples must not contain real device identifiers,
machine/host names, home-directory paths, personal image content, network addresses, signing team IDs,
credentials, private keys, provisioning profiles or account dumps. Do not disguise real identifiers
with reversible code names. Use neutral examples and reserved domains/addresses only when needed.
`Config/Identity.local.xcconfig`, `.brain/` and raw deployment output are local, ignored material.
Publish only sanitized validation summaries; [security guidance](memory-bank/security.md) defines scope.

## 2. Session startup

### Every session

1. Read `AGENTS.md`, `memory-bank/toc.md`, `activeContext.md` and `progress.md`.
2. Read the current month's task README and the relevant task note when present.
3. Inspect current files, repository status if Git exists, and active ownership. Preserve unrelated edits.
4. Read relevant local tool configuration only when present; use only tools available in the session.
5. Select a startup mode, identify the task's authorization, evidence level and next concrete action.
6. For an editing task, append a factual session event to local `.brain/sessions.jsonl`. Do not write
   files during an explicitly read-only review. Do not fabricate timestamps, token counts or outcomes.

### Startup modes

| Mode | Use for | Additional reads |
|---|---|---|
| Fast | Small fixes, focused reviews, documentation corrections | Current task, relevant project rules/source; `quick-start.md` as needed |
| Standard | Features, tests, shared contracts, service changes | `projectbrief.md`, `systemPatterns.md`, `techContext.md`, applicable decisions and testing guidance |
| Deep | Architecture, rendering, privacy, resource usage or capture research | Standard context, data model/security notes, historical tasks, actual SDK declarations and primary documentation |

A missing note is a gap to report and populate when documentation is in scope, not a reason to invent
history or stop useful work. [Quick start](memory-bank/quick-start.md) provides the minimal restart path.

### Operational logging

Use append-only JSONL under ignored `.brain/`. Record actual timestamp, session/task identifier, mode,
state transition, action, known result and next step. Avoid image/file names supplied by users, device
identifiers, account details and command dumps. Operational logs are local; project history belongs in
the memory bank. The following illustrates a record shape, not a historical event:

```json
{"timestamp":"2026-10-15T12:00:00Z","session_id":"example-session","mode":"deep","event":"state_transition","from":"PLAN","to":"BUILD","task":"security-remediation","summary":"Local remediation authorized; rendering regression identified."}
```

### Compaction and handoff

At meaningful state transitions and before a handoff, preserve the objective, current state, ownership,
affected files, authorization already given, actual validation, unresolved limits and next action.
Update `activeContext.md` and the task note; summarize milestones in the monthly README. Record only new
architectural decisions in `decisions.md`. Workers report to the owner of aggregate notes rather than
editing them concurrently. A compacted conversation continues the same task and authorization.

## 3. Memory bank

[The index](memory-bank/toc.md) is the navigation entry point. These files organize project knowledge;
they do not replace source or turn plans into evidence.

Keep all memory notes, individual task contracts and detailed outcome records directly in `memory-bank/`.
Only monthly task indexes and summaries belong under `memory-bank/tasks/`, using `YYYY-MM/README.md`.
Link monthly entries to their detailed records in the memory-bank root.

| File | Responsibility | Update when |
|---|---|---|
| `projectbrief.md` | Scope and acceptance; links to the authoritative product contract | Product goals change |
| `productContext.md` | User problem, primary workflow and UX priorities | Product rationale changes |
| `systemPatterns.md` | Architecture, ownership, concurrency and rendering boundaries | Patterns or boundaries change |
| `techContext.md` | Toolchain, targets, frameworks and configuration | Build/runtime constraints change |
| `activeContext.md` | Current objective, authorization, state, ownership and next action | Task transition/handoff |
| `progress.md` | Implemented, verified and still-unverified capabilities | Milestone or new evidence |
| `projectRules.md` | Concrete coding, native UX, privacy and evidence rules | An enduring rule changes |
| `decisions.md` | Dated decisions with provenance and status | A substantive decision is made/superseded |
| `quick-start.md` | Minimal restart and common verification route | Workflow changes |
| `data-model.md` | Local image/edit/history/export ownership; no database | Value/lifetime model changes |
| `build-deployment.md` | Reproducible builds and authorized device installation | Build/signing/deployment process changes |
| `testing-patterns.md` | Regression, integration, UI and hardware test boundaries | Test strategy changes |
| `security.md` | Threat surface, privacy, input limits and public hygiene | Security boundary/findings change |
| `tasks/YYYY-MM/README.md` | Monthly task index and milestone summary | Task starts or reaches a milestone |
| `<date>_<topic>.md` | Individual task contract, concrete work, validation and remaining limitations; stored in the memory-bank root | Task checkpoint/completion |

`Documentation/BUILD_BRIEF.md` owns the full product contract. `Documentation/STATUS.md` owns verified
results and acceptance gaps. `Documentation/CAPTURE_CAPABILITIES.md` owns the capability matrix.
Link to these authorities rather than maintaining conflicting copies. Publish only sanitized evidence
under `Documentation/Validation/`; raw local logs are not a substitute for a reproducible command.

## 4. State machine

Use `PLAN → BUILD → DIFF → QA → APPROVAL → APPLY → DOCS`. States are workflow checkpoints, not
seven mandatory human interruptions. `APPROVAL` checks existing authorization and asks only for
an additional decision/action that actually needs it. Documentation checkpoints may occur throughout.

| State | Inputs and actions | Exit evidence / failure path |
|---|---|---|
| PLAN | Define the objective, affected owners, reuse strategy, risks and tests. Resolve material uncertainty; continue independent work when possible. | Concrete task contract and authorized scope. Revisit if scope changes. |
| BUILD | Make focused complete changes in the assigned workspace/staging copy. Add meaningful regressions; preserve existing work. | Proposed implementation and tests; compilation errors return to BUILD. |
| DIFF | Review changed files, integration points, new-file purpose, privacy and unintended drift. Use `git diff` if available or compare against the staging baseline. | Explain what changed and why; remove unintended changes before QA. |
| QA | Run appropriate core, native build, service and UI checks. Record commands, exit status, suite results and limitations. | Passing required checks; failures return to BUILD. External environment failures remain explicit. |
| APPROVAL | Check which next actions are already authorized. Present the concrete tested result before any genuinely required new approval. | Existing authorization permits continuing; a new permission question waits for an actual answer. |
| APPLY | Transfer the reviewed staging result, or finalize authorized workspace edits. Verify file application and build identity where relevant. | Result is applied without overwriting unrelated edits; conflicts return to BUILD. |
| DOCS | Update task, status, progress, decisions and index where affected. Summarize outcome and material limits. | Accurate cross-linked record and self-contained final response. No automatic commit/publication. |

Useful substates are `CODING`, `WAITING_TOOL`, `RUNNING` and `IDLE`. Track the reason for waiting.
A failed test is not waived by documentation, time pressure or a green build. If an external limit
prevents a required check, report the exact unverified behavior instead of claiming acceptance.
Rollback removes only this task's edits; never reset the user's workspace or replace newer user work.

## 5. Task contract and budgets

### Task contract

Record a concise contract in the current task note, scaled to the change:

- **Objective and context:** desired behavior, prior evidence, relevant task/decision links.
- **Authorization:** local changes/testing/docs and any additional deployment/external scope already granted.
- **Owners and reuse:** affected services/types, existing implementations, file ownership if delegated.
- **Constraints:** native Apple UX, immutable source, source-pixel coordinates, resource/privacy boundaries.
- **Acceptance:** observable outcomes and meaningful tests, with simulator/hardware limits separated.
- **Risks and next action:** material failure modes, verification route and unresolved decisions.

A small correction does not require a separate plan document. A request to fix a demonstrated defect
already authorizes its necessary local implementation and regression tests.

### Budgets and checkpoints

Use three BUILD/QA iterations and thirty minutes as **review checkpoints**, not automatic task
cancellation or invented hard limits. At a checkpoint, report progress, diagnose repeated failures and
adjust the approach. User-specified time/token limits take precedence. Track only measurable usage;
do not invent remaining token counts. Keep the task contract, current state and required constraints
in core context; load task files and historical references on demand.

### Stall detection

Two repeated attempts with the same diff/failure and no new evidence, or three failed QA iterations,
trigger a diagnostic checkpoint. Compare the current diff, inspect tool exit status/environment and
load the relevant pattern or SDK declaration before retrying. Change the hypothesis or narrow the
reproduction. Continue useful independent work. Ask for user input only when the next required action
needs information/authorization unavailable in the session. Do not repeatedly invoke a rejected tool
operation without new evidence or a safer authorized approach.

## 6. Quality and documentation

### Implementation and security

- Complete the behavior; do not mark a stub, empty implementation, fixture or compile-only probe as working.
- Fix the root cause. Validate finite dimensions/coordinates before integer conversion and allocations.
- Preserve original bytes and metadata privacy. Crop from full-resolution source; render annotations after
  cropping; share preview/export geometry and composition rules. Pixelation must replace underlying detail.
- Keep image work off the main actor, propagate cancellation, and bound aggregate expensive work.
- Use Apple default controls and visible usable error recovery. Test actions named by an error message.
- Consolidate duplicated responsibilities when fixing them; avoid unrelated abstraction or refactors.
- Review changed code for credentials, private identifiers, unsafe data/logging, unnecessary permissions,
  malformed-image handling, clipping, resource limits and stale async completions.
- No backend, accounts, analytics, uploads, external dependencies or new permissions without demonstrated
  product need and an explicit scope decision. XSS needs an execution surface; do not claim a web pentest
  for an app with no HTML/JavaScript runtime. Reassess if such a surface is added.

### Testing

Run `swift test` for core geometry/rendering/model changes and a native app build for UI/services.
Test defects through externally meaningful outcomes: pixels, dimensions, original bytes, undo states,
cancelled jobs and visible controls. Use deterministic synthetic fixtures, including transparency,
orientation, invalid inputs and crop-boundary cases. Test mocks are permitted in test scope.
Do not add implementation-mirroring tests for low-impact edits. Use [testing patterns](memory-bank/testing-patterns.md).

Read the final exit status and actual suite summary; no failure lines is not proof of success.
A build-for-testing is not a UI run. A simulator clipboard round-trip is not ChatGPT paste acceptance.
Physical launch proves launch only. Do not hide failures, fabricate coverage percentages or dismiss
warnings without examining them. Broaden testing when changes/failures justify it, not indefinitely.

### Documentation and review output

Requested local documentation is authorized with the implementation. Update records truthfully while
working; do not wait for a second approval to document already authorized changes. Label decisions as
Proposed, Approved, Implemented, Observed or Superseded with provenance. Distinguish audit reproduction,
remediation changes and post-fix evidence. Use repository-relative links in tracked documents and
`path:line` or symbol references for precise code claims. Final responses lead with the result, explain
important behavior and validation, and state real limitations. No automatic release, commit or PR.

## 7. Example workflow

For the transparent-image pixelation defect:

1. **PLAN:** inspect `ImageRenderer`, canvas composition and the audit reproduction; retain original-image
   ownership and source-pixel crop behavior. Local remediation is already authorized.
2. **BUILD:** change the shared pixelation/composition responsibility so PNG/JPEG cannot retain the original
   within-block detail; add a synthetic translucent-checkerboard regression and crop-grid/layer-order checks.
3. **DIFF:** review rendering, cancellation/resource effects and preview integration; preserve unrelated edits.
4. **QA:** run core regressions and native builds; exercise preview/export and the inspector UI as applicable.
   Record exact pass/fail results and separate any physical-device acceptance still outstanding.
5. **APPROVAL:** confirm the local fix, tests and documentation are within the owner's instruction. Continue.
   Publication would need a separate instruction; it is not part of this task.
6. **APPLY:** transfer the reviewed result if staged, verifying that only assigned changes are applied.
7. **DOCS:** update the remediation task, verified status and relevant architecture/security notes. Report the
   observed result without claiming recipient interoperability or physical capture from core test success.

## 8. Troubleshooting

| Symptom | First check and next action |
|---|---|
| A feature fails after a recent edit | Read the current diff and test assertion before proposing a framework explanation. |
| Xcode builds but installation appears unchanged | Use a fresh successful product; read installed display name/version/build back before reporting deployment. |
| Device/signing access denied | Use supported approved execution under existing deployment authorization; report an auto-review rejection if it persists. Do not weaken app entitlements. |
| ScreenCaptureKit cannot import in simulator | Check the actual simulator/device SDK declarations. Run the separate device probe for hardware research; do not infer unsupported source access. |
| Swift package tests pass but UI fails | Inspect native accessibility tree and real interactions; model correctness does not prove control identity or edit transactions. |
| UI runner/report stalls | Distinguish completed assertions from result finalization. Preserve sanitized outcomes, stop only this task's runner, and retry a focused check when justified. |
| Export pressure or stale results | Inspect cancellation propagation, worker serialization, bounded allocations and request ownership; test after dismissal/replacement. |
| Documentation conflicts | Prefer current source plus the newest verified evidence; correct the record in place and label historical results. |
| Memory context is lost | Read `activeContext.md`, task note and status; resume the recorded next action with existing authorization. |
| A public-safety scan finds private material | Remove it from proposed tracked content, retain necessary raw evidence only in ignored local storage, then rescan. |
