class_name EventRunner
extends RefCounted
## Runs event scripts: lists of command dictionaries written in the map data files.
## Each command has exactly one of these keys (listed in MapRules.EVENT_COMMANDS):
##
##   say: "text" | ["page", ...]          show dialogue ({player}, {rival} etc. are filled in)
##   choice: "prompt", options: [{ label, then: [...] }]
##   if_flag: "flag", then: [...], else: [...]
##   set_flag / clear_flag: "flag"
##   run: "name"                           run a named script from the map's "scripts"
##   give_monster: "species", level: n
##   give_money: n
##   heal: true                            fully heal the party
##   set_respawn: true                     blacking out returns the player here
##   hide_npc / show_npc: "npc id"         permanent, remembered in the save
##   step_player: "up" | "down" | ...
##   exclaim: "npc id"                     "!" above an NPC's head
##   npc_approach: "npc id"                NPC walks up to the player
##   wait: seconds
##   warp: "map", cell: [x, y], facing: "down"
##   battle: "trainer id", can_lose: bool, win: [...], lose: [...]
##
## A battle changes scene, so the rest of the script is stored in Game.resume and
## the overworld continues it when the player returns.

var world: Node   # the overworld
var busy := false


func _init(p_world: Node) -> void:
	world = p_world


func run(commands: Array) -> void:
	if busy:
		return
	busy = true
	var queue: Array = commands.duplicate(true)
	while not queue.is_empty():
		var command: Dictionary = queue.pop_front()
		var keep_going: bool = await _execute(command, queue)
		if not keep_going:
			return   # a battle has taken over; this overworld is about to be freed
	world.dialogue.close()
	busy = false


func _execute(c: Dictionary, queue: Array) -> bool:
	if c.has("say"):
		var pages: Array = c["say"] if c["say"] is Array else [c["say"]]
		for page in pages:
			await world.dialogue.say(Game.format_text(page))
	elif c.has("choice"):
		var labels := []
		for option in c["options"]:
			labels.append(Game.format_text(option["label"]))
		var picked: int = await world.dialogue.choose(Game.format_text(c["choice"]), labels)
		_prepend(queue, c["options"][picked].get("then", []))
	elif c.has("if_flag"):
		_prepend(queue, c.get("then", []) if Game.has_flag(c["if_flag"]) else c.get("else", []))
	elif c.has("set_flag"):
		Game.set_flag(c["set_flag"])
	elif c.has("clear_flag"):
		Game.clear_flag(c["clear_flag"])
	elif c.has("run"):
		var scripts: Dictionary = world.map.get("scripts", {})
		assert(scripts.has(c["run"]), "Unknown script: %s" % c["run"])
		_prepend(queue, scripts.get(c["run"], []))
	elif c.has("give_monster"):
		await world.dialogue.say(Game.give_monster(c["give_monster"], int(c.get("level", 5))))
	elif c.has("give_money"):
		Game.money += int(c["give_money"])
	elif c.has("heal"):
		Game.heal_party()
	elif c.has("set_respawn"):
		Game.set_respawn(world.map_id, world.player.cell)
	elif c.has("hide_npc"):
		world.set_npc_hidden(c["hide_npc"], true)
	elif c.has("show_npc"):
		world.set_npc_hidden(c["show_npc"], false)
	elif c.has("step_player"):
		world.dialogue.close()
		await world.player.walk(Dirs.from_name(c["step_player"]))
	elif c.has("exclaim"):
		await world.npc_by_id(c["exclaim"]).exclaim()
	elif c.has("npc_approach"):
		await world.npc_approach(c["npc_approach"])
	elif c.has("wait"):
		await world.get_tree().create_timer(float(c["wait"])).timeout
	elif c.has("warp"):
		world.dialogue.close()
		await world.change_map(c["warp"], Dirs.cell(c["cell"]), Dirs.from_name(c.get("facing", "down")))
	elif c.has("battle"):
		Game.resume = { "queue": queue.duplicate(true), "win": c.get("win", []), "lose": c.get("lose", []) }
		Game.start_trainer_battle(c["battle"], bool(c.get("can_lose", false)))
		return false
	else:
		push_error("Unknown event command: %s" % c)
	return true


static func _prepend(queue: Array, commands: Array) -> void:
	for i in range(commands.size() - 1, -1, -1):
		queue.push_front(commands[i].duplicate(true))
