class_name Monster
extends RefCounted
## One individual monster: its species, level, hidden potential (IVs),
## training (EVs), temperament, moves and current condition.

const MAX_LEVEL := 100
const MAX_MOVES := 4
const MAX_EV_PER_STAT := 252
const MAX_EV_TOTAL := 510

var species_id := ""
var nickname := ""
var level := 1
var experience := 0
var temperament := "steady"
var ivs := {}
var evs := {}
var stats := {}
var hp := 0
var status := ""   # "", "burn", "poison", "paralysis", "sleep", "freeze"
var sleep_turns := 0
var moves: Array = []   # [{ "id": String, "pp": int }]


static func create(p_species: String, p_level: int, rng: RandomNumberGenerator = null) -> Monster:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var m := Monster.new()
	m.species_id = p_species
	m.level = clampi(p_level, 1, MAX_LEVEL)
	m.experience = Growth.exp_for_level(m.growth_rate(), m.level)
	for key in Stats.KEYS:
		m.ivs[key] = rng.randi_range(0, Stats.MAX_IV)
		m.evs[key] = 0
	var temperament_ids := Dex.temperaments.keys()
	m.temperament = temperament_ids[rng.randi() % temperament_ids.size()]
	m.recalculate_stats()
	m.hp = m.stats["hp"]
	m._learn_default_moves()
	return m


func species() -> Dictionary:
	return Dex.species_data(species_id)


func display_name() -> String:
	return nickname if nickname != "" else species()["name"]


func types() -> Array:
	return species()["types"]


func growth_rate() -> String:
	return species().get("growth", "medium_fast")


func max_hp() -> int:
	return stats["hp"]


func is_fainted() -> bool:
	return hp <= 0


func recalculate_stats() -> void:
	var old_max: int = stats.get("hp", 0)
	stats = Stats.calc_all(species()["base_stats"], ivs, evs, level, temperament)
	# Levelling up adds the HP gained to current HP, as in the originals.
	if old_max > 0 and hp > 0:
		hp = clampi(hp + stats["hp"] - old_max, 1, stats["hp"])


func knows(move_id: String) -> bool:
	for slot in moves:
		if slot["id"] == move_id:
			return true
	return false


func has_usable_moves() -> bool:
	for slot in moves:
		if slot["pp"] > 0:
			return true
	return false


## Adds a move if there is a free slot. Returns false if it was not learned.
func learn_move(move_id: String) -> bool:
	if knows(move_id) or moves.size() >= MAX_MOVES:
		return false
	moves.append({ "id": move_id, "pp": int(Dex.move(move_id)["pp"]) })
	return true


func moves_learned_at(p_level: int) -> Array:
	var result := []
	for entry in species().get("learnset", []):
		if int(entry[0]) == p_level:
			result.append(entry[1])
	return result


func exp_to_next_level() -> int:
	if level >= MAX_LEVEL:
		return 0
	return Growth.exp_for_level(growth_rate(), level + 1) - experience


## Adds experience and handles level-ups. Returns messages describing what happened.
func gain_experience(amount: int) -> Array:
	var messages := []
	if level >= MAX_LEVEL or amount <= 0:
		return messages
	experience += amount
	while level < MAX_LEVEL and experience >= Growth.exp_for_level(growth_rate(), level + 1):
		level += 1
		recalculate_stats()
		messages.append("%s grew to Lv. %d!" % [display_name(), level])
		for move_id in moves_learned_at(level):
			var move_name: String = Dex.move(move_id)["name"]
			if learn_move(move_id):
				messages.append("%s learned %s!" % [display_name(), move_name])
			elif not knows(move_id):
				# TODO: let the player choose a move to forget.
				messages.append("%s tried to learn %s, but already knows %d moves." % [display_name(), move_name, MAX_MOVES])
	return messages


func add_evs(ev_yield: Dictionary) -> void:
	var total := 0
	for key in evs:
		total += int(evs[key])
	for key in ev_yield:
		var room := mini(MAX_EV_PER_STAT - int(evs.get(key, 0)), MAX_EV_TOTAL - total)
		var gained := clampi(int(ev_yield[key]), 0, maxi(room, 0))
		evs[key] = int(evs.get(key, 0)) + gained
		total += gained
	recalculate_stats()


func heal() -> void:
	hp = stats["hp"]
	status = ""
	sleep_turns = 0
	for slot in moves:
		slot["pp"] = int(Dex.move(slot["id"])["pp"])


## Species this monster is ready to evolve into, or "" if none.
func evolution_target() -> String:
	for evo in species().get("evolutions", []):
		if evo.get("method", "level") == "level" and level >= int(evo["level"]):
			return evo["into"]
	return ""


func evolve(into: String) -> void:
	species_id = into
	recalculate_stats()


func _learn_default_moves() -> void:
	# Like wild monsters in the originals: the most recent moves up to this level.
	var learnable := []
	for entry in species().get("learnset", []):
		if int(entry[0]) <= level and not learnable.has(entry[1]):
			learnable.append(entry[1])
	for move_id in learnable.slice(maxi(learnable.size() - MAX_MOVES, 0)):
		learn_move(move_id)
