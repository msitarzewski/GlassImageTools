# Window transparency regression — October 19, 2026

Historical implementation/validation checkpoint from October 19. The October 21
[documentation reconciliation](261021_memory-and-release-docs.md) confirms unchanged build-22 source.
For current follow-up use [active context](activeContext.md); old unlock/launch statements below are
recorded observations, not a new query or current lock-state claim.


State: DOCS; reviewed/tested/applied, deployment recorded. [Build-20 baseline](261018_sidebar-and-toolbar-refinement.md).

Objective: Restore Opacity/Glass settings, including a clear background at 0/0, across the editor/sidebar/inspector while preserving opaque image/controls, current document navigation, in-pane Done and native interactions.

Authorization: Owner requests this correction and explicitly references Glass Power Tools. Local edits/build/test/docs and paired Vision Pro signing/install/normal launch remain authorized. No Git/publication/delegation.

Owners/reuse: Existing ImageWindowBackground/AppStorage remains the one rear surface owner; EditorView replaces navigation-container columns with the Glass-family SwiftUI layout pattern. Keep native List/DisclosureGroup, Form, buttons/menus, system sheets and bottom toolbar. No source/render/history ownership changes.

Evidence and risk: Sibling GlassSpatialWindowGlass/GlassSpatialColumns explicitly document system material from NavigationSplitView/NavigationStack and use plain-window columns. These containers exist in build 20 above the unchanged rear background. Reproduce with actual clear settings/compositor; confirm supported API declarations. Plain-list disclosure selection, title sizing, contextual Form editing and appearance foreground/input need regressions.

Acceptance: Clear/partial/opaque backgrounds visibly respond; image pixels and controls do not fade. Independent sidebars/disclosures/Recents, text editing, crop/copy, native palette and new-window imports remain usable. Simulator observations, automatic audits and hardware launch/input remain separate.

Toolchain: Default Xcode selection changed to 27.1/visionOS SDK 27.0. Installed Xcode beta 27.2/visionOS SDK 27.2 remains available; task helpers select it explicitly without changing the global developer directory.

## Reproduction

The added clear-background UI case sets both native sliders to 0, opens both side panels and captures actual compositor views. Build 20 retains two navigation bars and a visibly grey sidebar/canvas/inspector plate; the new assertion fails (2 versus 0). Existing appearance controls and native interactions work, so saved preferences are not the cause. Settings itself remains a native modal surface intentionally.

Implementation replaces only persistent navigation-container columns with a matched 92-point heading and native SwiftUI column layout. Native plain Lists use DisclosureGroup and hidden scroll backgrounds; inspector Forms retain grouped controls with hidden scroll backgrounds. Appearance keys, one rear glass/black plane and full-opacity foreground remain. Native modal navigation containers and the bottom system toolbar remain.

## First correction QA

Document switching/Undo/close/Recents and largest-text cases pass. The new transparency case has one failed assertion: an unnecessary native endpoint drag changes an already-selected 0% Opacity to 5%. No navigation bars remain, and compositor views show the room through all three columns with image pixels intact, but that capture is not claimed as exact 0/0. The helper now leaves an already-matching slider value untouched. Plain List rows keep their system backgrounds/selection instead of explicit clear row overrides, matching the sibling pattern. Re-run exact 0/0, native foreground interaction, persistence, palette/audits and navigation before deployment.

## Native Form visibility diagnostic

The palette audit case reports one scroll-helper failure, while its subsequent real Add at Center, selection, palette RGB/live change/Undo and app audits complete. Its snapshot places the 332×64.5 Add at Center button fully inside the 380×668 native Form. The no-container layout can report a nonhittable/-1 point for a visible SwiftUI Form action. The test helper now stops scrolling when the full row lies in its native Form viewport; actual tap and resulting selection/palette assertions remain unchanged. This is an automation observation, not a physical-input certification. Production source remains unchanged.


## Applied result and validation

Release 1.0 (21) is installed and identity verified; normal launch/process verification awaits headset unlock.

The sidebar rebuild introduced persistent navigation-container material above the unchanged adjustable
backplate. Build 20 reproduces a grey plate at Opacity/Glass 0/0. The editor now follows Glass-family
plain SwiftUI columns with one rear native glass/paint surface. Native List/DisclosureGroup selection,
Forms, Buttons, Menus, ControlGroups, system modal presentation and bottom toolbar remain. Native header
controls retain leading image metadata, grouped document actions, separate sidebar toggles and in-pane
Done. Appearance preferences, opaque foreground and source/render/history owners are unchanged.

Six distinct UI cases pass on the final app source across stages: exact clear/opaque/glass with both
panels, largest-text title/caption, appearance persistence/reset and real crop/text/drawing/Undo,
document switching/Recents and system picker return, native color palette/audits, and separate-window
acquisition. Earlier failed assertions, test-query corrections and result-finalization limits remain
recorded; no clean full six-case suite or full UI suite is claimed. All-issue app audits ignore no finding.
The final four-case command exits 0 (392.085 seconds).
All 42 native service/model checks pass. Signed Release build/analyze, strict signature/privacy/debug
exclusion and isolated device-SDK probe compilation pass. Final UI/services/signed/applied App/Core
sources agree. Core source/tests are unchanged; the prior 62-test/four-suite baseline was not rerun.
Compositor views show the clear room, black opaque paint and native glass while image/controls remain
full-strength; this is visual observation, not an automated pixel-equivalence test.

Hardware appearance/gaze/hand/assistive/focus/keyboard, motion/Reduce Transparency and resource/recipient
acceptance remain separate. No new capture capability, permissions, dependencies or networking.

Reviewed ten implementation/test/project files against the staging baseline; application is conflict-free.
No core/model/service/AppearanceSettings changes. Native simulator access failed once before assertions
(exit 70); supported authorized execution restored access. Broad five-case execution retained two passes
(clear/largest) and three failures (ten assertions): Form hit-point hint, a slow native picker Cancel,
numeric selection plus cascading unchanged crop/history checks and ambiguous Done. Corrected test
queries retain actual user actions and exact output/history checks; no production edit followed those
failures. Earlier endpoint-helper failure and interrupted Xcode result finalization remain in the evidence.

Actual command exits/times/case names, 42 service results and signed/probe results are linked in
[validation](../Documentation/Validation/window-transparency-restoration.json). The final-source clear
compositor was inspected alongside opaque/default-glass captures; raw screenshots/logs remain private.
Native source/Release excludes Debug fixtures and probe; only add-only Photos usage remains. Two expected AppIntents metadata skips were examined; this editor has no AppIntents dependency.

Installation exits 0 in 4.004 seconds; installed identity exits 0 in 1.067 seconds. The supported lock-state check exits 0 and reports passcode required. Normal launch was not attempted while locked.

Next action: normal launch/process verification after unlock; do not reinstall unchanged code.
