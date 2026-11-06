# App Store preparation — build 29, October 25, 2026

State: complete. Reviewed, checked and applied; **installed and running on the headset** (October 25, once
the owner woke it; the first attempt found it unreachable). Nothing was uploaded, submitted or published.

Objective: the owner pointed out that the distribution model differs: "AutoPaper isn't a visionOS app
though, this will have to go through the app store. More like Glass Power Tools in that regard. Though it
hasn't really made it either lol". Compared with Glass Power Tools' App Store work, this project lacked
five things:
- a privacy manifest;
- the privacy page's account of Apple's crash reports;
- a support URL;
- the listing and App Store Connect answers, with the encryption key;
- the wording the site needs once TestFlight exists.

The owner: "yes, bring those over now".

Authorization: local edits, builds, checks and documentation; same-headset install and launch (standing).
No Git, upload, App Store Connect changes, publication or delegation. Staged in a private copy against a
hashed baseline.

Owners/reuse: Glass Power Tools' `Documentation/AppStore/` layout (fastlane `deliver` files and a
README of answers), its privacy manifest and its PRIVACY.md crash-report line, adapted to this app. The
support URL reuses the Help page's existing "Asking for help" section rather than adding a SUPPORT.md.
No App Store files existed here before. App Swift sources, tests, core and the capture probe are
hash-identical to build 28.

## Changes

- **Privacy manifest** (`App/PrivacyInfo.xcprivacy`, new; a resource of the app and of the capture probe
  through XcodeGen):
  - no tracking, tracking domains or collected data;
  - one required reason, user defaults `CA92.1`, for the window's Opacity and Glass settings
    (`@AppStorage`).
  - The Release binaries were scanned against Apple's list. The app imports only `NSUserDefaults`, through
    `AppStorage`.
  - `VisionSnipCore` uses `attributesOfItem` for sizes, types and permissions (`NSFileSize`, `NSFileType`,
    `NSFilePosixPermissions`). None of those are on the list, so the framework needs no manifest. Apple
    requires one for "each executable or dynamic library in an app that uses a required reason API".
- **Encryption:** `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO` on the app target. The app has no
  encryption of its own; its private copies use the system's file protection.
- **Build 29:** `CURRENT_PROJECT_VERSION` raised from 28 to 29 so the changed bundle has its own identity.
  The project was regenerated: 12 project lines changed, all for the manifest, the key and the version.
- **PRIVACY.md:** a short-version line and a new "TestFlight and the App Store" section. Today a self-built
  copy sends the author nothing. Apple's [TestFlight & Privacy](https://www.apple.com/legal/privacy/data/en/test-flight/)
  page (January 27, 2025) says TestFlight collects crash logs and usage information automatically, with no
  opt-out. Feedback goes to the developer too, and so do name and email unless the tester joined through a
  public link. The App Store passes crash data and usage statistics only to users who share analytics with
  developers. A sentence on the author's own use ("only to find and fix problems … doesn't pass them on")
  is the owner's commitment, confirmed October 25 ("keep it"). The intro's "checked against the source" date is now
  October 25.
- **`Documentation/AppStore/`** (new):
  - **Listing**, in `metadata/`:
    - name, subtitle, promotional text, description and keywords, each within App Store Connect's limits
      (17/30, 28/30, 166/170, 2,356/4,000, 97/100);
    - support, marketing and privacy URLs and the copyright;
    - categories Graphics & Design, then Productivity (owner-confirmed October 25; Developer Tools doesn't
      fit Apple's definition, "tools for app development, management, and distribution");
    - App Review notes (1,474/4,000). The description is drawn from the Help page.
  - **README.md:**
    - the App Store Connect answers: free; Data Not Collected, under Apple's definition and its "You are not
      responsible for disclosing data collected by Apple"; no third-party content; every age-rating question
      No (4+); no export documentation; China mainland's ICP filing number;
    - Accessibility Nutrition Labels, held until headset checks;
    - EU trader status, the owner's decision;
    - screenshots: 3840 × 2160 full frames from the existing simulator tour;
    - versions and the steps before the first upload (distribution archive, Organizer privacy report);
    - a seven-point list for the day a TestFlight link exists.
- **README and CONTRIBUTING:**
  - The README's privacy list notes Apple's TestFlight and App Store reports, and its status adds build 29.
  - CONTRIBUTING lists the manifest and listing, and adds a rule: keep the manifest true when a change uses a
    required-reason API.

The site's home page and Help are unchanged: they say "not on TestFlight yet", which is still true. The App
Store README's TestFlight list holds their future edits.

## Validation

| Check | Result |
|---|---|
| Core | `swift test`: 67 tests in 5 suites pass, exit 0 |
| Simulator build | Debug, generic visionOS Simulator: exit 0; the bundle carries the manifest |
| Signed Release | Build/analyze exit 0; strict signature; 1.0 (29); `ITSAppUsesNonExemptEncryption` false; add-only Photos string; manifest at the bundle root, byte-identical to the source, `plutil` OK; framework has no manifest; no Debug test markers. Only notes: App Intents metadata extraction skipped, as in build 28's first full build |
| Required-reason scan | App binary: `NSUserDefaults` (via `AppStorage`) only. Framework: none of Apple's listed APIs |
| Simulator launch | Install exit 0; launch exit 0; one running process; build 29 |
| Physical | First, lockState and one bounded install attempt: CoreDevice 4016 (unreachable), exit 1. After the owner woke the headset ("headset's awake, install build 29"): lockState exit 0, no passcode required; install exit 0; identity 1.0 (29); normal launch exit 0; one running process |
| Site | 6 pages, 0 link/anchor/alt problems; only `privacy.html` changed; the new Apple link returns 200; no overflow at 375 px (light) or 1280 px (dark); Lighthouse mobile/light and desktop/dark: accessibility, best practices and SEO 100, 0 failed audits |
| Listing | Every field within its limit; no keyword repeated or taken from the name or subtitle |
| Sources | App, core, tests, UI tests, capture probe and tools Swift files hash-identical to build 28 |

Limits:
- The headset install proves installation, identity and launch only; nothing on screen changed.
- The manifest is checked against Apple's documentation and the binaries, not by App Store Connect. An
  archive, distribution signing, the Organizer privacy report and an upload remain untried.
- EU trader status, TestFlight version numbers and screenshot framing are the owner's to confirm.
- Glass Power Tools hasn't been released either. Its layout is a model, not proof of acceptance.

## Build 30: the bundle identifier

The owner, shown the old identifier: "definitely not this: com.glasspowertools.visionsnip maybe
com.glassimagetools ?". `Config/Identity.xcconfig` now sets `com.glassimagetools`, mirroring Glass Power Tools'
`com.glasspowertools`; the derived identifiers follow (`.core`, `.captureprobe`, `.uitests`). No code reads the
identifier. `CURRENT_PROJECT_VERSION` is 30; regenerating changed only the two version lines. No source or
test changed, so the suites were not rerun.

| Check | Result |
|---|---|
| Signed Release | Build/analyze exit 0 (77 s, Xcode 27.2 beta); `com.glassimagetools` 1.0 (30); framework `com.glassimagetools.core`; strict signature; manifest matches source; encryption key false; add-only Photos only; no Debug markers |
| Headset | lockState exit 0, no passcode; install exit 0 (3 s); identity 1.0 (30); normal launch exit 0 (1 s). Build 29 remains installed under the old identifier as a separate app; two app processes were running, the old copy having been open |
| Account | Development signing still uses the team's wildcard profile, so nothing was registered; the identifier isn't reserved until an App ID or the App Store Connect record is created |

## Other owner decisions, October 25

- Kept PRIVACY.md's sentence on the author's use of Apple's reports ("keep it").
- Categories: Graphics & Design, then Productivity. Developer Tools was raised; Apple defines it as "tools for
  app development, management, and distribution".
- Support and security contact: the owner's Gmail, as in Glass Power Tools ("use my gmail like my other
  apps"), in Help, SECURITY.md, PRIVACY.md and the App Store README. The site rebuilt with 0 problems; the
  privacy scan finds the address only in those files.
- The account, checked locally: Xcode has one paid individual developer team, the same as Glass Power
  Tools'. The released Xcode 27.1 builds signed Release 1.0 (29) (exit 0, 51 s); uploads need a released Xcode.
- Still open: 1.0 or another version number for TestFlight, EU trader status and screenshot framing. The
  owner removed build 29 from the headset before October 26; `devicectl` finds no app under the old identifier.

[Sanitized evidence](../Documentation/Validation/app-store-preparation.json).
