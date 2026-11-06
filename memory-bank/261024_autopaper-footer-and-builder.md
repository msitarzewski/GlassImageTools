# AutoPaper's site footer, builder and Pages workflow — October 24, 2026

State: complete — reviewed, checked and applied. Website only: no app source, test or build-number change;
the installed app stays 1.0 (28). The site is built locally and **not published**.

Objective: after the AutoPaper correction (the October 22 request named AutoPaper, which build 26 read as
AudioPaper), the owner asked: "Yes, bring over the footer row and builder changes. It's important to be
thorough."

Authorization: local edits, builds, checks and documentation. No Git, publication or delegation. Staged in
a private copy against a hashed baseline.

Owners/reuse: AutoPaper's `site/layout.html`, `site/static/style.css`, `scripts/build_site.py` and
`.github/workflows/pages.yml` (its local checkout matched GitHub) against this project's copies, which came
from AudioPaper's. In AutoPaper's history the builder changes date from its first commit, and the workflow
changes from its 0.1.4 security round ("CI actions are pinned"), after its security review found that the
build job held a Pages deploy token it doesn't need. No new site files.

## Changes

- **Footer** (`site/layout.html`, `site/static/style.css`): Help and Privacy join Source, Issues, Security
  and Credits, and a new "Also by Michael Sitarzewski" row lists AudioPaper, AutoPaper, Agency Agents and
  Brew Browser with the README's descriptions. As on AutoPaper, footer lines keep the reading width and the
  row is 14 px dim text. One addition AutoPaper doesn't have: a project name never breaks across lines
  ("Brew / Browser" did at desktop width).
- **Builder** (`scripts/build_site.py`):
  - links only pages that were built, in the nav and the sitemap;
  - renders PRIVACY.md only when it exists, so pandoc is needed only then, and the error names the file;
  - rewrites links only in real `<a href>` tags, keeping their other attributes, so text inside code
    examples stays as written (the old pattern rewrote `href="…"` inside code too);
  - inserts the source note without regex replacement escapes;
  - skips Finder's `.DS_Store` files and reports skipped documents.

  AutoPaper-only parts were left out: NETWORK.md, the update feeds and `examples.json`. A side effect: the
  old nav f-string put a backslash inside braces, which only Python 3.12 or later accepts; the new code
  also runs on macOS's own Python 3.9.
- **Pages workflow** (`.github/workflows/pages.yml`): only the deploy job has `pages: write` and
  `id-token: write`; the build job reads contents only. Each action is pinned to a release commit with the
  version beside it: checkout v7.0.1 (`3d3c42e…`), upload-pages-artifact v5.0.0 (`fc324d3…`) and
  deploy-pages v5.0.1 (`368f825…`), each matched to its tag on October 24. `configure-pages` is dropped,
  as on AutoPaper (it needs the Pages permission the build job no longer has); Pages must be set to GitHub
  Actions before the first deploy, as already documented.
- **Records:** tech context still described build 26 and the toolbox icon; it now says 1.0 (28) and the
  round picture icon.

## Validation

| Check | Result |
|---|---|
| Builder regression | New builder with the old layout: all 26 output files byte-identical to the old builder's |
| Footer diff | New layout: each of the 6 pages differs only by its 3 footer lines; the stylesheet only by footer rules |
| Edge cases | No PRIVACY.md and no pandoc: 5 pages, no Privacy in nav or sitemap, skip reported. PRIVACY.md without pandoc: exit 1 naming it. `.DS_Store` not copied. A link test document (titles, folders, anchors, footnotes, autolinks, code) is rewritten correctly with code untouched; the old builder rewrote the code |
| Python | Builds with Homebrew Python 3.15 and macOS Python 3.9.6; the old builder doesn't parse on 3.9 |
| Workflow | actionlint: 0 problems; same as AutoPaper's apart from project lines; pinned commits equal the current v7/v5/v5 tags |
| Site | 6 pages; 0 local link, anchor or alt problems; nothing loads from elsewhere; the 4 new outside links return 200 |
| Layout | 375 px light and 1280 px dark: no horizontal overflow; each project name on one line |
| Lighthouse | Home, mobile light and desktop dark: accessibility, best practices and SEO 100; 0 failed audits |
| Privacy scan | Known false positives, plus one new: the three pinned action commits match the 40-hex device-ID pattern; they are public GitHub commits |

Limits: the workflow change is checked with actionlint and against AutoPaper's working workflow, not by a run
here; it first runs on the first push. The footer's Privacy link is static, so a build without PRIVACY.md would
link a missing page (AutoPaper's footer has the same property).
[Sanitized evidence](../Documentation/Validation/autopaper-footer-and-builder.json).

## Documents updated

Build/deployment, security, testing patterns, tech context, decisions, progress, active context, index, the
October summary, STATUS, CONTRIBUTING and the October 22 task note's correction.
