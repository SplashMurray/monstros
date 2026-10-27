class_name MapRules
extends RefCounted
## Shared definitions for map data: the tile legend and the event script commands.
## Kept free of autoload references so the headless tests can use it.
##
## Tile legend:
##   outdoors  . ground  p path  f flowers  g tall grass  T tree  w water  = fence  S sign
##             r R G roofs (red, blue, brown)  # building wall  D door
##   indoors   _ floor  X wall  b shelf  t table  k counter (talk across it)  m exit mat

const BLOCKING := "Tw=SrRG#Xbtk"
const COLORS := {
	".": Color("#a8d878"), "p": Color("#e0cc90"), "f": Color("#a8d878"), "g": Color("#4f9a4a"),
	"T": Color("#2f6b3a"), "w": Color("#5090d8"), "=": Color("#a8d878"), "S": Color("#a8d878"),
	"r": Color("#c85050"), "R": Color("#4f78c8"), "G": Color("#9a6a40"), "#": Color("#ece4d4"),
	"D": Color("#6a4a2a"), "_": Color("#e8dcc0"), "X": Color("#5a4a40"), "b": Color("#8a5a3a"),
	"t": Color("#b07a48"), "k": Color("#c8a878"), "m": Color("#c04848"),
}

## Event script commands understood by EventRunner (see event_runner.gd for details).
const EVENT_COMMANDS := [
	"say", "choice", "if_flag", "set_flag", "clear_flag", "run", "give_monster", "give_money", "heal",
	"set_respawn", "hide_npc", "show_npc", "step_player", "exclaim", "npc_approach", "wait", "warp", "battle",
]
