extends Node
## Autoload "Game": global state that survives scene changes (the player, their
## party, story flags and position in the world) plus saving and loading.

const SAVE_PATH := "user://save.json"
const SAVE_VERSION := 1
const TITLE_SCENE := "res://scenes/title/title_screen.tscn"
const OVERWORLD_SCENE := "res://scenes/overworld/overworld.tscn"
const BATTLE_SCENE := "res://scenes/battle/battle_scene.tscn"
const RIVAL_NAME := "Corin"
const DEFAULT_PLAYER_NAME := "Sam"
const START_MAP := "player_house"
const START_CELL := Vector2i(2, 2)
const START_RESPAWN := { "map": "player_house", "cell": [4, 5] }
const START_MONEY := 300
const MAX_PARTY := 6
const ENCOUNTER_ROLL := 180   # chance per grass step is rate / ENCOUNTER_ROLL

var player_name := DEFAULT_PLAYER_NAME
var money := START_MONEY
var flags := {}          # story flags: name -> true
var vars := {}           # strings available to dialogue as {name}
var party: Array[Monster] = []
var storage: Array[Monster] = []
var map_id := START_MAP
var player_cell := START_CELL
var player_facing := Vector2i.DOWN
var respawn: Dictionary = START_RESPAWN.duplicate(true)
var play_time := 0.0
var pending_battle: Dictionary = {}
var resume: Dictionary = {}   # event script to continue after a scripted battle
var autosave_allowed := false   # the overworld enables this when the game is in a safe state
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	Dex.ensure_loaded()
	rng.randomize()
	var ui_font := Art.font()
	if ui_font:
		ThemeDB.fallback_font = ui_font


func _process(delta: float) -> void:
	play_time += delta


func _notification(what: int) -> void:
	# Phones kill backgrounded apps without warning, so save whenever we lose focus.
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if autosave_allowed:
			save_game()


func new_game(p_name: String) -> void:
	player_name = p_name if p_name.strip_edges() != "" else DEFAULT_PLAYER_NAME
	money = START_MONEY
	flags = {}
	vars = {}
	party.clear()
	storage.clear()
	map_id = START_MAP
	player_cell = START_CELL
	player_facing = Vector2i.DOWN
	respawn = START_RESPAWN.duplicate(true)
	play_time = 0.0
	pending_battle = {}
	resume = {}


# --- Flags and text ------------------------------------------------------------

func has_flag(flag: String) -> bool:
	return flags.has(flag)


func set_flag(flag: String) -> void:
	flags[flag] = true


func clear_flag(flag: String) -> void:
	flags.erase(flag)


func badge_count() -> int:
	var count := 0
	for flag in flags:
		if flag.begins_with("badge_"):
			count += 1
	return count


## Replaces {player}, {rival} and any {var} in dialogue text.
func format_text(text: String) -> String:
	var values := { "player": player_name, "rival": RIVAL_NAME }
	values.merge(vars)
	return text.format(values)


# --- Party -----------------------------------------------------------------------

func heal_party() -> void:
	for m in party:
		m.heal()


func has_usable_monster() -> bool:
	for m in party:
		if not m.is_fainted():
			return true
	return false


func give_monster(species_id: String, level: int) -> String:
	var m := Monster.create(species_id, level, rng)
	if not vars.has("starter"):
		vars["starter"] = m.display_name()
	return format_text("{player} received %s!" % m.display_name()) + " " + receive_monster(m)


## Adds a monster to the party, or to storage if the party is full.
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


func set_respawn(p_map: String, cell: Vector2i) -> void:
	respawn = { "map": p_map, "cell": [cell.x, cell.y] }


# --- Battles -----------------------------------------------------------------------

## Rolls for a wild encounter using an encounter table. Starts the battle and returns true on success.
func roll_encounter(table_id: String) -> bool:
	var table: Dictionary = Dex.encounters.get(table_id, {})
	var slots: Array = table.get("grass", [])
	if slots.is_empty() or not has_usable_monster():
		return false
	if rng.randi_range(1, ENCOUNTER_ROLL) > int(table.get("rate", 0)):
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


func start_trainer_battle(trainer_id: String, can_lose: bool = false) -> void:
	var enemy := []
	for entry in Dex.trainer(trainer_id)["party"]:
		enemy.append(Monster.create(entry[0], int(entry[1]), rng))
	start_battle(enemy, false, { "trainer_id": trainer_id, "can_lose": can_lose })


func start_battle(enemy_party: Array, wild: bool, extra: Dictionary = {}) -> void:
	autosave_allowed = false
	pending_battle = { "enemy": enemy_party, "wild": wild, "terrain": Art.map_terrain(Dex.map_data(map_id)) }
	pending_battle.merge(extra)
	get_tree().change_scene_to_file.call_deferred(BATTLE_SCENE)


func trainer_display_name(trainer_id: String) -> String:
	var t := Dex.trainer(trainer_id)
	return format_text("%s %s" % [t["class"], t["name"]])


func trainer_speaker(trainer_id: String) -> String:
	return format_text(Dex.trainer(trainer_id)["name"])


## Called by the battle screen when a battle ends.
func end_battle(result: String) -> void:
	var trainer_id: String = pending_battle.get("trainer_id", "")
	var can_lose: bool = pending_battle.get("can_lose", false)
	pending_battle = {}
	if result == "win" and trainer_id != "":
		set_flag("defeated:" + trainer_id)
	if result == "lose":
		if can_lose:
			heal_party()
		else:
			_blackout()
	if not resume.is_empty():
		resume["result"] = result
	get_tree().change_scene_to_file.call_deferred(OVERWORLD_SCENE)


func blackout_penalty() -> int:
	return floori(money / 2.0)


func _blackout() -> void:
	money -= blackout_penalty()
	heal_party()
	resume = {}   # an interrupted story event starts over when talked to again
	map_id = respawn["map"]
	player_cell = Dirs.cell(respawn["cell"])
	player_facing = Vector2i.DOWN


# --- Saving ------------------------------------------------------------------------

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game() -> bool:
	var data := {
		"version": SAVE_VERSION, "player_name": player_name, "money": money, "flags": flags, "vars": vars,
		"party": party.map(func(m: Monster) -> Dictionary: return m.to_dict()),
		"storage": storage.map(func(m: Monster) -> Dictionary: return m.to_dict()),
		"map": map_id, "cell": [player_cell.x, player_cell.y], "facing": Dirs.to_name(player_facing),
		"respawn": respawn, "play_time": play_time,
	}
	# Write to a temporary file first so a crash mid-save can't corrupt the save.
	var tmp_path := SAVE_PATH + ".tmp"
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write save: %s" % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(data))
	file.close()
	return DirAccess.rename_absolute(tmp_path, SAVE_PATH) == OK


func load_game() -> bool:
	if not has_save():
		return false
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if not data is Dictionary:
		push_error("Save file is corrupt")
		return false
	new_game(data.get("player_name", DEFAULT_PLAYER_NAME))
	money = int(data.get("money", START_MONEY))
	flags = data.get("flags", {})
	vars = data.get("vars", {})
	for d in data.get("party", []):
		party.append(Monster.from_dict(d))
	for d in data.get("storage", []):
		storage.append(Monster.from_dict(d))
	map_id = data.get("map", START_MAP)
	if not Dex.maps.has(map_id):
		map_id = START_MAP
	player_cell = Dirs.cell(data.get("cell", [START_CELL.x, START_CELL.y]))
	player_facing = Dirs.from_name(data.get("facing", "down"))
	respawn = data.get("respawn", START_RESPAWN.duplicate(true))
	play_time = float(data.get("play_time", 0.0))
	return true
