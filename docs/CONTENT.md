# Adding content

All game content is JSON in `data/`. Run the tests after editing. They check that every reference
resolves, every map row has the same width, every warp lands on a walkable tile, and every warp
and NPC is reachable on foot.

```sh
godot --headless -s tests/run_tests.gd
```

## Monsters, moves, trainers

- `species.json`: base stats, types, catch rate, base exp, growth curve, EV yield, learnset `[[level, move], ...]`, evolutions.
- `moves.json`: `type`, `category` (physical / special / status), `power`, `accuracy` (0 = never misses), `pp`,
  plus optional `priority`, `crit_stage`, `drain`, `recoil_max_hp` and `effects`
  (`{ kind: "stat", target, stat, stages, chance }` or `{ kind: "status", status, chance }`).
- `trainers.json`: `class`, `name`, `party: [[species, level], ...]`, `prize` (multiplied by the last monster's level),
  and lines: `intro`, `defeat` (you won), `victory` (you lost), `after` (talking to them later).
- `encounters.json`: wild encounter tables. A map refers to one with `"encounters": "route_1"`.

## Maps (`data/maps/<id>.json`)

```jsonc
{
  "id": "fenwick",               // must match the file name
  "name": "Fenwick Town",        // shown in the banner when entering outdoors
  "indoor": false,
  "layout": ["TTTT", "T..T", ...],   // one character per tile, see the legend in scripts/overworld/map_rules.gd
  "encounters": "route_1",       // optional: wild monsters in tall grass (g)
  "warps":   [{ "at": [6, 5], "to": "fenwick_gym", "cell": [5, 12], "facing": "up" }],
  "signs":   [{ "cell": [3, 7], "text": "..." }],          // must sit on an S tile
  "npcs":    [{ "id": "nurse", "cell": [6, 1], "facing": "down", "color": "#f0a0b0", "script": [ ... ] },
              { "id": "ada", "cell": [12, 7], "facing": "left", "trainer": "route1_ada", "sight": 4 }],
  "triggers":[{ "cells": [[8, 1]], "unless_flag": "got_starter", "script": [ ... ] }],
  "scripts": { "name": [ ... ] } // reusable scripts, called with { "run": "name" }
}
```

A warp's arrival cell must not itself be a warp; arrive one tile inside the door instead.
An NPC with `trainer` and no `script` battles automatically. Give it a `script` for custom events,
as with Leader Brenna.

## Event scripts

A script is a list of commands, each a dictionary with exactly one command key:

| Command | Example |
|---|---|
| Dialogue | `{ "say": "Hello, {player}!" }` or `{ "say": ["page 1", "page 2"] }` |
| Choice | `{ "choice": "Heal?", "options": [{ "label": "Yes", "then": [...] }, { "label": "No", "then": [] }] }` |
| Branch | `{ "if_flag": "badge_stone", "then": [...], "else": [...] }` |
| Flags | `{ "set_flag": "x" }`, `{ "clear_flag": "x" }` |
| Call a named script | `{ "run": "rival_leaves" }` |
| Give | `{ "give_monster": "fernling", "level": 5 }`, `{ "give_money": 100 }` |
| Heal / respawn point | `{ "heal": true }`, `{ "set_respawn": true }` |
| NPCs | `{ "hide_npc": "rival" }`, `{ "show_npc": "rival" }`, `{ "exclaim": "ada" }`, `{ "npc_approach": "ada" }` |
| Movement | `{ "step_player": "down" }`, `{ "warp": "lab", "cell": [5, 8], "facing": "up" }`, `{ "wait": 0.5 }` |
| Battle | `{ "battle": "leader_brenna", "can_lose": false, "win": [...], "lose": [...] }` |

Text can use `{player}`, `{rival}` and `{starter}`. Flags are saved with the game. Built-in flags:
`defeated:<trainer id>` (set automatically when you win) and `hidden:<map>:<npc id>` (set by `hide_npc`).
