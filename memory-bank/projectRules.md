# Project rules

These rules apply with [AGENTS.md](../AGENTS.md). They carry the Apple-default UX requirements into this
repository so no sibling checkout is required. Rules 14–15 retain their original identifiers for continuity.

1. **Native platform applications.** Swift 6, SwiftUI and Apple frameworks; native visionOS and macOS shells; no compatibility-mode editor,
   backend, accounts, telemetry, external packages or unnecessary immersive environment.
2. **Immutable original.** Privately copy an imported file while access is valid; never edit/overwrite its
   bytes. Export and Photos save always create new artifacts/assets.
3. **One coordinate system.** Upright source pixels, top-left origin. Preview fitting, zoom, pan and
   display scale must never determine export resolution or annotation geometry.
4. **Nondestructive state.** Geometry, crop constraint and editable annotation objects belong in value
   state. Undo history contains no image buffers. A deliberate inspector edit is one undo transaction.
5. **Full-resolution export.** Decode source data for export, handle all EXIF orientations, crop before
   annotations, clip drawing to output and create fresh metadata. PNG preserves alpha; JPEG flattens white.
6. **Shared composition semantics.** Preview and export use a source-anchored pixelation grid and the same
   annotation order. Pixelated regions replace original detail even when the source has transparency.
7. **Bound work before paying its cost.** Validate dimensions, finite numbers and safe integer ranges
   before allocations/conversions. A 2048-pixel preview is the display ceiling; per-image caps alone do
   not establish aggregate memory safety.
8. **Image work off the main actor.** Import/render/encode outside UI execution. Propagate cancellation,
   serialize expensive export work and reject stale completions using current request ownership.
9. **Permissions at the operation.** PhotosPicker selects without broad library reading; saving requests
   add-only permission. Security-scoped file access stays active while the private copy is created.
10. **Evidence levels stay separate.** Source inspection, SDK declarations, compile results, simulator
    checks and physical behavior are different. Test the actual recipient before claiming paste/share.
11. **Private screenshots stay private.** Use synthetic fixtures; capture only app elements where possible.
    Simulator workspace screenshots and raw device logs remain local and ignored. Publish no personal pixels.
12. **Research is isolated.** Capture belongs in `GlassImageToolsCaptureProbe`. Authorization comes from
    public system APIs and actual consent; framework availability does not authorize arbitrary sources.
13. **Use the system window.** SwiftUI owns native resizable windows, materials, toolbars, focus and sheets.
    No custom window chrome, forced color scheme or window manipulation through competing UI owners.
14. **No ornaments for controls inside visionOS sheets.** Controls needed by a sheet live inside its
    content surface. Do not rely on TabView/hand-built ornaments being visible or accessible in a sheet.
    Choose native in-surface pickers or grouped controls appropriate to the task.
15. **Apple HIG patterns by default.** Every surface uses the platform's native pattern unless the user
    explicitly requests otherwise. Modal editors use sheets, a clear title, grouped Form content and
    standard Cancel/primary-action placement. Do not invent title-bar buttons or custom chrome for editing.
16. **Stable accessible interaction targets.** Canvas identity must survive Crop/Annotate mode changes
    while exposing actual crop controls. Verify the accessibility tree and real drawing/undo interactions.
17. **Read installed identity back.** A failed build may leave an old product. Install only a successful
    fresh build and verify display name, version/build and launch before reporting deployment success.
18. **Public means no private infrastructure.** No real device/host identifiers, home paths, team/account
    identifiers, personal screenshots, credentials or signing artifacts in tracked source/docs/tests/logs.
    Neutral examples must stand for no real machine. Raw evidence belongs in ignored local storage.
19. **Do not infer Git authorization.** No incidental initialization, commits, resets, merges or publication.
    A public-repository plan is a hygiene requirement, not permission to publish.
20. **Complete behavior and honest failures.** No empty production implementations, fake completion,
    silent error swallowing or hidden test fixtures. Every recovery action offered to a user must work.
21. **Meaningful verification.** Core changes require `swift test`; UI/services require native builds and
    focused integration/UI checks. Read exit status and suite summary; build-for-testing is not a UI run.
22. **Reproduce before generalizing.** Inspect the current diff, call sites and failing input before a
    platform explanation. Label hypotheses; update historical claims explicitly when new evidence changes them.
23. **Current project configuration is checked in.** `project.yml` is the XcodeGen source; regenerate the
    Xcode project after membership/settings changes. Local signing overrides stay ignored.
24. **Test fixtures require two gates.** Compile fixtures/integration checks only in Debug and run them only
    with explicit testing arguments. Normal startup and Release must never load them.

25. **Opaque foreground above appearance.** Window Opacity/Glass apply only to rear background surfaces.
    Keep the image workspace and foreground text/buttons at full view opacity on the front plane. Crop
    handles and editable annotations stay above image pixels; native sheets/toolbars retain their own
    surfaces. Never fade a shared foreground/window ancestor. Preserve source alpha and export semantics.

26. **Explicit accessible image actions.** Use the native PasteButton, native color wells and grouped
    Forms with visible/spoken labels and pixel units. Pair dimensions normally and adapt for large text.
    Keep crop controls reachable during zoom/Pan without changing source geometry. Provide named precise
    adjustments and native inspector alternatives; passing audits do not certify hardware speech/focus.
27. **Provider ownership precedes decoding.** Retain only validated private copies, bound encoded bytes,
    share the preview worker and propagate provider cancellation. Keep progress honest while synchronous
    image work finishes; do not read the clipboard in the background.
28. **Keep chosen colors and wide gamut.** Annotation colors are extended-range sRGB; a valid palette
    color must never fail validation. Keep Display P3 output for wide-gamut sources or colors and sRGB
    otherwise. Test with an actual P3 color, not only in-gamut system colors. Give native ColorPicker
    bindings value-equal colors (`Color(.sRGB, …)` is extended-range); a fresh CGColor-backed Color
    per read intermittently dropped palette selections.
29. **Readable content clears system ornaments.** The bottom toolbar overlaps the window edge. Keep text,
    controls and scroll endings above `ImageWindowAppearance.bottomOrnamentClearance` and confirm in the
    compositor; accessibility frames cannot show ornament overlap.


## Adjustable visionOS window surfaces

Keep one rear window material/paint owner. Persistent navigation containers introduce independent glass
above it and can defeat clear settings. Use the existing plain SwiftUI columns/native controls and hide
List/Form scroll backgrounds; keep system selection, hover and modal surfaces. Foreground image alpha,
buttons/text, source pixels and history stay independent. Verify both side panels at actual 0/0 through
the simulator compositor plus real interactions; preference values or successful builds alone are insufficient.
[Regression and evidence](261019_transparency-regression.md).

30. **Public claims are checkable and dated.** The website, README, `PRIVACY.md` and `SECURITY.md` state
    facts a stranger can verify in the source or on a device. Testing status (what was checked, where,
    and what wasn't) belongs in the README and STATUS, not on the website; the site keeps only limits a
    reader would act on, such as assistive features not yet tried on a headset (owner, 2026-10-23).
    A change to data flow, permissions, storage or limits updates `PRIVACY.md` and the site in the same
    change. No urgency, selling or unverifiable comparisons on the site.

31. **Explicit image-link requests only.** Owner-authorized HTTPS Paste may fetch one direct image using the bounded private importer. Prefer image bytes, never scan ordinary clipboard prose for links, never upload images or use shared cookies/cache/credentials. Validate redirects, cap bytes during transfer, propagate cancellation and keep public privacy/store claims accurate. See [the scope decision](261103_paste-image-links.md).

## Native Mac extension — November 5

Use the native macOS NavigationSplitView, inspector, toolbar, menu bar, Settings and Open/Save panels.
The visionOS rear-surface exception does not require hand-built Mac navigation columns or glass controls.
Keep actual App Sandbox enabled with the four grants in Mac/GlassImageToolsMac.entitlements; build-script
sandboxing is a separate flag. Text responders retain Select All/Cut/Copy/Paste/Undo/Redo. Reuse shared
source-pixel models and inspectors. Never infer runtime sandbox behavior from Xcode's injected test app.

**Mac GUI tests belong in the headless VM** (owner, November 5). Host compilation/core tests may run
normally; interactive launches, pointer/keyboard automation and GUI captures use the isolated guest.
Preserve existing host windows and VMs. Keep clipboard/audio/graphics bridges off and never share the
whole repo, signing environment or personal image files. Do not automatically accept OS capture or
accessibility prompts; preserve an approval rejection and continue unaffected checks when possible.

**Match the established editing toolbar** (owner clarification, November 5). Use Vision Pro's actual
EditorView as the reference: mode → contextual tools → zoom/view → settings. Annotate groups shapes
in one chooser with separate Select/Draw/Text/Pixelate controls. Preserve grouping and order across
platforms while using native placement/menus/settings. Do not reinterpret “same toolbar” as flattening
all shapes into separate buttons. [Correction](261105_mac-toolbar-parity.md).

**Mac Settings belongs in the main toolbar**, directly before Inspector (owner screenshot, build 41).
Keep it available without an image. Only open images get the editing accessory row. This explicit
refinement supersedes placing Mac Settings at the end of the Vision Pro-like editing row; visionOS
keeps its current gear placement.

**Mac toolbar layout refinement (approved November 5, build 42):** leading Open Image before title;
standard fixed spacers separate history/document/view actions. Keep Markup hideable with a native toggle,
View command and keyboard shortcut, and provide menu equivalents for toolbar editing actions. Preserve
Vision Pro's editing-tool grouping/order and trailing Mac Settings/Inspector. [Record](261105_mac-native-toolbar.md).

**Use the actual Preview Markup reference for Mac editing chrome** (owner image, build 43). Avoid compact
scope-button styling for drawing actions. Native SwiftUI borderless buttons and AppKit pop-up controls
are appropriate; keep semantic labels, consistent targets and system menu arrows. A stock native control
adapter is preferable when toolbar synthesis ignores needed label sizing. Preserve shared editing state.

**Compact, centered Mac Markup** (owner, November 6, build 44) supersedes build 43's large treatment.
Use body-sized symbols and smaller native menu symbols with forgiving targets. Center the content row
inside the native accessory bar; verify actual bounds, since ToolbarSpacer did not expand in this
placement. Keep native edge arrows, existing tool order/actions and the main toolbar unchanged.
