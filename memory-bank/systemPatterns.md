# System patterns

## Native Mac shell

`Mac/GlassImageToolsMacApp.swift` supplies the Mac WindowGroup, menu commands and Settings. `MacEditorView`
uses native NavigationSplitView/List and `.inspector` around the shared ImageCanvas, EditorModel,
DocumentWorkspace and crop/annotation Forms. Shared `EditorFields` owns exact pixel controls;
`EditorPlatform` contains only interaction sizing, numeric keyboard and hover/context-menu differences.
`MacPasteboard` preserves encoded images and explicit-link priority; ClipboardService writes NSPasteboard.
MacWindowCloseGuard forwards SwiftUI's window delegate and coordinates native Save/Discard/Cancel with
MacApplicationDelegate for Quit. The editor holds only a weak window reference to avoid retaining
closed image sources. Core rendering/import resource ownership is unchanged. Vision presentation below is platform-specific.


## Native presentation and ownership

`App/GlassImageToolsApp.swift` owns a native plain `WindowGroup`; its identified `editor` scene and per-window `EditorWindow` owns the dynamic scene minimum-width binding. `EditorView` derives that minimum from visible columns/text size and presents system controls,
PhotosPicker/fileImporter, inspectors and the export sheet. `ImageCanvas` owns aspect-fit display,
zoom/pan, crop interaction and live vector-object editing. Native UX rules are local in [projectRules.md](projectRules.md),
including sheet controls and Apple default modal editing patterns. [Current release](../Documentation/RELEASE_NOTES.md).

The plain window owns one native glass backplate. `EditorView` explicitly places the background at
spatial z = −1 and stacking index −1, with the full-opacity workspace at the native interaction plane (z = 0), index +1. The image is
above the appearance surface; crop handles/annotations remain above its pixels within the canvas.
Native title/toolbars are separate foreground surfaces. No opacity modifier wraps their shared ancestor.
Source alpha is preserved independently of window appearance.

The background is the only owner of appearance strength. `AppearanceSettings.swift` uses the Glass-family
46-point continuous corner radius. EditorView owns local column/header/canvas spacing; the old
whole-window inset wrapper is gone. Apple supplies the edge;
there is no custom stroke. Opacity (default 0) paints a black background and Glass (default 1) controls only
the backplate. Both range 0–1 with endpoint/midpoint detents. They persist in local AppStorage and are
independent of editing/history/export. Reduce Transparency resolves both to 1 and disables appearance edits.
The material remains System Glass, matching the reference visionOS controls.
The Settings sheet (`AppearanceSettings`) also leads to `AboutSettings`, through an ⓘ in its title bar. About
reads the version from the bundle and links to the website through `Website`, the one place its URLs live.

The persistent workspace uses plain SwiftUI columns with a single adjustable rear surface, following
Glass-family visionOS windows. NavigationSplitView and NavigationStack add their own material above that
surface; build 20 reproduced a grey plate even at Opacity/Glass 0/0. Persistent columns therefore avoid
those containers. Native inspector Forms hide only their scroll-content backgrounds. Native sheets keep
their navigation surfaces.
No UIKit hosting override or private API clears glass.

The leading Images sidebar (`DocumentSidebar`) owns Open Images and session Recents. Build 36 uses direct native plain List rows, with automatic native category Buttons (tinted Label symbols, counts, SF chevrons and spoken expanded/collapsed state). Children are indented 32 points; targets grow from 60 points. Open Images starts expanded and Recents collapsed. List owns document selection; no custom selection/hover drawing. Build 36 removes the category-only borderless style and rounded-rectangle shape overrides after the owner reported inconsistent native treatments; automatic List controls supply category appearance. Hidden scroll-content background and standard hidden separators keep one rear surface. The heading uses native title2 with a 24-point inset. Width remains 360 points (380 at accessibility sizes). Build 35 replaces text-height thumbnails and the second metadata line with a small SF image symbol and single-line filename, plus an unsaved dot and spoken type/edit status. Native List still owns row targets and selection.

The native DisclosureGroup candidate rendered expanded children inline within a single cell in the observed SDK/runtime, breaking hit targets and nested selection; direct conditional List rows avoid that behavior. This is runtime evidence for this composition, not a universal assertion that the API is unsupported. Native `.sidebar` List styling also rendered an inset grouped card here; standard `.plain` styling supplies the intended flat hierarchy. [Task and exact checks](261029_sidebar-hierarchy.md).

`ImageStartView` owns adaptive native Photos/Files wells and a native bordered drop/Paste well. A tap reads clipboard providers only after that user action; the empty view's public UIKit keyboard responder handles standard Paste/⌘V. It takes no pointer events and leaves with the empty view, so text inputs keep their responder. Drop and Paste go through EditorView's new-document request and the same protected provider importer. No clipboard polling or additional decoding owner is introduced. SwiftUI onPasteCommand is unavailable on visionOS in the inspected SDK.

A 92-point header uses standard Buttons and Menus with system styling: sidebar toggle, one round + Menu
with no chevron (New Window, Photos, Files, explicit Paste; build 27), leading image metadata, then one glass capsule
(`documentToolGroup`, `editor-tool-group`) holding Undo, Redo, Copy, Share, Export and the inspector toggle
(compact layouts move Undo/Redo/Export into its ⋯ menu), and Close Image alone in the trailing corner.
Navigation-style ControlGroups draw separate circles and the automatic style recesses its icons, so the
capsule is the platform glass material around borderless standard buttons (build 25). A matching Images heading
aligns the columns. Native title-bar navigation-container behavior is not claimed; headings and accessible
groups preserve structure. The bottom system toolbar owns mode, tools, zoom/Pan and Settings. Its ornament
overlaps the window's lower edge and visionOS exposes no inset for it, so
`ImageWindowAppearance.bottomOrnamentClearance` (32 points) pads the image column (canvas, status and
caption) and adds bottom scroll-content margins to the sidebar and inspector Forms; dividers still reach the edge.

An independent trailing in-window Form supplies contextual Crop or annotation properties. This follows
Apple's macOS inspector grouping/behavior without calling SwiftUI .inspector or UIKit's inspector column,
both unavailable in the recorded visionOS 27.2 SDK. Native SwiftUI composition, controls and
materials own presentation; no custom material/button rendering or extra window is added. Showing the
inspector raises the native minimum width to preserve the canvas. Reduced Motion disables transitions.
A fresh document-keyed Form owns draft/focus lifetime; leaving commits the existing edit transaction. Shared InspectorHeader keeps Done inside the pane. Panel accessibility identity belongs to the Form before its header inset. The editor has a separate circular Close Image button. A 640-point detail minimum reserves room for the canvas and native header controls.

`ImageDescriptionCaption` owns session-only caption presentation below the main image. Source identity
owns the view task; only its bounded upright CGImage is passed to `ImageDescriptionService`. The actor
uses Apple's on-device SystemLanguageModel when visionOS 27/model/vision support is actually available,
allows one inference across windows, returns explicit failures and retains no session cache. The view intentionally hides loading/unavailable states. A busy model (another window's inference) is retried every 2 seconds and a not-yet-ready model every 30 seconds while the image stays shown; cancellation ends the wait, and permanent unavailability stays hidden. Successful text uses measured native content height, side margins matching the canvas inset (`ImageCanvas.contentInset`, 36 points) and default text leading; only overflow invokes scrolling. The maximum is a safety ceiling, not reserved height.
Caption results never enter document edits, image rendering or export. No model is initialized by this
feature during empty-window startup, and viewport/edit changes do not regenerate the original description.

`DocumentWorkspace` is the main-actor per-window selection/lifetime owner; each open image has its own
`EditorModel` UI owner. It connects import, source/edit/history state, tool selection
and async copy/export results. Image decoding and full-resolution rendering/encoding run outside the
main actor. The live canvas draws bounded preview pixels and retained vectors during its display pass;
it does not become the full-resolution renderer or own a second source buffer.

Selection bounds/handles appear only with Select outside an active draw; retained vectors and history are unchanged.

## Source-pixel editing

`CanvasTransform` converts between the view and upright source-pixel coordinates using the fitted image
bounds, zoom, pan and quarter-turn rotation. `CropGeometry` clamps and pixel-aligns crops within the source. Annotation points
are source coordinates. Letterboxing and preview scale affect display only, never export dimensions.

`ImageSource` owns an immutable private file copy or in-memory captured frame, decoded content type,
friendly filename/original dimensions and one bounded upright preview. `EditState` and `EditHistory` contain value geometry/annotations, never image buffers. The selected crop
constraint is part of EditState; inspector changes commit one undo transaction. Undo/redo preserves
selection only while the selected object survives; see the [task record](261015_security-remediation-and-memory-bank.md) for actual verification.

## Rendering and composition

`ImageRenderer` decodes the full-resolution source, handles EXIF orientation, crops in source pixels,
then clips/renders ordered annotations and encodes a new PNG/JPEG. PNG preserves alpha; JPEG flattens
onto white. Output metadata is generated for the new image rather than copying source metadata.

`ImageRenderer.drawPreview` draws the bounded source and retained vector shapes/text directly into the
live canvas's source-coordinate context. Preview and export share Core Graphics paths, CoreText layout,
insertion order and source-anchored pixelation. Pixelation replaces underlying affected pixels, including
outward-aligned fractional edges, within the same blend-aware drawing pass. A canvas-local, nonpublished
cache holds bounded pixelation tiles; no async flattened image is rebuilt for each drag. The legacy
renderPreview bitmap convenience remains for core/test consumers.

Crop mode displays all annotations beneath a 65% black outside-selection mask; Annotate clips to the current crop. Only the mask shares the image Canvas viewport clip, so zoomed shading cannot paint reserved margins while crop controls/labels retain their generous reachable space.
Objects outside a crop remain in value state and reappear when it expands. Native handles manipulate
source-space bounds or line/arrow endpoints; path-aware hits select the topmost object. Native annotation controls
expose selected text/style while the image stays visible. Shared geometry/composition prevents display
scale, letterboxing or preview resolution from changing exported dimensions.

Annotation colors are extended-range sRGB, matching UIKit, so Display P3 palette colors render instead of
failing validation. `ImageRenderer.workingColorSpace` keeps Display P3 when the source image or any
annotation color is outside sRGB, and sRGB otherwise; pixelation tiles follow the source image's gamut.
Exports remain 8-bit SDR with an embedded profile.

Crop width/height badges use the pixel-aligned output crop and sit along its horizontal/vertical edges,
using the canvas padding where possible. They remain display-sized during zoom and do not intercept drags.
Annotation interaction targets use the shared paths, full stroke/arrow bounds and display-space tolerance,
clipped to the output crop. Native context menus belong to those objects, with a safely composed cropped
preview, rather than to the entire canvas. Ordinary text taps select the label and request its editor.
Preview pixelation caches release their tiles when the view disappears, including menu-preview dismissal.

## Async operations and resource lifetime

Imports and exports capture immutable source/edit snapshots. Ownership tokens or generations prevent
stale completion from overwriting current state. Cancellation must reach expensive workers and be checked
at meaningful pipeline boundaries; cancelled results do not publish. `ImageExportQueue` serializes full-resolution exports; ExportView debounces quality changes.
The live canvas draws only the bounded upright source; its pixelation cache is capped at 8 MiB and never
decodes the original file. Full-resolution export remains serialized off the main actor.

An async method may suspend and reenter: capture Start/Stop/background/picker callbacks must invalidate
older requests before awaiting and preserve the active stream owner. A stored stream cannot be treated
as current merely because its earlier start call returned successfully.

## System service boundaries

`ImageImportService` owns private-copy loading and image limits; file security-scoped access stays at the
import boundary. `ClipboardService` owns pasteboard writes, matching Share › Copy. `ExportService`
owns add-only Photos saving; `ExportFile` adapts a new output to FileDocument. Sharing uses system UI.
The renderer produces an owned export artifact; the app decides whether to copy, share or save it.
Dirty state compares current edits with the initial/last durably saved snapshot. Only a successful Files/
Photos save of the same source and edit snapshot marks it saved; Copy/Share does not. Save-before-close/
replacement continues after native sheet dismissal. Cancel/failure retains the open document; actual close
invalidates pending operations and releases image ownership. Saved images are flattened PNG/JPEG copies.
Dedicated private working roots initialize once per process and purge abandoned prior-process artifacts
on next launch. Regular-file/owned-path checks protect original files from cleanup/protection operations;
see [the data model](data-model.md). Clipboard writes match Share › Copy (normal lifetime and reach) with no app history.
Copy renders without the editor-wide processing overlay; only Copy itself waits (`EditorModel.copying`).

Hardware-keyboard ⌘N and ⌘, are scene `EditorCommands` acting through the focused window's
`EditorCommandActions` focused value; shortcuts attached to controls in a closed Menu or toolbar ornament
were not registered. Build 33 supplies empty-workspace ⌘V through a public UIKit standard Paste responder. SwiftUI PasteButton shortcuts remain unverified for a loaded canvas; use + › Paste there. Text fields retain their native responder and editing commands.

## Capture isolation

`CaptureProbe` is compiled only into `GlassImageToolsCaptureProbe`, targeting visionOS 27. The editor
remains usable without ScreenCaptureKit. A permitted frame enters through `ImageImportService.fromCapture`
in memory. SDK availability, unsigned/signed builds, simulator results and hardware source/consent behavior
are separate facts. [The capability matrix](../Documentation/CAPTURE_CAPABILITIES.md) owns those facts.

The build-labeled presentation notes below retain implementation history. For current window/header/
inspector ownership, use the opening section: build-11/12 navigation/ornament details were superseded
by later document layout and the build-21 transparency correction.

## Native UX/provider iteration — build 10

Crop corners use display-only 60-point separated proxies at viewport edges; source bounds remain unchanged.
Frozen CanvasTransform.sourceDelta in a named canvas space prevents jumps during corner/object drags. Pan
updates only view state; Show Crop recenters without changing zoom/history. Native geometry fields and
named pixel movement/resize actions remain available. Add at Center creates retained non-freehand objects
through the existing model/style/history owner. Native selected toggles/checkmarks avoid tint-only state.

Grouped Forms pair labeled numeric dimensions at normal sizes and stack at accessibility sizes. In the
380-point trailing inspector (build 23) paired fields place their label above the value, as Mac
inspectors do, because inline label/value/unit pairs cannot fit; narrower rows still stack. The
large-text title ornament attaches above the window to preserve crop-axis visibility. One native Paste
button in the persistent top ornament owns explicit providers and the unsaved replacement lifecycle.
The native ColorPicker retains selection and exposes RGB/opacity; its system host is separate from the app.
Processing owns a retained task/cancellation identity, with Cancel outside the disabled editor. Public
accessibility announcements report completions. ImageImportQueue serializes Photos/Files/Paste preview
loading; OwnedImageImport holds cleanup ownership before decoding and transfers it once to ImageSource.

## Contextual annotation panel and adaptive ornaments — build 11

`EditorView` owns actual window geometry and native ornament composition. Title and document actions adapt
together; the native bottom toolbar stays in one row because its host clips multi-row content. A compact
Drawing Tools Menu retains commands and native target sizes. Single Shapes tap/hold remains the owner-
approved shape interaction. The annotation Form lives in `AnnotationInspector` beside `ImageCanvas`, with
native navigation/Done and adaptive labeled fields; it does not cover the object as a popover.

`EditorModel.effectiveAnnotationKind` resolves selection, then active annotation tool, then last shape.
The persistent inspector marks its lifetime in the model. `beginCanvasGesture` finishes live form edits;
`finishGesture` commits geometry separately and reopens a form transaction if appropriate. Undo/Redo and
context actions close/reopen those boundaries deliberately. Tool/default changes alone do not dirty the
image. Form context resets on object/tool changes, while ordinary typing/style updates preserve focus.

`CanvasTransform` owns shared reachable corner rectangles, endpoint spacing and reveal deltas.
`ImageCanvas` consumes reveal requests using its actual viewport; changing proxy positions, Pan or reveal
never changes source geometry/history. Handles freeze the source transform during a drag. Offset markers,
tethers and accessible help explain proxies; selection outside the export crop is explicitly labeled.
Native hover highlights interaction surfaces, with decorations kept noninteractive.

`EditedImageTransfer` owns an immutable source/edit snapshot for native direct sharing. It reuses the
serialized cancellable export queue and returns only flattened PNG bytes; no source thumbnail or metadata
is supplied to the share preview. Recipient behavior and system UI are separate validation boundaries.

## Native per-control toolbar refinement — build 12

The approved family comparison supersedes build 11's enclosing ViewThatFits/HStack toolbar composition.
`EditorView.editorToolbar` now contributes each native control directly to ToolbarItemGroup. The system
owns control sizes/spacing/label presentation; only the actual window-width/text category chooses which
commands overflow. At compact/accessibility sizes, Annotation Options lives inside Drawing Tools; native
text commands and explicit labels preserve discoverability. This retains the bottom mode toggle, single
Shapes tap/hold, zoom value and Settings without shrinking native controls. Source/history owners do not
participate in this presentation decision.

The title uses native capsule glass with family padding; responsive metadata/actions remain composed in
that ornament. Embedded AnnotationInspector uses its native Form/NavigationStack surface without extra
outer glass. Rear window glass, geometry and background-only appearance ownership remain unchanged.
Actual compositor/host bounds are necessary: a passing accessibility audit alone missed toolbar overhang.
[Task and evidence](261016_native-glass-chrome.md).

## Quarter-turn image edits

EditState stores ImageRotation alongside original source-space crop/annotations. CanvasTransform rotates the viewport, maps screen-labelled corners/deltas back to source, and shares its affine basis with vector drawing/hit regions. Output dimensions and exact crop fields/presets use rotated visible axes. CGContext composes crop/source/annotations directly into rotated output dimensions; no second full-size rotation bitmap or source-file rewrite. Rotation and Undo fit the viewport; Reset Crop preserves rotation. `EditorModel.displayRect`/`displayPoint` map upright source geometry to the visible rotated axes for crop and annotation fields, handle values and spoken descriptions; typed values map back through the inverse transform. EditorWindow is a shared per-window scene owner for the main and research entry points. [Task](261017_sidebar-defaults-and-rotation.md).

## Image-link acquisition — build 37

The shared item-provider importer remains image-first. EditorModel explicitly enables its URL fallback for Paste only; image drops remain image-only. URL and plain-text providers use the generic cancellable provider request; original plain text wins over Foundation's auto-converted URL representation, enforcing one whole link. ImageLinkImportService owns ephemeral HTTPS transport and a lock-protected serial delegate writes bounded chunks directly to protected import storage. An OwnedImageImport transfers into the existing serial preview loader. Errors/cancellation preserve the previous document through the existing processing generation. New native Paste content types admit URLs/text without new controls or automatic clipboard polling.

### Mac editing controls

Build 42 mirrors Vision Pro's mode/contextual-tool/zoom grouping in a native image-only accessory row.
Shapes remains one seven-choice menu beside Select/Draw/Text/Pixelate. Mac's leading navigation item
opens images before the title. Native fixed spacers separate history, document actions and view controls;
Markup, SettingsLink and Inspector form the trailing group. Markup visibility is per-window State,
controlled by native toggle/View command/⌘⇧M. Image/View/File menu equivalents use the focused window's
EditorModel and existing export/Transferable owners; selecting a tool reveals Markup. Empty windows
retain Open Image/Settings/Inspector and omit the editing row. No custom toolbar chrome or shared/core
change. [Current layout](261105_mac-native-toolbar.md), [prior parity](261105_mac-toolbar-parity.md).

Build 43 refines the supplied Preview Markup reference. Native borderless controls use a shared semantic
icon label with a 32-point target; standard Dividers separate the existing groups. MacMarkupMenu owns
only Shapes/Crop Preset/Zoom presentation using NSPopUpButton with explicit symbol/target sizing and a
retained control target/action coordinator. This avoids SwiftUI toolbar synthesis discarding Menu label
geometry. Existing model methods/selection/enabling stay authoritative. No custom drawing/private API.
[Checkpoint](261105_mac-native-toolbar.md#preview-markup-reference-follow-up--build-43).

Build 44 supersedes the large build-43 treatment at the owner's older Preview reference. Smaller native
controls keep 28-point targets; menu symbols are 14 points. One expanding SwiftUI content row centers
mode/contextual/view controls inside the native system accessory bar. ToolbarSpacer did not expand
here in guest observation. MacMarkupMenu centralizes dimensions, uses native edge arrows and explicitly
MainActor control callbacks. Model/window ownership and main-toolbar grouping stay unchanged.
[Current layout](261106_compact-centered-markup.md).

## Mac termination ordering

MacWindowCloseRegistry asks NSAlert synchronously before returning a termination reply. Save returns
terminateCancel, runs ordinary SwiftUI export/close with a sequential window owner, then requests a
normal Quit once no edited windows remain. Do not schedule a SwiftUI decision after terminateLater.
Confirmed window closure waits for attached sheets to detach; no second close-gate question.
