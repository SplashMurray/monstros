extends Node2D
## Grid-based player movement, tuned to feel like the GBA games:
## tapping a direction turns on the spot, holding it walks, holding B runs.

signal stepped(cell: Vector2i)

const TILE := 16
const STEP_TIME := 0.25   # seconds per tile when walking
const RUN_STEP_TIME := 0.125
const TURN_DELAY := 0.09  # hold time before a turn becomes a step

var map: Node   # needs is_walkable(cell: Vector2i) -> bool
var cell := Vector2i.ZERO
var facing := Vector2i.DOWN
var frozen := false
var _moving := false
var _turn_wait := 0.0
var _was_walking := false
var _tween: Tween
var _step_count := 0
var _running := false


func place(p_cell: Vector2i, p_facing: Vector2i) -> void:
	if _tween:
		_tween.kill()   # cancel any step in progress so it can't overwrite the new position
	_moving = false
	cell = p_cell
	facing = p_facing
	position = Vector2(cell * TILE)
	queue_redraw()


func _process(delta: float) -> void:
	if _moving or frozen:
		return
	var dir := _read_direction()
	if dir == Vector2i.ZERO:
		_was_walking = false
		_turn_wait = 0.0
		return
	if dir != facing:
		facing = dir
		queue_redraw()
		if not _was_walking:
			_turn_wait = TURN_DELAY
			return
	if _turn_wait > 0.0:
		_turn_wait -= delta
		return
	var target := cell + dir
	if map.is_walkable(target):
		_step_to(target)
	else:
		_was_walking = false


func is_moving() -> bool:
	return _moving


func face(direction: Vector2i) -> void:
	facing = direction
	queue_redraw()


## Scripted single step (used by events). Turns even if the way is blocked.
func walk(direction: Vector2i) -> void:
	face(direction)
	if map.is_walkable(cell + direction):
		await _step_to(cell + direction)


func _step_to(target: Vector2i) -> void:
	_moving = true
	_was_walking = true
	_step_count += 1
	_running = Input.is_action_pressed("run")
	queue_redraw()
	_tween = create_tween()
	var step_time := RUN_STEP_TIME if _running else STEP_TIME
	_tween.tween_property(self, "position", Vector2(target * TILE), step_time)
	await _tween.finished
	cell = target
	_moving = false
	queue_redraw()
	stepped.emit(cell)


func _read_direction() -> Vector2i:
	if Input.is_action_pressed("move_up"):
		return Vector2i.UP
	if Input.is_action_pressed("move_down"):
		return Vector2i.DOWN
	if Input.is_action_pressed("move_left"):
		return Vector2i.LEFT
	if Input.is_action_pressed("move_right"):
		return Vector2i.RIGHT
	return Vector2i.ZERO


func _draw() -> void:
	var sheet: Texture2D = Art.character("player_run") if _moving and _running else null
	if sheet == null:
		sheet = Art.character("player")
	if sheet:
		Art.draw_character(self, sheet, facing, (1 + _step_count % 2) if _moving else 0)
		return
	# Placeholder sprite: a capped trainer with a dot showing which way they face.
	draw_rect(Rect2(3, 2, 10, 13), Color("#3050a0"))
	draw_rect(Rect2(3, 1, 10, 4), Color("#d03030"))
	var eye := Vector2(8, 8) + Vector2(facing) * 3.0
	draw_rect(Rect2(eye - Vector2(1.5, 1.5), Vector2(3, 3)), Color.WHITE)
