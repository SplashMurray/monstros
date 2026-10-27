class_name DialogueBox
extends CanvasLayer
## Text box with typewriter text. Advance with A (gamepad, keyboard or on-screen)
## or by tapping the box. Also shows choice lists, where B picks the last option ("No").

signal _advanced
signal _chosen(index: int)

const CHARS_PER_SECOND := 60.0
const BOX_HEIGHT := 64.0
const EDGE := 8.0
const TOUCH_SIDE_ROOM := 112.0   # keeps the box clear of the on-screen D-pad and buttons

var _panel: PanelContainer
var _label: Label
var _arrow: Label
var _choices: VBoxContainer
var _tween: Tween
var _revealing := false
var _waiting := false
var _choice_count := 0
var _opened_frame := 0


func _ready() -> void:
	layer = 50
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = Theme.new()
	root.theme.default_font_size = 12
	add_child(root)

	_panel = PanelContainer.new()
	_panel.anchor_top = 1.0
	_panel.anchor_right = 1.0
	_panel.anchor_bottom = 1.0
	_panel.gui_input.connect(_on_panel_input)
	root.add_child(_panel)
	var margin := MarginContainer.new()
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 8)
	_panel.add_child(margin)
	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	margin.add_child(_label)
	_arrow = Label.new()
	_arrow.text = "▼"
	_arrow.size_flags_horizontal = Control.SIZE_SHRINK_END
	_arrow.size_flags_vertical = Control.SIZE_SHRINK_END
	margin.add_child(_arrow)

	_choices = VBoxContainer.new()
	_choices.anchor_left = 1.0
	_choices.anchor_top = 1.0
	_choices.anchor_right = 1.0
	_choices.anchor_bottom = 1.0
	_choices.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_choices.grow_vertical = Control.GROW_DIRECTION_BEGIN
	root.add_child(_choices)
	visible = false


func is_open() -> bool:
	return visible


## Shows one page of text and waits until the player advances it.
func say(text: String) -> void:
	_open()
	_label.text = text
	_label.visible_ratio = 0.0
	_revealing = true
	_waiting = false
	_arrow.visible = false
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_label, "visible_ratio", 1.0, maxf(0.05, text.length() / CHARS_PER_SECOND))
	_tween.finished.connect(_reveal_done)
	await _advanced


## Shows a prompt with options and returns the chosen index.
func choose(prompt: String, options: Array) -> int:
	_open()
	_label.text = prompt
	_label.visible_ratio = 1.0
	_revealing = false
	_waiting = false
	_arrow.visible = false
	for child in _choices.get_children():
		child.queue_free()
	for i in options.size():
		var button := Button.new()
		button.text = options[i]
		button.custom_minimum_size = Vector2(72, 26)
		button.pressed.connect(func() -> void: _chosen.emit(i))
		_choices.add_child(button)
	_choice_count = options.size()
	_choices.visible = true
	if not Controls.is_touch():
		_choices.get_child(_choices.get_child_count() - options.size()).grab_focus()
	var picked: int = await _chosen
	_choice_count = 0
	_choices.visible = false
	return picked


func close() -> void:
	visible = false


func _open() -> void:
	_layout()
	visible = true
	_opened_frame = Engine.get_process_frames()


func _layout() -> void:
	var side := TOUCH_SIDE_ROOM if Controls.overlay.visible else EDGE
	_panel.offset_left = side
	_panel.offset_right = -side
	_panel.offset_top = -BOX_HEIGHT - EDGE
	_panel.offset_bottom = -EDGE
	_choices.offset_right = -side
	_choices.offset_bottom = -BOX_HEIGHT - EDGE * 2


func _reveal_done() -> void:
	_revealing = false
	_label.visible_ratio = 1.0
	if _choice_count == 0:
		_waiting = true
		_arrow.visible = true


func _process(_delta: float) -> void:
	# Ignore the press that opened the box (e.g. A pressed to talk to someone).
	if not visible or Engine.get_process_frames() <= _opened_frame:
		return
	if _choice_count > 0:
		if Input.is_action_just_pressed("cancel"):
			_chosen.emit(_choice_count - 1)
	elif Input.is_action_just_pressed("accept") or Input.is_action_just_pressed("cancel"):
		_press()


func _on_panel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Engine.get_process_frames() > _opened_frame and _choice_count == 0:
			_press()


func _press() -> void:
	if _revealing:
		_tween.kill()
		_reveal_done()
	elif _waiting:
		_waiting = false
		_advanced.emit()
