class_name Art
extends RefCounted
## Paths, sizes and loaders for all artwork. The full format is in docs/ART_SPEC.md.
## Every loader returns null while a file hasn't been delivered, so the game falls
## back to placeholder drawing and art can be added a piece at a time.

const ROOT := "res://assets/"
const TILE := 16

const MONSTER_SIZE := Vector2i(64, 64)
const ICON_SIZE := Vector2i(64, 32)                   # two 32x32 frames side by side
const CHARACTER_FRAME := Vector2i(16, 32)
const CHARACTER_SHEET := Vector2i(48, 128)            # 3 columns (idle, step L, step R) x 4 rows
const CHARACTER_SHEET_MIRRORED := Vector2i(48, 96)    # no "right" row: the left row is mirrored
const OBJECT_SIZE := Vector2i(16, 16)
const TRAINER_SIZE := Vector2i(64, 64)
const TILESET_WIDTH := 128                            # 8 tiles across, any number of rows
const BATTLE_BG_SIZE := Vector2i(360, 112)            # centre 240 px always visible
const BATTLE_BASE_SIZE := Vector2i(128, 32)
const TYPE_BADGE_SIZE := Vector2i(32, 16)
const STATUS_BADGE_SIZE := Vector2i(24, 8)
const FRAME_SIZE := Vector2i(24, 24)                  # 9-slice with 8 px borders
const FRAME_MARGIN := 8
const FRAME_TEXT_COLOR := Color("#303038")            # text drawn on frames, so frame interiors must be light
const TITLE_LOGO_MAX := Vector2i(240, 80)
const APP_ICON_SIZE := Vector2i(192, 192)
const ADAPTIVE_ICON_SIZE := Vector2i(432, 432)

const CHARACTER_ROWS := { Vector2i.DOWN: 0, Vector2i.UP: 1, Vector2i.LEFT: 2, Vector2i.RIGHT: 3 }
const STATUSES := ["burn", "poison", "paralysis", "sleep", "freeze"]

static var _cache := {}


## Loads assets/<rel_path>, or returns null if it doesn't exist yet.
static func texture(rel_path: String) -> Texture2D:
	if _cache.has(rel_path):
		return _cache[rel_path]
	var path := ROOT + rel_path
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path)
	elif FileAccess.file_exists(path):
		# Dropped into the folder but not imported by the editor yet (development only).
		var image := Image.load_from_file(path)
		if image:
			tex = ImageTexture.create_from_image(image)
	_cache[rel_path] = tex
	return tex


static func clear_cache() -> void:
	_cache.clear()


static func monster_front(species_id: String) -> Texture2D:
	return texture("monsters/%s/front.png" % species_id)


static func monster_back(species_id: String) -> Texture2D:
	return texture("monsters/%s/back.png" % species_id)


static func monster_icon(species_id: String) -> Texture2D:
	return texture("monsters/%s/icon.png" % species_id)


static func character(sprite_id: String) -> Texture2D:
	return texture("characters/%s.png" % sprite_id)


static func object(object_id: String) -> Texture2D:
	return texture("objects/%s.png" % object_id)


static func trainer(portrait_id: String) -> Texture2D:
	return texture("trainers/%s.png" % portrait_id)


static func battle_background(terrain: String) -> Texture2D:
	return texture("battle/bg_%s.png" % terrain)


static func battle_base(terrain: String) -> Texture2D:
	return texture("battle/base_%s.png" % terrain)


static func tileset(tileset_name: String) -> Texture2D:
	return texture("tiles/%s.png" % tileset_name)


## Maps each map-layout character to tileset cells. See docs/ART_SPEC.md.
static func tileset_legend(tileset_name: String) -> Dictionary:
	var key := "legend:" + tileset_name
	if not _cache.has(key):
		var text := FileAccess.get_file_as_string(ROOT + "tiles/%s.json" % tileset_name)
		var parsed: Variant = JSON.parse_string(text) if text != "" else null
		_cache[key] = parsed.get("tiles", {}) if parsed is Dictionary else {}
	return _cache[key]


## A 9-slice frame (assets/ui/<frame_name>.png) as a StyleBox, or null.
static func frame_style(frame_name: String) -> StyleBox:
	var tex := texture("ui/%s.png" % frame_name)
	if tex == null:
		return null
	var style := StyleBoxTexture.new()
	style.texture = tex
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, FRAME_MARGIN)
		style.set_content_margin(side, FRAME_MARGIN)
	return style


## Applies a frame (if delivered) to a container, with dark text for its labels.
static func apply_frame(container: Control, frame_name: String) -> void:
	var style := frame_style(frame_name)
	if style == null:
		return
	container.add_theme_stylebox_override("panel", style)
	if container.theme == null:
		container.theme = Theme.new()
	container.theme.set_color("font_color", "Label", FRAME_TEXT_COLOR)


## HP bar colours like the classics: green above half, yellow above a fifth, then red.
static func hp_color(ratio: float) -> Color:
	if ratio > 0.5:
		return Color("#48c048")
	if ratio > 0.2:
		return Color("#e8c030")
	return Color("#e04040")


static func font() -> Font:
	var path := ROOT + "fonts/main.ttf"
	return load(path) if ResourceLoader.exists(path) else null


## Draws one frame of a character sheet with its feet on the tile at (0, 0).
## column: 0 idle, 1 left-foot step, 2 right-foot step.
static func draw_character(canvas: CanvasItem, sheet: Texture2D, facing: Vector2i, column: int) -> void:
	var row: int = CHARACTER_ROWS.get(facing, 0)
	var flip := false
	if sheet.get_height() == CHARACTER_SHEET_MIRRORED.y and row == 3:
		row = 2
		flip = true
	var source := Rect2(Vector2(column * CHARACTER_FRAME.x, row * CHARACTER_FRAME.y), Vector2(CHARACTER_FRAME))
	var target := Rect2(Vector2(0, TILE - CHARACTER_FRAME.y), Vector2(CHARACTER_FRAME))
	if flip:
		canvas.draw_set_transform(Vector2(TILE, 0), 0.0, Vector2(-1, 1))
	canvas.draw_texture_rect_region(sheet, target, source)
	if flip:
		canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# --- Checklist and validation ---------------------------------------------------

## Every piece of art the current game data needs:
## [{ path, kind, size (Vector2i, or ZERO if not fixed), for, used }]
## "used" is false for art the engine doesn't display yet (planned).
static func required_assets() -> Array:
	var list := []
	for id in Dex.species:
		var name: String = Dex.species[id]["name"]
		list.append(_entry("monsters/%s/front.png" % id, "monster_front", MONSTER_SIZE, name + " (front)", true))
		list.append(_entry("monsters/%s/back.png" % id, "monster_back", MONSTER_SIZE, name + " (back)", true))
		list.append(_entry("monsters/%s/icon.png" % id, "monster_icon", ICON_SIZE, name + " (party icon)", false))
	var characters := { "player": "The player", "player_run": "The player, running" }
	var objects := {}
	var terrains := {}
	var tilesets := {}
	for map_id in Dex.maps:
		var m: Dictionary = Dex.maps[map_id]
		tilesets[map_tileset(m)] = true
		terrains[map_terrain(m)] = true
		for npc in m.get("npcs", []):
			if npc.has("sprite"):
				characters[npc["sprite"]] = "%s (%s)" % [npc["sprite"].capitalize(), m.get("name", map_id)]
			if npc.has("object"):
				objects[npc["object"]] = npc["object"].capitalize()
	for id in characters:
		list.append(_entry("characters/%s.png" % id, "character", CHARACTER_SHEET, characters[id], true))
	for id in objects:
		list.append(_entry("objects/%s.png" % id, "object", OBJECT_SIZE, objects[id], true))
	var portraits := { "player_back": "The player, seen from behind in battle" }
	for id in Dex.trainers:
		var t: Dictionary = Dex.trainers[id]
		var who: String = t["class"] if t["name"].begins_with("{") else "%s %s" % [t["class"], t["name"]]
		portraits[t.get("portrait", id)] = who
	for id in portraits:
		list.append(_entry("trainers/%s.png" % id, "trainer", TRAINER_SIZE, portraits[id], true))
	for id in tilesets:
		list.append(_entry("tiles/%s.png" % id, "tileset", Vector2i.ZERO, "%s tileset" % id.capitalize(), true))
		list.append(_entry("tiles/%s.json" % id, "tileset_legend", Vector2i.ZERO, "%s tile legend" % id.capitalize(), true))
	for id in terrains:
		list.append(_entry("battle/bg_%s.png" % id, "battle_bg", BATTLE_BG_SIZE, "Battle background: " + id, true))
		list.append(_entry("battle/base_%s.png" % id, "battle_base", BATTLE_BASE_SIZE, "Battle ground base: " + id, true))
	for id in Dex.types:
		list.append(_entry("ui/types/%s.png" % id, "type_badge", TYPE_BADGE_SIZE, Dex.type_name(id) + " type badge", false))
	for id in STATUSES:
		list.append(_entry("ui/status/%s.png" % id, "status_badge", STATUS_BADGE_SIZE, id.capitalize() + " status badge", false))
	list.append(_entry("ui/textbox.png", "frame", FRAME_SIZE, "Dialogue and battle text box frame", true))
	list.append(_entry("ui/panel.png", "frame", FRAME_SIZE, "Menu panel frame", true))
	list.append(_entry("ui/title_logo.png", "title_logo", Vector2i.ZERO, "Title screen logo", true))
	list.append(_entry("icon/icon.png", "app_icon", APP_ICON_SIZE, "App icon", false))
	list.append(_entry("icon/adaptive_foreground.png", "adaptive_icon", ADAPTIVE_ICON_SIZE, "Android adaptive icon foreground", false))
	list.append(_entry("icon/adaptive_background.png", "adaptive_icon", ADAPTIVE_ICON_SIZE, "Android adaptive icon background", false))
	list.append(_entry("fonts/main.ttf", "font", Vector2i.ZERO, "UI font (OFL or similar licence)", true))
	return list


static func map_tileset(m: Dictionary) -> String:
	return m.get("tileset", "indoor" if m.get("indoor", false) else "outdoor")


static func map_terrain(m: Dictionary) -> String:
	return m.get("battle_terrain", "indoor" if m.get("indoor", false) else "grass")


## Returns "" if an image of this kind and size is acceptable, else what is wrong.
static func check_size(kind: String, size: Vector2i) -> String:
	match kind:
		"character":
			if size == CHARACTER_SHEET or size == CHARACTER_SHEET_MIRRORED:
				return ""
			return "must be %s (or %s without the right-facing row)" % [_fmt(CHARACTER_SHEET), _fmt(CHARACTER_SHEET_MIRRORED)]
		"tileset":
			if size.x == TILESET_WIDTH and size.y > 0 and size.y % TILE == 0:
				return ""
			return "must be %d px wide and a multiple of %d px tall" % [TILESET_WIDTH, TILE]
		"title_logo":
			if size.x <= TITLE_LOGO_MAX.x and size.y <= TITLE_LOGO_MAX.y:
				return ""
			return "must fit within %s" % _fmt(TITLE_LOGO_MAX)
	for entry in [["monster_front", MONSTER_SIZE], ["monster_back", MONSTER_SIZE], ["monster_icon", ICON_SIZE],
			["object", OBJECT_SIZE], ["trainer", TRAINER_SIZE], ["battle_bg", BATTLE_BG_SIZE],
			["battle_base", BATTLE_BASE_SIZE], ["type_badge", TYPE_BADGE_SIZE], ["status_badge", STATUS_BADGE_SIZE],
			["frame", FRAME_SIZE], ["app_icon", APP_ICON_SIZE], ["adaptive_icon", ADAPTIVE_ICON_SIZE]]:
		if kind == entry[0]:
			return "" if size == entry[1] else "must be %s" % _fmt(entry[1])
	return ""


static func _entry(path: String, kind: String, size: Vector2i, description: String, used: bool) -> Dictionary:
	return { "path": path, "kind": kind, "size": size, "for": description, "used": used }


static func _fmt(size: Vector2i) -> String:
	return "%dx%d" % [size.x, size.y]
