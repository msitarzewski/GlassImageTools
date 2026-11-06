#!/usr/bin/env python3
"""Archive, Developer ID export, notarize and staple a sandboxed Mac release.

Requires a local signing team, Developer ID certificate and existing notarytool Keychain profile.
No credentials are read/exported by this script. Logs and generated signing configuration stay in
ignored build output. This prepares artifacts only; repository, release and site publication are separate.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import plistlib
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent.parent
ENTITLEMENTS = {
    "com.apple.security.app-sandbox": True,
    "com.apple.security.files.user-selected.read-write": True,
    "com.apple.security.network.client": True,
    "com.apple.security.personal-information.photos-library": True,
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", required=True)
    parser.add_argument("--build", required=True, type=int)
    parser.add_argument("--notary-profile", default=os.environ.get("GLASS_IMAGE_NOTARY_PROFILE"))
    parser.add_argument("--dry-run", action="store_true", help="Archive and verify only; no notary upload")
    parser.add_argument("--output", type=Path, default=ROOT / "build/mac-release")
    args = parser.parse_args()
    if not re.fullmatch(r"[0-9]+(?:\.[0-9]+){0,2}", args.version) or args.build <= 0:
        parser.error("Use a numeric version and positive build number")
    if not args.dry_run and not args.notary_profile:
        parser.error("Set GLASS_IMAGE_NOTARY_PROFILE or --notary-profile to an existing Keychain profile")
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)  # Never destroy a previous release.
    log = (output / "release.log").open("ab")
    sequence = 0

    def run(label, command):
        nonlocal sequence
        sequence += 1
        print(f"{sequence}. {label}", flush=True)
        result = subprocess.run(command, cwd=ROOT, capture_output=True)
        log.write(result.stdout + result.stderr); log.flush()
        if result.returncode:
            raise RuntimeError(f"{label} failed (exit {result.returncode}); inspect local release.log")
        return result.stdout

    xcode = run("Check released Xcode", ["xcodebuild", "-version"]).decode()
    build = re.search(r"Build version (\S+)", xcode)
    if not build or build[1][-1].islower():
        raise RuntimeError("Use a released Xcode for distribution")
    if not args.dry_run:
        run("Check existing notary profile", ["xcrun", "notarytool", "history", "--keychain-profile", args.notary_profile, "--output-format", "json"])
    settings = json.loads(run("Read local signing configuration", ["xcodebuild", "-project", "GlassImageTools.xcodeproj", "-scheme", "GlassImageToolsMac", "-configuration", "Release", "-destination", "generic/platform=macOS", "-showBuildSettings", "-json"]))
    team = next(item["buildSettings"].get("DEVELOPMENT_TEAM") for item in settings if item["target"] == "GlassImageToolsMac")
    if not team:
        raise RuntimeError("Set a local signing team in Config/Identity.local.xcconfig")
    identities = run("Find matching Developer ID certificate", ["security", "find-identity", "-v", "-p", "codesigning"]).decode()
    identity = next((m[1] for m in re.finditer(r'([A-F0-9]{40}) "Developer ID Application: [^"\n]+ \(' + re.escape(team) + r'\)"', identities)), None)
    if not identity:
        raise RuntimeError("No Developer ID Application certificate matches the local signing team")
    archive = output / "GlassImageTools.xcarchive"
    run("Archive universal Mac Release", ["xcodebuild", "-project", "GlassImageTools.xcodeproj", "-scheme", "GlassImageToolsMac", "-configuration", "Release", "-destination", "generic/platform=macOS", "-archivePath", str(archive), "-allowProvisioningUpdates", "MARKETING_VERSION=" + args.version, "CURRENT_PROJECT_VERSION=" + str(args.build), "ARCHS=arm64 x86_64", "ONLY_ACTIVE_ARCH=NO", "archive"])
    with tempfile.TemporaryDirectory(prefix="glass-image-export-") as temporary:
        options = Path(temporary) / "ExportOptions.plist"
        options.write_bytes(plistlib.dumps({"method": "developer-id", "teamID": team, "signingStyle": "automatic"}))
        run("Export Developer ID app", ["xcodebuild", "-exportArchive", "-archivePath", str(archive), "-exportPath", str(output / "export"), "-exportOptionsPlist", str(options), "-allowProvisioningUpdates"])
    app = output / "export/GlassImageToolsMac.app"
    info = plistlib.loads((app / "Contents/Info.plist").read_bytes())
    if (info["CFBundleShortVersionString"], info["CFBundleVersion"]) != (args.version, str(args.build)):
        raise RuntimeError("Exported app identity does not match the requested release")
    run("Verify strict app signature", ["codesign", "--verify", "--deep", "--strict", str(app)])
    details = subprocess.run(["codesign", "-dv", "--verbose=4", str(app)], capture_output=True)
    log.write(details.stdout + details.stderr); log.flush()
    if details.returncode or b"Authority=Developer ID Application:" not in details.stderr or b"runtime" not in details.stderr:
        raise RuntimeError("Export must have Developer ID and hardened runtime")
    grants = plistlib.loads(run("Verify production sandbox grants", ["codesign", "-d", "--entitlements", ":-", str(app)]))
    # Signing may add application/team identity keys; permissions must remain exactly these four.
    permissions = {key: value for key, value in grants.items() if key.startswith("com.apple.security.")}
    if permissions != ENTITLEMENTS:
        raise RuntimeError("Exported app sandbox grants differ from the production contract")
    architectures = run("Verify both Mac architectures", ["lipo", "-archs", str(app / "Contents/MacOS/GlassImageToolsMac")]).decode().split()
    if set(architectures) != {"arm64", "x86_64"}:
        raise RuntimeError("Release must support Apple silicon and Intel")
    if (app / "Contents/Resources/PrivacyInfo.xcprivacy").read_bytes() != (ROOT / "App/PrivacyInfo.xcprivacy").read_bytes():
        raise RuntimeError("Privacy manifest does not match source")
    if args.dry_run:
        print("Archive/export/signature/sandbox/architectures verified; no notary upload.")
        return

    def notarize(path):
        result = json.loads(run("Submit to Apple notarization", ["xcrun", "notarytool", "submit", str(path), "--keychain-profile", args.notary_profile, "--wait", "--output-format", "json"]))
        if result.get("status") != "Accepted":
            raise RuntimeError("Apple did not accept the submission; inspect local release.log")
        run("Staple Apple ticket", ["xcrun", "stapler", "staple", str(path)])
        run("Validate stapled ticket", ["xcrun", "stapler", "validate", str(path)])

    upload = output / "notary-upload.zip"
    run("Package app for notarization", ["ditto", "-c", "-k", "--sequesterRsrc", "--keepParent", str(app), str(upload)])
    result = json.loads(run("Notarize app", ["xcrun", "notarytool", "submit", str(upload), "--keychain-profile", args.notary_profile, "--wait", "--output-format", "json"]))
    if result.get("status") != "Accepted":
        raise RuntimeError("Apple did not accept the app; inspect local release.log")
    run("Staple app ticket", ["xcrun", "stapler", "staple", str(app)])
    run("Validate app ticket", ["xcrun", "stapler", "validate", str(app)])
    run("Assess app with Gatekeeper", ["spctl", "--assess", "--type", "execute", "--verbose=2", str(app)])
    artifacts = output / "artifacts"
    artifacts.mkdir()
    stem = "GlassImageTools-" + args.version + "-mac"
    zipped = artifacts / (stem + ".zip")
    run("Create stapled-app ZIP", ["ditto", "-c", "-k", "--sequesterRsrc", "--keepParent", str(app), str(zipped)])
    with tempfile.TemporaryDirectory(prefix="glass-image-dmg-") as temporary:
        folder = Path(temporary)
        run("Copy app for disk image", ["ditto", str(app), str(folder / "Glass Image Tools.app")])
        (folder / "Applications").symlink_to("/Applications")
        dmg = artifacts / (stem + ".dmg")
        run("Create install disk image", ["hdiutil", "create", "-volname", "Glass Image Tools", "-srcfolder", str(folder), "-format", "UDZO", str(dmg)])
    run("Sign disk image", ["codesign", "--force", "--timestamp", "--sign", identity, str(dmg)])
    notarize(dmg)
    run("Assess disk image", ["spctl", "--assess", "--type", "open", "--context", "context:primary-signature", "--verbose=2", str(dmg)])
    (artifacts / "SHA256SUMS.txt").write_text("".join(hashlib.sha256(path.read_bytes()).hexdigest() + "  " + path.name + "\n" for path in sorted(artifacts.iterdir()) if path.is_file()))
    print("Notarized, stapled Mac artifacts and SHA256SUMS.txt are ready. Nothing published.")


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, OSError, ValueError, subprocess.SubprocessError) as error:
        sys.exit(str(error))
