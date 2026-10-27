extends Control
## Battle screen. Builds its UI in code and plays back the events produced by the
## Battle engine. Layout follows the GBA screen at 2x: a 480x224 battle field
## (wider on wide phones) above a 96 px text and menu area. Sprites, backgrounds and
## frames come from assets/ (see docs/ART_SPEC.md) with placeholders for anything missing.

const MESSAGE_DELAY := 0.9
const HP_TWEEN_TIME := 0.4
const STATUS_TAGS := { "burn": "BRN", "poison": "PSN", "paralysis": "PAR", "sleep": "SLP", "freeze": "FRZ" }
const SCALE := 2           # battle art is drawn at GBA scale and shown at 2x
const FIELD_HEIGHT := 224  # Art.BATTLE_BG_SIZE.y * SCALE
const BOTTOM_HEIGHT := 96
## Positions relative to the screen's horizontal centre, matching the GBA layout at 2x.
const ENEMY_SPRITE := Vector2(48, 16)
const PLAYER_SPRITE := Vector2(-160, 96)
const ENEMY_INFO := Rect2(-224, 16, 200, 44)
const PLAYER_INFO := Rect2(16, 140, 208, 44)

var battle: Battle
var _info: Array[Label] = [null, null]
var _bars: Array[ProgressBar] = [null, null]
var _sprites: Array[TextureRect] = [null, null]
var _placeholders: Array[ColorRect] = [null, null]
var _snap: Array = [{}, {}]
var _log: Label
var _menu: GridContainer
var _back_action := Callable()   # what B / the Android back button does in the current menu
var _trainer_id := ""
var _terrain := "grass"


func _ready() -> void:
	# Battle menus are tapped directly, so the on-screen D-pad is not needed here.
	Controls.set_overlay_wanted(false)
	Controls.device_changed.connect(_on_device_changed)
	theme = Theme.new()
	theme.default_font_size = 12
	var setup: Dictionary = Game.pending_battle
	_terrain = setup.get("terrain", "grass")
	_build_ui()
	battle = Battle.new(Game.party, setup.get("enemy", []), setup.get("wild", true), Game.rng)
	_trainer_id = setup.get("trainer_id", "")
	if _trainer_id != "":
		battle.trainer_name = Game.trainer_display_name(_trainer_id)
		_set_sprite(Battle.ENEMY, Art.trainer(Dex.trainer(_trainer_id).get("portrait", "")), Color("#808080"))
	_set_sprite(Battle.PLAYER, Art.trainer("player_back"), Color("#3050a0"))
	await _play(battle.start())
	_show_main_menu()


# --- Layout ----------------------------------------------------------------

func _build_ui() -> void:
	var backing := ColorRect.new()
	backing.color = Color("#283040")
	backing.set_anchors_preset(PRESET_FULL_RECT)
	add_child(backing)
	var field := Control.new()
	field.anchor_right = 1.0
	field.offset_bottom = FIELD_HEIGHT
	field.clip_contents = true
	add_child(field)

	var fill := ColorRect.new()
	fill.color = Color("#f8f0d8")
	fill.set_anchors_preset(PRESET_FULL_RECT)
	field.add_child(fill)
	var background := Art.battle_background(_terrain)
	if background:
		var bg := TextureRect.new()
		bg.texture = background
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_SCALE
		_place(bg, Rect2(-background.get_width() * SCALE / 2.0, 0, background.get_width() * SCALE, FIELD_HEIGHT))
		field.add_child(bg)

	var base := Art.battle_base(_terrain)
	var sprite_size := Vector2(Art.MONSTER_SIZE * SCALE)
	for side in [Battle.ENEMY, Battle.PLAYER]:
		var origin := ENEMY_SPRITE if side == Battle.ENEMY else PLAYER_SPRITE
		if base:
			var base_rect := TextureRect.new()
			base_rect.texture = base
			base_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			var base_size := Vector2(Art.BATTLE_BASE_SIZE * SCALE)
			_place(base_rect, Rect2(origin + Vector2((sprite_size.x - base_size.x) / 2.0, sprite_size.y - base_size.y * 0.6), base_size))
			field.add_child(base_rect)
		var placeholder := ColorRect.new()
		_place(placeholder, Rect2(origin + sprite_size * 0.2, sprite_size * 0.6))
		field.add_child(placeholder)
		var sprite := TextureRect.new()
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_place(sprite, Rect2(origin, sprite_size))
		field.add_child(sprite)
		_sprites[side] = sprite
		_placeholders[side] = placeholder
		field.add_child(_build_info(side))

	var bottom := HBoxContainer.new()
	bottom.anchor_top = 1.0
	bottom.anchor_right = 1.0
	bottom.anchor_bottom = 1.0
	bottom.offset_top = -BOTTOM_HEIGHT
	add_child(bottom)
	var log_panel := PanelContainer.new()
	log_panel.size_flags_horizontal = SIZE_EXPAND_FILL
	Art.apply_frame(log_panel, "textbox")
	_log = Label.new()
	_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_panel.add_child(_log)
	bottom.add_child(log_panel)
	_menu = GridContainer.new()
	_menu.columns = 2
	_menu.custom_minimum_size = Vector2(240, 0)
	_menu.visible = false
	bottom.add_child(_menu)


func _build_info(side: int) -> PanelContainer:
	var panel := PanelContainer.new()
	Art.apply_frame(panel, "panel")
	_place(panel, ENEMY_INFO if side == Battle.ENEMY else PLAYER_INFO)
	panel.visible = false   # shown once a monster is out
	var box := VBoxContainer.new()
	panel.add_child(box)
	var info := Label.new()
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 6)
	var track := StyleBoxFlat.new()
	track.bg_color = Color("#404850")
	bar.add_theme_stylebox_override("background", track)
	bar.add_theme_stylebox_override("fill", StyleBoxFlat.new())
	bar.value_changed.connect(func(value: float) -> void:
		(bar.get_theme_stylebox("fill") as StyleBoxFlat).bg_color = Art.hp_color(value / maxf(bar.max_value, 1.0)))
	box.add_child(info)
	box.add_child(bar)
	_info[side] = info
	_bars[side] = bar
	return panel


## Positions a control relative to the top centre of its parent.
func _place(control: Control, rect: Rect2) -> void:
	control.anchor_left = 0.5
	control.anchor_right = 0.5
	control.offset_left = rect.position.x
	control.offset_top = rect.position.y
	control.offset_right = rect.end.x
	control.offset_bottom = rect.end.y


func _set_sprite(side: int, texture: Texture2D, fallback: Color) -> void:
	_sprites[side].texture = texture
	_placeholders[side].visible = texture == null
	_placeholders[side].color = fallback


# --- Event playback ----------------------------------------------------------

func _play(events: Array) -> void:
	for event in events:
		match event["type"]:
			"message":
				_log.text = event["text"]
				await get_tree().create_timer(MESSAGE_DELAY).timeout
			"hp":
				_snap[event["side"]]["hp"] = event["hp"]
				_update_info(event["side"])
				var tween := create_tween()
				tween.tween_property(_bars[event["side"]], "value", float(event["hp"]), HP_TWEEN_TIME)
				await tween.finished
			"refresh":
				var side: int = event["side"]
				_snap[side] = event
				_bars[side].max_value = event["max"]
				_bars[side].value = event["hp"]
				_bars[side].value_changed.emit(_bars[side].value)   # recolour even if the value didn't change
				var art := Art.monster_front(event["species"]) if side == Battle.ENEMY else Art.monster_back(event["species"])
				_set_sprite(side, art, Dex.type_color(event["types"][0]))
				_info[side].get_parent().get_parent().visible = true
				_update_info(side)
			"shake":
				for i in event["count"]:
					_log.text = "..." + ".".repeat(i)
					await get_tree().create_timer(0.4).timeout


func _update_info(side: int) -> void:
	var s: Dictionary = _snap[side]
	if s.is_empty():
		return
	var tag: String = STATUS_TAGS.get(s.get("status", ""), "")
	var type_names := []
	for t in s["types"]:
		type_names.append(Dex.type_name(t))
	_info[side].text = "%s  Lv%d %s\n%s   HP %d/%d" % [
		s["name"], s["level"], tag, "/".join(type_names), s["hp"], s["max"]]


# --- Menus -------------------------------------------------------------------

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cancel") and _back_action.is_valid():
		_back_action.call()


func _on_device_changed(_device: String) -> void:
	# Picking up a controller mid-menu: make sure something is focused.
	if get_viewport().gui_get_focus_owner() == null:
		_focus_first()


func _clear_menu() -> void:
	_back_action = Callable()
	_menu.visible = false   # the text box spans the full width while there's no menu
	for child in _menu.get_children():
		_menu.remove_child(child)
		child.queue_free()


func _add_button(text: String, callback: Callable, disabled: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.disabled = disabled
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.custom_minimum_size = Vector2(0, 22)   # 4 rows fit the 96 px menu area; ~75 px tall on a phone
	button.pressed.connect(callback)
	_menu.add_child(button)
	_menu.visible = true
	return button


func _focus_first() -> void:
	if Controls.is_touch():
		return   # no focus highlight while tapping
	for child in _menu.get_children():
		if child is Button and not child.disabled:
			child.grab_focus()
			return


func _show_main_menu() -> void:
	_clear_menu()
	_log.text = "What will %s do?" % battle.mon(Battle.PLAYER).display_name()
	_add_button("Fight", _show_move_menu)
	_add_button("Catch", _submit.bind({ "type": "catch" }), not battle.is_wild)
	_add_button("Party", _show_party_menu.bind(false))
	_add_button("Run", _submit.bind({ "type": "run" }))
	_focus_first()


func _show_move_menu() -> void:
	var m := battle.mon(Battle.PLAYER)
	if not m.has_usable_moves():
		_submit({ "type": "move", "index": -1 })
		return
	_clear_menu()
	for i in m.moves.size():
		var slot: Dictionary = m.moves[i]
		var data := Dex.move(slot["id"])
		var text := "%s %d/%d" % [data["name"], slot["pp"], data["pp"]]
		var button := _add_button(text, _submit.bind({ "type": "move", "index": i }), slot["pp"] <= 0)
		var details := "%s: %s, %s" % [data["name"], Dex.type_name(data["type"]), data["category"]]
		if data["category"] != "status":
			details += ", power %d" % data["power"]
		button.focus_entered.connect(func() -> void: _log.text = details)
	_add_button("Back", _show_main_menu)
	_back_action = _show_main_menu
	_focus_first()


func _show_party_menu(forced: bool) -> void:
	_clear_menu()
	if forced:
		_log.text = "Choose a monster to send out."
	var party: Array = battle.parties[Battle.PLAYER]
	for i in party.size():
		var m: Monster = party[i]
		var text := "%s Lv%d  %d/%d" % [m.display_name(), m.level, m.hp, m.max_hp()]
		_add_button(text, _submit.bind({ "type": "switch", "index": i }), m.is_fainted() or i == battle.active[Battle.PLAYER])
	if not forced:
		_add_button("Back", _show_main_menu)
		_back_action = _show_main_menu
	_focus_first()


func _submit(action: Dictionary) -> void:
	_clear_menu()
	await _play(battle.take_turn(action))
	if battle.over:
		await _finish()
	elif battle.awaiting_switch:
		_show_party_menu(true)
	else:
		_show_main_menu()


func _finish() -> void:
	var lines := []
	var can_lose: bool = Game.pending_battle.get("can_lose", false)
	if battle.result == "caught":
		lines.append(Game.receive_monster(battle.caught))
	if _trainer_id != "":
		var trainer := Dex.trainer(_trainer_id)
		var speaker := Game.trainer_speaker(_trainer_id)
		if battle.result == "win":
			lines.append("%s: %s" % [speaker, Game.format_text(trainer["defeat"])])
			var prize: int = int(trainer.get("prize", 10)) * battle.parties[Battle.ENEMY].back().level
			Game.money += prize
			lines.append("You got %d money for winning!" % prize)
		elif battle.result == "lose":
			lines.append("%s: %s" % [speaker, Game.format_text(trainer["victory"])])
	if battle.result == "lose" and not can_lose:
		lines.append(Game.format_text("{player} dropped %d money and hurried back to safety..." % Game.blackout_penalty()))
	elif battle.result != "lose":
		lines.append_array(Game.process_evolutions())
	for line in lines:
		_log.text = line
		await get_tree().create_timer(MESSAGE_DELAY * 1.5).timeout
	Game.end_battle(battle.result)
