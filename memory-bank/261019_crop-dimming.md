# Crop-area dimming — October 19, 2026

Historical implementation/validation checkpoint from October 19. The October 21
[documentation reconciliation](261021_memory-and-release-docs.md) confirms unchanged build-22 source.
For current follow-up use [active context](activeContext.md); old unlock/launch statements below are
recorded observations, not a new query or current lock-state claim.


State: reviewed/tested/applied; installed identity verified.

Objective: Dim only source-image content outside the current crop in Crop mode; keep the selected region, handles and window surfaces unaffected.

Authorization: Requested local change/build/tests/docs and standing paired Vision Pro signing/install/launch authorization. No Git/publication/delegation.

Owners/reuse: ImageCanvas/VectorImageLayer/CropOverlay already own display composition and crop affordances. CropOverlay currently has a separate 50% black even-odd Path. Simulator observation confirms this mask works, so retain its current owner/composition and increase black opacity to 65%. Do not change renderer/export/source/history or allocate another image.

Acceptance and risks: Observe four-sided crop dimming, bright crop/controls, live zoom/rotation alignment and undimmed Annotate/export. Retain real crop edits, Undo and Copy checks. Native build, actual simulator compositor/UI and signed product verification; physical appearance/input remain separate from installation/launch.

Implementation: increase the existing CropOverlay black opacity from 0.5 to 0.65; keep the same even-odd path, transform, image bounds and input/accessibility exclusions, and clip only the mask to the image Canvas viewport.

## Baseline observation

Actual simulator compositor shows working 50% masking on all four sides of a centered 800×600 crop. No composition/depth defect was reproduced. Keep the existing even-odd, image-bounded, input-transparent overlay; strengthen it to 65% rather than moving image composition. Existing source-pixel transforms already own zoom, pan and rotation alignment.

## Zoomed margin correction

The stronger first variant passes actual crop/Copy/Undo assertions, but compositor review reveals the mask paints into reserved padding when the source extends past the Canvas viewport. The source Canvas already clips there. Clip only the mask to the same viewport; retain all crop borders, labels and reachable controls outside that clip. Re-run the focused case and existing zoom/Pan corner-drag regression.

## Result and evidence

Release 1.0 (22) is installed and identity verified; normal launch/process verification awaits headset unlock.

Crop mode now darkens image content outside the selection with 65% black instead of 50%. The existing
image-bounded even-odd mask is retained and clipped to the image Canvas viewport: selected pixels, bright controls, window appearance, source
bytes, vectors/history and export are unaffected. Baseline compositor observation showed the prior mask
working; zoomed observation found the separate mask spilling into the reserved margin. Only the mask now shares the image Canvas clip; controls keep their generous targets. No renderer change.

The focused native UI cases exercise a centered 800×600 crop, reachable zoomed handles, rotation,
undimmed Annotate, actual 600×800 Copy and two-step Undo to the full image, plus actual zoomed corner dragging with Pan enabled. Fit/zoom/rotation/Annotate/
reset compositor views are inspected. This is visual observation, not automated pixel-equivalence testing.
Both final UI cases complete with zero failures; Xcode result finalization was interrupted (native exit -15, command 135.929 seconds). No clean UI command is claimed.
Signed Release build/analyze and strict signature/permissions/Debug-exclusion checks pass. Final UI,
signed and applied App/Core sources agree. Core, model, service and export implementations and core tests are
unchanged; the prior 62-core/42-native-service baseline was not rerun. Physical visual/input acceptance
remains separate from installation/launch. No new permission, dependency, network or capture capability.

Reviewed and applied four implementation/test/project files after a baseline conflict check. The final build emits one expected AppIntents metadata skip; the initial signed build emitted two. No AppIntents dependency is required. Raw synthetic compositor/screenshots, target/signing and deployment output remain private.

Next action: normal launch/process verification after headset unlock; no reinstall required.

[Sanitized validation](../Documentation/Validation/crop-dimming.json), [physical history](../Documentation/Validation/physical-deployment.json).
