# Monstros design notes

## Goal

Recreate the *feel* and *structure* of a GBA-era monster-collecting RPG (Kanto-style
progression, grid movement, turn-based 1v1 battles). Battle rules are modernised where
it clearly improves the game. All content (names, monsters, maps, art, music, text) is original.

## Platform

- **Target: Android phones and tablets**, landscape (sensor landscape), immersive full-screen.
  Desktop also runs for development.
- **Resolution**: 480x320 base (2x the GBA) scaled to fit. The width expands on wider phones,
  so a 20:9 phone sees a few extra tiles to each side, with no letterboxing.
- **Rendering**: Compatibility (OpenGL ES 3) renderer, for the widest device support. ETC2/ASTC texture compression.
- **Input**: everything reads named actions (`move_*`, `accept`, `cancel`, `run`, `menu`) defined in
  `scripts/input/control_scheme.gd`, so touch, gamepad and keyboard are interchangeable.
  - On-screen controls: a GBA-style D-pad plus A/B, multi-touch (hold B to run while steering), haptic tick on press,
    and kept clear of notches using the display safe area. Shown only while the player is using touch.
  - Gamepads (Backbone One and other Android HID controllers) use the Xbox layout: A bottom = confirm, B right = back/run.
    Connecting a controller hides the touch controls. Battle menus can be navigated with the D-pad or stick.
  - Battle menus are also directly tappable, so the D-pad is hidden in battles.
  - The Android back button acts as B instead of closing the app.
- To do for mobile: autosave on `NOTIFICATION_APPLICATION_PAUSED` (once saving exists), an adjustable
  touch-control size and opacity, and an app icon.

## Types

There are 18 types. They follow the familiar matchups, including the Gen 6 chart with the fairy-equivalent **Fae**.
To play the 17-type GBA chart instead, delete `fae` from `data/types.json`.

| Monstros | Classic equivalent | | Monstros | Classic equivalent |
|---|---|---|---|---|
| Common | Normal | | Mind | Psychic |
| Flame | Fire | | Insect | Bug |
| Water | Water | | Stone | Rock |
| Flora | Grass | | Spirit | Ghost |
| Volt | Electric | | Wyrm | Dragon |
| Frost | Ice | | Shadow | Dark |
| Brawl | Fighting | | Metal | Steel |
| Toxic | Poison | | Fae | Fairy |
| Earth | Ground | | Wind | Flying |

Type IDs are lowercase keys in `data/types.json`, which is the single source of truth for the chart.

## Battle mechanics

| Mechanic | Rule used | Origin |
|---|---|---|
| Physical/special | **Per move** (`category` field), not per type | Gen 4 |
| Stat formulas | HP/stat formulas with IVs (0-31), EVs (252/510 caps) | Gen 3+ |
| Temperaments (natures) | 25, +10% / -10% | Gen 3+ |
| Damage formula | Level/power/attack/defence base, then crit, random 85-100%, STAB 1.5x, type, burn | Gen 5+ |
| Critical hits | 1.5x, stages 1/24, 1/8, 1/2, 1/1; ignore bad stages for the attacker | Gen 6/7 |
| Burn | Halves physical damage, 1/16 HP per turn | Gen 7 |
| Poison | 1/8 HP per turn | Gen 3+ |
| Paralysis | Speed halved, 25% chance to lose the turn | Gen 7 |
| Sleep | 1-3 turns | Gen 5+ |
| Freeze | 20% thaw chance per turn | Gen 3+ |
| Type status immunities | Flame can't be burned, Volt can't be paralysed, Toxic/Metal can't be poisoned, Frost can't be frozen | Gen 3-6 |
| Struggle equivalent | Typeless "Thrash About", recoil 1/4 max HP | Gen 4+ |
| Catch formula | Gen 3/4 shake checks; sleep/freeze 2.5x, other statuses 1.5x | Gen 3-5 |
| Escape formula | Gen 3 | Gen 3 |
| Experience | base_exp x level / 7 (x1.5 vs trainers), four growth curves | Gen 3 |

Possible future modernisations (not yet implemented): abilities, held items, the
Exp. Share giving the whole party experience, re-learning moves, a "forget a move" prompt
(currently the new move is skipped), double battles, smarter trainer AI.

## Engine architecture

- **Data-driven**: `Dex` loads JSON once and serves it statically.
- **Pure battle logic**: `Battle` holds no nodes. `take_turn(action)` returns a list
  of events (`message`, `hp`, `refresh`, `shake`, `request_switch`, `end`), and the scene
  plays them back with animations. This makes the rules testable without a UI and
  lets any future presentation (real sprites, animations) reuse the same engine.
- **Global state** lives in the `Game` autoload (party, storage, position).

## Roadmap

1. **Vertical slice**: starter choice, one town and route, a rival battle, one gym, 10-15 monsters, save/load.
2. TileMap-based maps (Tiled or the Godot editor), NPCs, a dialogue/event scripting layer, doors and warps.
3. Bag and items, healing centre, shop, monster storage UI, dex screen.
4. Trainer battles with AI and rewards, gyms, the villain team storyline.
5. Content production: the region, 100-150 monsters, music, sound.
