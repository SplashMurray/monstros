class_name TouchOverlay
extends CanvasLayer
## On-screen GBA-style controls: a D-pad on the left, A and B on the right.
## Touches are converted into input actions, so the rest of the game never
## needs to know whether the player is using touch or a controller.
## Supports multi-touch (e.g. holding B to run while steering with the D-pad).

const DPAD_RADIUS := 42.0
const DPAD_TOUCH_RADIUS := 70.0   # generous hit area so thumbs don't slip off
const DPAD_DEADZONE := 8.0
const BUTTON_RADIUS := 20.0
const BUTTON_TOUCH_RADIUS := 30.0
const MARGIN := 14.0
const IDLE_COLOR := Color(1, 1, 1, 0.35)
const PRESSED_COLOR := Color(1, 1, 1, 0.7)
const OUTLINE_COLOR := Color(0, 0, 0, 0.35)
const HAPTIC_MS := 12

const DIRECTION_ACTIONS := {
	Vector2i.UP: ["move_up", "ui_up"],
	Vector2i.DOWN: ["move_down", "ui_down"],
	Vector2i.LEFT: ["move_left", "ui_left"],
	Vector2i.RIGHT: ["move_right", "ui_right"],
}
const BUTTON_ACTIONS := {
	"A": ["accept", "ui_accept"],
	"B": ["cancel", "ui_cancel", "run"],
	"MENU": ["menu"],
}
const MENU_SIZE := Vector2(40, 18)

## Extra space to keep clear of camera notches/rounded corners, in viewport pixels.
var inset_left := 0.0
var inset_right := 0.0

var _canvas: Control
var _dpad_finger := -1
var _dpad_direction := Vector2i.ZERO
var _button_fingers := {}   # finger index -> button name


## 4-way direction for a thumb offset from the D-pad centre (dominant axis wins).
static func direction_from_offset(offset: Vector2, deadzone: float = DPAD_DEADZONE) -> Vector2i:
	if offset.length() < deadzone:
		return Vector2i.ZERO
	if absf(offset.x) > absf(offset.y):
		return Vector2i.RIGHT if offset.x > 0.0 else Vector2i.LEFT
	return Vector2i.DOWN if offset.y > 0.0 else Vector2i.UP


func _ready() -> void:
	layer = 100
	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_controls)
	add_child(_canvas)
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()


func set_shown(shown: bool) -> void:
	if visible == shown:
		return
	visible = shown
	if not shown:
		release_all()


func release_all() -> void:
	_set_dpad(Vector2i.ZERO)
	_dpad_finger = -1
	for finger in _button_fingers.keys():
		_release_button(finger)


# --- Layout ------------------------------------------------------------------

func screen_size() -> Vector2:
	return get_viewport().get_visible_rect().size


func dpad_center() -> Vector2:
	return Vector2(MARGIN + inset_left + DPAD_RADIUS, screen_size().y - MARGIN - DPAD_RADIUS)


func button_center(button_name: String) -> Vector2:
	if button_name == "MENU":
		return Vector2(screen_size().x - MARGIN - inset_right - MENU_SIZE.x / 2.0, MARGIN + MENU_SIZE.y / 2.0)
	var a := Vector2(screen_size().x - MARGIN - inset_right - BUTTON_RADIUS, screen_size().y - MARGIN - BUTTON_RADIUS * 2.6)
	if button_name == "A":
		return a
	return a + Vector2(-BUTTON_RADIUS * 2.5, BUTTON_RADIUS * 1.5)


func _on_viewport_resized() -> void:
	inset_left = 0.0
	inset_right = 0.0
	if OS.has_feature("mobile"):
		var window_size := Vector2(DisplayServer.window_get_size())
		var safe := Rect2(DisplayServer.get_display_safe_area())
		var to_viewport := screen_size().x / maxf(window_size.x, 1.0)
		inset_left = maxf(0.0, safe.position.x) * to_viewport
		inset_right = maxf(0.0, window_size.x - safe.end.x) * to_viewport
	_canvas.queue_redraw()


# --- Touch handling ----------------------------------------------------------

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if _touch_down(event.index, event.position):
				get_viewport().set_input_as_handled()
		else:
			_touch_up(event.index)
	elif event is InputEventScreenDrag and event.index == _dpad_finger:
		_set_dpad(direction_from_offset(event.position - dpad_center()))
		get_viewport().set_input_as_handled()


func _touch_down(finger: int, pos: Vector2) -> bool:
	if _dpad_finger == -1 and pos.distance_to(dpad_center()) <= DPAD_TOUCH_RADIUS:
		_dpad_finger = finger
		_set_dpad(direction_from_offset(pos - dpad_center()))
		return true
	for button_name in BUTTON_ACTIONS:
		if pos.distance_to(button_center(button_name)) <= BUTTON_TOUCH_RADIUS and not _button_fingers.values().has(button_name):
			_button_fingers[finger] = button_name
			for action in BUTTON_ACTIONS[button_name]:
				_send(action, true)
			Input.vibrate_handheld(HAPTIC_MS)
			_canvas.queue_redraw()
			return true
	return false


func _touch_up(finger: int) -> void:
	if finger == _dpad_finger:
		_dpad_finger = -1
		_set_dpad(Vector2i.ZERO)
	elif _button_fingers.has(finger):
		_release_button(finger)


func _release_button(finger: int) -> void:
	for action in BUTTON_ACTIONS[_button_fingers[finger]]:
		_send(action, false)
	_button_fingers.erase(finger)
	_canvas.queue_redraw()


func _set_dpad(direction: Vector2i) -> void:
	if direction == _dpad_direction:
		return
	if _dpad_direction != Vector2i.ZERO:
		for action in DIRECTION_ACTIONS[_dpad_direction]:
			_send(action, false)
	_dpad_direction = direction
	if direction != Vector2i.ZERO:
		for action in DIRECTION_ACTIONS[direction]:
			_send(action, true)
		Input.vibrate_handheld(HAPTIC_MS)
	_canvas.queue_redraw()


func _send(action: String, pressed: bool) -> void:
	# action_press/release rather than parsing InputEventActions: in Godot 4.3 a parsed
	# InputEventAction resets the held state of other actions, which breaks holding
	# B to run while steering with the D-pad.
	if pressed:
		Input.action_press(action)
	else:
		Input.action_release(action)


# --- Drawing -----------------------------------------------------------------

func _draw_controls() -> void:
	var center := dpad_center()
	var arm := DPAD_RADIUS * 0.38
	var font := ThemeDB.fallback_font
	_canvas.draw_circle(center, DPAD_RADIUS + 4.0, OUTLINE_COLOR)
	for direction in DIRECTION_ACTIONS:
		var d := Vector2(direction)
		var rect := Rect2(center + d * DPAD_RADIUS * 0.5 - Vector2(arm, arm), Vector2(arm, arm) * 2.0)
		rect = rect.merge(Rect2(center - Vector2(arm, arm), Vector2(arm, arm) * 2.0))
		_canvas.draw_rect(rect, PRESSED_COLOR if direction == _dpad_direction else IDLE_COLOR)
	for button_name in BUTTON_ACTIONS:
		var pos := button_center(button_name)
		var pressed := _button_fingers.values().has(button_name)
		if button_name == "MENU":
			var rect := Rect2(pos - MENU_SIZE / 2.0, MENU_SIZE)
			_canvas.draw_rect(rect.grow(2.0), OUTLINE_COLOR)
			_canvas.draw_rect(rect, PRESSED_COLOR if pressed else IDLE_COLOR)
			_canvas.draw_string(font, rect.position + Vector2(0, 13), "MENU", HORIZONTAL_ALIGNMENT_CENTER, MENU_SIZE.x, 10, Color(0, 0, 0, 0.6))
			continue
		_canvas.draw_circle(pos, BUTTON_RADIUS + 2.0, OUTLINE_COLOR)
		_canvas.draw_circle(pos, BUTTON_RADIUS, PRESSED_COLOR if pressed else IDLE_COLOR)
		_canvas.draw_string(font, pos + Vector2(-5, 6), button_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(0, 0, 0, 0.6))
