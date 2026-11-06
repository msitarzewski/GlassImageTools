# Website, icon colors and MIT license — October 22, 2026

State: complete — reviewed, tested, applied; Release 1.0 (26) installed and identity read back. The
headset was locked, so normal launch is pending unlock. The website is built and checked locally and
**not published**.

Objective: The owner asked: "Take a look at the AutoPaper website and build one just like it for this
project. It was only supposed to be a tool for me, but maybe others will find value. I think the license
will be MIT. I'll put it into TestFlight when the time comes. Please also verify that the memory bank is
clean of PII, machine names, IPs, etc. Use the same BEDROCK vision for the home page. It'll also be hosted
with GitHub Pages! Update the colors in the icon to match AutoPaper too." Then: "Take screenshots, the
whole 9 yards."

**Correction (October 24):** AutoPaper is the owner's AI-wallpaper app. This build read "autopaper" as a
typo for AudioPaper, the owner's music-wallpaper app, without looking for AutoPaper, so everything below
was modeled on AudioPaper. AutoPaper's site is adapted from AudioPaper's (its build script says so) and
both apps' icons use the same red and silver, so the design, pages and colors match what was asked.
AutoPaper's later additions, such as footer links to the author's other projects, were not carried over
then; they were on October 24 ([AutoPaper footer and builder](261024_autopaper-footer-and-builder.md)).

Authorization: local edits, builds, tests, documentation, same-headset install/launch. The site is
prepared for GitHub Pages but no Git initialization, commit, push or Pages configuration happened.
Staged in a private copy against a hashed baseline (b26).

## Reuse

- AudioPaper's `scripts/build_site.py`, `site/layout.html`, `site/static/style.css`, page-fragment format,
  Pages workflow, LICENSE, SECURITY/CONTRIBUTING structure and FUNDING file were adapted, not reinvented.
  The site is a new responsibility here (no existing site, docs builder or Pages config).
- The existing README's usage and architecture text became the Help page and the public README.
- The icon keeps its SVG masters and generator; only colors and the generator's palette maps change.

## Privacy check (memory bank and everything publishable)

Private tokens were gathered locally and never printed: user name and home path, computer/local/host
names, headset and simulator identifiers, signing team and the owner's email. Every file outside ignored
local material was searched for them and for patterns (home paths, IPv4/IPv6, MAC, email, UUID, device
ECID/UDID shapes, possessive device names, team-ID settings). Before the change: 125 files, no private
identifiers; five pattern hits were false positives. After: 187 staged files, no host or device tokens;
the owner's name appears only as the deliberate author credit (LICENSE, README, site footer); remaining
hits are `example.com` (reserved), the `YOURTEAMID` placeholder and "Apple's Vision Pro". Shipped images
carry no camera, GPS or creator metadata.

## Changes

- **Website** (`site/`, `scripts/build_site.py`, `.github/workflows/pages.yml`): Home, Help, Reference,
  Privacy (rendered from `PRIVACY.md`), Credits and 404, with AudioPaper's layout and red tokens. The home
  page follows AudioPaper's honest structure: how it works, what leaves the headset (nothing on its own),
  what it can't do, what it asks of you (Xcode for now; 7-day free-account installs), leaving is easy, what
  has and hasn't been tested (dated), who made it and what's in it for them (AI assistance disclosed),
  check it yourself, and a hand-back line. Not on TestFlight yet; the page says so.
- **Repository files:** MIT `LICENSE` (© 2026 Michael Sitarzewski), `PRIVACY.md`, `SECURITY.md` (GitHub
  private vulnerability reporting rather than a published email), `CONTRIBUTING.md`, issue templates,
  `FUNDING.yml`, a public `README.md`, `_site/` ignored.
- **Screenshots** (`site/static/shots/`): taken from the real app in a dedicated visionOS 27.2 simulator by
  a scratch-only UI test (`SiteScreenshotTour`, never applied) that drives a normal launch: paste a made-up
  garden sign-up page, crop by exact fields, pixelate the name and email, box the error, add a note and an
  arrow, open a second image (this project's Geometry.swift), Copy, Export, Appearance. The before/after
  pair crops the original page and the PNG the app actually copied. Social card and favicons from the icon.
- **Icon:** recolored to AudioPaper's red as it renders (`#e33d32` → `#861910` ramp, lit top-left) and its
  bezel silver; background unchanged. Generator cobalt/dark maps follow. Build 26.

## Validation

| Check | Result |
|---|---|
| Core | 67 tests / 5 suites pass, exit 0 |
| UI suite | Not rerun: App, UITests and Sources are byte-identical to build 25 (37/37, exit 0) |
| Screenshot tour | Six iterations; final run exit 0, no skipped steps, 12 captures |
| Icon | Generator validated three planes; `actool` xros compile exit 0, SolidImageStack |
| Site | Build exit 0 (6 pages); 0 local link/anchor problems; no overflow at 390 px; all images have alt text |
| Lighthouse | Home (desktop light, mobile dark) and Help (desktop dark): accessibility, best practices, SEO 100 |
| Signed Release | build + analyze exit 0 (21 s); strict signature; 1.0 (26); add-only Photos only; no Debug markers |
| Capture probe | Device-SDK compile exit 0 (compilation only) |
| Headset | First install reported a dropped connection (exit 1) though the app list already read 1.0 (26); retry exit 0; identity 1.0 (26); locked, launch pending |

Screenshot-tour lessons are in [testing patterns](testing-patterns.md#website-screenshots-and-site-checks--build-26).

## Owner actions to publish

1. Create the GitHub repository (the site assumes `msitarzewski/GlassImageTools`; change `REPO`/`BASE_URL`
   in `scripts/build_site.py` and the links in `site/` and README if it differs), then commit and push.
2. **Settings → Pages → Source: GitHub Actions.** The `Website` workflow builds and deploys on push.
3. **Settings → Security → Private vulnerability reporting: enable**, which `SECURITY.md` relies on.
4. Add the TestFlight link to the home page, Help and README when there is one.

Limits: icon appearance on the Home View, launch of build 26, and the published site are owner
observations. [Evidence](../Documentation/Validation/website-icon-and-license.json).
