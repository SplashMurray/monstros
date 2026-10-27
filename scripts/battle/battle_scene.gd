extends Control
## Placeholder battle screen. Builds a simple UI in code and plays back
## the events produced by the Battle engine. Sprites are coloured blocks for now.

const MESSAGE_DELAY := 0.9
const HP_TWEEN_TIME := 0.4
const STATUS_TAGS := { "burn": "BRN", "poison": "PSN", "paralysis": "PAR", "sleep": "SLP", "freeze": "FRZ" }

var battle: Battle
var _info: Array[Label] = [null, null]
var _bars: Array[ProgressBar] = [null, null]
var _sprites: Array[ColorRect] = [null, null]
var _snap: Array = [{}, {}]
var _log: Label
var _menu: GridContainer
var _back_action := Callable()   # what B / the Android back button does in the current menu


func _ready() -> void:
	# Battle menus are tapped directly, so the on-screen D-pad is not needed here.
	Controls.set_overlay_wanted(false)
	Controls.device_changed.connect(_on_device_changed)
	theme = Theme.new()
	theme.default_font_size = 12
	_build_ui()
	var setup: Dictionary = Game.pending_battle
	battle = Battle.new(Game.party, setup.get("enemy", []), setup.get("wild", true), Game.rng)
	await _play(battle.start())
	_show_main_menu()


# --- Layout ----------------------------------------------------------------

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#f8f0d8")
	background.set_anchors_preset(PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 10)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)

	column.add_child(_build_side_row(Battle.ENEMY))
	var spacer := Control.new()
	spacer.size_flags_vertical = SIZE_EXPAND_FILL
	column.add_child(spacer)
	column.add_child(_build_side_row(Battle.PLAYER))

	var log_panel := PanelContainer.new()
	log_panel.custom_minimum_size = Vector2(0, 44)
	_log = Label.new()
	_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_panel.add_child(_log)
	column.add_child(log_panel)

	_menu = GridContainer.new()
	_menu.columns = 2
	_menu.custom_minimum_size = Vector2(0, 52)
	column.add_child(_menu)


func _build_side_row(side: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	var info_box := VBoxContainer.new()
	var info := Label.new()
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(140, 8)
	info_box.add_child(info)
	info_box.add_child(bar)

	var sprite := ColorRect.new()
	sprite.custom_minimum_size = Vector2(56, 56)
	var filler := Control.new()
	filler.size_flags_horizontal = SIZE_EXPAND_FILL

	# Enemy: info top-left, sprite top-right. Player: sprite left, info right.
	if side == Battle.ENEMY:
		row.add_child(info_box)
		row.add_child(filler)
		row.add_child(sprite)
	else:
		row.add_child(sprite)
		row.add_child(filler)
		row.add_child(info_box)
	_info[side] = info
	_bars[side] = bar
	_sprites[side] = sprite
	return row


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
				_snap[event["side"]] = event
				_bars[event["side"]].max_value = event["max"]
				_bars[event["side"]].value = event["hp"]
				_sprites[event["side"]].color = Dex.type_color(event["types"][0])
				_update_info(event["side"])
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

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _back_action.is_valid():
		get_viewport().set_input_as_handled()
		_back_action.call()


func _on_device_changed(_device: String) -> void:
	# Picking up a controller mid-menu: make sure something is focused.
	if get_viewport().gui_get_focus_owner() == null:
		_focus_first()


func _clear_menu() -> void:
	_back_action = Callable()
	for child in _menu.get_children():
		_menu.remove_child(child)
		child.queue_free()


func _add_button(text: String, callback: Callable, disabled: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.disabled = disabled
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 26)   # comfortable touch target on phones
	button.pressed.connect(callback)
	_menu.add_child(button)
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
		var text := "%s  %s  %d/%d" % [data["name"], Dex.type_name(data["type"]), slot["pp"], data["pp"]]
		_add_button(text, _submit.bind({ "type": "move", "index": i }), slot["pp"] <= 0)
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
	if battle.result == "caught":
		lines.append(Game.receive_monster(battle.caught))
	if battle.result == "lose":
		lines.append("You hurried back to the healing pad...")
	else:
		lines.append_array(Game.process_evolutions())
	for line in lines:
		_log.text = line
		await get_tree().create_timer(MESSAGE_DELAY * 1.5).timeout
	Game.end_battle(battle.result)
