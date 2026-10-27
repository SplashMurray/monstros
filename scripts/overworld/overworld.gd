extends Node2D
## The overworld: draws the current map from its ASCII layout, owns the player and
## NPCs, and handles warps, step triggers, trainer sightlines, talking and wild encounters.
## Maps are defined in data/maps/*.json; the tile legend is in map_rules.gd.

const TILE := 16
const NpcScript := preload("res://scripts/overworld/npc.gd")
const PlayerScript := preload("res://scripts/overworld/player.gd")

var map: Dictionary = {}
var map_id := ""
var player: Node2D
var npcs: Array = []
var runner: EventRunner
var dialogue: DialogueBox
var menu: StartMenu
var _layout: Array = []
var _camera: Camera2D
var _fade: ColorRect
var _banner: Label
var _transitioning := true
var _tileset: Texture2D
var _legend: Dictionary = {}
var _animated_tiles := false
var _anim_time := 0.0
var _last_area := ""   # last outdoor map, so the name banner only shows on entering a new area


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	Controls.set_overlay_wanted(true)
	y_sort_enabled = true
	dialogue = DialogueBox.new()
	add_child(dialogue)
	menu = StartMenu.new()
	add_child(menu)
	runner = EventRunner.new(self)

	player = PlayerScript.new()
	player.map = self
	add_child(player)
	player.stepped.connect(_on_player_stepped)
	_camera = Camera2D.new()
	_camera.zoom = Vector2(2, 2)   # 15x10 tiles like the GBA; wider phones see a little more
	_camera.position = Vector2(TILE / 2.0, TILE / 2.0)
	player.add_child(_camera)
	get_viewport().size_changed.connect(_update_camera_limits)

	var ui := CanvasLayer.new()
	ui.layer = 40
	add_child(ui)
	_fade = ColorRect.new()
	_fade.color = Color.BLACK
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(_fade)
	_banner = Label.new()
	_banner.position = Vector2(10, 8)
	_banner.add_theme_color_override("font_color", Color.WHITE)
	_banner.add_theme_color_override("font_outline_color", Color.BLACK)
	_banner.add_theme_constant_override("outline_size", 4)
	ui.add_child(_banner)

	_load_map(Game.map_id)
	_last_area = map_id
	player.place(Game.player_cell, Game.player_facing)
	_update_camera_limits()
	_camera.reset_smoothing()
	await _fade_to(0.0)
	_transitioning = false
	if not Game.has_flag("seen_controls_hint"):
		Game.set_flag("seen_controls_hint")
		_show_banner("Move with the D-pad. A talks, hold B to run, MENU opens the menu.", 5.0)
	_resume_after_battle()


func _process(delta: float) -> void:
	if _animated_tiles:
		_anim_time += delta
		queue_redraw()
	var blocked := runner.busy or menu.visible or _transitioning
	player.frozen = blocked
	Game.autosave_allowed = not blocked
	if blocked or player.is_moving():
		return
	if Input.is_action_just_pressed("menu"):
		menu.open()
	elif Input.is_action_just_pressed("accept"):
		_interact()


# --- Map ----------------------------------------------------------------------

func _load_map(id: String) -> void:
	map_id = id
	map = Dex.map_data(id)
	_layout = map["layout"]
	Game.map_id = id
	_tileset = Art.tileset(Art.map_tileset(map))
	_legend = Art.tileset_legend(Art.map_tileset(map)) if _tileset else {}
	_animated_tiles = false
	for entry in _legend.values():
		_animated_tiles = _animated_tiles or entry.get("mode", "") == "animate"
	for npc in npcs:
		npc.queue_free()
	npcs.clear()
	for data in map.get("npcs", []):
		if not Game.has_flag(_hidden_flag(data["id"])):
			_spawn_npc(data)
	queue_redraw()


func _spawn_npc(data: Dictionary) -> void:
	var npc: Node2D = NpcScript.new()
	npc.setup(data)
	add_child(npc)
	npcs.append(npc)


func change_map(id: String, cell: Vector2i, facing: Vector2i) -> void:
	_transitioning = true
	await _fade_to(1.0)
	_load_map(id)
	player.place(cell, facing)
	Game.player_cell = cell
	Game.player_facing = facing
	_update_camera_limits()
	_camera.reset_smoothing()
	await _fade_to(0.0)
	_transitioning = false
	if not map.get("indoor", false) and id != _last_area:
		_last_area = id
		_show_banner(map.get("name", ""))


func size_in_tiles() -> Vector2i:
	return Vector2i(_layout[0].length(), _layout.size())


func tile_at(cell: Vector2i) -> String:
	if cell.y < 0 or cell.y >= _layout.size() or cell.x < 0 or cell.x >= _layout[cell.y].length():
		return "X"
	return _layout[cell.y][cell.x]


func is_walkable(cell: Vector2i) -> bool:
	return not MapRules.BLOCKING.contains(tile_at(cell)) and npc_at(cell) == null


func npc_at(cell: Vector2i) -> Node2D:
	for npc in npcs:
		if npc.cell == cell:
			return npc
	return null


func npc_by_id(id: String) -> Node2D:
	for npc in npcs:
		if npc.id == id:
			return npc
	return null


func set_npc_hidden(id: String, hidden: bool) -> void:
	var flag := _hidden_flag(id)
	if hidden:
		Game.set_flag(flag)
		var npc := npc_by_id(id)
		if npc:
			npcs.erase(npc)
			npc.queue_free()
	else:
		Game.clear_flag(flag)
		if npc_by_id(id) == null:
			for data in map.get("npcs", []):
				if data["id"] == id:
					_spawn_npc(data)


func _hidden_flag(npc_id: String) -> String:
	return "hidden:%s:%s" % [map_id, npc_id]


# --- Player actions -------------------------------------------------------------

func _interact() -> void:
	var target: Vector2i = player.cell + player.facing
	var npc := npc_at(target)
	if npc == null and tile_at(target) == "k":
		npc = npc_at(target + player.facing)   # talk across shop and healing counters
	if npc:
		npc.face(-player.facing)
		runner.run(_npc_script(npc))
		return
	for sign_data in map.get("signs", []):
		if Dirs.cell(sign_data["cell"]) == target:
			runner.run([{ "say": sign_data["text"] }])
			return


func _npc_script(npc: Node2D) -> Array:
	var trainer_id: String = npc.data.get("trainer", "")
	if trainer_id != "" and not npc.data.has("script"):
		if Game.has_flag("defeated:" + trainer_id):
			return [{ "say": "%s: %s" % [Game.trainer_speaker(trainer_id), Dex.trainer(trainer_id)["after"]] }]
		return _trainer_challenge(trainer_id)
	return npc.data.get("script", [])


func _trainer_challenge(trainer_id: String) -> Array:
	var intro: String = Dex.trainer(trainer_id).get("intro", "")
	var script := []
	if intro != "":
		script.append({ "say": "%s: %s" % [Game.trainer_speaker(trainer_id), intro] })
	script.append({ "battle": trainer_id })
	return script


func _on_player_stepped(cell: Vector2i) -> void:
	Game.player_cell = cell
	Game.player_facing = player.facing
	if runner.busy:
		return
	for warp in map.get("warps", []):
		if Dirs.cell(warp["at"]) == cell:
			change_map(warp["to"], Dirs.cell(warp["cell"]), Dirs.from_name(warp.get("facing", "down")))
			return
	for trigger in map.get("triggers", []):
		if trigger.has("unless_flag") and Game.has_flag(trigger["unless_flag"]):
			continue
		for trigger_cell in trigger["cells"]:
			if Dirs.cell(trigger_cell) == cell:
				runner.run(trigger["script"])
				return
	if _check_trainer_sight():
		return
	if tile_at(cell) == "g" and map.has("encounters"):
		if Game.roll_encounter(map["encounters"]):
			_transitioning = true


## Trainers who see the player in a straight line walk over and challenge them.
func _check_trainer_sight() -> bool:
	for npc in npcs:
		var trainer_id: String = npc.data.get("trainer", "")
		if trainer_id == "" or Game.has_flag("defeated:" + trainer_id):
			continue
		for distance in range(1, int(npc.data.get("sight", 0)) + 1):
			var look: Vector2i = npc.cell + npc.facing * distance
			if look == player.cell:
				var script := [{ "exclaim": npc.id }, { "npc_approach": npc.id }]
				script.append_array(_trainer_challenge(trainer_id))
				runner.run(script)
				return true
			if not is_walkable(look):
				break
	return false


func npc_approach(id: String) -> void:
	var npc := npc_by_id(id)
	for i in 16:
		if npc.cell + npc.facing == player.cell:
			break
		await npc.step(npc.facing)
	player.face(-npc.facing)


func _resume_after_battle() -> void:
	if Game.resume.is_empty():
		return
	var saved := Game.resume
	Game.resume = {}
	var queue: Array = saved.get("win" if saved.get("result") == "win" else "lose", []).duplicate(true)
	queue.append_array(saved.get("queue", []))
	runner.run(queue)


# --- Presentation -----------------------------------------------------------------

func _update_camera_limits() -> void:
	var view := get_viewport_rect().size / _camera.zoom
	var map_size := Vector2(size_in_tiles() * TILE)
	# Small rooms are centred on screen; larger maps scroll and stop at their edges.
	var pad := ((view - map_size) / 2.0).max(Vector2.ZERO)
	_camera.limit_left = floori(-pad.x)
	_camera.limit_top = floori(-pad.y)
	_camera.limit_right = ceili(map_size.x + pad.x)
	_camera.limit_bottom = ceili(map_size.y + pad.y)


func _fade_to(alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", alpha, 0.18)
	await tween.finished


func _show_banner(text: String, seconds: float = 2.0) -> void:
	_banner.text = text
	_banner.visible = text != ""
	await get_tree().create_timer(seconds).timeout
	if _banner.text == text:
		_banner.visible = false


func _draw() -> void:
	for y in _layout.size():
		for x in _layout[y].length():
			var tile: String = _layout[y][x]
			if _legend.has(tile):
				_draw_tileset_tile(_legend[tile], Vector2i(x, y))
			else:
				_draw_tile(tile, Vector2(x * TILE, y * TILE))


func _draw_tileset_tile(entry: Dictionary, cell: Vector2i) -> void:
	var cells: Array = entry.get("cells", [entry.get("cell", [0, 0])])
	var index := 0
	if entry.get("mode", "") == "animate":
		index = floori(_anim_time * float(entry.get("fps", 4))) % cells.size()
	elif cells.size() > 1:
		index = absi(hash(cell)) % cells.size()   # stable random variant per position
	var source := Rect2(Vector2(Dirs.cell(cells[index]) * TILE), Vector2(TILE, TILE))
	draw_texture_rect_region(_tileset, Rect2(Vector2(cell * TILE), Vector2(TILE, TILE)), source)


## Placeholder tile drawing, used for any tile the map's tileset doesn't cover yet.
func _draw_tile(tile: String, o: Vector2) -> void:
	draw_rect(Rect2(o, Vector2(TILE, TILE)), MapRules.COLORS.get(tile, Color.MAGENTA))
	match tile:
		"T":
			draw_circle(o + Vector2(8, 7), 6.5, Color("#3f8a48"))
			draw_rect(Rect2(o + Vector2(7, 12), Vector2(2, 4)), Color("#6a4a2a"))
		"g":
			for i in 3:
				var base := o + Vector2(3 + i * 5, 13)
				draw_line(base, base + Vector2(-2, -8), Color("#2f7a34"), 1.0)
				draw_line(base, base + Vector2(2, -8), Color("#2f7a34"), 1.0)
		"f":
			draw_circle(o + Vector2(5, 5), 2, Color("#f06060"))
			draw_circle(o + Vector2(11, 11), 2, Color("#f0f060"))
		"w":
			draw_line(o + Vector2(3, 6), o + Vector2(9, 6), Color("#80b8f0"), 1.0)
			draw_line(o + Vector2(8, 11), o + Vector2(13, 11), Color("#80b8f0"), 1.0)
		"r", "R", "G":
			draw_line(o + Vector2(0, 15), o + Vector2(16, 15), MapRules.COLORS[tile].darkened(0.3), 1.0)
		"#":
			draw_rect(Rect2(o + Vector2(4, 5), Vector2(8, 6)), Color("#90b8d8"))
		"D":
			draw_rect(Rect2(o + Vector2(2, 1), Vector2(12, 15)), Color("#8a6040"))
		"=":
			draw_rect(Rect2(o + Vector2(0, 6), Vector2(16, 3)), Color("#c8a070"))
		"S":
			draw_rect(Rect2(o + Vector2(7, 9), Vector2(2, 6)), Color("#6a4a2a"))
			draw_rect(Rect2(o + Vector2(2, 3), Vector2(12, 7)), Color("#c09060"))
		"_":
			draw_line(o + Vector2(0, 15), o + Vector2(16, 15), Color("#d4c4a4"), 1.0)
		"b":
			for i in 3:
				draw_line(o + Vector2(1, 4 + i * 4), o + Vector2(15, 4 + i * 4), Color("#5a3a20"), 1.0)
		"m":
			draw_rect(Rect2(o + Vector2(2, 3), Vector2(12, 10)), Color("#e06060"))
