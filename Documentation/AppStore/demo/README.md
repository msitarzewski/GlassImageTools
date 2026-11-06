# Owned demonstration inputs

`garden.svg` is a fictional garden reservation page. The organization, Sam Rivera and the address at example.com are demonstration content. `geometry.svg` is an illustrative Swift crop example authored for this project, not a private document from another app. Both are covered by the repository's MIT license.

To reproduce the input PNGs, use the existing icon-authoring tool `rsvg-convert`:

```sh
rsvg-convert garden.svg -o garden.png
rsvg-convert geometry.svg -o geometry.png
```

The app imports these PNGs through its normal Paste action. The tour uses native controls to set a crop at Left 40, Top 150, Width 2060 and Height 1390; a pixelated region at Left 210, Top 470, Width 1070 and Height 340; and an editable 64-pixel text note. The before/after comparison is a 1070 × 340 region from the original input and the actual PNG copied by the app. It is not a reconstructed preview.

Marketing screenshots use only those normal app actions. Coordinate-based shape drags in this capture harness were not reliable and are not newly certified by this tour; existing app/core regression evidence is recorded separately.
