# Decisions

Dates record the current project's known history. Status means what the evidence supports, not an
approval inferred from documentation. Link substantive changes to their task and actual validation.

## 2026-10-15 — Product name is Glass Image Tools

**Status: Approved and implemented.** The owner explicitly replaced the VisionSnip working name.
The Xcode project/scheme and displayed app name use Glass Image Tools. Internal `VisionSnipCore` and
configuration variable names remain to avoid needless implementation churn. Physical installed metadata
confirmed the display name for 1.0 build 2. [Status](../Documentation/STATUS.md) owns deployment evidence.

## 2026-10-15 — Native editor before capture integration

**Status: Approved and implemented as the architecture.** The owner's brief prioritizes Photos/Files
→ crop → annotate → copy/share using Apple default UX. An ordinary visionOS window and local Apple
frameworks satisfy this scope with no backend/external dependencies. Capture research stays in its own
visionOS 27 target so uncertain APIs/consent cannot block the reliable editor. Hardware capture remains
unconfirmed; see [the matrix](../Documentation/CAPTURE_CAPABILITIES.md).

## 2026-10-15 — Source-pixel nondestructive model

**Status: Approved and implemented baseline.** Immutable sources and bounded upright previews are separate
from editable value geometry. Export uses full-resolution source pixels and crops before annotations;
undo contains no images. This follows the build brief and reduces source duplication. The audit showed
composition, numeric-input and undo-transaction defects within that architecture; remediation extends
existing owners rather than replacing the model. [Local model](data-model.md) describes ownership.

## 2026-10-15 — Public repository and private local configuration

**Status: Approved requirement; implemented and public-content scan passed.** The owner declared that this
will be a public repository. Public docs/configuration must be self-contained and exclude team/account,
device/host/home-path details, personal screenshots and credential/signing artifacts. Signing overrides
and raw evidence stay ignored. This decision does not authorize Git initialization, commits or publication.
See [security](security.md) and the [original remediation task](261015_security-remediation-and-memory-bank.md).

## 2026-10-15 — AGENTS 2.1 project adaptation

**Status: Approved requirement; populated guide and link/consistency review completed.** The owner
requested a full AGENTS 2.1 or 2.2 memory bank. This repository uses the actual eight-section 2.1 structure,
including seven workflow states, startup/logging, task contracts, budgets, quality, examples and troubleshooting.
Authorization guidance respects the owner's local-work and persistent physical-deployment permissions;
it does not add repeated human approval gates to already authorized work. No new external AGENTS 2.2
standard is asserted. [AGENTS.md](../AGENTS.md) is canonical; [the index](toc.md) defines durable file roles.

## 2026-10-15 — Privacy verification and temporary-file ownership

**Status: Implemented under the owner's remediation/privacy instruction.** Privacy claims use actual
encoded pixel/metadata tests, including alpha and fractional-edge redaction. Dedicated private working
roots purge prior-process files once on the next launch, retain current owners and request protection/
backup exclusion. Cleanup first validates ownership; sources use neutral filenames. Immediate post-kill
deletion cannot be promised. Host/simulator tests passed; locked-device/backup behavior needs hardware
verification. Clipboard retains local-only Apple lifetime because no optional expiry preference was
received. [Security](security.md) and [the task](261015_security-remediation-and-memory-bank.md)
record scope and evidence.

## 2026-10-15 — Flattened image saves and live annotation objects

**Status: Implemented and verified in build 5.** The owner explicitly approved the editor/icon plan and
confirmed flattening to ordinary images when closing. Keep editable vector geometry/text during the open
session and encode PNG/JPEG copies through existing export services. A reopenable project format is outside
this iteration. Native popovers expose live style/text controls while the canvas stays visible. See
[the approved plan](261015_editor-polish-and-glass-icon-plan.md).

## 2026-10-15 — Larger closed toolbox and recognizable crop rulers

**Status: Owner-requested; implemented, catalog-verified and installed in build 7. Superseded by the
2026-10-24 round picture icon (build 28).** After
build 6 the owner requested more icon coverage, a classic closed-toolbox silhouette and correction of the
crop emblem. Use original pitched-roof/handle vector geometry and two substantial broken L-shaped crop
rulers, with the red/neutral/steel family palette and three native depth planes. The measured foreground
union grows from 20.51% to 28.49% of the canvas, a 38.86% area increase, with 698 × 629 inclusive bounds
and a 412.64-pixel maximum radius. The 440-pixel guard is an internal authoring constraint, not an Apple
safe-area specification. Native catalog compilation and static-mask proofs passed. Release 1.0 build 7
was installed and normally launched with identity/process verification; installed clipping, lighting and
parallax remain unobserved. [The icon guide](../Tools/Icon/README.md) owns the portable recipe;
[the task](261015_editor-polish-and-glass-icon-plan.md) owns acceptance.

## 2026-10-15 — Native service-window appearance and bottom zoom control

**Status: Owner-requested; implemented, verified and installed in build 7.** Match the
family service-window geometry using a plain SwiftUI window, one native glass backplate, continuous
46-point radius and 22/34/26-point side/top/bottom insets. Use the system edge without a border stroke.
Remove the root NavigationStack background, retain a native top title ornament and keep the capture
probe's return action in the bottom toolbar. Show current zoom beside the bottom magnifier and remove
the lower-left crop footer while retaining crop-axis labels.

A native settings gear/sheet/Form exposes independent local Opacity and Glass sliders, defaults 0/1,
and a read-only System Glass material. Reduce Transparency resolves both to 1 and disables settings;
image pixels and controls do not fade with window presentation. This extends presentation owners only:
no backend, dependency, capture source or image/export permission change is included.
[Technology context](techContext.md#current-presentation) records configuration.

## 2026-10-15 — Verify native canvas event delivery and numeric display

**Status: Observed UI defects corrected and verified in build 7.** Build 7 UI execution showed a clear sibling gesture
layer did not reliably deliver image input after the plain-window change. Moving drag/tap onto the visible
vector image makes the same native input create rectangle/text objects. Double-gated Debug scene-local
markers guide event synthesis through real gestures and must stay out of Release. The text case
passed in the focused two-case run; the other case created a rectangle but failed its sole width assertion
because a near-300 floating width displayed as 299. Safe bounded display rounding and a source regression
are implemented and verified by actual fractional-origin model/service and UI checks. The expected
300-pixel dimension was preserved rather than weakened to mask the defect. The settings test's persistence/reset assertions passed after its incorrect Material accessibility
assertion failed, so the overall case still failed. Signed Release build/analyze, separate probe SDK compile
and Release test-code/permission/icon boundaries passed. The final full UI suite passed 11/zero in
277.766 seconds, followed by the caption-only focused appearance pass in 32.615 seconds; all 15 native
model/service checks passed. Applied hashes matched tested source, and physical build 7 installed/launched
normally with identity/process readback. The unchanged core source/test hashes retain the 42-test baseline;
that suite was not rerun. A stopped earlier diagnostics invocation remains distinguished from completed
assertions and successful final commands. New hardware interactions/icon motion and toggled Reduce
Transparency behavior are still unobserved. [Testing guidance](testing-patterns.md),
[the task record](261015_editor-polish-and-glass-icon-plan.md) and
[sanitized iteration evidence](../Documentation/Validation/window-appearance-and-icon.json) retain actual scope.

## 2026-10-15 — Rear-only appearance surface with normal-plane foreground

**Status: Owner-requested; implemented, validated and installed in build 8; normal launch unverified.**
The owner requires images/buttons/text to remain opaque above the appearance surface. The final workspace
keeps opacity 1 at native interaction depth 0/stacking index 1 and places only glass/tint at depth -1/index -1.
An earlier foreground +1 experiment missed native endpoint/control input; its failure is retained rather
than presented as a working spatial layout. Crop/selection/annotation overlays remain above the image,
while native title/toolbars keep system surfaces. Source alpha, original bytes and exports are preserved.

Four unique UI cases passed across the rear-only run and final 113.651-second appearance retry. Native
slider extremes/persistence/reset, exact crop/history, opaque rectangle input and clear text re-edit/Undo
passed. The initial one-pass/three-failure run and later selection-menu setup failure remain historical
evidence. No full eleven-case rerun or new core/service run is claimed: their hashes retain build 7's 42/15
baseline. Signed final Release/analyze, separate unsigned probe SDK compile, Release exclusions and exact
applied source hashes passed. Device installation and metadata confirmed Glass Image Tools 1.0 build 8;
two normal-launch SDK commands timed out after 40 and 30 seconds, and a completed process query after the
first found no matching process. Normal launch is unverified; no timeout cause is established.

Separate settled simulator compositor checks found seven opaque color interiors identical across
0/1, 1/1 and 0/0 appearance settings. The 1,031,318-pixel image region matched exactly glass/opaque;
clear had 2.63% rendered-edge differences, maximum 18/mean 0.0987 channel levels. These bounded metrics
are not a full-scene identity claim or physical visual acceptance. Raw images stay private; unsupported
manual XCUIScreen captures are not proof. [Technology context](techContext.md#current-presentation),
[testing guidance](testing-patterns.md#foreground-layering-checks--build-8),
[the task record](261015_editor-polish-and-glass-icon-plan.md) and
[sanitized evidence](../Documentation/Validation/foreground-layering.json) record scope.

## 2026-10-15 — Full native UX iteration and explicit paste ownership

**Status: Implemented and verified locally/simulator; physical limits recorded.** Provenance: the owner
explicitly directs all five queued workstreams to proceed, superseding the feedback hold. Retain native
Forms, PasteButton and ColorPicker; extend existing source/history/import owners rather than introduce
parallel pipelines. Display-only reachable crop proxies preserve source boundaries while zoom/Pan works.
Owned provider copies and one preview worker preserve immutable bytes, bounded work and cancellation;
encoded inputs are capped at 256 MiB. Native named actions/Add at Center provide precision alternatives.
Large-text title placement is above the window after a compositor check exposed label occlusion.
The accessibility audit distinguishes app automation, actual system palette interaction and manual
headset acceptance; it makes no full accessibility certification from passing automation.

## 2026-10-16 — Native contextual panel, compact tools and direct PNG sharing

**Status: Approved by the owner's “Proceed with all of them”; implemented/applied in prepared build 11.**
Provenance: [HIG-01–08 review](../Documentation/HIG_REVIEW.md) and the subsequent implementation instruction.
Use a native in-window annotation Form beside the canvas instead of the obstructing popover. Preserve
live editable vectors with separate form/gesture/context Undo boundaries. Since `.inspector` is unavailable
on visionOS, extend existing SwiftUI owners rather than add a custom framework or immersive surface.

Actual native toolbar execution clipped a two-row proposal, so the toolbar adapts within one row and uses
a compact native Drawing Tools menu. Native symbol bridging exposed Pixelate as Small Grid despite
label/AX overrides; plain text commands passed actual name/selection checks. Keep the single tap/hold
Shapes chooser and magnifier/current zoom with persistent Pan feedback. *(Tap/hold superseded by build 20:
Shapes is an ordinary Menu that opens on a normal tap; see the 2026-10-18 new-window decision.)*

Direct native Share defaults to an immutable flattened PNG snapshot through the existing export queue.
Keep explicit format/quality/save options in Export. Provide no original thumbnail to the system preview.
Fifty-seven core, 30 native service and 25 UI cases passed across recorded runs, with failures/command
limits retained. Build 11 is prepared locally, not installed; headset/recipient/resource acceptance remains
separate. [Implementation and evidence](261016_apple-hig-fixes.md).

## 2026-10-16 — Let native visionOS toolbar items own sizing and spacing

**Status: Owner-approved; implemented/applied in prepared build 12.** Provenance: the owner approved
simplifying custom chrome and explicitly requested comparison with Glass Power Tools visionOS. Its
GlassNativeWindowFrame provides controls separately to ToolbarItemGroup, avoids forced icon-only label
sizing and uses capsule title glass. Adopt those patterns without importing a dependency or macOS-only
Liquid Glass behavior. Preserve existing native rear glass/appearance, opaque image and editing state.

The native toolbar still needs a responsive command set: actual largest-text inspection measured 802
points in a 720-point window despite a passing audit. Move Options into Drawing Tools only at compact/
accessibility sizes; the strengthened native bounds/action test passes at 715.5/720. No smaller custom
control targets are introduced. Remove redundant outer glass around the native annotation panel; keep
responsive metadata/actions app-composed in their native title ornament. [Implementation](261016_native-glass-chrome.md).

## 2026-10-17 — Contextual right Tool Options and local Apple image captions

**Status: Owner-requested; implemented/applied/deployed in build 14.** Provenance: the owner asks to
remove the redundant Shapes checkmark, move Tool Options to a right sidebar and display Apple's image
description in the main panel. Automatic description was the stated working interpretation while an
optional saved-caption clarification remained unanswered; stored Photos caption retrieval is outside
this implementation. Existing same-headset signing/deployment authorization persists.

Reuse the existing native right Form/transaction owner, open it with Annotate and put its native sidebar
toggle in document actions. Retain current Shapes symbol, traits/tint and tap/hold, without the extra
checkmark. `.inspector` remains unavailable on visionOS; no navigation hierarchy or custom framework is
introduced. The canvas/source/edit/render/export owners remain unchanged.

The explicit caption request supplies the demonstrated need for this scoped AI feature. Use Apple's
SystemLanguageModel only, gated to actual visionOS 27/model/vision support. No cloud fallback, tools,
network client, new permission or external package. Infer from the bounded upright original preview,
one operation across windows with visible busy/retry states. Source-keyed view state owns text and
cancellation; the app stores no caption/transcript and excludes it from image Copy/Share/save/history.
Three visible native lines keep the caption footprint limited; it is informational and can be inaccurate.

The exact service generated real text from synthetic pixels on Vision Pro. Ten UI cases pass across
broad nine/ten and a focused native palette/RGB/live-color/Undo retry; the initial host failure is retained
without a causal claim. Signed build/analyze/signature/privacy and nine-file conflict-free application
pass. Installed identity, normal launch and independent process readback pass. Hardware editor/gaze/
speech/resource/recipient and capture limits remain separate. [Task](261017_tool-sidebar-and-image-caption.md),
[evidence](../Documentation/Validation/sidebar-and-caption.json).

## 2026-10-17 — Clear drawing, sliding tools and quiet descriptions

**Status: Owner-requested; implemented/applied/deployed in build 15.** Show bounds only with Select, preserving vector editing/history. Use standard SwiftUI motion around the existing native right Form, with Reduce Motion respected; actual SDK still excludes inspector on visionOS. Caption text gets padding/wrapping/native scrolling. This supersedes build 14’s three-line limit and visible loading/unavailable/retry presentation: owner explicitly requests no placeholders if there is no description. The on-device service, original-image scope, resource/privacy boundaries and export exclusion are unchanged. [Task](261017_drawing-and-sliding-tools.md).

### Build-16 owner feedback: content-sized caption

**Status: Owner-requested; implemented/applied/deployed.** Reduce caption margins and use actual wrapped native content height, with a maximum only for overflow scrolling. This supersedes build-15 caption reservation/spacing; drawing and sliding Tool Options remain. [Follow-up](261017_drawing-and-sliding-tools.md#owner-feedback-follow-up--intrinsic-caption-sizing).

## 2026-10-17 — Formal native left Tool Options

**Status: Superseded placement/implementation; implemented/deployed in build 17, replaced by the build-19 document/right-inspector decision and build-21 plain-column surface decision below.** Historically used NavigationSplitView leading column for supplementary controls, preserving the native horizontal primary toolbar. This supersedes the earlier composed right column. Keep column content declared while hidden; explicit visibility owns inspector edit lifetime, and the split view owns navigation. Native content minima expand the window for readable columns; accessibility sizes keep compact tools. No tab model or vertical toolbar introduced. [Task](261017_native-left-sidebar.md).

## 2026-10-17 — Native split defaults and real rotation

**Status: Owner-requested; implemented/applied in build 18.** Remove loaded outer padding rather than suppressing unsupported native backgrounds. Use one ordinary sidebar button in the native topBarLeading toolbar after both automatic/default-item attempts emit none. Move standalone blue Paste into Import; retain native PasteButton and quick standard Copy. Distinguish Rotate Left from Reset Crop. Rotation belongs in value edits/history and shared source-pixel affine composition, preserving originals and vectors without a second full-size bitmap. Selectable captions use a modest 16-point margin while keeping natural height. Share the existing per-window scene owner with the probe. [Task](261017_sidebar-defaults-and-rotation.md).


## 2026-10-18 — Separate document navigation and contextual properties

**Status: Owner-approved layout; implemented/applied in build 19.** Replace leading Tool Options with actual Images navigation and independently shown trailing Crop/annotation properties. Use the Mac inspector example for grouped context and visibility, with supported visionOS composition: installed SwiftUI/UIKit inspector APIs are unavailable. Leading image metadata and compact native overflow preserve readability. Each open document owns its existing EditorModel/history/viewport; saved closed images flatten as already approved. Session-only bounded Recents and Clear Recents are implementation choices within local-first privacy; no persistent catalog or broader Photos permissions. Failed optional cache copying must not trap close; cancellation retains the open editor. This supersedes build 17's leading property-column placement, while preserving native materials/controls. [Task](261018_document-sidebar-and-inspector.md).

## 2026-10-18 — Separate new-window acquisition and workspace import

**Status: Approved and implemented, simulator-observed.** The owner requests + to create a separate window and an adjacent caret to retain current-workspace import choices, matching the roles of the Glass Power Tools Mac Terminal control. Native ControlGroups own both new/import and document commands; the inspector toggle remains independent. Collapsible Images/Recents navigation, title-bar metadata, in-pane Done and separate editor Close follow the same feedback. Shapes becomes an ordinary Menu that opens on a normal tap, superseding the 2026-10-16 tap/hold chooser. Use supported visionOS composition; do not substitute unavailable inspector/ToolbarSpacer APIs. [Task](261018_sidebar-and-toolbar-refinement.md).


## 2026-10-19 — One adjustable rear surface across workspace columns

**Implemented; owner requested restoration and the Glass Power Tools model.** Keep the existing independent
Opacity/Glass settings and opaque foreground, but replace persistent navigation-container columns with
plain SwiftUI columns and system controls. Build 20 reproduces extra system glass at 0/0; the sibling
window model and actual compositor establish the gap. Native List disclosures/selection, Forms, bottom
toolbar and modal navigation remain. The header uses standard controls and accessible headings/groups;
it does not claim native NavigationSplitView behavior or adjustable column dragging. No private APIs,
new source/render/permission ownership or additional material is introduced.
[Task and validation limits](261019_transparency-regression.md).

## 2026-10-21 — Extended-range annotation colors and wide-gamut output

**Status: Owner instruction ("fix all of these"); implemented in build 23.** The system color palette
can return Display P3 colors, which UIKit reports as extended-range sRGB outside 0–1. The renderer
rejected those values, so a vivid palette color could stop canvas drawing and fail Copy/Share/Export.
`StrokeColor` now stores extended-range sRGB (UIKit's convention), bounded to −2…2 with alpha 0–1;
nonfinite or unbounded values are still rejected. Output uses Display P3 when the source image or an
annotation color is outside sRGB, and sRGB otherwise, so ordinary screenshots keep their previous bytes.
Output remains 8-bit SDR; HDR headroom is not preserved. Pixelation tiles keep the source's gamut.
[Task](261021_review-fixes-and-caption-clearance.md).

## 2026-10-21 — Reserve space above the system bottom toolbar

**Status: Owner-reported defect; implemented in build 23.** The bottom toolbar ornament overlaps the
window's lower edge and the caption ran to that edge. visionOS exposes no ornament inset, so
`ImageWindowAppearance.bottomOrnamentClearance` (32 points) is reserved below the image column and as
bottom scroll-content margins in the sidebar and inspectors. Column dividers still reach the window edge.
The value is checked in the simulator compositor; headset parallax remains a physical observation.
[Task](261021_review-fixes-and-caption-clearance.md).

## 2026-10-21 — Paired dimension fields in the narrow inspector

**Status: Restores an earlier owner request; implemented in build 23.** The owner asked on 2026-10-15
for Width and Height on the same row at normal text sizes. Since build 19 those fields live in the
380-point trailing inspector, where inline label, value and unit stacked; the full UI suite exposed it.
Paired fields now show their label above the value (spoken labels unchanged); accessibility text sizes
and narrower rows keep stacked labeled rows. [Task](261021_review-fixes-and-caption-clearance.md).

## 2026-10-21 — Copy matches Share › Copy

**Status: Owner-requested; implemented in build 24.** The owner saw toolbar Copy differ from Share › Copy,
including a brief modal. Both wrote one `public.png` item; the modal was the editor-wide processing
overlay, and toolbar Copy alone set `.localOnly`. Copy now renders without that overlay (a canvas status
reports Copying…/Copied) and writes the same unrestricted item, so Universal Clipboard behaves as Share ›
Copy does. This supersedes the 2026-10-15 local-only default, which was not an owner requirement.
[Task](261021_toolbar-sidebar-and-inspector.md).

## 2026-10-21 — Text and Pixelate are actions; one + menu

**Status: Owner-requested; implemented in build 24.** Tapping Text or Pixelate places a selected object at
the crop center, so the inspector no longer offers Add at Center; the canvas accessibility action remains
the non-drag path for shapes. The separate + (new window) and chevron (import) controls become one +
menu styled like Shapes. ⌘N and ⌘, move to scene commands because control shortcuts inside a closed
menu or ornament did not register. Supersedes the 2026-10-18 split of + and caret.
[Task](261021_toolbar-sidebar-and-inspector.md).

## 2026-10-22 — One title-bar tool group; Close in the corner

**Status: Owner-requested; implemented in build 25.** With an annotated screenshot, the owner asked to
move the close box to the upper-right corner and wrap the remaining tools in a single group. Undo, Redo,
Copy, Share, Export and the inspector toggle now share one glass capsule; Close Image sits alone in the
trailing corner of the header, and the separate close row above the canvas is gone. Simulator captures
showed navigation-style ControlGroups as separate circles, the automatic style as a recessed capsule
with near-invisible icons and the palette style as one empty circle, so the capsule is the platform
`glassBackgroundEffect` around borderless standard buttons. Supersedes the build-20 separate inspector
toggle and separate editor Close row. [Task](261022_titlebar-tool-group.md).

## 2026-10-22 — MIT license and a public website

**Status: Owner decision ("I think the license will be MIT", "hosted with GitHub Pages"); prepared in
build 26, not published.** The project carries an MIT `LICENSE` (© 2026 Michael Sitarzewski) and a static
site in `site/`, built by `scripts/build_site.py` and deployed by a GitHub Pages workflow, adapted from
AudioPaper's, which AutoPaper's site also adapts, so the projects share one maintainable pattern. The
owner asked for AutoPaper's; build 26 read the name as AudioPaper (corrected October 24). `PRIVACY.md` is
rendered into the site so the two cannot disagree.
The home page follows the BEDROCK measure: checkable, dated facts; no urgency or selling; costs, limits
and exit stated; provenance and AI assistance disclosed; the decision handed back. Supersedes the open
"license selection pending" notes. Publication still needs its own instruction.
[Task](261022_website-icon-and-license.md).

## 2026-10-22 — Icon colors match AudioPaper

**Status: Owner-requested; implemented in build 26. Superseded by the 2026-10-24 round picture icon
(build 28).** The toolbox uses AudioPaper's red as it renders
(Icon Composer mutes `#E7090A` to about `#E33D32`–`#861910`; visionOS image stacks don't, so the rendered
values are used directly) and AudioPaper's bezel silver for the handle and latch. The owner asked for
AutoPaper's colors; AutoPaper's icon uses the same red and silver. Supersedes the 2026-10-15 pure-red
`#FF0000` ramp and gray steel. [Icon README](../Tools/Icon/README.md).

## 2026-10-22 — Security reports through GitHub, not email

**Status: Superseded 2026-10-25.** The owner: "use my gmail like my other apps". `SECURITY.md`, `PRIVACY.md`
and Help now give the owner's email beside GitHub, as Glass Power Tools does. Originally: `SECURITY.md` points to GitHub private
vulnerability reporting so no personal email is added to this repository. AudioPaper publishes an email;
switching is a one-line change if the owner prefers it. Requires enabling the feature in the repository.

## 2026-10-23 — Sidebar rows of our own, like the terminal's

**Status: Owner-requested ("match the new lists in the Vision Pro version of Glass Power Tools' terminal:
tighter, smaller, more intentional"); implemented in build 27.** The Images sidebar's rows are plain
Buttons in a ScrollView, measured like the Glass Power Tools Vision Pro terminal sidebar: 2-point spacing,
8-point column inset, 12 × 8-point padding, a 16-point rounded shape tinted `primary` at 12% while
selected, and the highlight hover effect. On visionOS a `List(selection:)` draws each selected row as a
large system platter. Sections stay native DisclosureGroups with a section style; rows carry the
`isSelected` trait the List used to supply. Supersedes the build-19/20 native List rows; the
text-height previews (build 24) remain. [Task](261023_sidebar-rows-and-plus-menu.md).

## 2026-10-23 — A plain + for New Image

**Status: Owner-requested ("it's a mess. Just make the + the drop down for now"); implemented in build 27.**
The title bar's + is a round Menu button with no chevron. The decorative chevron (build 13's shared
`menuLabel`) widened it into a capsule that crowded the image name beside it. The bottom toolbar's
choosers keep their chevrons. "For now" leaves the control open to a later redesign.
[Task](261023_sidebar-rows-and-plus-menu.md).

## 2026-10-23 — No testing status on the website

**Status: Owner decision ("I love the idea behind this... but not sure the people reading this will
care"); implemented in build 27.** The home page's "What has been tested, and what hasn't" section is
removed; "Who made this" stands alone at reading width. Help lists keyboard shortcuts without saying where
each was checked. Accessibility limits a reader would act on stay on Help and Reference. The README and
STATUS keep the dated testing record. Amends the 2026-10-22 website decision and project rule 30.
[Task](261023_sidebar-rows-and-plus-menu.md).

## 2026-10-24 — A round picture icon, frame in front

**Status: Owner decision ("Let's just roll with the regular circle image icon ... Please prepare this for
Vision Pro's layered glass icon system so it's as beautiful as possible"); implemented in build 28.** The
icon is a white sun and two hills on red glass in a silver frame that fills the circle, in Glass Power
Tools' visionOS red. The frame is the Front layer (opaque from the glass edge to the icon's edge), the sun
and hills are Middle (running under the frame), the glass is Back (silver beneath the frame). Apple's
visionOS guidance advises against a hole or concave shape in the background layer and says the system adds
shadows and embosses upper layers from their alpha, so the frame is the nearest layer rather than a recess
painted on Back; the hills and the silver underlay keep edges closed when layers shift. The generator
checks this layering in place of the 440-pixel guard. No highlights are drawn in; the system supplies
them (owner, after seeing a gloss: "Take yours out anyway... let's leave those touches to Apple's default team."). Set aside: softened toolboxes; a Vision Pro headset with a picture and wrench (App Review
5.2.5 and Apple's marketing rules on depicting its products made it a risk); a wrench head as the
mountain's peak ("I'm just trying to make it more complex"). Supersedes the toolbox (2026-10-15) and its
AudioPaper colors (2026-10-22). [Task](261024_round-picture-icon.md).

## 2026-10-24 — The site follows AutoPaper's footer, builder and Pages workflow

**Status: Owner-requested ("Yes, bring over the footer row and builder changes. It's important to be
thorough."); implemented, not published.** The footer adds Help, Privacy and an "Also by Michael
Sitarzewski" row for the author's other projects, kept in step with the README's Other projects. The
builder links only pages it built, needs pandoc only for Markdown that exists and rewrites links only in
real anchors. The Pages workflow gives only the deploy job the publishing permissions and pins each action
to a release commit, as AutoPaper's security round did. AutoPaper-only parts (network page, update feeds,
example data) are not copied. [Task](261024_autopaper-footer-and-builder.md).

## 2026-10-25 — TestFlight and the App Store, prepared like Glass Power Tools

**Status: Owner direction ("AutoPaper isn't a visionOS app though, this will have to go through the app
store. More like Glass Power Tools in that regard", then "yes, bring those over now"); implemented in build
29, not submitted.** AutoPaper stays the model for the website's plumbing only; for distribution the model is
Glass Power Tools' App Store work. The app carries a privacy manifest: no tracking or collected data, and user
defaults (`CA92.1`), the only required-reason API in its binaries. It sets `ITSAppUsesNonExemptEncryption` to
`NO`, having no encryption of its own. App Privacy is answered with Data Not Collected; Apple says "You are not
responsible for disclosing data collected by Apple". The privacy page says what TestFlight and the App Store
pass to the author through Apple. The support URL is Help's existing contact section, not a new SUPPORT.md.
Proposed, not decided: EU trader status, TestFlight version numbers and screenshot framing. Approved by
the owner: the support email, the owner's Gmail as in the other apps ("use my gmail like my other apps"),
in Help, SECURITY.md and PRIVACY.md; the categories, Graphics & Design then Productivity ("Graphics & Design and
Productivity are fine"; Developer Tools was raised and doesn't fit Apple's definition, "tools for app
development, management, and distribution"); and ("keep it") PRIVACY.md's sentence that the author uses these reports
only to find and fix problems and doesn't pass them on. [Task](261025_app-store-preparation.md).

## 2026-10-25 — Bundle identifier `com.glassimagetools`

**Status: Owner decision ("definitely not this: com.glasspowertools.visionsnip maybe com.glassimagetools ?");
implemented in build 30.** The public default in `Config/Identity.xcconfig` is `com.glassimagetools`, mirroring
Glass Power Tools' `com.glasspowertools`; the old value carried the working name VisionSnip. Apple fixes the
identifier when the App Store Connect record is created, so it was settled before that. The build setting
keeps its name, `VISIONSNIP_BUNDLE_ID`, and contributors still override it locally. Build 29 under the old
identifier stays on the headset as a separate app until the owner removes it. [Task](261025_app-store-preparation.md#build-30-the-bundle-identifier).

## 2026-10-26 — About in Settings, after AutoPaper's

**Status: Owner request ("Use the AutoPaper version so users know the who/where/why behind it"); implemented in
build 31.** Settings gains AutoPaper's About pane, adapted to visionOS: the icon, name and version from the
bundle; what the app is for and who made it ("Michael Sitarzewski made it for exactly that, and shares it free
in case it's useful to you too."); Website · Privacy · Help on the GitHub Pages site; "MIT · © 2026 Michael
Sitarzewski". AutoPaper's update controls are left out: TestFlight and the App Store update the app. An ⓘ button
in the Settings sheet's title bar opens the page, because the appearance form already fills the sheet and a
last row would sit below the fold. The sheet is titled Settings, like the gear and ⌘,. The links open Safari;
the app still has no networking code, and PRIVACY.md lists the links. [Task](261026_about-settings.md).

## 2026-10-29 — Native start/sidebar and whole-well Paste

**Status: Implemented under explicit owner requests; scoped validation recorded.** The owner requested Apple-default main/left-sidebar presentation and then explicitly replaced the blue Paste control with whole-area tapping or Command V. System bordered import wells and List selection/disclosures replace the custom rows, while the single adjustable rear glass remains. Empty-only UIKit standard Paste handles the unavailable visionOS SwiftUI onPasteCommand use case without replacing text-field editing commands. Explicit input only; one protected provider-import owner. [Task](261029_native-start-and-sidebar.md), [evidence](../Documentation/Validation/native-start-and-sidebar.json).

## 2026-10-29 — Flat native sidebar hierarchy

**Status: Implemented and runtime verified under the owner's styling request.** Use native plain List rows and borderless category Buttons with standard SF Symbol/count/chevron labels; keep children directly selectable. The native DisclosureGroup candidate rendered inline in this composition, and sidebar List styling appeared as a grouped card. Those findings support the focused fallback without custom row, hover or selection drawing or another navigation-container backplate. [Task](261029_sidebar-hierarchy.md), [evidence](../Documentation/Validation/sidebar-hierarchy.json).

## 2026-11-03 — Direct HTTPS image-link Paste

**Approved:** the owner explicitly requested pasting a copied URL to a web image. This permits narrowly scoped, user-initiated image acquisition networking. Existing images remain local, with no uploads, backend, analytics, accounts, shared cookies/credentials or persistent network cache. Reuse native Paste and protected image ownership; reject webpages and unsafe/unbounded transfers. Prior no-network source/marketing claims are superseded for build 37. [Task and evidence](261103_paste-image-links.md).

## 2026-11-05 — Native sandboxed Mac editor

**Approved and implemented**, provenance: owner's “Build them. Let's see it! It can be sandboxed right?”
following inspection of existing shared-core groundwork. Separate native macOS 26 shell; reuse the shared
core/model/canvas/inspectors, keep visionOS presentation and isolated capture research. Actual App Sandbox
with user-selected files, network client for already-approved link acquisition and Photos capability;
no broad folder access. Build-script sandboxing was prior groundwork, not a prior Mac App Sandbox decision.
Use native Mac NavigationSplitView/inspector and standard menus/panels. Editable session vectors flatten
on deliberate export/close as previously approved. Mac capture, store account/platform records and
notarized distribution remain separate. [Task](261105_native-sandboxed-mac.md).


## 2026-11-05 — Native Mac markup row and headless GUI testing

**Approved and implemented**, provenance: owner screenshot/request to put the object choices in a toolbar
like visionOS, followed by “can you do that testing in the mac vm? see Glass Power Tools' setup”. Use
Apple's native Mac accessory bar for direct tools, preserving shared model/inspector semantics. GUI
verification now runs in an isolated headless guest; host builds/core tests remain permitted. Do not
accept capture/Accessibility prompts automatically; the rejected optional capture notice stays
unapproved. Mac build versions may advance independently of unchanged visionOS/store candidates.


## 2026-11-05 — Toolbar grouping correction

**Approved and implemented**, owner clarification: “why isn't this the same toolbar as Vision Pro?”
Build 39's flattened-shape layout was an agent interpretation, not an owner-approved departure. That
layout is superseded. Match the complete existing mode/context/zoom/settings order and the grouped
Shapes/Draw/Text/Pixelate controls. Native placement remains platform-specific; VM-only GUI testing
remains approved. Mac 40, visionOS unchanged at 38. [Task](261105_mac-toolbar-parity.md).

