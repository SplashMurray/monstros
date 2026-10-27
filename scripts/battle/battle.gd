class_name Battle
extends RefCounted
## Turn-based single battle engine. Pure logic: it never touches nodes.
## Each call returns a list of event dictionaries for the UI to play back:
##   { type: "message", text }
##   { type: "hp", side, hp, max }
##   { type: "refresh", side, name, level, hp, max, types, status }
##   { type: "shake", count }
##   { type: "request_switch" }    player must pick a replacement
##   { type: "end", result }       "win", "lose", "ran" or "caught"

const PLAYER := 0
const ENEMY := 1
const STRUGGLE_MOVE := "thrash_about"
const STATUS_IMMUNITY := {
	"burn": ["flame"], "poison": ["toxic", "metal"], "paralysis": ["volt"], "freeze": ["frost"],
}
const STATUS_INFLICTED := {
	"burn": "%s was burned!", "poison": "%s was poisoned!", "paralysis": "%s is paralysed! It may be unable to move!",
	"sleep": "%s fell asleep!", "freeze": "%s was frozen solid!",
}
const CATCH_FAIL_MESSAGES := ["It burst free immediately!", "It wriggled out!", "Argh! Almost!", "So close! It broke free!"]

var parties: Array = [[], []]
var active: Array[int] = [0, 0]
var stages: Array = [{}, {}]
var is_wild := true
var trainer_name := ""   # e.g. "Schoolkid Ada"; empty for wild battles
var rng: RandomNumberGenerator
var run_attempts := 0
var over := false
var result := ""
var awaiting_switch := false
var caught: Monster = null
var _events: Array = []
var _fainted_this_turn := false


func _init(player_party: Array, enemy_party: Array, wild: bool = true, random: RandomNumberGenerator = null) -> void:
	parties = [player_party, enemy_party]
	is_wild = wild
	rng = random if random != null else RandomNumberGenerator.new()
	active[PLAYER] = _first_usable(PLAYER)
	active[ENEMY] = _first_usable(ENEMY)
	stages = [_fresh_stages(), _fresh_stages()]


func mon(side: int) -> Monster:
	return parties[side][active[side]]


func label(side: int) -> String:
	if side == ENEMY:
		return ("Wild " if is_wild else "Foe ") + mon(side).display_name()
	return mon(side).display_name()


func start() -> Array:
	_events = []
	_snapshot(ENEMY)
	if is_wild:
		_msg("A wild %s leapt out!" % mon(ENEMY).display_name())
	else:
		_msg("%s wants to battle!" % _opponent())
		_msg("%s sent out %s!" % [_opponent(), mon(ENEMY).display_name()])
	_snapshot(PLAYER)
	_msg("Go, %s!" % mon(PLAYER).display_name())
	return _events


## action: { type: "move", index } | { type: "switch", index } | { type: "catch", ball_bonus } | { type: "run" }
## A move index of -1 (or a party with no PP left) uses the fallback struggle move.
func take_turn(action: Dictionary) -> Array:
	_events = []
	_fainted_this_turn = false
	if over:
		return _events

	if awaiting_switch:
		# Replacing a fainted monster is free; the foe does not act.
		if action.get("type") == "switch" and _can_switch_to(int(action["index"])):
			awaiting_switch = false
			_switch(PLAYER, int(action["index"]))
		return _events

	match action.get("type", "move"):
		"run":
			if _try_run():
				return _events
			_use_move(ENEMY, _ai_choose_move())
		"catch":
			if _try_catch(float(action.get("ball_bonus", 1.0))):
				return _events
			_use_move(ENEMY, _ai_choose_move())
		"switch":
			_switch(PLAYER, int(action["index"]))
			_use_move(ENEMY, _ai_choose_move())
		_:
			var player_slot := int(action.get("index", 0))
			var enemy_slot := _ai_choose_move()
			for entry in _turn_order(player_slot, enemy_slot):
				if over or awaiting_switch or _fainted_this_turn:
					break
				_use_move(entry[0], entry[1])

	if not over and not awaiting_switch:
		_end_of_turn()
	return _events


# --- Turn structure -------------------------------------------------------

func _turn_order(player_slot: int, enemy_slot: int) -> Array:
	var player_first: bool
	var player_priority := int(Dex.move(_resolve_move_id(PLAYER, player_slot)).get("priority", 0))
	var enemy_priority := int(Dex.move(_resolve_move_id(ENEMY, enemy_slot)).get("priority", 0))
	if player_priority != enemy_priority:
		player_first = player_priority > enemy_priority
	else:
		var player_speed := effective_speed(PLAYER)
		var enemy_speed := effective_speed(ENEMY)
		player_first = player_speed > enemy_speed or (player_speed == enemy_speed and rng.randi_range(0, 1) == 0)
	if player_first:
		return [[PLAYER, player_slot], [ENEMY, enemy_slot]]
	return [[ENEMY, enemy_slot], [PLAYER, player_slot]]


func effective_speed(side: int) -> float:
	var m := mon(side)
	var speed: float = m.stats["spe"] * Stats.stage_multiplier(stages[side]["spe"])
	if m.status == "paralysis":
		speed *= 0.5
	return speed


func _end_of_turn() -> void:
	for side in [PLAYER, ENEMY]:
		var m := mon(side)
		if m.is_fainted():
			continue
		if m.status == "burn":
			_msg("%s is hurt by its burn!" % label(side))
			_damage(side, maxi(1, floori(m.max_hp() / 16.0)))
		elif m.status == "poison":
			_msg("%s is hurt by poison!" % label(side))
			_damage(side, maxi(1, floori(m.max_hp() / 8.0)))
		_check_faints()
		if over or awaiting_switch:
			return


# --- Moves ----------------------------------------------------------------

func _resolve_move_id(side: int, slot: int) -> String:
	var m := mon(side)
	if slot < 0 or slot >= m.moves.size() or m.moves[slot]["pp"] <= 0:
		return STRUGGLE_MOVE
	return m.moves[slot]["id"]


func _ai_choose_move() -> int:
	var usable := []
	var m := mon(ENEMY)
	for i in m.moves.size():
		if m.moves[i]["pp"] > 0:
			usable.append(i)
	if usable.is_empty():
		return -1
	if is_wild:
		return usable[rng.randi_range(0, usable.size() - 1)]   # wild monsters act on instinct
	# Trainers favour the move with the best expected damage, with a little randomness.
	var best := usable[0] as int
	var best_score := -1.0
	for i in usable:
		var score := move_score(m, mon(PLAYER), Dex.move(m.moves[i]["id"])) * rng.randf_range(0.85, 1.15)
		if score > best_score:
			best_score = score
			best = i
	return best


## Rough value of using a move against a target, for the trainer AI.
static func move_score(user: Monster, target: Monster, move: Dictionary) -> float:
	if move["category"] == "status":
		return 20.0
	var score := float(move.get("power", 0)) * Dex.effectiveness(move.get("type", ""), target.types())
	if user.types().has(move.get("type", "")):
		score *= DamageCalc.STAB
	var attack_key := "atk" if move["category"] == "physical" else "spa"
	score *= user.stats[attack_key] / 50.0
	var accuracy := float(move.get("accuracy", 0))
	return score * (accuracy / 100.0 if accuracy > 0.0 else 1.0)


func _use_move(side: int, slot: int) -> void:
	var user := mon(side)
	var target_side := 1 - side
	var target := mon(target_side)
	if user.is_fainted() or not _can_act(side):
		return

	var move_id := _resolve_move_id(side, slot)
	if move_id == STRUGGLE_MOVE:
		_msg("%s has no moves left!" % label(side))
	else:
		user.moves[slot]["pp"] -= 1
	var move := Dex.move(move_id)
	_msg("%s used %s!" % [label(side), move["name"]])

	if not _hits(side, move):
		_msg("%s's attack missed!" % label(side))
		return

	if move["category"] == "status":
		for effect in move.get("effects", []):
			_apply_effect(side, effect, true)
		return

	var hit := DamageCalc.compute(user, stages[side], target, stages[target_side], move, rng)
	if hit["effectiveness"] == 0.0:
		_msg("It has no effect on %s..." % label(target_side))
		return
	var dealt := mini(hit["damage"], target.hp)
	_damage(target_side, hit["damage"])
	if hit["crit"]:
		_msg("A critical strike!")
	if hit["effectiveness"] > 1.0:
		_msg("It's very effective!")
	elif hit["effectiveness"] < 1.0:
		_msg("It's barely effective...")

	if move.has("drain") and dealt > 0 and not user.is_fainted():
		_heal(side, maxi(1, floori(dealt * float(move["drain"]))))
		_msg("%s had its energy drained!" % label(target_side))
	if move.has("recoil_max_hp"):
		_msg("%s is damaged by recoil!" % label(side))
		_damage(side, maxi(1, floori(user.max_hp() * float(move["recoil_max_hp"]))))

	for effect in move.get("effects", []):
		var effect_target := side if effect.get("target", "target") == "self" else target_side
		if not mon(effect_target).is_fainted():
			_apply_effect(side, effect, false)
	_check_faints()


func _hits(side: int, move: Dictionary) -> bool:
	var accuracy := float(move.get("accuracy", 0))
	if accuracy <= 0.0:
		return true   # 0 means the move never misses
	var stage := clampi(stages[side]["acc"] - stages[1 - side]["eva"], -6, 6)
	return rng.randf() * 100.0 < accuracy * Stats.accuracy_stage_multiplier(stage)


## Pre-move status checks. Returns false if the monster loses its turn.
func _can_act(side: int) -> bool:
	var m := mon(side)
	match m.status:
		"sleep":
			m.sleep_turns -= 1
			if m.sleep_turns > 0:
				_msg("%s is fast asleep." % label(side))
				return false
			m.status = ""
			_msg("%s woke up!" % label(side))
			_snapshot(side)
		"freeze":
			if rng.randf() < 0.2:
				m.status = ""
				_msg("%s thawed out!" % label(side))
				_snapshot(side)
			else:
				_msg("%s is frozen solid!" % label(side))
				return false
		"paralysis":
			if rng.randf() < 0.25:
				_msg("%s is paralysed! It can't move!" % label(side))
				return false
	return true


func _apply_effect(user_side: int, effect: Dictionary, from_status_move: bool) -> void:
	if rng.randi_range(1, 100) > int(effect.get("chance", 100)):
		return
	var target_side := user_side if effect.get("target", "target") == "self" else 1 - user_side
	match effect.get("kind", ""):
		"stat":
			_change_stage(target_side, effect["stat"], int(effect["stages"]))
		"status":
			_inflict(target_side, effect["status"], from_status_move)


func _change_stage(side: int, stat: String, amount: int) -> void:
	var current: int = stages[side][stat]
	var updated := clampi(current + amount, -6, 6)
	var stat_name: String = Stats.NAMES.get(stat, stat)
	if updated == current:
		_msg("%s's %s won't go any %s!" % [label(side), stat_name, "higher" if amount > 0 else "lower"])
		return
	stages[side][stat] = updated
	var size := absi(amount)
	if amount > 0:
		_msg("%s's %s %s!" % [label(side), stat_name, "rose" if size == 1 else "rose sharply"])
	else:
		_msg("%s's %s %s!" % [label(side), stat_name, "fell" if size == 1 else "fell harshly"])


func _inflict(side: int, status: String, announce_failure: bool) -> bool:
	var m := mon(side)
	var immune := false
	for t in STATUS_IMMUNITY.get(status, []):
		if m.types().has(t):
			immune = true
	if m.status != "" or immune:
		if announce_failure:
			_msg("But it failed!")
		return false
	m.status = status
	if status == "sleep":
		m.sleep_turns = rng.randi_range(1, 3)
	_msg(STATUS_INFLICTED[status] % label(side))
	_snapshot(side)
	return true


# --- HP, fainting, experience ---------------------------------------------

func _damage(side: int, amount: int) -> void:
	var m := mon(side)
	m.hp = maxi(0, m.hp - amount)
	_events.append({ "type": "hp", "side": side, "hp": m.hp, "max": m.max_hp() })


func _heal(side: int, amount: int) -> void:
	var m := mon(side)
	m.hp = mini(m.max_hp(), m.hp + amount)
	_events.append({ "type": "hp", "side": side, "hp": m.hp, "max": m.max_hp() })


func _check_faints() -> void:
	if over:
		return
	if mon(ENEMY).is_fainted():
		_fainted_this_turn = true
		_msg("%s fainted!" % label(ENEMY))
		_award_experience(mon(ENEMY))
		var next := _first_usable(ENEMY)
		if next == -1:
			_msg("You won the battle!")
			_finish("win")
			return
		active[ENEMY] = next
		stages[ENEMY] = _fresh_stages()
		_snapshot(ENEMY)
		_msg("%s sent out %s!" % [_opponent(), mon(ENEMY).display_name()])
	if mon(PLAYER).is_fainted() and not awaiting_switch:
		_fainted_this_turn = true
		_msg("%s fainted!" % label(PLAYER))
		if _first_usable(PLAYER) == -1:
			_msg("You have no monsters left that can fight...")
			_finish("lose")
			return
		awaiting_switch = true
		_events.append({ "type": "request_switch" })


func _award_experience(defeated: Monster) -> void:
	var winner := mon(PLAYER)
	if winner.is_fainted():
		return
	var amount := floori(int(defeated.species()["base_exp"]) * defeated.level / 7.0 * (1.0 if is_wild else 1.5))
	amount = maxi(amount, 1)
	winner.add_evs(defeated.species().get("ev_yield", {}))
	if winner.level < Monster.MAX_LEVEL:
		_msg("%s gained %d Exp. Points!" % [winner.display_name(), amount])
	for line in winner.gain_experience(amount):
		_msg(line)
	_snapshot(PLAYER)


# --- Running, catching, switching -----------------------------------------

func _try_run() -> bool:
	if not is_wild:
		_msg("You can't run from a trainer battle!")
		return false
	run_attempts += 1
	var player_speed := mon(PLAYER).stats["spe"] as int
	var enemy_speed := maxi(1, floori(mon(ENEMY).stats["spe"] / 4.0) % 256)
	var odds := floori(player_speed * 32.0 / enemy_speed) + 30 * run_attempts
	if player_speed >= mon(ENEMY).stats["spe"] or odds > 255 or rng.randi_range(0, 255) < odds:
		_msg("You got away safely!")
		_finish("ran")
		return true
	_msg("Couldn't get away!")
	return false


func _try_catch(ball_bonus: float) -> bool:
	_msg("You threw a capture orb!")
	if not is_wild:
		_msg("The trainer knocked the orb away! Don't be a thief!")
		return false
	var shakes := Capture.shake_count(Capture.catch_value(mon(ENEMY), ball_bonus), rng)
	_events.append({ "type": "shake", "count": mini(shakes, 3) })
	if shakes >= 4:
		caught = mon(ENEMY)
		_msg("Got it! %s was captured!" % caught.display_name())
		_finish("caught")
		return true
	_msg(CATCH_FAIL_MESSAGES[shakes])
	return false


func _can_switch_to(index: int) -> bool:
	return index >= 0 and index < parties[PLAYER].size() and index != active[PLAYER] \
		and not parties[PLAYER][index].is_fainted()


func _switch(side: int, index: int) -> void:
	if not mon(side).is_fainted():
		_msg("Come back, %s!" % mon(side).display_name())
	active[side] = index
	stages[side] = _fresh_stages()
	_snapshot(side)
	_msg("Go, %s!" % mon(side).display_name())


# --- Helpers ---------------------------------------------------------------

func _first_usable(side: int) -> int:
	for i in parties[side].size():
		if not parties[side][i].is_fainted():
			return i
	return -1


func _opponent() -> String:
	return trainer_name if trainer_name != "" else "Your opponent"


func _finish(outcome: String) -> void:
	over = true
	result = outcome
	_events.append({ "type": "end", "result": outcome })


func _msg(text: String) -> void:
	_events.append({ "type": "message", "text": text })


func _snapshot(side: int) -> void:
	var m := mon(side)
	_events.append({
		"type": "refresh", "side": side, "name": m.display_name(), "level": m.level,
		"hp": m.hp, "max": m.max_hp(), "types": m.types(), "status": m.status,
	})


static func _fresh_stages() -> Dictionary:
	return { "atk": 0, "def": 0, "spa": 0, "spd": 0, "spe": 0, "acc": 0, "eva": 0 }
