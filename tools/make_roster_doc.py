"""Builds docs/ROSTER.md (the sprite design brief) from docs/roster.json.

    python3 tools/make_roster_doc.py
"""
import json
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TYPE_NAMES = {k: v["name"] for k, v in json.loads((ROOT / "data/types.json").read_text())["types"].items()}
SIZES = {
    "S": "Small: fills about half the 64x64 frame",
    "M": "Medium: about two thirds of the frame",
    "L": "Large: most of the frame",
    "XL": "Huge: fills the frame, may touch the edges",
}


def types(m):
    return " / ".join(TYPE_NAMES[t] for t in m["types"])


def evolves(m, line):
    if not m["evolves"]:
        return "Final" if len(line["members"]) > 1 else "Does not evolve"
    nxt = line["members"][[x["id"] for x in line["members"]].index(m["id"]) + 1]
    return "%s → %s" % (m["evolves"], nxt["name"])


def main():
    data = json.loads((ROOT / "docs/roster.json").read_text())
    lines = data["lines"]
    members = [m for l in lines for m in l["members"]]
    tally = Counter(t for m in members for t in m["types"])
    out = [
        "# Monstros roster",
        "",
        "The planned roster of %d monsters, with design notes to support sprite creation." % len(members),
        "Generated from [`roster.json`](roster.json) by `tools/make_roster_doc.py`. Edit the JSON, not this file.",
        "",
        "- **Status:** *in game* monsters already exist in `data/species.json`; *planned* ones will be added as the",
        "  region is built. All of them can be drawn now. Use the ID as the folder name: `assets/monsters/<id>/`.",
        "- **Sprites per monster:** `front.png` (64×64, facing left), `back.png` (64×64), `icon.png` (64×32,",
        "  2 frames). See [ART_SPEC.md](ART_SPEC.md).",
        "- **Size** is how much of the 64×64 frame the front sprite should fill, so relative sizes read",
        "  correctly in battle: " + "; ".join("**%s** %s" % (k, v.split(": ")[1]) for k, v in SIZES.items()) + ".",
        "- **Palette** lists the main colours, most dominant first. Keep each sprite to about 15 colours plus transparency.",
        "- Evolution stages should read as the same creature growing up: keep a signature feature,",
        "  colour or marking through each line.",
        "- **Evolution methods** marked *Item*, *Trade* or *Friendship* are planned and not implemented yet.",
        "  Levels and items may change during balancing.",
        "- All names and designs are original. Don't base a design on any existing franchise's monster;",
        "  see [CONTENT_GUIDELINES.md](CONTENT_GUIDELINES.md).",
        "",
        "## Type distribution",
        "",
        "How many monsters carry each type (dual types count for both):",
        "",
        "| Type | Count | | Type | Count | | Type | Count |",
        "|---|---|---|---|---|---|---|---|",
    ]
    ranked = sorted(tally.items(), key=lambda kv: -kv[1])
    for i in range(0, len(ranked), 3):
        row = ranked[i:i + 3]
        out.append("| " + " | | ".join("%s | %d" % (TYPE_NAMES[t], n) for t, n in row) + " |")
    out += ["", "## Index", "", "| # | Name | Type | Status |", "|---|---|---|---|"]
    for m in members:
        out.append("| %03d | %s | %s | %s |" % (m["number"], m["name"], types(m), m["status"]))
    out += ["", "## Design notes"]
    for l in lines:
        first, last = l["members"][0], l["members"][-1]
        span = "%03d" % first["number"] if first is last else "%03d–%03d" % (first["number"], last["number"])
        title = first["name"] if first is last else first["name"] + " line"
        out += ["", "### %s · %s" % (span, title), "", "*%s* · Found in: %s" % (l["concept"], l["habitat"]), ""]
        for m in l["members"]:
            out.append("**%03d %s** (`%s`) · %s · %s · Size %s%s  " % (
                m["number"], m["name"], m["id"], types(m), evolves(m, l), m["size"],
                " · *in game*" if m["status"] == "in game" else ""))
            out.append("Palette: %s  " % m["palette"])
            out.append(m["design"])
            out.append("")
    (ROOT / "docs/ROSTER.md").write_text("\n".join(out).rstrip() + "\n")
    print("Wrote docs/ROSTER.md (%d monsters)" % len(members))


if __name__ == "__main__":
    main()
