# 2026-10-16 — Apple HIG review

## Task contract

**Objective:** Review the delivered native editor against current Apple visionOS HIG while the owner is
unavailable for headset validation; produce prioritized, actionable findings with honest evidence levels.

**Authorization:** The owner's request authorizes source review, official-document research, local
simulator observation and documentation. This task does not implement the proposed fixes or contact the
headset. Earlier deployment authorization persists, but no repeated physical request is useful now.
Git initialization, commits and publication remain outside scope.

**Owners and reuse:** Root owns the review, simulator observation and all aggregate documentation.
Existing independent reviewers inspected native forms and crop/canvas behavior without editing files.
Reused EditorView, AppearanceSettings, ImageCanvas and renderer ownership; no new service was proposed.

**Constraints:** Native Apple surfaces, ordinary resizable window, immutable source and source-pixel edits;
single tap/hold Shapes chooser; opaque image/foreground above adjustable glass; live editable vectors
until flattened saving. Keep personal images, identifiers, raw logs and private tool configuration out
of public notes.

**Acceptance:** Official HIG citations, specific source owners, simulator reproduction for observable
layout/context issues, prioritized proposed fixes with testable outcomes, updated navigation/status, and
unchanged production source. Separate hardware observations still needed from simulator/source evidence.

## Completed checkpoint — DOCS

[The HIG report](../Documentation/HIG_REVIEW.md) owns findings HIG-01 through HIG-08 and the proposed
implementation order. [Sanitized validation](../Documentation/Validation/hig-review.json) owns exact
walkthrough results, measurements and limits.

- Reviewed current official HIG and source; two independent read-only reviews informed the aggregate.
- Built a private observation copy and executed two native UI walkthroughs: zero failures, 137.774
  seconds; command exit 0. Sixteen actual compositor views were inspected.
- Reproduced long-title clipping and visually hidden document actions at minimum size/largest text;
  measured a 910.5-point annotation toolbar against a 720-point content window.
- Observed inappropriate Text/Pixelate options, hidden closed-menu Pan state, annotation-popover
  obstruction, and fragmented Appearance endpoint captions. Tiny/offscreen annotation targeting and
  custom hover remain source/hardware verification concerns, not new hardware failures.
- Checked all 32 baseline app/core/UI/configuration/project hashes: unchanged. Only review documentation
  and ignored operational evidence were written in the workspace. The private harness was not applied.
- Restored the previously tested simulator app and normally launched it without review arguments.
  No physical-device call, new deployment, commit or publication occurred.
- Checked relative links and private-data patterns across all nine changed review/navigation records:
  no missing targets or pattern hits. Monthly task layout remains valid; detailed task stays at the root.

## Next action and limits

The review is complete; proposed app changes have not been applied. Start a subsequent implementation
task with HIG-01/02, followed by contextual annotation controls, preserving the existing product choices.
The owner is unavailable for headset checks; leave those pending without asking for immediate validation.
Installed Release 1.0 (10) identity remains verified, with its earlier normal-launch check awaiting unlock.

The prior short-filename largest-text audit passed; it did not cover the new long-filename case. These
records are complementary, not a reason to erase earlier results or claim all large-text layouts pass.
Actual gaze/focus/speech, keyboard, icon motion, Reduce Transparency and hardware resource acceptance
remain unobserved. Simulator screenshots and accessibility trees cannot certify those behaviors.
