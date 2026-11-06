# Local image and editing data model

There is **no database, backend, user account or synchronized document catalog**. The current editor
uses an in-memory nondestructive value model and private temporary source/export artifacts.

## Source ownership

`ImageSource` retains upright source size, original orientation, display name, a preview capped at
2048 pixels, decoded content type/type label, and either an immutable owned file URL or an authorized in-memory `CGImage` frame.
File import copies while provider/security-scoped access is valid. On successful ownership transfer,
the source owns its private directory and removes it when no operation retains the source. A failed
load cleans only that private copy, never the original provider/user file.

`ImageTemporaryStorage` initializes dedicated import/export roots once per process and purges abandoned
previous-process artifacts. Repeated preparation and new windows preserve current owners. Sources use
neutral `source.image` filenames, retaining friendly names in memory; regular-file and owned-directory
validation precede protection/cleanup. Private permissions, requested complete visionOS protection and
backup exclusion reduce working-file exposure. Normal owner release attempts deletion; forced termination
cannot run that code, so leftovers persist until next launch/system cleanup. These paths are not durable
documents. Hardware locked-device protection/backup behavior remains unverified.

An in-flight export retains its source snapshot so changing the selected image does not invalidate
readable input. Preview dimensions are not the source dimensions and cannot drive export resolution.

## Editable values

`EditState` owns the crop, crop preset/constraint, quarter-turn rotation and ordered editable annotations. All are undoable
value state. `Annotation` has an identity, kind, source-coordinate
points, stroke color/width, optional fill, text/font family/size/traits/underline/alignment. `StrokeColor`
stores extended-range sRGB (UIKit's convention): Display P3 colors have components outside 0–1. Rendering
accepts finite components within −2…2 and alpha 0–1, and rejects anything else. Rectangle,
ellipse, arrow, line, rounded rectangle, triangle, speech bubble, freehand, text and pixelation regions
remain objects throughout the open session. Selection/tool/mode and viewport state serve interaction rather than image data.

`EditHistory` stores past/current/future value states with no pixel buffers. A committed new edit clears
redo history. Inspector drafts and gestures should commit deliberate transactions rather than each typed
digit; undo/redo restore both resulting geometry and crop constraint consistently. Validation bounds
numeric values before conversion/allocation, independent of the text field's display formatting.
While an inspector session has an uncommitted change, Undo is available (it commits, then undoes) and
Redo is not (committing clears it).

## View transformation

`CanvasTransform` uses source bounds, viewport dimensions, aspect-fit scale, zoom, pan and quarter-turn rotation to map points.
Source origin is top-left and units are upright source pixels. Letterboxing and Retina/display scale
stay in presentation. Crop geometry clamps and aligns the final rect to valid source bounds. Zoom changes
pan with it so the pinched point, or the visible center for menu commands, stays over the same source pixel.
Inspector Left/Top/Width/Height for crops and annotations use the visible rotated axes; stored values stay upright.

## Output ownership

`ImageRenderer` takes source and edit snapshots, returns full-resolution new image pixels and encodes a
fresh artifact. `ExportedImage` retains output URL, dimensions, byte count and format for sharing/copy/save.
`ExportFile` owns file data for the system exporter. PNG retains alpha; JPEG flattens onto white.
Output is Display P3 when the source or an annotation color is wide-gamut, otherwise sRGB. Metadata
from the source is not passed through wholesale. The original is neither replaced nor attached as a
hidden editing layer in exported output.

The owner explicitly chose flattened saves on close. Files/Photos save a new PNG/JPEG; retained vectors
are not persisted as a reopenable project. A saved edit checkpoint is separate from undo history; exact
state equality restores clean status after Undo. Cancelled/failed saves and failed new imports preserve
all existing sources, edits and history. Future project persistence would require its own scope decision.

## Provider transfer ownership

OwnedImageImport validates a regular source.image file inside an app-owned import directory before
accepting cleanup responsibility. Photos transfer and explicit Paste/Drop keep this owner immediately, including
the interval before decoding. One serial ImageImportQueue transfers it to ImageSource only after successful
loading; cancellation/unconsumed/late providers release the right copy. Paste providers are requested only after an explicit menu/well/empty-workspace keyboard action; Drop providers arrive only from the system drop callback. Suggested names are retained, with contextual fallback names/errors. A successful import adds a new
document; it never replaces the current image or prompts to discard its edits. Files enter the same
worker with security-scoped access covering copy/decode. A 256 MiB encoded-input cap is checked before and
after copy; existing 200 MP import/100 MP export limits remain. No clipboard catalog or durable project is added.

## Contextual defaults, history and direct share — build 11

`textLabel` and existing font/traits/alignment/color are prepared annotation defaults. They do not change
the document until an object is inserted. Selected objects remain the inspector's source of truth; an
active annotation tool controls the form when nothing is selected. Pixelation Size exposes the renderer's
`max(16, lineWidth * 4)` target in original pixels (16–320), retaining the existing storage/rendering model.
Blocks adapt to the selected region; it is not a stroke or a promise of exact uniform block width.

Persistent form edits are a transaction; direct gestures and context actions commit their own steps.
Undo/Redo can restore objects without reselecting them. Reveal requires a current selection and updates
only a canvas-owned viewport request/pan, preserving image bytes, edits and history. Proxy coordinates
never enter retained Annotation points. The native tiny-object test verifies separate field/drag Undo.

Direct Share snapshots immutable `ImageSource` plus value `EditState`. CoreTransferable requests encoded
PNG bytes through the existing queue and scoped owned output. The share preview uses a neutral name and
no original thumbnail; exported pixels/metadata follow the shared crop/annotation/privacy renderer.
The actual native transfer check decodes an 800 × 600 annotated PNG and compares unchanged original/private
source bytes. UI sheet availability alone would not prove this data contract.

## Original-image descriptions — builds 14–15

Caption text belongs to ImageDescriptionCaption's SwiftUI state, not ImageSource/EditState/history or
export metadata. The view is keyed to source identity and retains only the bounded upright preview;
closing/replacing the image cancels its task and guarded completions cannot update another source's view.
ImageDescriptionService retains at most one model inference and rejects overlapping requests. Per the owner’s build-15 preference, loading/unavailable results show no caption region.
Its local session is released after completion; the app stores no caption/transcript file or cache.
Pan, crop, annotations, Undo and export do not regenerate the original-image description. Native text
selection is available, but the app's image Copy/Share/save paths contain only rendered edited pixels.

## Native column lifetime — build 17

Historical implementation: the leading NavigationSplitView property column was replaced by document
navigation and a trailing inspector in build 19, then plain columns in build 21. Current visibility
belongs to EditorView; removing/hiding a document-keyed Form finishes its inspector transaction.
Showing it begins a fresh session, and document switching finishes the prior model's transaction.
No navigation-container persistence is required for image/history ownership.
[Current presentation](systemPatterns.md), [historical task](261017_native-left-sidebar.md).

## Rotation — build 18

ImageRotation is value-only edit/history state. Crop and editable annotations remain in upright original source coordinates. Display/export rotation uses shared exact affine quarter-turns. Visible crop fields invert that transform into bounded source geometry; fresh export pixels carry rotation, with metadata stripping unchanged. No new source buffer or document persistence. [Task](261017_sidebar-defaults-and-rotation.md).


## Per-window documents and session Recents — build 19

DocumentWorkspace owns a stable-ID collection of EditorModel instances, selection and session Recents.
Each open editor retains its original source, value edits/Undo, selection, tools and viewport. Switching
finishes live inspector transactions; the right Form is keyed to document identity so drafts/focus cannot
leak between images. Only the visible canvas owns its preview drawing cache. Captions remain view-local,
on-device and outside edits/exports; revisiting a document can request its original description again.

Photos/Files/Paste adds a new model only after validated import succeeds. Failure/cancellation leaves
existing documents intact. At most eight open documents and eight recent items are retained. The shared
512 MiB source/preview budget counts unique source identities, encoded input, captured bytes and preview
bytes; old Recents evict first. This is a retention bound, not an export peak-memory guarantee. Existing
serial export/input limits still apply; the last successful output artifact may be retained per open image.

Save callbacks capture document ID, source identity and edit snapshot. Only a matching successful Files/
Photos save records a clean checkpoint and the actual encoded output. Closing after Save privately loads
that flattened PNG/JPEG for Recents. Discard uses the last saved output, or the original if never saved.
Closing clears the editor's vectors/history/source and selects another open model. Reopening a recent
creates a clean full-image editor without vector/history recovery. Cancelled close retains the document.

Recents have no durable catalog or clipboard polling. They exist only in their window/process; Clear
Recents releases image ownership. Normal final release deletes owned temporary copies; forced termination
still relies on next-launch purge. Original/external saved files remain under their owners' lifetimes.
[Task](261018_document-sidebar-and-inspector.md).

An unavailable/over-limit optional Recent copy closes without adding a broken item and returns a visible warning. Cancellation preserves the editor. Close import/identity checks live in DocumentWorkspace; completion announcements stay with their initiating model.

## Preview-only appearance and crop mask

Opacity/Glass preferences, captions, mask shading and control proxies are presentation state. The
65% outside-selection mask is clipped to the image Canvas viewport while controls retain reserved
margin space. Neither it nor the window material enters EditState, source bytes, saved checkpoints,
Copy/Share/save or Recents. Full-resolution output follows the retained crop/rotation/annotations.

## Download ownership — build 37

An explicit HTTPS Paste owns one partial source.image in the existing protected import root during transport. The downloader closes and transfers it as OwnedImageImport on success; failure/cancellation removes it. The regular image loader validates and owns full-resolution bytes plus one bounded upright preview. Only the response filename is kept; no full URL/query, cookie jar, credentials, download history or separate web-image cache is retained. Recents/eviction/window closure and next-launch purge use their existing source ownership.

## Mac ownership

The Mac shell reuses the same DocumentWorkspace, ImageSource, EditState, export queue and temporary
ownership. NSPasteboard reads occur only on explicit Paste. Native file panels supply selected-file scope;
no bookmarks or between-session file history were introduced. Mac UI windows retain only weak native
window references. Close/quit checks every open model's unsaved state, saving flattened copies through
the existing ExportView/recordSave contract before closing. Cancelling or failing a save keeps work open.

