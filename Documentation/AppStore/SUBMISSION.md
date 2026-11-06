# App Store Connect entry guide

Updated November 6, 2026 for build 38 source and Apple's current references. Answers below are a local preparation, not a declaration already entered in Apple's account. The metadata text files are authoritative for customer-facing wording.

## App and version

| Field | Prepared value |
|---|---|
| Name / primary language | Glass Image Tools / English (U.S.), `en-US` |
| Platform / minimum system | Apple Vision Pro / visionOS 26.0 |
| Bundle ID | `com.glassimagetools` (owner-approved permanent identifier) |
| Version / current local build | 1.0 / 38; confirm the account's last used build before upload |
| Suggested SKU for a new record | `glass-image-tools-visionos`; use the existing SKU if a record already exists |
| Primary / secondary category | Graphics & Design / Productivity (owner-approved) |
| Price | Free; no in-app purchases, subscription or payment flow |
| Copyright | `metadata/copyright.txt` (Apple adds the copyright symbol) |
| URLs | `metadata/en-US/{marketing,support,privacy}_url.txt`; public pages currently need publication |
| Sign-in required | No; leave demo credentials empty |
| First-release What's New | Not applicable; this field is unavailable for an initial version |
| Release setting | Manual release is suggested for the first review; the owner chooses it in App Store Connect |

## App Privacy and export compliance

**Prepared privacy answer: Data Not Collected.** There is no app backend, account, telemetry, tracking or third-party runtime SDK. Photos/Files are user-selected input. Explicit Paste of an HTTPS image link contacts its chosen host (and permitted redirect hosts), which sees the URL/query and IP address. Requests use no cookies, saved credentials or persistent cache; no existing image is uploaded and the developer receives no requests. Reassess the disclosure if a developer-controlled image service or telemetry is added. Crop/markup and optional Foundation Models captions run locally. User-initiated Copy/Share/save use system services and may reach other devices or destinations under those services' rules. Apple's definition excludes data processed only on device and says the developer does not disclose data Apple itself collects. See [Apple's privacy definitions](https://developer.apple.com/app-store/app-privacy-details/) and [the actual privacy policy](../../PRIVACY.md).

The current [privacy manifest](../../App/PrivacyInfo.xcprivacy) declares no tracking or collected data, and UserDefaults reason `CA92.1` for the app's appearance preferences. Review the final archive's Organizer privacy report before upload; development signature checks do not replace that report.

**Prepared encryption answer:** `ITSAppUsesNonExemptEncryption` is false in the app's Info.plist configuration. The app uses system HTTPS for explicit image-link downloads and system file protection; it implements no custom cryptography. The configured key remains false; confirm the final archive and Apple’s current exemption questions. Use the final binary's actual settings when answering Apple's [export-compliance questions](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance/); no country-specific availability or legal determination is made by this packet.

## Age rating and content rights

Complete the current questionnaire in the account; Apple calculates the global and regional rating. **4+ is the expected outcome, not an assigned rating.** Apple's [definitions](https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions/) distinguish local editing from broad distribution of user-generated content.

| Question group | Prepared answer and rationale |
|---|---|
| Parental controls / age assurance | No / No; the editor implements neither |
| Unrestricted web access | No; About opens fixed website links in Safari, with no embedded browser |
| User-generated content / social media | No / No; private image editing has no feed, discovery, hosted content or broad in-app distribution |
| Social media disabled for under-13 users | Not applicable to an editor with no social media capability |
| Messaging and chat / advertising | No / No; a system share sheet is not an in-app messaging service |
| Mature themes, profanity, horror/fear, violence, weapons, sexual content/nudity, alcohol/tobacco/drugs | None; the app supplies no such content |
| Medical/treatment information / health and wellness | None / No; no health claims or guidance |
| Simulated gambling / contests / gambling / loot boxes | None / None / No / No |
| Kids category / age override | Not selected; no higher-rating override is proposed |

**Content-rights answer needs owner review against the current account question.** The app opens user-supplied Photos/Files images and now downloads images from user-supplied HTTPS links; it has no developer-provided catalog or hosted content service. Marketing demo inputs are owned project material, and screenshots use the real app and Apple's simulator environment. Do not claim ownership or a license over an arbitrary remote image. Confirm the appropriate account answer and rights representation before submission.

## Accessibility declarations

No App Store accessibility support label is proposed yet. Simulator audits, Dynamic Type and labeled native controls are verified, but a label requires the complete common workflow to work with that feature on the actual headset. Follow [Apple's declaration guidance](https://developer.apple.com/documentation/appstoreconnectapi/configuring-accessibility-declarations) after scoped physical VoiceOver, Voice Control, Switch Control, keyboard and pointer checks. Do not turn simulator audit success into a hardware support declaration.

## Account-only steps still required

1. Confirm or create the visionOS app record and identifier; preserve any existing SKU.
2. Enter App Review contact name, phone and email privately in App Store Connect; no sign-in account is needed.
3. Owner completes trader status, agreements and territory availability in the account. No choice is inferred from other apps.
4. **Completed November 6:** public marketing/support/privacy pages and source return HTTP 200. Recheck the existing URLs before submission; see [publication evidence](../Validation/mac-public-release.json).
5. Archive the `GlassImageTools` scheme with a supported released Xcode; the experimental Capture Probe is a separate research app. Validate the distribution archive, review its compiled layered AppIcon and privacy report, then upload and confirm Apple's processed version/build. Current distribution signing/upload remains unverified; development installation does not establish distribution approval.
6. Enter the prepared metadata, age/privacy answers and ordered screenshots. Select a release setting and submit only under the owner's explicit upload/submission instruction.

For TestFlight, use the separate beta description, feedback email and What to Test files. Apple requires beta information and a first external build review ([test information](https://developer.apple.com/help/app-store-connect/test-a-beta-version/provide-test-information/), [external testing](https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers/)).

November 6 distribution checkpoint: public source and canonical website/help/privacy URLs are live (HTTP 200);
[Mac 1.0 (45)](../MAC_RELEASE.md) is separately Developer ID notarized and distributed. This resolves the
prior website-publication gap, without changing the account-only visionOS archive/upload/review steps.
