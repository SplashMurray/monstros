extends Node
## Autoload "Controls": sets up the input map, tracks which kind of device the player
## is using (touch, gamepad such as a Backbone, or keyboard) and shows the on-screen
## controls only while they are useful.
##
## Desktop testing of touch controls: godot --path . -- --touch

signal device_changed(device: String)

const TOUCH := "touch"
const GAMEPAD := "gamepad"
const KEYBOARD := "keyboard"

var device := KEYBOARD
var overlay: TouchOverlay
var _overlay_wanted := true   # does the current scene want on-screen controls?


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	ControlScheme.apply()
	overlay = TouchOverlay.new()
	add_child(overlay)
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

	var force_touch := OS.get_cmdline_user_args().has("--touch")
	if force_touch:
		Input.emulate_touch_from_mouse = true
	if force_touch or (DisplayServer.is_touchscreen_available() and Input.get_connected_joypads().is_empty()):
		device = TOUCH
	elif not Input.get_connected_joypads().is_empty():
		device = GAMEPAD
	_refresh()


## Scenes with their own tappable UI (e.g. battle menus) turn the overlay off.
func set_overlay_wanted(wanted: bool) -> void:
	_overlay_wanted = wanted
	_refresh()


func is_touch() -> bool:
	return device == TOUCH


func _input(event: InputEvent) -> void:
	var detected := ""
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		detected = TOUCH
	elif event is InputEventJoypadButton:
		detected = GAMEPAD
	elif event is InputEventJoypadMotion and absf(event.axis_value) > ControlScheme.DEADZONE:
		detected = GAMEPAD
	elif event is InputEventKey:
		detected = KEYBOARD
	# Mouse events are ignored: on Android they are emulated from touches.
	if detected != "" and detected != device:
		device = detected
		_refresh()
		device_changed.emit(device)


func _notification(what: int) -> void:
	# Android back button/gesture acts as B in menus instead of quitting the app.
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_tap("ui_cancel")


func _on_joy_connection_changed(_device_id: int, connected: bool) -> void:
	if connected:
		device = GAMEPAD
	elif Input.get_connected_joypads().is_empty() and DisplayServer.is_touchscreen_available():
		device = TOUCH
	_refresh()
	device_changed.emit(device)


func _refresh() -> void:
	overlay.set_shown(_overlay_wanted and device == TOUCH)


func _tap(action: String) -> void:
	for pressed in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)
