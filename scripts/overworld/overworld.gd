extends Node2D
## Placeholder overworld: a test route drawn from an ASCII layout until real
## tilesets and a TileMap-based map pipeline exist.
##   T tree   w water   . ground   f flowers   g tall grass   H healing pad

const TILE := 16
const MAP_ID := "route_1"
const BLOCKING := "Tw"
const LAYOUT := [
	"TTTTTTTTTTTTTTTTTTTTTTTT",
	"T..........gggggggg....T",
	"T..ff......gggggggg....T",
	"T..........gggggggg....T",
	"T....TT....gggggggg....T",
	"T....TT................T",
	"T......................T",
	"Tgggggg.......wwwww....T",
	"Tgggggg.......wwwww....T",
	"Tgggggg.......wwwww....T",
	"Tgggggg................T",
	"T..........ff..........T",
	"T....H.................T",
	"T......................T",
	"TTTTTTTTTTTTTTTTTTTTTTTT",
]
const COLORS := {
	".": Color("#a8d878"), "f": Color("#a8d878"), "g": Color("#4f9a4a"),
	"T": Color("#2f6b3a"), "w": Color("#5090d8"), "H": Color("#f0c0d0"),
}

var player: Node2D
var _toast: Label


func _ready() -> void:
	player = preload("res://scripts/overworld/player.gd").new()
	player.map = self
	add_child(player)
	player.place(Game.player_cell, Game.player_facing)
	player.stepped.connect(_on_player_stepped)

	var camera := Camera2D.new()
	camera.zoom = Vector2(2, 2)   # 480x320 viewport shows 15x10 tiles, like the GBA
	camera.position = Vector2(TILE / 2.0, TILE / 2.0)
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = LAYOUT[0].length() * TILE
	camera.limit_bottom = LAYOUT.size() * TILE
	player.add_child(camera)

	var ui := CanvasLayer.new()
	add_child(ui)
	_toast = Label.new()
	_toast.position = Vector2(12, 280)
	_toast.add_theme_color_override("font_color", Color.WHITE)
	_toast.add_theme_color_override("font_outline_color", Color.BLACK)
	_toast.add_theme_constant_override("outline_size", 4)
	ui.add_child(_toast)
	_show_toast("Arrow keys to move. Tall grass hides wild monsters.")


func tile_at(cell: Vector2i) -> String:
	if cell.y < 0 or cell.y >= LAYOUT.size() or cell.x < 0 or cell.x >= LAYOUT[cell.y].length():
		return "T"
	return LAYOUT[cell.y][cell.x]


func is_walkable(cell: Vector2i) -> bool:
	return not BLOCKING.contains(tile_at(cell))


func _on_player_stepped(cell: Vector2i) -> void:
	Game.player_cell = cell
	Game.player_facing = player.facing
	match tile_at(cell):
		"H":
			Game.heal_party()
			_show_toast("Your monsters were fully restored!")
		"g":
			if Game.roll_encounter(MAP_ID):
				player.frozen = true


func _show_toast(text: String) -> void:
	_toast.text = text
	_toast.visible = true
	await get_tree().create_timer(3.0).timeout
	if _toast.text == text:
		_toast.visible = false


func _draw() -> void:
	for y in LAYOUT.size():
		for x in LAYOUT[y].length():
			var tile: String = LAYOUT[y][x]
			var rect := Rect2(x * TILE, y * TILE, TILE, TILE)
			draw_rect(rect, COLORS.get(tile, Color.MAGENTA))
			var origin := rect.position
			match tile:
				"T":
					draw_circle(origin + Vector2(8, 7), 6.5, Color("#3f8a48"))
					draw_rect(Rect2(origin + Vector2(7, 12), Vector2(2, 4)), Color("#6a4a2a"))
				"g":
					for i in 3:
						var base := origin + Vector2(3 + i * 5, 13)
						draw_line(base, base + Vector2(-2, -8), Color("#2f7a34"), 1.0)
						draw_line(base, base + Vector2(2, -8), Color("#2f7a34"), 1.0)
				"f":
					draw_circle(origin + Vector2(5, 5), 2, Color("#f06060"))
					draw_circle(origin + Vector2(11, 11), 2, Color("#f0f060"))
				"w":
					draw_line(origin + Vector2(3, 6), origin + Vector2(9, 6), Color("#80b8f0"), 1.0)
				"H":
					draw_rect(Rect2(origin + Vector2(6, 3), Vector2(4, 10)), Color("#e04060"))
					draw_rect(Rect2(origin + Vector2(3, 6), Vector2(10, 4)), Color("#e04060"))
