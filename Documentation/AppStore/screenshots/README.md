# Apple Vision Pro screenshots

Prepared for candidate 1.0 (38), captured from the real app using normal startup in the visionOS 27.2 simulator. Seven unchanged editor views retain their build-36 capture provenance; the opening screen is refreshed from build 37 to show image-link Paste. Each entry records its capture build. The [manifest](manifest.json) gives capture-run completion time, order and SHA-256 hashes.

| Order | Image | What it shows |
|---|---|---|
| 1 | [01-editor.png](01-editor.png) | Crop, pixelate and add an editable note |
| 2 | [02-open.png](02-open.png) | Photos, Files, Drop and Paste |
| 3 | [03-crop.png](03-crop.png) | Exact crop dimensions in original pixels |
| 4 | [04-text.png](04-text.png) | Native inspector and editable text |
| 5 | [05-pixelate.png](05-pixelate.png) | Pixelate before sharing |
| 6 | [06-images.png](06-images.png) | Native Open Images and Recents sidebar |
| 7 | [07-export.png](07-export.png) | PNG/JPEG export and save-new-image options |
| 8 | [08-appearance.png](08-appearance.png) | Window opacity and glass settings |

Every store image keeps the full **3840 × 2160** native frame. The PNGs are opaque 8-bit sRGB; metadata is stripped. Controls were not redrawn, repositioned or composited after capture. Website images use cropped/resized versions of these same captures.

The inputs are [fictional demo images](../demo/README.md); no personal screenshot or real account details are included. The simulator environment and system controls are Apple's. Pixelation, text, crop and copied output are actual app operations. These pictures do not certify capture APIs, recipient-app compatibility or physical assistive control support.

Apple accepts one to ten Vision Pro screenshots at this size, JPEG or PNG without an alpha channel ([specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)). This packet supplies eight. App previews are optional and are not included.

Build 38 adds a separate Mac target. These retained visionOS views are unchanged; they are not Mac screenshots and their capture-build fields remain 36/37.
