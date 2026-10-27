"""Imports delivered monster sprites from incoming/sprites/ into assets/monsters/.

Files are named by roster number (docs/roster.json) or species id, plus the sprite kind:
    001_front.png  001_back.png  001_icon.png      (also accepted: 1_front.png, fernling_front.png)

Each file is checked against docs/ART_SPEC.md (PNG, correct size) and moved to
assets/monsters/<id>/<kind>.png, replacing any older version. Problem files stay put.

    python3 tools/import_sprites.py            import everything in incoming/sprites/
    python3 tools/import_sprites.py --dry-run  only report what would happen
"""
import json
import re
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
INBOX = ROOT / "incoming" / "sprites"
SIZES = {"front": (64, 64), "back": (64, 64), "icon": (64, 32)}
NAME = re.compile(r"^(?P<who>[a-z0-9]+)_(?P<kind>front|back|icon)\.png$", re.IGNORECASE)


def png_size(path):
    """Width and height from the PNG header, or None if it isn't a PNG."""
    with open(path, "rb") as f:
        header = f.read(24)
    if len(header) < 24 or header[:8] != b"\x89PNG\r\n\x1a\n" or header[12:16] != b"IHDR":
        return None
    return struct.unpack(">II", header[16:24])


def load_roster():
    roster = json.loads((ROOT / "docs" / "roster.json").read_text())
    by_number, by_id = {}, {}
    for line in roster["lines"]:
        for m in line["members"]:
            by_number[m["number"]] = m
            by_id[m["id"]] = m
    return by_number, by_id


def main():
    dry_run = "--dry-run" in sys.argv
    by_number, by_id = load_roster()
    files = sorted(p for p in INBOX.iterdir() if p.is_file() and not p.name.startswith(".")) if INBOX.exists() else []
    imported, problems = [], []
    for path in files:
        match = NAME.match(path.name)
        if not match:
            problems.append((path.name, "name should look like 001_front.png, 001_back.png or 001_icon.png"))
            continue
        who, kind = match["who"].lower(), match["kind"].lower()
        monster = by_number.get(int(who)) if who.isdigit() else by_id.get(who)
        if monster is None:
            problems.append((path.name, "no monster %s in the roster" % (("#" + who) if who.isdigit() else who)))
            continue
        size = png_size(path)
        if size is None:
            problems.append((path.name, "not a PNG file"))
            continue
        if size != SIZES[kind]:
            problems.append((path.name, "%s is %dx%d, must be %dx%d" % (kind, *size, *SIZES[kind])))
            continue
        target = ROOT / "assets" / "monsters" / monster["id"] / ("%s.png" % kind)
        replaced = target.exists()
        if not dry_run:
            target.parent.mkdir(parents=True, exist_ok=True)
            path.replace(target)
        imported.append("%s -> %s (%s)%s" % (path.name, target.relative_to(ROOT), monster["name"],
                                             "  [replaced existing]" if replaced else ""))
    print(("Would import" if dry_run else "Imported") + " %d file(s)." % len(imported))
    for line in imported:
        print("  " + line)
    if problems:
        print("%d file(s) left in incoming/sprites/:" % len(problems))
        for name, why in problems:
            print("  %s: %s" % (name, why))
    # Point out monsters that now have some sprites but not all three.
    partial = []
    for m in by_id.values():
        folder = ROOT / "assets" / "monsters" / m["id"]
        have = [k for k in SIZES if (folder / ("%s.png" % k)).exists()]
        if have and len(have) < len(SIZES):
            partial.append("%03d %s: missing %s" % (m["number"], m["name"], ", ".join(k for k in SIZES if k not in have)))
    if partial and not dry_run:
        print("Incomplete sets:")
        for line in sorted(partial):
            print("  " + line)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
