# Sidebar and toolbar refinement — October 18, 2026

State: DOCS / complete authorized implementation and installation. Prior [document workspace](261018_document-sidebar-and-inspector.md).

Objective: Native collapsible wider Images sidebar, Recents initially collapsed; source metadata in the title bar; grouped document actions independent of the inspector toggle; in-pane Done; separate circular image close; immediate Shapes menu; + opens a fresh window with explicit acquisition choices, caret imports into this workspace.

Authorization: Owner requests implementation and retains local build/test/documentation and paired Vision Pro signing/install/normal-launch authorization. No publication or Git operations.

Owners/reuse: Extend EditorView, DocumentSidebar, existing inspector Forms, app WindowGroup and native UI regressions. Preserve DocumentWorkspace/source/edit/history owners, async import cancellation and save/discard/cancel. Glass Power Tools MacWorkspaceView native Menu primary action inspected; visionOS uses native grouped Button and Menu for distinct hit targets.

Constraints: Apple controls/materials; immutable originals, source pixels and opaque foreground; no new permissions/dependencies/persistence. SwiftUI inspector remains SDK-unavailable, so the native trailing Form composition remains.

Acceptance: Actual disclosures/reopening, new-window acquisition choices, immediate Shapes menu, accessible title/metadata and actions at largest text; independent inspector with Done inside it; safe Close workflow; native build and focused UI checks. Signed installation identity and physical input observation remain separate.

Risks/next action: Title-bar pressure, collapsed section selection, window isolation and toolbar grouping. Inspect current SDK and actual UI bounds; retain failed assertions and distinguish runner finalization from completed assertions.

## Implementation checkpoint

- Native sidebar Sections use expansion bindings; Open Images starts expanded, Recents collapsed. Ideal width 320 points, 340 at accessibility text sizes, versus 260 previously.
- Native ControlGroups group +/caret and document actions; the right inspector toggle remains a separate toolbar item. + targets the editor WindowGroup; the empty workspace offers explicit system Paste, Photos and Files. The capture experiment registers the same ordinary editor scene so its shared editor action has a valid destination.
- Inspector confirmation uses a shared in-pane native heading and Done above each Form. Close Image is a circular system button in a separate editor row; it retains save/discard/cancel. Shapes is now an ordinary Menu without a primary action/hold requirement.
- Initial native build-for-testing succeeds. The first three UI cases have one pass (immediate Shapes/drawing/resize/crop) and two failures: the native ControlGroup promotes buttons without their SwiftUI identifiers, and the compact largest-text title is omitted at principal placement. Tests now resolve the real visible/spoken toolbar labels; metadata moves to a leading native toolbar item, with a wider detail-column minimum to preserve controls. Those changes require fresh verification.
- Installed SDK declarations allow collapsible Section and ControlGroup; SwiftUI ToolbarSpacer/sharedBackgroundVisibility are explicitly unavailable on visionOS. No unavailable API or custom capsule/background substitute is introduced.

References: [Apple ControlGroup](https://developer.apple.com/documentation/swiftui/controlgroup), [Apple OpenWindowAction](https://developer.apple.com/documentation/swiftui/openwindowaction); actual installed SDK declarations and sibling MacWorkspaceView were inspected.

Second QA checkpoint: native palette accessibility, collapsed-panel Files/Cancel, immediate Shapes and largest-text title/caption cases pass. Workspace lifecycle stops at two assertions because a panel identifier applied outside safeAreaInset propagated onto Done. The identifier now belongs directly to the Form before adding the header, preserving both native container and confirmation identities. Native title-bar ancestry replaces comparisons across ornament/content coordinate spaces. Final source needs fresh UI/service checks; signed Release build/analyze/signature/privacy pass and the updated isolated probe compiles. Repeated result-finalization stalls are isolated to this task runner after completed assertions; fresh runs use a 30-second finalization grace and retain native interruption status.

## Final result and evidence

Release 1.0 (20) is installed, identity verified and launched normally; the running app process was read back.

All 42 native service/model checks pass. Seven distinct final UI cases pass their assertions,
including disclosures and reopening, close cancellation/discard, independent panels, real picker return,
new-window acquisition, system palette/live color/Undo, immediate Shapes/resize/crop, editable rotated
text, and largest-text title/caption layout. Native all-issue audits ignore no app finding. The final six-case command exits 0; the separate new-window command also exits 0. Earlier failed iterations and their interrupted result finalization remain historical. No
full UI suite is claimed. Core source/tests are unchanged, retaining the build-19 62-test/four-suite baseline;
the core suite was not rerun. Signed Release build/analyze, strict signature/privacy/debug exclusion and
separate device-SDK probe compilation pass. Final UI, services, signed and applied App/Core sources agree.

Physical gesture/assistive/focus/keyboard, appearance/motion and resource validation remain manual. No new recipient or capture capability is claimed.

### sidebar-first

Native exit -15; 236.25 seconds. Executed 3 tests, with 2 failures (0 unexpected) in 66.124 (66.141) seconds Finalization interrupted: True.

### sidebar-refined

Native exit -15; 346.821 seconds. Executed 5 tests, with 2 failures (0 unexpected) in 195.539 (195.554) seconds Finalization interrupted: True.

### sidebar-final

Native exit 0; 310.012 seconds. Executed 6 tests, with 0 failures (0 unexpected) in 273.871 (273.887) seconds Finalization interrupted: False.

### sidebar-new-window-initial

Native exit -15; 85.254 seconds. Executed 1 test, with 2 failures (0 unexpected) in 26.195 (26.201) seconds Finalization interrupted: True.

### sidebar-new-window

Native exit 0; 29.176 seconds. Executed 1 test, with 0 failures (0 unexpected) in 22.699 (22.703) seconds Finalization interrupted: False.

Signed Release build/analyze: exit 0, 25.389 seconds. Strict signature/privacy/debug marker checks pass; only Photos add-only usage and standard development signing keys. Both Release warnings are the examined AppIntents metadata skip. The existing Debug-only weak-observer warning belongs to the lifetime check; weak observation is retained. Separate probe compile: exit 0, 6.031 seconds; no capture execution claimed. XcodeGen regeneration changes only the two build-number settings. Staged implementation applied only after baseline conflict, source identity and private-content checks. No Git, publication, dependencies, permissions or rendering/model changes.

[Sanitized validation](../Documentation/Validation/sidebar-and-toolbar-refinement.json), [physical deployment](../Documentation/Validation/physical-deployment.json).
