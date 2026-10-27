extends SceneTree
## Headless test runner. From the project root:
##   godot --headless --import            (first run only, builds the class cache)
##   godot --headless -s tests/run_tests.gd

var _checks := 0
var _failures := 0


func _initialize() -> void:
	Dex.ensure_loaded()
	var tests := [
		test_type_chart_is_well_formed, test_type_matchups, test_data_integrity,
		test_stat_formulas, test_temperaments, test_growth_curves,
		test_physical_special_split, test_damage_modifiers, test_capture_maths,
		test_level_up_and_moves, test_status_immunity, test_running, test_battle_simulation,
		test_control_scheme, test_touch_dpad_directions,
		test_trainers, test_maps_are_well_formed, test_map_scripts, test_maps_are_connected,
		test_monster_save_round_trip, test_trainer_ai,
	]
	for test in tests:
		test.call()
	print("\n%d checks, %d failures" % [_checks, _failures])
	quit(1 if _failures > 0 else 0)


func check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("FAIL: " + description)


func seeded(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func damage(attacker: Monster, defender: Monster, move: Dictionary, crit: int = 0) -> int:
	return DamageCalc.compute(attacker, Battle._fresh_stages(), defender, Battle._fresh_stages(), move, seeded(1), crit, 100)["damage"]


# --- Data ----------------------------------------------------------------------

func test_type_chart_is_well_formed() -> void:
	check(Dex.types.size() == 18, "there are 18 types")
	for attacker in Dex.type_chart:
		check(Dex.types.has(attacker), "chart attacker %s is a type" % attacker)
		for defender in Dex.type_chart[attacker]:
			check(Dex.types.has(defender), "chart defender %s is a type" % defender)
			check(float(Dex.type_chart[attacker][defender]) in [0.0, 0.5, 2.0], "%s->%s uses 0, 0.5 or 2" % [attacker, defender])


func test_type_matchups() -> void:
	check(Dex.effectiveness("flame", ["flora"]) == 2.0, "flame beats flora")
	check(Dex.effectiveness("water", ["flame"]) == 2.0, "water beats flame")
	check(Dex.effectiveness("flora", ["water"]) == 2.0, "flora beats water")
	check(Dex.effectiveness("volt", ["earth"]) == 0.0, "earth is immune to volt")
	check(Dex.effectiveness("common", ["spirit"]) == 0.0, "spirit is immune to common")
	check(Dex.effectiveness("wyrm", ["fae"]) == 0.0, "fae is immune to wyrm")
	check(Dex.effectiveness("toxic", ["metal"]) == 0.0, "metal is immune to toxic")
	check(Dex.effectiveness("frost", ["earth", "wind"]) == 4.0, "dual weakness multiplies to 4x")
	check(Dex.effectiveness("flame", ["water", "wyrm"]) == 0.25, "dual resistance multiplies to 0.25x")
	check(Dex.effectiveness("", ["spirit"]) == 1.0, "typeless moves are always neutral")


func test_data_integrity() -> void:
	for id in Dex.moves:
		var m: Dictionary = Dex.moves[id]
		check(m["category"] in Dex.CATEGORIES, "move %s has a valid category" % id)
		check(m["type"] == "" or Dex.types.has(m["type"]), "move %s has a valid type" % id)
		for effect in m.get("effects", []):
			check(effect["kind"] in ["stat", "status"], "move %s effect kind is known" % id)
			if effect["kind"] == "status":
				check(Battle.STATUS_INFLICTED.has(effect["status"]), "move %s status is known" % id)
	for id in Dex.species:
		var s: Dictionary = Dex.species[id]
		for t in s["types"]:
			check(Dex.types.has(t), "species %s type %s exists" % [id, t])
		for key in Stats.KEYS:
			check(s["base_stats"].has(key), "species %s has base %s" % [id, key])
		for entry in s["learnset"]:
			check(Dex.moves.has(entry[1]), "species %s learns existing move %s" % [id, entry[1]])
		for evo in s.get("evolutions", []):
			check(Dex.species.has(evo["into"]), "species %s evolves into existing %s" % [id, evo["into"]])
	for map_id in Dex.encounters:
		for slot in Dex.encounters[map_id]["grass"]:
			check(Dex.species.has(slot["species"]), "encounter on %s uses existing %s" % [map_id, slot["species"]])


# --- Stats -----------------------------------------------------------------------

func test_stat_formulas() -> void:
	check(Stats.calc_hp(100, 31, 252, 100) == 404, "max HP for base 100 is 404")
	check(Stats.calc_stat(100, 31, 252, 100) == 299, "max neutral stat for base 100 is 299")
	check(Stats.calc_stat(100, 31, 252, 100, 11) == 328, "boosted stat for base 100 is 328")
	check(Stats.calc_stat(100, 31, 252, 100, 9) == 269, "hindered stat for base 100 is 269")
	check(Stats.calc_hp(1, 0, 0, 1) == 11, "minimum HP at level 1")
	check(Stats.stage_multiplier(2) == 2.0 and Stats.stage_multiplier(-6) == 0.25, "stat stage multipliers")


func test_temperaments() -> void:
	check(Dex.temperaments.size() == 25, "there are 25 temperaments")
	var seen := {}
	for id in Dex.temperaments:
		var t: Dictionary = Dex.temperaments[id]
		var key: String = t["up"] + ">" + t["down"]
		check(not seen.has(key), "temperament %s is unique" % id)
		seen[key] = true


func test_growth_curves() -> void:
	check(Growth.exp_for_level("fast", 100) == 800000, "fast curve")
	check(Growth.exp_for_level("medium_fast", 100) == 1000000, "medium-fast curve")
	check(Growth.exp_for_level("medium_slow", 100) == 1059860, "medium-slow curve")
	check(Growth.exp_for_level("slow", 100) == 1250000, "slow curve")
	for rate in ["fast", "medium_fast", "medium_slow", "slow"]:
		for n in range(2, 101):
			check(Growth.exp_for_level(rate, n) > Growth.exp_for_level(rate, n - 1), "%s increases at %d" % [rate, n])


# --- Damage -------------------------------------------------------------------

func test_physical_special_split() -> void:
	var attacker := Monster.create("nibbet", 50, seeded(1))
	var defender := Monster.create("nibbet", 50, seeded(2))
	var physical := { "type": "common", "category": "physical", "power": 60 }
	var special := { "type": "common", "category": "special", "power": 60 }
	attacker.stats["atk"] = 200
	attacker.stats["spa"] = 50
	check(damage(attacker, defender, physical) > damage(attacker, defender, special) * 2, "physical move uses Attack")
	attacker.stats["atk"] = 50
	attacker.stats["spa"] = 200
	check(damage(attacker, defender, special) > damage(attacker, defender, physical) * 2, "special move uses Sp. Atk")
	attacker.stats["atk"] = 100
	attacker.stats["spa"] = 100
	defender.stats["def"] = 300
	defender.stats["spd"] = 50
	check(damage(attacker, defender, special) > damage(attacker, defender, physical) * 2, "special move hits Sp. Def, physical hits Defence")
	# The type of a move no longer decides its category (the pre-Gen 4 rule).
	check(Dex.move("flare_lash")["category"] == "physical" and Dex.move("cinder_spit")["category"] == "special",
		"one type can have both physical and special moves")


func test_damage_modifiers() -> void:
	var emberkit := Monster.create("emberkit", 20, seeded(3))
	var nibbet := Monster.create("nibbet", 20, seeded(4))
	var fernling := Monster.create("fernling", 20, seeded(5))
	var flame_hit := { "type": "flame", "category": "physical", "power": 60 }
	var water_hit := { "type": "water", "category": "physical", "power": 60 }
	var common_hit := { "type": "common", "category": "physical", "power": 60 }
	fernling.stats = nibbet.stats.duplicate()
	check(damage(emberkit, nibbet, flame_hit) > damage(emberkit, nibbet, water_hit), "STAB boosts damage")
	check(damage(emberkit, fernling, flame_hit) > damage(emberkit, nibbet, flame_hit) * 1.5, "super-effective hits harder")
	check(damage(emberkit, nibbet, common_hit, 1) > damage(emberkit, nibbet, common_hit, 0), "critical hits deal more damage")
	var normal := damage(emberkit, nibbet, common_hit)
	emberkit.status = "burn"
	check(damage(emberkit, nibbet, common_hit) < normal, "burn weakens physical moves")
	var special_hit := { "type": "common", "category": "special", "power": 60 }
	var burned_special := damage(emberkit, nibbet, special_hit)
	emberkit.status = ""
	check(burned_special == damage(emberkit, nibbet, special_hit), "burn does not weaken special moves")
	var ghost_proof := Monster.create("pipwing", 20, seeded(6))
	check(damage(emberkit, ghost_proof, { "type": "earth", "category": "physical", "power": 60 }) == 0, "immunity deals no damage")


# --- Catching, levelling, status ------------------------------------------

func test_capture_maths() -> void:
	var wild := Monster.create("grubble", 5, seeded(7))
	var full_hp := Capture.catch_value(wild)
	wild.hp = 1
	var low_hp := Capture.catch_value(wild)
	check(low_hp > full_hp, "lower HP is easier to catch")
	wild.status = "sleep"
	check(Capture.catch_value(wild) > low_hp, "sleep makes catching easier")
	check(Capture.shake_count(255.0, seeded(1)) == 4, "a value of 255 always catches")
	var starter := Monster.create("fernling", 5, seeded(8))
	check(Capture.catch_value(starter) < full_hp, "rare species are harder to catch")


func test_level_up_and_moves() -> void:
	var m := Monster.create("emberkit", 4, seeded(9))
	check(m.knows("shove") and m.knows("bristle"), "starts with level-1 moves")
	check(not m.knows("cinder_spit"), "does not know moves above its level")
	var old_max := m.max_hp()
	var messages := m.gain_experience(Growth.exp_for_level(m.growth_rate(), 5) - m.experience)
	check(m.level == 5, "levels up with enough experience")
	check(m.knows("cinder_spit"), "learns a move on level up")
	check(m.max_hp() >= old_max and messages.size() >= 2, "level-up raises HP and reports it")
	var high := Monster.create("nibbet", 30, seeded(10))
	check(high.moves.size() == Monster.MAX_MOVES, "wild monsters fill four move slots")
	check(high.knows("headlong"), "wild monsters know their most recent moves")
	var evolver := Monster.create("ripplet", 16, seeded(11))
	check(evolver.evolution_target() == "tidalisk", "ready to evolve at level 16")


func test_status_immunity() -> void:
	var battle := Battle.new([Monster.create("emberkit", 10, seeded(1))], [Monster.create("grubble", 10, seeded(2))], true, seeded(3))
	check(not battle._inflict(Battle.PLAYER, "burn", false), "flame types cannot be burned")
	check(battle._inflict(Battle.ENEMY, "burn", false), "other types can be burned")
	check(not battle._inflict(Battle.ENEMY, "poison", false), "a monster can only have one status")


func test_running() -> void:
	var fast := Monster.create("nibbet", 50, seeded(1))
	var battle := Battle.new([fast], [Monster.create("grubble", 2, seeded(2))], true, seeded(3))
	battle.take_turn({ "type": "run" })
	check(battle.over and battle.result == "ran", "a faster monster always escapes")
	var trainer := Battle.new([fast], [Monster.create("grubble", 2, seeded(2))], false, seeded(3))
	trainer.take_turn({ "type": "run" })
	check(not trainer.over, "you cannot run from trainers")


func test_battle_simulation() -> void:
	# Many full battles with random seeds must always end cleanly.
	for seed_value in 50:
		var rng := seeded(seed_value)
		var party := [Monster.create("emberkit", 8, rng), Monster.create("ripplet", 6, rng)]
		var enemies := [Monster.create("pipwing", rng.randi_range(4, 9), rng), Monster.create("grubble", 5, rng)]
		var battle := Battle.new(party, enemies, seed_value % 2 == 0, rng)
		battle.start()
		var turns := 0
		while not battle.over and turns < 300:
			turns += 1
			if battle.awaiting_switch:
				battle.take_turn({ "type": "switch", "index": battle._first_usable(Battle.PLAYER) })
			else:
				battle.take_turn({ "type": "move", "index": rng.randi_range(0, battle.mon(Battle.PLAYER).moves.size() - 1) })
		check(battle.over, "battle %d finishes" % seed_value)
		check(battle.result in ["win", "lose"], "battle %d ends in a win or loss" % seed_value)
		for m in party + enemies:
			check(m.hp >= 0 and m.hp <= m.max_hp(), "HP stays in range in battle %d" % seed_value)


# --- Input ---------------------------------------------------------------------

func test_control_scheme() -> void:
	ControlScheme.apply()
	ControlScheme.apply()   # idempotent
	for action in ["move_up", "move_down", "move_left", "move_right", "accept", "cancel", "run", "menu"]:
		check(InputMap.has_action(action), "action %s exists" % action)
	var has_joy_a := false
	for event in InputMap.action_get_events("accept"):
		if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_A:
			has_joy_a = true
	check(has_joy_a, "gamepad A confirms")
	var stick_and_dpad := 0
	for event in InputMap.action_get_events("move_left"):
		if event is InputEventJoypadMotion or event is InputEventJoypadButton:
			stick_and_dpad += 1
	check(stick_and_dpad == 2, "moving works with both the d-pad and the left stick")
	var keyboard_events := 0
	for event in InputMap.action_get_events("ui_cancel"):
		if event is InputEventKey and event.physical_keycode == KEY_X:
			keyboard_events += 1
	check(keyboard_events == 1, "bindings are not duplicated")


func test_touch_dpad_directions() -> void:
	check(TouchOverlay.direction_from_offset(Vector2(3, 2)) == Vector2i.ZERO, "small offsets are ignored")
	check(TouchOverlay.direction_from_offset(Vector2(30, -10)) == Vector2i.RIGHT, "mostly-right is right")
	check(TouchOverlay.direction_from_offset(Vector2(-30, 5)) == Vector2i.LEFT, "mostly-left is left")
	check(TouchOverlay.direction_from_offset(Vector2(10, -30)) == Vector2i.UP, "mostly-up is up")
	check(TouchOverlay.direction_from_offset(Vector2(-5, 40)) == Vector2i.DOWN, "mostly-down is down")


# --- World ---------------------------------------------------------------------

const TRAINER_TEXT := ["intro", "defeat", "victory", "after"]


func test_trainers() -> void:
	for id in Dex.trainers:
		var t: Dictionary = Dex.trainers[id]
		check(not t["party"].is_empty(), "trainer %s has a party" % id)
		for entry in t["party"]:
			check(Dex.species.has(entry[0]), "trainer %s uses existing species %s" % [id, entry[0]])
			check(int(entry[1]) >= 1 and int(entry[1]) <= 100, "trainer %s levels are valid" % id)
		for key in TRAINER_TEXT:
			check(t.has(key), "trainer %s has %s text" % [id, key])


func _blocking(tile: String) -> bool:
	return MapRules.BLOCKING.contains(tile)


func _tile(m: Dictionary, cell: Vector2i) -> String:
	var layout: Array = m["layout"]
	if cell.y < 0 or cell.y >= layout.size() or cell.x < 0 or cell.x >= layout[0].length():
		return "X"
	return layout[cell.y][cell.x]


func test_maps_are_well_formed() -> void:
	check(Dex.maps.has("player_house"), "start map exists")
	for id in Dex.maps:
		var m: Dictionary = Dex.maps[id]
		check(m.get("id") == id, "map %s id matches its file name" % id)
		var width: int = m["layout"][0].length()
		for row in m["layout"]:
			check(row.length() == width, "map %s rows are all %d wide" % [id, width])
			for tile in row:
				check(MapRules.COLORS.has(tile), "map %s tile '%s' is in the legend" % [id, tile])
		if m.has("encounters"):
			check(Dex.encounters.has(m["encounters"]), "map %s encounter table exists" % id)
		for warp in m.get("warps", []):
			check(not _blocking(_tile(m, Dirs.cell(warp["at"]))), "map %s warp at %s is walkable" % [id, warp["at"]])
			check(Dex.maps.has(warp["to"]), "map %s warps to existing map %s" % [id, warp["to"]])
			if Dex.maps.has(warp["to"]):
				var target: Dictionary = Dex.maps[warp["to"]]
				var arrival := Dirs.cell(warp["cell"])
				check(not _blocking(_tile(target, arrival)), "warp %s -> %s arrives on a walkable tile" % [id, warp["to"]])
				for other in target.get("warps", []):
					check(Dirs.cell(other["at"]) != arrival, "warp %s -> %s doesn't arrive on another warp" % [id, warp["to"]])
		var ids := {}
		for npc in m.get("npcs", []):
			check(not ids.has(npc["id"]), "map %s npc id %s is unique" % [id, npc["id"]])
			ids[npc["id"]] = true
			check(not _blocking(_tile(m, Dirs.cell(npc["cell"]))) or _tile(m, Dirs.cell(npc["cell"])) == "t",
				"map %s npc %s stands on a free tile" % [id, npc["id"]])
			if npc.has("trainer"):
				check(Dex.trainers.has(npc["trainer"]), "map %s npc %s uses existing trainer" % [id, npc["id"]])
			else:
				check(npc.has("script"), "map %s npc %s has a script" % [id, npc["id"]])
		for sign_data in m.get("signs", []):
			check(_tile(m, Dirs.cell(sign_data["cell"])) == "S", "map %s sign at %s is on a sign tile" % [id, sign_data["cell"]])


## Validates every command in a script, recursing into branches.
func _check_script(script: Array, m: Dictionary, where: String) -> void:
	for command in script:
		var keys := []
		for key in command:
			if key in MapRules.EVENT_COMMANDS:
				keys.append(key)
		check(keys.size() == 1, "%s: command %s has exactly one action" % [where, command])
		if keys.size() != 1:
			continue
		match keys[0]:
			"run":
				check(m.get("scripts", {}).has(command["run"]), "%s: script %s exists" % [where, command["run"]])
			"battle":
				check(Dex.trainers.has(command["battle"]), "%s: trainer %s exists" % [where, command["battle"]])
				_check_script(command.get("win", []), m, where)
				_check_script(command.get("lose", []), m, where)
			"give_monster":
				check(Dex.species.has(command["give_monster"]), "%s: species %s exists" % [where, command["give_monster"]])
			"if_flag":
				_check_script(command.get("then", []), m, where)
				_check_script(command.get("else", []), m, where)
			"choice":
				check(command.get("options", []).size() >= 2, "%s: choice has options" % where)
				for option in command.get("options", []):
					_check_script(option.get("then", []), m, where)
			"hide_npc", "show_npc", "exclaim", "npc_approach":
				var found := false
				for npc in m.get("npcs", []):
					found = found or npc["id"] == command[keys[0]]
				check(found, "%s: npc %s exists" % [where, command[keys[0]]])
			"step_player":
				check(Dirs.BY_NAME.has(command["step_player"]), "%s: direction is valid" % where)
			"warp":
				check(Dex.maps.has(command["warp"]), "%s: warp map exists" % where)


func test_map_scripts() -> void:
	for id in Dex.maps:
		var m: Dictionary = Dex.maps[id]
		for npc in m.get("npcs", []):
			_check_script(npc.get("script", []), m, "%s/%s" % [id, npc["id"]])
		for trigger in m.get("triggers", []):
			_check_script(trigger["script"], m, "%s/trigger" % id)
		for script_name in m.get("scripts", {}):
			_check_script(m["scripts"][script_name], m, "%s/%s" % [id, script_name])


## Every warp and NPC must be reachable on foot from where the player enters each map.
func test_maps_are_connected() -> void:
	var entries := { "player_house": [Vector2i(2, 2), Vector2i(4, 5)] }
	for id in Dex.maps:
		for warp in Dex.maps[id].get("warps", []):
			if not entries.has(warp["to"]):
				entries[warp["to"]] = []
			entries[warp["to"]].append(Dirs.cell(warp["cell"]))
	for id in Dex.maps:
		var m: Dictionary = Dex.maps[id]
		check(entries.has(id), "map %s can be entered" % id)
		var reachable := {}
		var frontier: Array = entries.get(id, []).duplicate()
		while not frontier.is_empty():
			var cell: Vector2i = frontier.pop_back()
			if reachable.has(cell) or _blocking(_tile(m, cell)):
				continue
			reachable[cell] = true
			for d in Dirs.BY_NAME.values():
				frontier.append(cell + d)
		for warp in m.get("warps", []):
			check(reachable.has(Dirs.cell(warp["at"])), "map %s warp at %s is reachable" % [id, warp["at"]])
		for npc in m.get("npcs", []):
			var talkable := false
			var cell := Dirs.cell(npc["cell"])
			for d in Dirs.BY_NAME.values():
				talkable = talkable or reachable.has(cell + d) or (_tile(m, cell + d) == "k" and reachable.has(cell + d * 2))
			check(talkable, "map %s npc %s can be talked to" % [id, npc["id"]])


func test_monster_save_round_trip() -> void:
	var m := Monster.create("emberkit", 12, seeded(20))
	m.hp = 7
	m.status = "burn"
	m.moves[0]["pp"] = 3
	m.add_evs({ "spe": 10 })
	var copy := Monster.from_dict(JSON.parse_string(JSON.stringify(m.to_dict())))
	check(copy.species_id == m.species_id and copy.level == m.level and copy.experience == m.experience, "identity survives saving")
	check(copy.stats == m.stats, "stats survive saving")
	check(copy.hp == 7 and copy.status == "burn", "condition survives saving")
	check(copy.moves == m.moves, "moves and PP survive saving")
	check(copy.ivs == m.ivs and copy.evs == m.evs and copy.temperament == m.temperament, "hidden values survive saving")


func test_trainer_ai() -> void:
	var picks := 0
	for seed_value in 20:
		var foe := Monster.create("emberkit", 10, seeded(seed_value))
		foe.moves = [{ "id": "shove", "pp": 10 }, { "id": "cinder_spit", "pp": 10 }]
		var battle := Battle.new([Monster.create("fernling", 10, seeded(99))], [foe], false, seeded(seed_value))
		if battle._ai_choose_move() == 1:
			picks += 1
	check(picks == 20, "trainers pick the super-effective STAB move (%d/20)" % picks)
