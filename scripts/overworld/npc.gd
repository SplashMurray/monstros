extends Node2D
## A person or object placed on a map. Blocks movement and can be talked to.
## Placeholder art: coloured figures, and capture orbs for objects with sprite "orb".

const TILE := 16
const STEP_TIME := 0.22

var data: Dictionary = {}
var id := ""
var cell := Vector2i.ZERO
var facing := Vector2i.DOWN
var _exclaiming := false


func setup(p_data: Dictionary) -> void:
	data = p_data
	id = data["id"]
	cell = Dirs.cell(data["cell"])
	facing = Dirs.from_name(data.get("facing", "down"))
	position = Vector2(cell * TILE)
	queue_redraw()


func is_person() -> bool:
	return data.get("sprite", "person") == "person"


func face(direction: Vector2i) -> void:
	if is_person():
		facing = direction
		queue_redraw()


func step(direction: Vector2i) -> void:
	face(direction)
	var tween := create_tween()
	tween.tween_property(self, "position", Vector2((cell + direction) * TILE), STEP_TIME)
	await tween.finished
	cell += direction


func exclaim() -> void:
	_exclaiming = true
	queue_redraw()
	await get_tree().create_timer(0.7).timeout
	_exclaiming = false
	queue_redraw()


func _draw() -> void:
	var color := Color(data.get("color", "#c08040"))
	if is_person():
		draw_rect(Rect2(3, 2, 10, 13), color)
		draw_rect(Rect2(4, 1, 8, 5), color.lightened(0.35))
		var eye := Vector2(8, 8) + Vector2(facing) * 3.0
		draw_rect(Rect2(eye - Vector2(1.5, 1.5), Vector2(3, 3)), Color.WHITE)
	else:
		# Capture orb: coloured top, white bottom, dark band.
		var c := Vector2(8, 7)
		draw_circle(c, 5.5, Color("#f4f4f4"))
		draw_arc(c, 2.75, PI, TAU, 12, color, 5.5)
		draw_line(c - Vector2(5.5, 0), c + Vector2(5.5, 0), Color("#303030"), 1.0)
		draw_circle(c, 1.5, Color("#303030"))
	if _exclaiming:
		draw_rect(Rect2(5, -12, 6, 10), Color.WHITE)
		draw_rect(Rect2(7, -11, 2, 5), Color("#d02020"))
		draw_rect(Rect2(7, -5, 2, 2), Color("#d02020"))
