# Security Policy

Thanks for taking the time to look. Reports, large or small, are welcome.

## Supported versions

Glass Image Tools is an early-stage project. Only the latest TestFlight build, or `main` before the first one, receives security fixes.

## Reporting a vulnerability

Report it privately: through GitHub, by opening the repository's **Security** tab and choosing **Report a vulnerability** ([direct link](https://github.com/msitarzewski/GlassImageTools/security/advisories/new)), or by email to <msitarzewski@gmail.com>. Include:

- a clear description of the issue and the impact you believe it has
- steps to reproduce, or a proof of concept if you have one (a synthetic image, never someone's real screenshot)
- the version or commit you tested against
- your name or handle, if you'd like credit (optional)

Please do **not** open a public GitHub issue for security reports. Privacy concerns are welcome through the same channels; what the app keeps and sends is documented in [PRIVACY.md](./PRIVACY.md).

## Response time

This is a side project, so responses are best-effort:

- **Acknowledgement:** within 7 days
- **Initial assessment:** within 14 days
- **Fix or mitigation plan:** within 30 days for high or critical findings

## Scope

**In scope:**

- Parsing untrusted images: malformed, oversized or deceptive files from Photos, Files or the clipboard
- Output that reveals more than the user chose: metadata (location, camera, dates) surviving into a new image, or detail recoverable from a pixelated area
- Working copies: temporary files readable by others, outliving their window, or surviving a force-quit
- Clipboard, sharing and Photos behavior beyond what [PRIVACY.md](./PRIVACY.md) describes, or permissions broader than add-only Photos
- Text inside an image steering the on-device image description (it is meant to be treated as content, never as instructions)

**Out of scope:**

- What Apple's clipboard, Universal Clipboard, share sheet, iCloud Photos or Apple Intelligence do once an image is handed to them (report those to Apple)
- That Pixelate leaves large, simple shapes recognizable; this is documented
- Issues that require an already-compromised device or Apple Account
