"""Draws the layout diagrams used by docs/ART_SPEC.md into docs/art/.

    python3 tools/make_art_diagrams.py      (needs Pillow)
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

OUT = Path(__file__).resolve().parent.parent / "docs" / "art"
FONT_PATH = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
BG = (250, 248, 242)
INK = (40, 40, 48)
GRID = (150, 150, 165)
TILE_FILL = (200, 230, 200)
ACCENT = (210, 70, 70)
BLUE = (70, 110, 200)


def font(size):
    try:
        return ImageFont.truetype(FONT_PATH, size)
    except OSError:
        return ImageFont.load_default()


def dashed_line(d, a, b, fill, dash=6, width=2):
    (x0, y0), (x1, y1) = a, b
    length = max(abs(x1 - x0), abs(y1 - y0))
    for i in range(0, length, dash * 2):
        t0, t1 = i / length, min(i + dash, length) / length
        d.line([(x0 + (x1 - x0) * t0, y0 + (y1 - y0) * t0), (x0 + (x1 - x0) * t1, y0 + (y1 - y0) * t1)], fill=fill, width=width)


def character_sheet():
    s, left, top = 6, 150, 70
    img = Image.new("RGB", (720, top + 128 * s + 80), BG)
    d = ImageDraw.Draw(img)
    d.text((10, 10), "Character sheet: 48x128 px (3 x 4 frames of 16x32), shown at 6x", fill=INK, font=font(18))
    for col, name in enumerate(["0: idle", "1: step L", "2: step R"]):
        d.text((left + col * 16 * s + 8, top - 24), name, fill=INK, font=font(14))
    for row, name in enumerate(["row 0: down", "row 1: up", "row 2: left", "row 3: right*"]):
        d.text((10, top + row * 32 * s + 90), name, fill=INK, font=font(15))
        for col in range(3):
            x, y = left + col * 16 * s, top + row * 32 * s
            d.rectangle([x, y + 16 * s, x + 16 * s, y + 32 * s], fill=TILE_FILL)
            d.rectangle([x, y, x + 16 * s, y + 32 * s], outline=GRID, width=2)
            dashed_line(d, (x, y + 16 * s), (x + 16 * s, y + 16 * s), ACCENT)
            d.line([(x + 8 * s, y + 30 * s), (x + 8 * s, y + 32 * s)], fill=BLUE, width=3)
    d.text((10, top + 128 * s + 12), "Green = the 16x16 tile the character stands on. Red dashes = top of that tile.\n"
           "Feet touch the bottom edge, centred on the blue tick. Head and hair may use the upper 16 px.\n"
           "* Row 3 is optional: a 48x96 sheet is fine and the game mirrors row 2.", fill=INK, font=font(14))
    img.save(OUT / "character_sheet_layout.png")


def monsters():
    s = 4
    img = Image.new("RGB", (64 * s * 2 + 64 * s + 160, 64 * s + 170), BG)
    d = ImageDraw.Draw(img)
    d.text((10, 10), "Monster sprites, shown at 4x", fill=INK, font=font(18))
    boxes = [("front.png 64x64\nfaces left (toward the player)", 20), ("back.png 64x64\nseen from behind, faces right", 64 * s + 60)]
    for label, x in boxes:
        y = 80
        d.rectangle([x, y, x + 64 * s, y + 64 * s], outline=GRID, width=2)
        for i in range(1, 8):
            d.line([(x + i * 8 * s, y), (x + i * 8 * s, y + 64 * s)], fill=(225, 225, 232))
            d.line([(x, y + i * 8 * s), (x + 64 * s, y + i * 8 * s)], fill=(225, 225, 232))
        dashed_line(d, (x, y + 60 * s), (x + 64 * s, y + 60 * s), ACCENT)
        dashed_line(d, (x + 32 * s, y), (x + 32 * s, y + 64 * s), BLUE)
        d.text((x, 34), label, fill=INK, font=font(14))
    x, y = 64 * s * 2 + 100, 80
    for f in range(2):
        d.rectangle([x + f * 32 * 3, y, x + (f + 1) * 32 * 3, y + 32 * 3], outline=GRID, width=2)
        d.text((x + f * 96 + 30, y + 40), "frame %d" % f, fill=INK, font=font(12))
    d.text((x, 34), "icon.png 64x32\n2 frames (party bob)", fill=INK, font=font(14))
    d.text((10, 64 * s + 95), "Red dashes = ground line (y = 60): feet or lowest point rest here. Blue = horizontal centre.\n"
           "Transparent background. Bigger monsters fill more of the square; small ones stay near the ground line.", fill=INK, font=font(14))
    img.save(OUT / "monster_layout.png")


def tileset():
    s, left, top = 5, 20, 60
    img = Image.new("RGB", (left * 2 + 128 * s, top + 64 * s + 70), BG)
    d = ImageDraw.Draw(img)
    d.text((10, 10), "Tileset: 128 px wide (8 tiles), any number of 16 px rows. Cells are [column, row].", fill=INK, font=font(16))
    for r in range(4):
        for c in range(8):
            x, y = left + c * 16 * s, top + r * 16 * s
            d.rectangle([x, y, x + 16 * s, y + 16 * s], outline=GRID, width=2)
            d.text((x + 18, y + 30), "[%d,%d]" % (c, r), fill=INK, font=font(14))
    d.text((10, top + 64 * s + 12), "No spacing or margins between tiles. Tiles are opaque (they include the ground).\n"
           "The tileset's .json legend says which cell(s) each map character uses.", fill=INK, font=font(14))
    img.save(OUT / "tileset_layout.png")


def battle():
    w, h = 760, 430
    img = Image.new("RGB", (w, h), BG)
    d = ImageDraw.Draw(img)
    ox, oy = 20, 50
    cx = ox + 360
    d.text((10, 10), "Battle screen (game pixels; art is drawn at half this size and shown at 2x)", fill=INK, font=font(16))
    d.rectangle([ox, oy, ox + 720, oy + 224], fill=(214, 232, 206), outline=GRID, width=2)
    d.rectangle([cx - 240, oy, cx + 240, oy + 224], outline=ACCENT, width=3)
    d.text((ox + 6, oy + 6), "bg_<terrain>.png: 360x112 -> 720x224", fill=INK, font=font(13))
    d.text((cx - 234, oy + 204), "always visible: centre 240x112 (480x224 here)", fill=ACCENT, font=font(13))
    d.rectangle([cx + 48, oy + 16, cx + 176, oy + 144], outline=BLUE, width=2)
    d.text((cx + 54, oy + 70), "enemy front", fill=BLUE, font=font(13))
    d.rectangle([cx - 160, oy + 96, cx - 32, oy + 224], outline=BLUE, width=2)
    d.text((cx - 150, oy + 150), "player back", fill=BLUE, font=font(13))
    d.rectangle([cx - 224, oy + 16, cx - 24, oy + 60], outline=INK, width=1)
    d.text((cx - 218, oy + 30), "enemy info", fill=INK, font=font(12))
    d.rectangle([cx + 16, oy + 140, cx + 224, oy + 184], outline=INK, width=1)
    d.text((cx + 22, oy + 154), "player info", fill=INK, font=font(12))
    d.rectangle([ox, oy + 224, ox + 720, oy + 320], fill=(235, 235, 240), outline=GRID, width=2)
    d.text((ox + 8, oy + 260), "text box (ui/textbox.png) + menu: 96 px tall", fill=INK, font=font(13))
    d.text((10, oy + 330), "Bases (base_<terrain>.png, 128x32) sit under each sprite. Wider phones show more of\n"
           "the background on both sides, so keep anything important inside the red box.", fill=INK, font=font(13))
    img.save(OUT / "battle_layout.png")


def nine_slice():
    s, o = 10, 30
    img = Image.new("RGB", (24 * s + o * 2 + 260, 24 * s + o * 2), BG)
    d = ImageDraw.Draw(img)
    d.rectangle([o, o, o + 24 * s, o + 24 * s], outline=GRID, width=2)
    for v in (8, 16):
        dashed_line(d, (o + v * s, o), (o + v * s, o + 24 * s), ACCENT)
        dashed_line(d, (o, o + v * s), (o + 24 * s, o + v * s), ACCENT)
    d.text((o + 24 * s + 20, o), "ui/textbox.png, ui/panel.png\n24x24, 8 px borders (9-slice)\n\n"
           "Corners stay as drawn.\nEdges and the centre stretch\nto any size, so keep them\nflat or evenly patterned.", fill=INK, font=font(14))
    img.save(OUT / "frame_layout.png")


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    for fn in (character_sheet, monsters, tileset, battle, nine_slice):
        fn()
    print("Wrote diagrams to", OUT)
