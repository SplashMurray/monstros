extends Control
## Title screen: continue a saved game or start a new one.

const NAME_MAX_LENGTH := 10

var _menu: VBoxContainer
var _name_box: VBoxContainer
var _name_edit: LineEdit


func _ready() -> void:
	Controls.set_overlay_wanted(false)
	Game.autosave_allowed = false
	theme = Theme.new()
	theme.default_font_size = 14
	var background := ColorRect.new()
	background.color = Color("#1c3a2a")
	background.set_anchors_preset(PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	add_child(center)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	center.add_child(column)

	var title := Label.new()
	title.text = "MONSTROS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color("#f2c94c"))
	column.add_child(title)

	_menu = VBoxContainer.new()
	column.add_child(_menu)
	var continue_button := _add_button(_menu, "Continue", _continue)
	continue_button.disabled = not Game.has_save()
	_add_button(_menu, "New Game", _ask_name)

	_name_box = VBoxContainer.new()
	_name_box.visible = false
	column.add_child(_name_box)
	var prompt := Label.new()
	prompt.text = "What's your name?"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_box.add_child(prompt)
	_name_edit = LineEdit.new()
	_name_edit.text = Game.DEFAULT_PLAYER_NAME
	_name_edit.max_length = NAME_MAX_LENGTH
	_name_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_edit.text_submitted.connect(func(_text: String) -> void: _start_new())
	_name_box.add_child(_name_edit)
	_add_button(_name_box, "Start", _start_new)

	if not Controls.is_touch():
		for button in _menu.get_children():
			if not button.disabled:
				button.grab_focus()
				break


func _add_button(parent: Control, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(180, 30)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _continue() -> void:
	if Game.load_game():
		get_tree().change_scene_to_file(Game.OVERWORLD_SCENE)


func _ask_name() -> void:
	_menu.visible = false
	_name_box.visible = true
	_name_box.get_child(_name_box.get_child_count() - 1).grab_focus()


func _start_new() -> void:
	Game.new_game(_name_edit.text.strip_edges())
	get_tree().change_scene_to_file(Game.OVERWORLD_SCENE)
