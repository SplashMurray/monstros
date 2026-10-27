extends Node
## Autoload "Game": global state that survives scene changes —
## the player's party, storage and position in the world.

const OVERWORLD_SCENE := "res://scenes/overworld/overworld.tscn"
const BATTLE_SCENE := "res://scenes/battle/battle_scene.tscn"
const MAX_PARTY := 6
const RESPAWN_CELL := Vector2i(6, 12)
const ENCOUNTER_ROLL := 180   # chance per grass step is rate / ENCOUNTER_ROLL

var party: Array[Monster] = []
var storage: Array[Monster] = []
var player_cell := RESPAWN_CELL
var player_facing := Vector2i.DOWN
var pending_battle: Dictionary = {}
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	Dex.ensure_loaded()
	rng.randomize()
	if party.is_empty():
		# Placeholder until the starter-choice event exists.
		party.append(Monster.create("emberkit", 6, rng))


func heal_party() -> void:
	for m in party:
		m.heal()


## Rolls for a wild encounter on the given map. Starts the battle and returns true on success.
func roll_encounter(map_id: String) -> bool:
	var table: Dictionary = Dex.encounters.get(map_id, {})
	var slots: Array = table.get("grass", [])
	if slots.is_empty() or rng.randi_range(1, ENCOUNTER_ROLL) > int(table.get("rate", 0)):
		return false
	var total := 0
	for slot in slots:
		total += int(slot["weight"])
	var pick := rng.randi_range(1, total)
	for slot in slots:
		pick -= int(slot["weight"])
		if pick <= 0:
			var level := rng.randi_range(int(slot["min_level"]), int(slot["max_level"]))
			start_battle([Monster.create(slot["species"], level, rng)], true)
			return true
	return false


func start_battle(enemy_party: Array, wild: bool) -> void:
	pending_battle = { "enemy": enemy_party, "wild": wild }
	get_tree().change_scene_to_file.call_deferred(BATTLE_SCENE)


## Adds a newly caught monster to the party, or storage if the party is full.
func receive_monster(m: Monster) -> String:
	if party.size() < MAX_PARTY:
		party.append(m)
		return "%s joined your party!" % m.display_name()
	storage.append(m)
	return "%s was sent to storage." % m.display_name()


## Evolves any party members that qualify. Returns messages to show.
func process_evolutions() -> Array:
	var messages := []
	for m in party:
		if m.is_fainted():
			continue
		var into := m.evolution_target()
		if into != "":
			var old_name := m.display_name()
			m.evolve(into)
			messages.append("%s is changing..." % old_name)
			messages.append("%s became %s!" % [old_name, Dex.species_data(into)["name"]])
	return messages


func end_battle(result: String) -> void:
	pending_battle = {}
	if result == "lose":
		heal_party()
		player_cell = RESPAWN_CELL
		player_facing = Vector2i.DOWN
	get_tree().change_scene_to_file.call_deferred(OVERWORLD_SCENE)
