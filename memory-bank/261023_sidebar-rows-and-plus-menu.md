# Sidebar rows, a plain + and owner hardware checks — October 23, 2026

State: complete — reviewed, tested and applied; Release 1.0 (27) built and verified but **never installed**:
the headset was unreachable (CoreDevice 4016). Its changes reached the headset in build 28 (October 24).

Objective: Four owner messages on October 23, 2026:

1. "I've tested these: a hardware keyboard, saving to Photos and Files, and pasting into apps other than
   ChatGPT." These were listed as unchecked on the home page, README, status and release notes.
2. With a capture of the title bar (the + with its chevron pressed against "Pasted Image"): "We need to
   fix this too... it's a mess. Just make the + the drop down for now."
3. With a capture of a selected sidebar row (a large rounded platter): "I'd like these lists to match the
   new lists in the Vision Pro version of Glass Power Tools' terminal: tighter, smaller, more intentional."
4. About the home page's "What has been tested, and what hasn't" section: "I love the idea behind this...
   but not sure the people reading this will care."

Authorization: The requests cover local edits, builds, tests and documentation; the standing
same-headset signing/install/normal-launch authorization applies. No Git, publication or delegation.
Staged in a private copy against a hashed baseline.

Owners/reuse: `DocumentSidebar` owns the Images list; `EditorView.newImageMenu` owns the +;
`EditorView.workspace` owns the Images heading. The reference is the Glass Power Tools Vision Pro
terminal sidebar (`VisionTerminalWorkgroupView.terminalSidebar` and `VisionTerminalSidebarRow`, read in
its working tree on October 23): rows of its own in a ScrollView, not a List. No new source files.

## Owner-reported hardware checks

Recorded as the owner reported them, on October 23, 2026. The build, the keyboard shortcuts used, the
recipient apps, PNG or JPEG, and permission prompts were not specified, and none of it was observed
here. They move out of the "not yet checked" lists:

- a hardware keyboard with the app on a Vision Pro;
- saving to Photos and to Files;
- pasting into apps other than ChatGPT.

Still not checked on a headset: VoiceOver, Voice Control, Switch Control and keyboard-only navigation,
very large images and resource use, and locked-device file protection.

## Changes

- **+ menu:** a round Menu button (`buttonBorderShape(.circle)`) with the plain "New Image" label and
  no chevron. The shared `menuLabel` chevron made it a capsule that crowded the image name. The bottom
  toolbar's choosers keep theirs.
- **Sidebar rows:** plain Buttons in a ScrollView, measured like the terminal's: 2-point spacing, 8-point
  column inset, 12 × 8-point padding, a 16-point continuous rounded shape tinted `primary` at 12% while
  selected, `contentShape` for hover and context-menu preview, `.hoverEffect(.highlight)`, and the
  `isSelected` trait that the List supplied. Close Image stays in each open row's context menu; Recents
  rows reopen, Clear Recents is a red row, and the session hint stays.
- **Sections:** native DisclosureGroups through a `SidebarSection` style: a headline title, a chevron
  that turns (animated unless Reduce Motion), and an Expanded/Collapsed value. Open Images starts
  expanded and Recents collapsed, as before.
- **Previews:** unchanged, as tall as the two text lines (build 24's owner request).
- **Images heading:** inset 20 points, the rows' text edge (8 + 12), was 24.
- **Website:** the home page's testing section is removed; "Who made this" stands alone at reading width
  (a `.read` section class keeps headings aligned). Help lists keyboard shortcuts without saying where
  each was checked; Reference keeps its assistive-technology limit. Eight screenshots retaken from build 27.
- **Records:** project rule 30 now keeps testing status in README/STATUS, off the website.
- **Build:** 1.0 (27).

## Validation

| Check | Result |
|---|---|
| Simulator build | Debug visionOS Simulator build exit 0; capture shows the round + and compact rows |
| Full UI suite | **37 / 37, exit 0, 1,138 s**, including all-issue audits and sidebar disclosure/row cases |
| Core | Not rerun; Sources, Tests, Package.swift, UITests and CaptureProbe hash-identical to build 26 |
| Screenshot tour | exit 0, 12 screens (224 s); 8 site images regenerated with the build-26 crops |
| Site | 6 pages; 0 local link, anchor or alt problems; no horizontal overflow; section headings aligned |
| Signed Release | build + analyze exit 0 (17 s); strict signature; 1.0 (27); add-only Photos only; no Debug markers |
| Headset | Not installed: lockState failed twice with CoreDevice 4016 (device unreachable) |

Limits: gaze/hand feel of the new rows and the + on a headset; the owner-reported checks above are not
tooling observations. [Sanitized evidence](../Documentation/Validation/sidebar-rows-and-plus-menu.json).

## Documents updated

README, home/help/reference pages and stylesheet, STATUS, release notes, accessibility audit, system patterns,
decisions, progress, active context, testing patterns, build/deployment, quick start, index and the
October summary.
