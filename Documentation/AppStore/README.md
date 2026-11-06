# Apple submission packet

Updated November 5, 2026 for **Glass Image Tools 1.0 (38)**, native Apple Vision Pro / visionOS 26 or later. Build 38 adds a separate native Mac preview and shared platform seams; prior build 37 added direct HTTPS image-link Paste. Last verified headset identity remains 36. This folder remains the visionOS packet; Mac screenshots, platform/account records and distribution work are not prepared here. Current verification is recorded in [verified status](../STATUS.md) and [the Mac extension task](../../memory-bank/261105_native-sandboxed-mac.md). This folder prepares store data and images; it does not represent a submitted build or App Store Connect account state.

## Start here

- [Submission answers and remaining account steps](SUBMISSION.md).
- [Screenshot order, provenance and format](screenshots/README.md).
- `metadata/en-US/`: the English name, subtitle, promotional text, description, keywords and three URLs, one plain UTF-8 value per file.
- `metadata/review_information/notes.txt`: paste into App Review Notes. No sign-in is required; there are no credentials.
- `metadata/copyright.txt`, `primary_category.txt`, `secondary_category.txt`: shared app information. Graphics & Design, then Productivity, were approved by the owner October 25.
- `testflight/en-US/`: beta description and What to Test; `testflight/feedback_email.txt` is the already approved public support email.
- [Validation report](validation.json): generated field lengths/bytes and screenshot checks. Rebuild it after editing fields or replacing images.

Run from the repository root:

```sh
python3 scripts/validate_store.py --report Documentation/AppStore/validation.json
python3 scripts/build_site.py
```

The [Apple field reference](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/) limits promotional text to 170 characters and description to 4,000 characters; keywords have a **100-byte UTF-8** budget and review notes a **4,000-byte UTF-8** budget. Name and subtitle allow 30 characters ([app information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/)). The validator checks the files, not Apple's eventual acceptance.

## Confirmed publication gap

On October 31, the proposed marketing, support and privacy URLs and public source repository all returned HTTP 404. Their contents are prepared locally here. Publish the public-safe repository/site and verify the pages before using them in App Review. A local site build is not proof those URLs are live. No TestFlight or App Store link has been supplied, so the site and README keep build-from-source instructions.

The canonical privacy page is generated from [PRIVACY.md](../../PRIVACY.md). Support points to the Help page's contact section, including the owner's approved email. App Review contact name/phone/email and trader information belong in App Store Connect, not this public packet.

## Build and release boundaries

The current project is 1.0 (38), bundle identifier `com.glassimagetools`. The consumer editor does not perform screen capture; the separate research probe remains unconfirmed. Image-link Paste now downloads only the explicitly supplied HTTPS image, with no existing-image upload or tracking. Xcode 27.2 (27B52) was observed and used for build 36; older beta-toolchain notes are historical. Mac build 38 is development-signed; visionOS source 38 has simulator compilation evidence only. Build a fresh visionOS distribution candidate before upload; the previous signed build-37 artifact is historical. An App Store distribution archive, Organizer privacy report, upload/processing, external TestFlight review and App Review submission are still separate steps; this task does not claim they passed.

Before uploading, verify the chosen build number has not already been used in the account. Regenerate `GlassImageTools.xcodeproj` from `project.yml` if either version changes. The initial 1.0 App Store version has no What's New field; Apple requires that field for later updates. TestFlight What to Test is prepared independently.

## After a public TestFlight link exists

Update the site home and Help getting-it sections, README availability and PRIVACY.md's distribution introduction together. Keep the Apple-managed TestFlight/analytics disclosure. Do not invent a TestFlight URL or imply the local build has distribution approval.
