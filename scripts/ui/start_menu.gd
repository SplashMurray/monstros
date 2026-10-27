class_name StartMenu
extends CanvasLayer
## Start menu (Start button / on-screen MENU / Tab): party summary, save, close.

var _root: Control
var _panel: PanelContainer
var _box: VBoxContainer
var _status: Label
var _back := Callable()   # what B does on the current page
var _opened_frame := 0


func _ready() -> void:
	layer = 60
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.theme = Theme.new()
	_root.theme.default_font_size = 12
	add_child(_root)
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_panel.custom_minimum_size = Vector2(240, 0)
	Art.apply_frame(_panel, "panel")
	_root.add_child(_panel)
	var margin := MarginContainer.new()
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 8)
	_panel.add_child(margin)
	_box = VBoxContainer.new()
	margin.add_child(_box)
	visible = false


func open() -> void:
	visible = true
	_opened_frame = Engine.get_process_frames()
	_show_main()


func close() -> void:
	visible = false


func _process(_delta: float) -> void:
	# Ignore the press that opened the menu.
	if visible and Engine.get_process_frames() > _opened_frame and (Input.is_action_just_pressed("cancel") or Input.is_action_just_pressed("menu")):
		_back.call()


func _clear() -> void:
	for child in _box.get_children():
		_box.remove_child(child)
		child.queue_free()


func _label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_box.add_child(label)
	return label


func _button(text: String, callback: Callable, disabled: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.disabled = disabled
	button.custom_minimum_size = Vector2(0, 26)
	button.pressed.connect(callback)
	_box.add_child(button)
	return button


func _focus_first() -> void:
	if Controls.is_touch():
		return
	for child in _box.get_children():
		if child is Button and not child.disabled:
			child.grab_focus()
			return


func _show_main() -> void:
	_clear()
	_back = close
	var minutes := floori(Game.play_time / 60.0)
	_label("%s    Money: %d    Badges: %d    Time: %d:%02d" % [
		Game.player_name, Game.money, Game.badge_count(), minutes / 60, minutes % 60])
	_button("Party", _show_party, Game.party.is_empty())
	_button("Save", _save)
	_button("Close", close)
	_status = _label("")
	_focus_first()


func _save() -> void:
	_status.text = "Game saved." if Game.save_game() else "Saving failed!"


func _show_party() -> void:
	_clear()
	_back = _show_main
	for i in Game.party.size():
		var m := Game.party[i]
		var tag := "  (fainted)" if m.is_fainted() else ""
		_button("%s  Lv%d  HP %d/%d%s" % [m.display_name(), m.level, m.hp, m.max_hp(), tag], _show_summary.bind(i))
	_button("Back", _show_main)
	_focus_first()


func _show_summary(index: int) -> void:
	_clear()
	_back = _show_party
	var m := Game.party[index]
	var types := []
	for t in m.types():
		types.append(Dex.type_name(t))
	var temperament: Dictionary = Dex.temperaments.get(m.temperament, {})
	_label("%s  Lv%d  %s\n%s temperament    Exp. to next level: %d" % [
		m.display_name(), m.level, "/".join(types), temperament.get("name", "?"), m.exp_to_next_level()])
	var stat_lines := []
	for key in Stats.KEYS:
		stat_lines.append("%s %d" % [Stats.NAMES[key], m.hp if key == "hp" else m.stats[key]])
	_label("  ".join(stat_lines))
	var move_lines := []
	for slot in m.moves:
		var move := Dex.move(slot["id"])
		move_lines.append("%s (%s, %s) %d/%d PP" % [move["name"], Dex.type_name(move["type"]), move["category"], slot["pp"], move["pp"]])
	_label("\n".join(move_lines))
	if index > 0:
		_button("Move to front", func() -> void:
			Game.party.insert(0, Game.party.pop_at(index))
			_show_party())
	_button("Back", _show_party)
	_focus_first()
