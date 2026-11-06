import hashlib
import importlib.util
import json
import plistlib
import struct
import tempfile
import unittest
import zlib
from pathlib import Path

spec = importlib.util.spec_from_file_location("validate_store", Path(__file__).parents[1]/"validate_store.py")
store = importlib.util.module_from_spec(spec)
spec.loader.exec_module(store)


def png(width, height, alpha=False):
    def chunk(kind, payload):
        return struct.pack(">I", len(payload))+kind+payload+struct.pack(">I", zlib.crc32(kind+payload)&0xffffffff)
    pixel = b"\x11\x22\x33\xff" if alpha else b"\x11\x22\x33"
    body = zlib.compress((b"\0"+pixel*width)*height)
    return b"\x89PNG\r\n\x1a\n"+chunk(b"IHDR", struct.pack(">IIBBBBB", width,height,8,6 if alpha else 2,0,0,0))+chunk(b"IDAT",body)+chunk(b"IEND",b"")


class StoreValidationTests(unittest.TestCase):
    def test_keywords_use_utf8_bytes(self):
        value = "é"*35+","+"ß"*20
        self.assertLess(len(value),100)
        self.assertTrue(any("exceeds 100" in x for x in store.field_findings("keywords.txt",value,100,"utf8_bytes")))

    def test_notes_use_utf8_bytes(self):
        value = "é"*2100
        self.assertLess(len(value),4000)
        self.assertTrue(store.field_findings("notes.txt",value,4000,"utf8_bytes"))

    def test_character_limited_fields_allow_multibyte_text(self):
        self.assertFalse(store.field_findings("subtitle.txt","é"*30,30,"characters"))

    def test_duplicate_and_empty_keywords_are_rejected(self):
        for value in ["photo,photo","photo,,crop","photo, crop"]:
            self.assertTrue(store.field_findings("keywords.txt",value,100,"utf8_bytes"))

    def test_public_urls_reject_credentials(self):
        self.assertTrue(store.field_findings("support_url.txt","https://user:secret@example.com/help",None,None))
        self.assertFalse(store.field_findings("support_url.txt","https://example.com/help#contact",None,None))

    def test_real_png_alpha_and_corruption(self):
        with tempfile.TemporaryDirectory() as directory:
            path=Path(directory)/"shot.png";path.write_bytes(png(2,2))
            self.assertFalse(store.png_info(path)["has_alpha"])
            path.write_bytes(png(2,2,alpha=True))
            self.assertTrue(store.png_info(path)["has_alpha"])
            bad=bytearray(png(2,2));bad[18]^=1;path.write_bytes(bad)
            with self.assertRaises(ValueError):store.png_info(path)
            path.write_bytes(png(2,2)[:-2])
            with self.assertRaises(ValueError):store.png_info(path)

    def test_complete_packet_and_stale_or_changed_media(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);packet=root/store.PACKET
            values={name:"Prepared text" for name in store.FIELDS}
            values.update({"metadata/en-US/name.txt":"Example Editor", "metadata/en-US/subtitle.txt":"Work with pictures",
                           "metadata/en-US/keywords.txt":"crop,annotate", "testflight/feedback_email.txt":"support@example.com"})
            for name in values:
                if name.endswith("_url.txt"):values[name]="https://example.com/help"
            for name,value in values.items():
                path=packet/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_text(value+"\n")
            (root/"project.yml").write_text('MARKETING_VERSION: "1.0"\nCURRENT_PROJECT_VERSION: "36"\n')
            (root/"App").mkdir();(root/"App/PrivacyInfo.xcprivacy").write_bytes(plistlib.dumps({"NSPrivacyTracking":False,"NSPrivacyCollectedDataTypes":[]}))
            shots=packet/"screenshots";shots.mkdir();path=shots/"01-editor.png";path.write_bytes(png(3840,2160))
            manifest={"version":"1.0","build":"36","screenshots":[{"file":path.name,"sha256":hashlib.sha256(path.read_bytes()).hexdigest()}]}
            (shots/"manifest.json").write_text(json.dumps(manifest))
            self.assertTrue(store.validate(root)["valid"])
            manifest["build"]="35";(shots/"manifest.json").write_text(json.dumps(manifest))
            self.assertTrue(any("version/build" in x for x in store.validate(root)["findings"]))
            manifest["build"]="36";(shots/"manifest.json").write_text(json.dumps(manifest));path.write_bytes(png(3840,2160,alpha=True))
            self.assertTrue(any("alpha" in x for x in store.validate(root)["findings"]))
            self.assertTrue(any("provenance" in x for x in store.validate(root)["findings"]))


if __name__=="__main__":unittest.main()
