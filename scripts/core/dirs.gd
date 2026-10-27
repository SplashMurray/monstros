class_name Dirs
extends RefCounted
## Converts between direction names used in data files and grid vectors.

const BY_NAME := { "up": Vector2i.UP, "down": Vector2i.DOWN, "left": Vector2i.LEFT, "right": Vector2i.RIGHT }


static func from_name(direction: String) -> Vector2i:
	return BY_NAME.get(direction, Vector2i.DOWN)


static func to_name(direction: Vector2i) -> String:
	for key in BY_NAME:
		if BY_NAME[key] == direction:
			return key
	return "down"


static func cell(value: Array) -> Vector2i:
	return Vector2i(int(value[0]), int(value[1]))
