#!/usr/bin/env python3
"""Validate local Apple listing/media files; does not upload or certify Apple acceptance."""
import argparse
import hashlib
import json
import plistlib
import re
import struct
import sys
import zlib
from pathlib import Path
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parent.parent
PACKET = Path("Documentation/AppStore")
FIELDS = {
    "metadata/en-US/name.txt": (30, "characters"),
    "metadata/en-US/subtitle.txt": (30, "characters"),
    "metadata/en-US/promotional_text.txt": (170, "characters"),
    "metadata/en-US/description.txt": (4000, "characters"),
    "metadata/en-US/keywords.txt": (100, "utf8_bytes"),
    "metadata/review_information/notes.txt": (4000, "utf8_bytes"),
    "metadata/en-US/marketing_url.txt": (None, None),
    "metadata/en-US/support_url.txt": (None, None),
    "metadata/en-US/privacy_url.txt": (None, None),
    "metadata/copyright.txt": (None, None),
    "metadata/primary_category.txt": (None, None),
    "metadata/secondary_category.txt": (None, None),
    "testflight/en-US/description.txt": (None, None),
    "testflight/en-US/what_to_test.txt": (None, None),
    "testflight/feedback_email.txt": (None, None),
}


def field_findings(name, value, limit, unit):
    issues = []
    if not value.strip():
        issues.append("empty required field")
    count = len(value.encode("utf-8")) if unit == "utf8_bytes" else len(value)
    if limit is not None and count > limit:
        issues.append(f"{count} {unit} exceeds {limit}")
    if name.endswith("name.txt") and len(value) < 2:
        issues.append("name must have at least two characters")
    if name.endswith("_url.txt"):
        parsed = urlsplit(value)
        if parsed.scheme != "https" or not parsed.hostname or parsed.username or parsed.password:
            issues.append("a complete public HTTPS URL without credentials is required")
    if name.endswith("feedback_email.txt") and not re.fullmatch(r"[^\s@]+@[^\s@]+\.[^\s@]+", value):
        issues.append("a feedback email address is required")
    if name.endswith("keywords.txt"):
        words = value.split(",")
        if any(len(word) < 3 or word != word.strip() or not word for word in words):
            issues.append("keywords must be comma-separated terms longer than two characters, without surrounding spaces")
        if len({word.casefold() for word in words}) != len(words):
            issues.append("duplicate keyword")
    return issues


def png_info(path):
    """Read and CRC-check PNG chunks without decoding or allocating image pixels."""
    data = path.read_bytes()
    if not data.startswith(b"\x89PNG\r\n\x1a\n"):
        raise ValueError("not a PNG")
    offset = 8; header = None; types = []; ended = False
    while offset < len(data):
        if len(data) - offset < 12:
            raise ValueError("truncated PNG chunk")
        length = struct.unpack_from(">I", data, offset)[0]
        if length > len(data) - offset - 12:
            raise ValueError("invalid PNG chunk length")
        kind = data[offset+4:offset+8]; payload = data[offset+8:offset+8+length]
        crc = struct.unpack_from(">I", data, offset+8+length)[0]
        if zlib.crc32(kind+payload) & 0xffffffff != crc:
            raise ValueError("PNG chunk checksum mismatch")
        if not types and kind != b"IHDR":
            raise ValueError("PNG header must come first")
        if kind == b"IHDR":
            if header is not None or length != 13:
                raise ValueError("invalid PNG header")
            width, height, depth, color, compression, filtering, interlace = struct.unpack(">IIBBBBB", payload)
            if not width or not height or compression or filtering or interlace not in (0, 1):
                raise ValueError("invalid PNG geometry or encoding")
            header = {"width": width, "height": height, "bit_depth": depth, "color_type": color}
        types.append(kind)
        offset += length + 12
        if kind == b"IEND":
            if length or offset != len(data):
                raise ValueError("unexpected data after PNG end")
            ended = True; break
    if header is None or b"IDAT" not in types or not ended:
        raise ValueError("incomplete PNG")
    return {**header, "has_alpha": header["color_type"] in (4, 6) or b"tRNS" in types,
            "metadata_chunks": [x.decode("ascii") for x in types if x in (b"tEXt", b"iTXt", b"zTXt", b"eXIf")],
            "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def validate(root):
    root = Path(root); folder = root/PACKET; findings = []; fields = []; values = {}
    for name, (limit, unit) in FIELDS.items():
        try:
            value = (folder/name).read_text(encoding="utf-8").rstrip("\n")
        except (OSError, UnicodeError):
            findings.append(f"{name}: missing or unreadable UTF-8 field"); continue
        values[name] = value
        fields.append({"file": name, "characters": len(value), "utf8_bytes": len(value.encode("utf-8")),
                       "limit": limit, "limit_unit": unit})
        findings.extend(f"{name}: {x}" for x in field_findings(name, value, limit, unit))
    reserved = set(re.findall(r"\w+", (values.get("metadata/en-US/name.txt", "")+" "+values.get("metadata/en-US/subtitle.txt", "")).casefold()))
    for word in values.get("metadata/en-US/keywords.txt", "").casefold().split(","):
        if word and word in reserved:
            findings.append(f"keywords.txt: {word!r} duplicates the name or subtitle")
    project = (root/"project.yml").read_text()
    version = re.search(r'MARKETING_VERSION:\s*"([^\"]+)"', project).group(1)
    build = re.search(r'CURRENT_PROJECT_VERSION:\s*"([^\"]+)"', project).group(1)
    manifest = plistlib.loads((root/"App/PrivacyInfo.xcprivacy").read_bytes())
    privacy = {"tracking": manifest.get("NSPrivacyTracking"), "collected_data_types": len(manifest.get("NSPrivacyCollectedDataTypes", []))}
    if privacy != {"tracking": False, "collected_data_types": 0}:
        findings.append("Privacy manifest changed: reconsider the prepared Data Not Collected answer")
    media = []; media_path = folder/"screenshots/manifest.json"
    try:
        media_manifest = json.loads(media_path.read_text())
        if media_manifest.get("version") != version or media_manifest.get("build") != build:
            findings.append("Screenshot manifest does not match the current project version/build")
        entries = media_manifest["screenshots"]
        if not 1 <= len(entries) <= 10:
            findings.append("Apple Vision Pro needs one to ten screenshots")
        seen = set()
        for entry in entries:
            name = entry["file"]; path = folder/"screenshots"/name
            if name in seen or Path(name).name != name or path.is_symlink():
                findings.append("Screenshot names must be unique, local files"); continue
            seen.add(name)
            try:
                info = png_info(path); media.append({"file": name, **info})
                if (info["width"], info["height"]) != (3840, 2160):
                    findings.append(f"{name}: expected native 3840 x 2160")
                if info["has_alpha"]:
                    findings.append(f"{name}: alpha channels/transparency are not accepted")
                if info["bit_depth"] != 8 or info["color_type"] != 2:
                    findings.append(f"{name}: this packet uses 8-bit RGB PNG")
                if info["metadata_chunks"]:
                    findings.append(f"{name}: remove text/EXIF metadata from the public asset")
                if info["sha256"] != entry["sha256"]:
                    findings.append(f"{name}: pixels/file changed; refresh screenshot provenance")
            except (OSError, ValueError) as error:
                detail = str(error) if isinstance(error, ValueError) else error.strerror
                findings.append(f"{name}: {type(error).__name__}: {detail}")
    except (OSError, ValueError, KeyError, TypeError):
        findings.append("Missing or invalid screenshot manifest")
    return {"candidate": {"version": version, "build": build, "platform": "visionOS"},
            "scope": "Local files only; not Apple acceptance, live URL verification, distribution signing or account declarations.",
            "fields": fields, "privacy_manifest": privacy, "screenshots": media,
            "findings": findings, "valid": not findings}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args(); report = validate(args.root)
    if args.report:
        path = args.report if args.report.is_absolute() else args.root/args.report
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(report, indent=2)+"\n")
    print(json.dumps(report, indent=2))
    return 0 if report["valid"] else 1


if __name__ == "__main__":
    sys.exit(main())
