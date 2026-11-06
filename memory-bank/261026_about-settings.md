# About in Settings — build 31, October 26, 2026

State: complete. Built, signed, verified and **installed** October 26; **normally launched and independently
verified running** October 29 after unlock, without rebuilding or reinstalling. Nothing was uploaded, committed or published.

Objective: the owner removed build 29 (the copy under the old identifier) from the headset, then asked:
"let's take a look at the about page in settings...it's missing right now. Use the AutoPaper version so users
know the who/where/why behind it." The Settings sheet had only the window's Opacity and Glass. No About page
had ever existed.

Authorization: local edits, builds, tests and documentation; same-headset install and launch (standing).
No Git, upload, App Store Connect change or publication.

Owners/reuse: AutoPaper's `apps/macos/AutoPaper/Settings/AboutSettings.swift`, itself AudioPaper's layout:
icon, name, "Version x (build)", a short description, Website · Privacy · Help, "MIT · © 2026 Michael
Sitarzewski". Its update controls are left out, since Apple's TestFlight and App Store handle updates. The
existing Settings sheet (`App/AppearanceSettings.swift`) hosts the link. The About image comes from the icon
generator, which already composites the three layers for proofs.

## Build 29 removed by the owner

The owner removed it. `devicectl device info apps` on October 26 finds nothing under
`com.glasspowertools.visionsnip` and `com.glassimagetools` at 1.0 (30).

## Changes

- **`App/AboutSettings.swift`** (new, after AutoPaper's file of the same name):
  - the icon at 96 points, clipped to its circle;
  - "Glass Image Tools" as a header, and "Version 1.0 (31)" read from the bundle;
  - who and why: "Crop a Vision Pro screenshot, mark it up, and paste it, without taking the headset off."
    and "Michael Sitarzewski made it for exactly that, and shares it free in case it's useful to you too.";
  - where: Website, Privacy and Help links to the GitHub Pages site (`Website`, as in AutoPaper);
  - "MIT · © 2026 Michael Sitarzewski".
- **Settings sheet:** titled **Settings** (it was "Appearance"), matching the gear's label and ⌘,. An ⓘ
  button in its title bar, opposite **Done** and labeled "About Glass Image Tools", opens the page. A first
  try put the link in a last section of the form; the simulator showed it below the fold, because the form
  already fills the sheet, so it moved to the title bar, where it is always visible.
- **About image:** `Tools/GenerateIcon.swift` also writes `AboutIcon.imageset`, the flat 256-pixel
  composite of the layers. Rerunning it left the three layer images byte-identical.
- **Build 31:** `CURRENT_PROJECT_VERSION` 30 → 31; the project differs only by the new file and the version.
- **Help:** "The window's look" is now **Settings and About**: the ⓘ button opens About, and what it shows;
  ⌘, opens Settings.
- **PRIVACY.md:** a row for the About links: Safari opens the site, hosted by GitHub.
- **UI test:** the accessibility audit opens About at standard and largest text, checks the version label
  against the bundle's and the three links, audits the page and goes back.
- **Help's Settings picture** retaken from the app with a short scratch tour, encoded like the other
  inspector shots (1200 × 962 JPEG, no metadata).

## Validation

| Check | Result |
|---|---|
| UI tests | The four tests that open Settings: 4/4 with About as the form's last row; with the ⓘ, 4/4 alone on a restarted simulator (exit 0, 419 s), no accessibility issues. A run alongside the tour, Release build and install failed two tests (a Glass drag stopping at 4%, then lost accessibility and app-termination errors); the audits passed in it. Full suite not rerun |
| Simulator look | Settings: ⓘ, centered title, Done, sliders unchanged. About: icon, name, Version 1.0 (31), both lines, three links, MIT line |
| Signed Release | Build/analyze exit 0 (73 s); strict signature; `com.glassimagetools` 1.0 (31); encryption key false; manifest matches source; add-only Photos; no Debug markers; About image in `Assets.car` (256 px, vision 2x) |
| Networking | `grep -rn -E "URLSession\|import Network\|NWConnection" App Sources`: none |
| Site | 6 pages, 0 problems; links 0 bad |
| Privacy scan | Findings unchanged; the new files add none |
| Headset | October 26/28 history: lockState exit 0, passcode required; install exit 0 (1 s); identity 1.0 (31). Launch timed out after 120 s (exit 124) while locked; no process. Retried October 28: still locked, exit 124, and a 20-minute wait for the unlock ended with the passcode still required |

Limits:
- Normal launch/process is verified October 29; a physical look at Settings/About and its input remain owner acceptance.
- The links lead to the GitHub Pages site, which isn't published yet.
- VoiceOver, gaze and hands on the ⓘ and the links are untried on a headset.

[Sanitized evidence](../Documentation/Validation/about-settings.json).

## October 29 — successful launch after unlock

The owner reported "vp is available." Supported device commands verified no passcode required, installed
identity 1.0 (31), normal launch exit 0 (1.375 s), and one matching process in an independent query (exit 0).
No rebuild, reinstall, forced termination or test arguments. Prior locked timeouts above remain historical.
[Launch record](261029_build31-launch.md). This verifies launch, not physical About appearance/input.
