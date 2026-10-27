class_name ControlScheme
extends RefCounted
## The game's input map. Game code only ever reads these actions, so every control
## works the same from a keyboard, a gamepad (Backbone and other standard controllers
## use the Xbox layout: A bottom, B right) and the on-screen touch controls.
##
##   Action      Keyboard          Gamepad            On-screen
##   move_*      Arrows / WASD     D-pad / left stick D-pad
##   accept      Z / Enter / Space A                  A
##   cancel      X / Backspace / Esc  B               B
##   run (hold)  X / Shift         B                  B
##   menu        Tab               Start / Menu       (none yet)

const DEADZONE := 0.5

const KEYS := {
	"move_up": [KEY_UP, KEY_W],
	"move_down": [KEY_DOWN, KEY_S],
	"move_left": [KEY_LEFT, KEY_A],
	"move_right": [KEY_RIGHT, KEY_D],
	"accept": [KEY_Z, KEY_ENTER, KEY_SPACE],
	"cancel": [KEY_X, KEY_BACKSPACE, KEY_ESCAPE],
	"run": [KEY_X, KEY_SHIFT],
	"menu": [KEY_TAB],
	# Extra keys for Godot's built-in UI navigation actions.
	"ui_accept": [KEY_Z],
	"ui_cancel": [KEY_X, KEY_BACKSPACE],
}

const JOY_BUTTONS := {
	"move_up": [JOY_BUTTON_DPAD_UP],
	"move_down": [JOY_BUTTON_DPAD_DOWN],
	"move_left": [JOY_BUTTON_DPAD_LEFT],
	"move_right": [JOY_BUTTON_DPAD_RIGHT],
	"accept": [JOY_BUTTON_A],
	"cancel": [JOY_BUTTON_B],
	"run": [JOY_BUTTON_B],
	"menu": [JOY_BUTTON_START],
	"ui_up": [JOY_BUTTON_DPAD_UP],
	"ui_down": [JOY_BUTTON_DPAD_DOWN],
	"ui_left": [JOY_BUTTON_DPAD_LEFT],
	"ui_right": [JOY_BUTTON_DPAD_RIGHT],
	"ui_accept": [JOY_BUTTON_A],
	"ui_cancel": [JOY_BUTTON_B],
}

const JOY_AXES := {
	"move_up": [JOY_AXIS_LEFT_Y, -1.0],
	"move_down": [JOY_AXIS_LEFT_Y, 1.0],
	"move_left": [JOY_AXIS_LEFT_X, -1.0],
	"move_right": [JOY_AXIS_LEFT_X, 1.0],
	"ui_up": [JOY_AXIS_LEFT_Y, -1.0],
	"ui_down": [JOY_AXIS_LEFT_Y, 1.0],
	"ui_left": [JOY_AXIS_LEFT_X, -1.0],
	"ui_right": [JOY_AXIS_LEFT_X, 1.0],
}


## Registers all actions and bindings. Safe to call more than once.
static func apply() -> void:
	for action in KEYS:
		for keycode in KEYS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = keycode
			_bind(action, event)
	for action in JOY_BUTTONS:
		for button in JOY_BUTTONS[action]:
			var event := InputEventJoypadButton.new()
			event.button_index = button
			_bind(action, event)
	for action in JOY_AXES:
		var event := InputEventJoypadMotion.new()
		event.axis = JOY_AXES[action][0]
		event.axis_value = JOY_AXES[action][1]
		_bind(action, event)


static func _bind(action: String, event: InputEvent) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, DEADZONE)
	if not InputMap.action_has_event(action, event):
		InputMap.action_add_event(action, event)
