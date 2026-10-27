class_name Dex
extends RefCounted
## Static access to all game data loaded from res://data/*.json.
## Call Dex.ensure_loaded() once before use (the Game autoload does this).

const DATA_DIR := "res://data/"
const CATEGORIES := ["physical", "special", "status"]

static var types: Dictionary = {}        # type id -> { name, color }
static var type_chart: Dictionary = {}   # attacking type id -> { defending type id: multiplier }
static var moves: Dictionary = {}
static var species: Dictionary = {}
static var temperaments: Dictionary = {}
static var encounters: Dictionary = {}
static var _loaded := false


static func ensure_loaded() -> void:
	if _loaded:
		return
	var type_data: Dictionary = _load_json("types.json")
	types = type_data.get("types", {})
	type_chart = type_data.get("chart", {})
	moves = _load_json("moves.json")
	species = _load_json("species.json")
	temperaments = _load_json("temperaments.json")
	encounters = _load_json("encounters.json")
	_loaded = true


static func move(id: String) -> Dictionary:
	ensure_loaded()
	assert(moves.has(id), "Unknown move: %s" % id)
	return moves[id]


static func species_data(id: String) -> Dictionary:
	ensure_loaded()
	assert(species.has(id), "Unknown species: %s" % id)
	return species[id]


static func type_name(id: String) -> String:
	return types.get(id, {}).get("name", "???")


static func type_color(id: String) -> Color:
	return Color(types.get(id, {}).get("color", "#808080"))


## Combined multiplier of an attacking type against one or two defending types.
## An empty attack type ("typeless") always deals neutral damage.
static func effectiveness(attack_type: String, defender_types: Array) -> float:
	ensure_loaded()
	if attack_type == "":
		return 1.0
	var row: Dictionary = type_chart.get(attack_type, {})
	var multiplier := 1.0
	for defender_type in defender_types:
		multiplier *= float(row.get(defender_type, 1.0))
	return multiplier


static func _load_json(file: String) -> Variant:
	var path := DATA_DIR + file
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		push_error("Could not read %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		push_error("Invalid JSON in %s" % path)
		return {}
	return parsed
