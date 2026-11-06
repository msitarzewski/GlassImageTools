# Product context

Vision Pro screenshots may be far larger than the detail someone wants to share. The intended user is
already in the headset and wants a fast native equivalent of selecting a region in a screenshot editor.
Transferring the whole screenshot to another device or another editor adds unnecessary steps.

## Primary workflow

Choose Photos/Files or explicitly Paste an image, adjust a forgiving crop in source pixels, then Copy. Optional
annotations and Export add precision or sharing choices without complicating the common crop/copy path.
The owner reports approximately ten successful uses of Photos → crop → Copy → ChatGPT on Vision Pro,
confirming clipboard interoperability for the primary workflow. This does not establish a ChatGPT share
extension or other recipients. See [verified status](../Documentation/STATUS.md) for evidence and remaining scope.

## Interaction priorities

- Apple default windows, materials, pickers, forms, sheets, toolbars and sharing make the app familiar.
- Generous crop handles and zoom/pan support eye/hand input while exact dimension fields retain precision.
- Preview feedback must agree with the exported crop, annotation order and obscuration regions.
- A numeric edit is one intentional undo operation; partial typing must not become separate user actions.
- Saving creates a new asset/file. Import does not imply permission to read the entire Photos library.
- Errors describe a usable next action, and cancelled or superseded operations do not replace current work.

## Privacy and performance

Screenshots may contain personal, work or account information. They stay local and redacted areas must
not leak original fine detail through transparency. Pixelation is an obscuration tool, not a claim of
cryptographic erasure or guaranteed anonymity. Bounded previews and background image work should keep
large screenshot editing responsive; hardware profiling remains necessary before performance claims.

Future automatic import, shortcuts or capture must reduce real friction within public platform APIs.
Do not add permission breadth, immersion or backend services merely because a framework exists.

The requested original-image caption supplies visual context while keeping the crop/share workflow
primary. It uses Apple's local model only when actually supported, remains separate from edited pixels
and saved output, and is informational. Tool Options opens beside the image so style/color controls are
visible during annotation; its native sidebar toggle lets the user recover canvas space.

The initial left Tool Options layout was superseded by separate document navigation and right-side
properties. [Historical build-17 layout](261017_native-left-sidebar.md).


The October 18 owner-approved refinement separates documents from properties: a normal leading Images
sidebar for open images/session Recents, +/chevron image acquisition and an independently shown right
contextual inspector. New imports preserve current edits; switching preserves each image's Undo/viewport.
Closed images reopen as saved flattened pixels or discarded originals. Recents are session-only with
explicit clearing. [Document workflow](261018_document-sidebar-and-inspector.md).

Current window appearance uses one adjustable rear surface; image/controls do not fade with its settings.
The preview dims only the source area outside a crop, preserving the selected region and reachable
controls at zoom. The mask is a selection aid, not exported redaction. [Current release](../Documentation/RELEASE_NOTES.md).

On November 3 the owner requested copying an image URL from the web into Paste. The explicit acquisition step may now contact that HTTPS image host; cropping, markup and export remain on-device. It is an image download, not webpage capture or a browser, and image-data Paste still works offline.

## Mac use

The November 5 extension brings the same precise crop → annotate → Copy workflow to Mac. Native mouse,
keyboard, menu bar and file panels matter more than duplicating headset presentation. Preserve original
bytes and editable vectors, and protect unsaved work across image/window closure and Quit.

