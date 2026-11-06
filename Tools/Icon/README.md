# Glass Image Tools icon

The editable masters are [Back.svg](Back.svg), [Middle.svg](Middle.svg) and [Front.svg](Front.svg).
Since build 28 (October 24, 2026) the shipping visionOS icon is a round picture: a white sun and two
hills on red glass, inside a silver frame that forms the icon's edge. SVG paths own the artwork; the
PNGs in the asset catalog are generated platform outputs.

## Layers

The asset stack lists **Front, Middle, Back**: its first layer is nearest the viewer, its last must be
opaque. The generator checks each plane's part in the stack and refuses output that breaks it.

| Plane | Content | Checked |
| --- | --- | --- |
| Front | The silver frame: everything outside the glass (radius 455.4), with a thin dark rim at the glass edge | Clear inside radius 450; opaque from 462 out to the icon's edge |
| Middle | The white sun and hills | Nothing beyond radius 490; the hills run under the frame to 485 |
| Back | Red glass; silver past radius 490 | Fully opaque |

visionOS masks the square layers to a circle, adds shadows between layers and uses the upper layers'
alpha to emboss them. Apple's guidance for visionOS advises against a hole or concave shape in the
background layer, so the frame is the nearest layer rather than a recess painted on the back: frame in
front, the picture in the middle, the sky behind. Because the layers shift when someone looks at the
icon, the hills extend under the frame and the back layer is silver beneath it, so no edge or gap opens.
Apple also says the system supplies highlights and shadows, so none are drawn in: the owner had the
gloss removed ("let's leave those touches to Apple's default team"). The gradients are the materials'
colors, not lighting.

## Colors and geometry

| Element | Color |
| --- | --- |
| Glass | `#f83835` lit top-left → `#e20707` → `#b00100` bottom-right, Glass Power Tools' visionOS screen red |
| Frame | Silver `#e4e6ec` → `#c6c9d2` → `#b6bbc8`, top to bottom |
| Rim | `#7d1010`, 6 pixels at the glass edge |
| Sun and hills | White |

On the 1024-pixel canvas the glass edge is at radius 455.4 and the sun is centered at (693, 353.6)
with radius 79.2. The hills' peaks and valley are rounded; the larger peak is left of center.

## Regenerate

Run from the repository root on macOS with Swift/Xcode and `rsvg-convert` installed on `PATH`.
`rsvg-convert` is an authoring tool only; the application gains no dependency on it or on another project.
The generator invokes it directly without a shell, then validates all plane sizes and the layer checks.

```sh
swift Tools/GenerateIcon.swift
```

The optional first argument is the destination asset catalog. The generator preserves unrelated catalog
content and writes only its own `AppIcon.solidimagestack` and `AboutIcon.imageset`, the flat 256-pixel
composite that Settings → About shows clipped to a circle (since build 31). Use scratch catalogs for design comparisons:

```sh
swift Tools/GenerateIcon.swift /tmp/GlassImageTools-icon/Assets.xcassets --proof-directory /tmp/GlassImageTools-icon/proofs
swift Tools/GenerateIcon.swift /tmp/GlassImageTools-icon-cobalt/Assets.xcassets --palette cobalt --proof-directory /tmp/GlassImageTools-icon-cobalt/proofs
```

`--palette` accepts `red` (the default, which the app ships) or `cobalt`, the same ramp built from the
family's `#0047AB`. Proof output includes checkerboard-separated planes, flat composites at
1024/256/64/32 pixels, and a sanitized validation JSON. The website icons, favicons and social card are
made from the 1024-pixel composite with a circular mask.

## Native verification

Compile the actual visionOS catalog rather than relying on a macOS icon rendition:

```sh
mkdir -p /tmp/GlassImageTools-icon-compiled
xcrun actool App/Assets.xcassets --compile /tmp/GlassImageTools-icon-compiled --platform xros --minimum-deployment-target 26.0 --app-icon AppIcon --output-partial-info-plist /tmp/GlassImageTools-icon-compiled/icon-info.plist --warnings --notices
plutil -p /tmp/GlassImageTools-icon-compiled/icon-info.plist
xcrun assetutil --info /tmp/GlassImageTools-icon-compiled/Assets.car
```

Installing a build in the Vision Pro simulator shows the system's rendering in the Home View; let the
install animation finish before judging it, since the icon first appears dimmed. Lighting, emboss and
the layers' movement when looked at are physical-device observations to record in the project status.

## History

Builds 5 to 27 shipped a red toolbox with a pitched lid, a metal handle, crop rulers and a brush (see
[decisions](../../memory-bank/decisions.md)). On October 24, 2026 the owner found it sharp. Softened
toolboxes, a Vision Pro headset and a wrench worked into the hills were drawn and set aside, and the
owner chose this round picture filling the icon.

## Mac icon

`Tools/GenerateMacIcon.swift` composites the existing visionOS Back/Middle/Front PNG planes into the same
round picture motif with transparent exterior, then generates the standard macOS icon sizes and About
asset in `Mac/Assets.xcassets`. Run `swift Tools/GenerateMacIcon.swift` from the repository root after
regenerating the visionOS planes. No new artwork, network tool or dependency is needed.

