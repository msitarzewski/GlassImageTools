# Round picture icon — October 24, 2026

State: complete — reviewed, verified, applied, **installed and running**: once the owner woke the headset on
October 24, Release 1.0 (28) was installed, its identity read back, normally launched and seen running.
Build 27 was never installed; its changes reached the headset in build 28.

Objective: owner messages on October 24, 2026, in order:

1. With the toolbox icon: "I like the direction of this icon, but it feels sharp? What can we do to soften
   or change it?"
2. "What if we start over (since this is Vision Pro only) and use Glass style (like the other apps), but
   instead of a monitor/display, we use a Vision Pro instead? Stylized like our monitor, but with the
   "image icon" and a basic wrench in the headset?"
3. "If we left out the Vision Pro and built a round version of the "image icon", what would that look
   like? Just that a round version of the image icon in our Glass style."
4. "I love the round one so much. Let's make it take more of the circle (all of it?), then we can see how a
   wrench might fit?"
5. With a sketch on the full-circle version: "Let's use the wrench's edge here instead of the right side of
   the mountain ... or as much as it takes to look like the tool, but is also the mountain shape?"
6. "Let's just roll with the regular circle image icon. It looks great, and I'm just trying to make it
   more complex. Please prepare this for Vision Pro's layered glass icon system so it's as beautiful as
   possible."
7. After the first build-28 report kept a baked gloss on the glass: "Take yours out anyway... let's leave those touches to Apple's default team."

Authorization: the icon redesign and its preparation cover local edits, builds and documentation; the
standing same-headset signing/install/normal-launch authorization applies. No Git, publication or
delegated edits (two read-only web lookups of Apple's guidance were delegated). Staged in a private copy
against a hashed baseline.

Owners/reuse: `Tools/Icon/*.svg` and `Tools/GenerateIcon.swift` own the icon; the website icons, favicons
and social card are derived from its composite as in build 26. New files: this note, the evidence JSON
and a 256-pixel proof.

## Explorations, set aside

Drawn as scratch proofs and shown to the owner; none shipped.

- **Softened toolboxes:** the same toolbox with rounded corners, round-capped crop marks and a thicker
  handle; a front view; a front view with the brush.
- **A Vision Pro headset** in the family style (silver frame, red visor) with a picture and a wrench,
  with and without the head band. Apple's pages were read: none bans a stylized Apple product in an app
  icon, but App Review guideline 5.2.5 ("confusingly similar to an existing Apple product") and the
  marketing guidelines' ban on "Illustrations that depict an Apple product" in marketing materials made it
  a risk. The HIG app-icons page did not load in that lookup.
- **The round picture** at three sizes; the owner chose "all of it", the frame at the icon's edge.
- **A wrench in the hills:** the head as the small hill read as a hook; the head as the peak, jaw open to
  the sky, read as a wrench. The owner set it aside as more complex than needed.

## Layer design

Apple's guidance (HIG app icons and Xcode's "Configuring your app icon", read through their JSON data on
October 24): a visionOS icon is "a background layer and one or two layers on top"; "The system enhances
the icon's visual dimensionality by adding shadows that convey a sense of depth between layers and by using
the alpha channel of the upper layers to create an embossed appearance"; "Avoid adding a shape that's
intended to look like a hole or concave area to the background layer"; provide square layers and let the
system mask them; keep content centered; the system supplies highlights and shadows.

| Plane | Content | Why |
| --- | --- | --- |
| Front | Silver frame: the whole canvas outside the glass (radius 455.4) plus a 6-pixel dark rim | Nearest, so the system embosses it and it shadows the picture; a frame painted on Back would be the recess Apple warns about |
| Middle | White sun and hills; hills clipped at radius 485 | They float between frame and glass; running under the frame keeps their edge hidden when layers shift |
| Back | Red glass (Glass Power Tools' visionOS red, a top-left to bottom-right ramp); silver past radius 490 | Simple full-bleed background; the silver only shows if the frame slides |

No highlights, shadows or glows are drawn in; the system supplies them. A soft gloss on the glass, kept
at first for the family's glass look, was removed at the owner's request (message 7).

## Changes

- **Masters:** new `Back.svg`, `Middle.svg`, `Front.svg` in the approved full-circle proportions, without
  the proof's gloss.
- **Generator:** each plane's part is checked (Back opaque; Middle nothing beyond radius 490; Front clear
  inside 450 and opaque from 462 to the edge), replacing the toolbox's 440-pixel guard. `--appearance`
  is removed: its dark comparison only swapped the neutral background, which the new icon doesn't have.
  The cobalt comparison maps the new ramp.
- **Website:** icon-256/64, favicons, Apple touch icon and social card regenerated; Home and Open Graph
  alt text and Credits describe the new icon.
- **Docs:** icon guide rewritten; status, release notes, README, accessibility scope and memory bank.
- **Build:** 1.0 (28).

## Validation

| Check | Result |
|---|---|
| Generator | Three 1024-pixel planes; Back fully opaque; Middle reaches radius 485.7, 0 pixels beyond 490; Front starts at radius 454.7, 0 pixels inside 450, 0 non-opaque pixels from 462 to the edge |
| Fidelity | Before the gloss came out, the masked composite matched the approved "all of it" proof except 0.4% of pixels (more than 6% different) at the glass edge and the proof's outer light edge; the gloss was then removed as asked |
| Catalog | `actool` xros compile exit 0, no warnings or notices; primary icon `AppIcon` |
| Simulator Home View | Debug build installed; once the install animation ended, the icon showed red glass, white sun and hills and the silver frame as designed (a first capture mid-animation was dimmed); rechecked after the gloss came out |
| Cobalt option | Generator validated the cobalt ramp |
| UI suite and core | Not rerun: app Swift sources, UI tests, core sources and tests and the capture probe hash-identical to build 27 (37/37 on build 27) |
| Site | 6 pages built; 0 local link, anchor or alt-text problems |
| Signed Release | Build + analyze exit 0 (49 s; rebuilt after the gloss came out, its back layer matching a fresh catalog compile); strict signature; 1.0 (28); `assetutil` lists a SolidImageStack with 1024-pixel Back/Middle/Front vision layers; add-only Photos only; no Debug markers |
| Privacy scan | No new findings; one pattern match is random bytes inside the compressed `Back.png` image data, like the existing `pixelate.jpg` match |
| Headset | Unreachable at first (CoreDevice 4016); after the owner woke it ("headset's awake, install it"): install exit 0 (7 s), identity 1.0 (28), normal launch exit 0, one running process |

Limits: lighting, emboss and the layers' movement on a headset. [Sanitized evidence](../Documentation/Validation/round-picture-icon.json).
