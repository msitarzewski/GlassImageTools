# Privacy

Glass Image Tools edits screenshots on your Apple Vision Pro or Mac. Screenshots often show things that aren't anyone else's business: names, messages, account pages. This page says exactly what the app keeps, what it sends, and what Apple's own features do with what you choose to share. Checked against the source on November 5, 2026.

## The short version

- **No backend, account, analytics, crash reporting or tracking.** If you explicitly paste a direct HTTPS image link, the app requests that image from its host. Editing and export run locally; the app never uploads your images.
- **Apple's TestFlight and App Store can add reports of their own.** A copy you build yourself sends the author nothing. A TestFlight copy sends crash logs and usage information through Apple; an App Store copy, only if you choose to share analytics with developers ([below](#testflight-and-the-app-store)).
- **It only opens images or image links you hand it.** Photos and Files open in Apple's own pickers, which give the app the one image you choose, not your library. Paste reads the clipboard only when you explicitly choose **Paste**, tap the empty window’s drop/Paste well, or press **⌘V** there. Drops receive only the image providers you hand over. A direct well/keyboard paste uses Apple’s clipboard privacy controls, which may request consent for content from another app.
- **Your original is never changed.** Copy, Share and Save always make a new image.
- **New images carry no location or camera details.** The metadata in the original (GPS position, camera, dates) is left out of everything the app writes.
- **Pasting an image link contacts its host.** The host sees your IP address and requested URL, including any query parameters. Copy, Share and save use Apple's services under their own rules (below).

## What stays on your device

| What | Where | How long |
|---|---|---|
| A private copy of each image you open | The app's temporary folder | While the image is open or listed in **Recents**. Closing its window or choosing **Clear Recents** deletes it; if the app is force-quit, the next launch deletes what was left |
| Your crop and annotations | Memory only | Until you close the image. They aren't saved anywhere unless you save a new image |
| **Recents**: images you closed, as the copy you last saved or, if you discarded your edits, the original | The app's temporary folder | Until you choose **Clear Recents** or close the window |
| The file being prepared for Copy, Share or Save | The app's temporary folder | Deleted when the sheet closes, or at the next launch |
| Vision Pro window appearance settings | The app's preferences | Until you change them or delete the app |

macOS also manages ordinary window placement and interface preferences. The app stores no persistent document list.

Nothing else is stored: no history of what you've copied, no list of the files you've opened, no thumbnails kept between launches.

## Pasting a web image link

Paste accepts one direct **HTTPS** image URL, either a URL item or plain text. A real image representation on the clipboard takes priority and requires no download. Ordinary text is not scanned for links, and copying a link alone never starts a request.

The download uses a temporary session with cookies, saved credentials and caching disabled. Requests send no existing image and no browser cookies or referrer. HTTPS redirects can contact another image host; each receives the requested URL and your IP address. A signed or tracking URL can contain identifying query parameters, so paste only links you intend to request. The hosts handle those requests under their own policies; the app's developer receives no request or image.

Only supported image data is opened. HTML pages, login prompts, insecure links and oversized responses are refused. There is a 256 MiB limit checked before and during transfer, a 20-second request inactivity timeout and a 60-second transfer limit. Cancel stops the request and removes its partial working file; interrupted files are purged at next launch. The completed image follows the same protected Open Images/Recents lifetime as other imports. The app keeps a filename, not the full URL, query or a download history. Some sites require browser authentication or a referrer; copy the image itself in your browser if their links fail.

## The description under the image

On visionOS 27 or later, with Apple Intelligence turned on, the app asks Apple's on-device model for a one-sentence description of the original image and shows it below the canvas. That request runs on the headset through Apple's Foundation Models framework; the app sends it nowhere else. The description isn't saved, isn't part of anything you copy or export, and is gone when you close the image. On earlier systems, or with Apple Intelligence off, no description is made and none is shown.

## What leaves, and only when you ask

| You choose | What happens | Who decides what happens next |
|---|---|---|
| **Paste an HTTPS image link** | An image request goes to that URL and permitted HTTPS redirect hosts; each can see your IP address and the requested URL/query | The image hosts, under their own privacy policies; no cookies, saved credentials or existing image are sent |
| **Copy** | A PNG of your edited image goes on the system clipboard, the same way Share › Copy does it | Apple's **Universal Clipboard** can make it pasteable on your other Apple devices signed in to the same Apple Account, nearby, with Handoff on. The app keeps no clipboard history |
| **Share…** | Apple's share sheet sends the new image wherever you pick | The app or person you send it to |
| **Save New Image to Photos** | A new photo is added to your library. The app asks for **add-only** access the first time, which lets it add photos but not see any | If you use iCloud Photos, Apple syncs it like any other photo |
| **Save to Files… / Save As…** | A new file is saved where you pick | Wherever that location syncs, if anywhere |
| A link in **Settings › About** | Safari opens this project's website: its home, privacy or help page | Safari and GitHub, which hosts the site, under their own privacy terms |

## TestFlight and the App Store

Today the only way to get Glass Image Tools is to build it yourself, and then none of this applies. When there is a TestFlight or App Store version, Apple's own services add what's below. The app's code has no part in them; they work the same way for every app.

| Where you got it | What Apple passes to the author |
|---|---|
| **You built it with Xcode** | Nothing |
| **TestFlight** | Crash logs and usage information, collected automatically while you test a beta; Apple says you can't opt out. Feedback you send from TestFlight, with any screenshot you attach, so crop or pixelate it first. If you were invited by email, your name and email address can come with them; if you joined through a public link, they don't. Apple keeps beta feedback for a year, and may keep crash and usage data until the bugs are fixed. Details: Apple's [TestFlight & Privacy](https://www.apple.com/legal/privacy/data/en/test-flight/) |
| **The App Store** | Crash data and statistics about how the app is used, and only if you've chosen in your device's settings to share analytics with app developers. That choice and those reports are Apple's |

The author uses these only to find and fix problems in the app and doesn't pass them on to anyone; for TestFlight data, Apple's terms forbid that anyway.

## Pixelate is not erasure

**Pixelate** redraws the area under it as large blocks, in the new image only: the area is shrunk to one color per block, then enlarged again. The fine detail underneath is gone from that copy, not hidden behind a filter. But each block is still an average of what was there: large text, faces or simple shapes can stay recognizable, and smaller blocks hide less. Use a larger block size, or crop the area out, when it matters. Your original still contains everything.

## Permissions

- **Photos (add only):** asked the first time you choose **Save New Image to Photos**. Without it, saving to Photos doesn't work; everything else does. Change it in **Settings › Privacy & Security › Photos** on Vision Pro, or **System Settings › Privacy & Security › Photos** on Mac.
- That is the only permission the app asks for. It doesn't ask for your camera, microphone, location, contacts or full Photos library.

## Mac sandbox

The native Mac app uses Apple's App Sandbox. Its entitlements allow read/write access to files you select,
Photos operations and outgoing network connections for explicit HTTPS image-link Paste. There is no
full-disk, whole Pictures/Downloads folder, incoming server or screen-capture grant. Originals and rendered
working files stay inside the app container; native Open/Save panels grant access to chosen locations.
Photos saving requests add-only authorization in code. Selecting a photo uses Apple's picker.

## Checking it yourself

- **Read the download boundary.** `Sources/VisionSnipCore/ImageLinkImportService.swift` owns the explicit HTTPS image requests, ephemeral session, redirect limits and bounded private-file writes. `ImageImportService` invokes it only for an explicit image-link Paste fallback. There is no upload API, telemetry client or backend.
- **Look at what it writes.** Export or copy an image of a photo that has a location, then check the new file's details in Photos or Files: there's no location.
- **Run the tests.** `swift test` includes checks that exported PNG and JPEG files carry no GPS or camera metadata from the original.

## Questions

Write to <msitarzewski@gmail.com>, or report a privacy concern privately the same way as a security issue; see [SECURITY.md](./SECURITY.md).
