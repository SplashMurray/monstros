# Monstros

A monster-collecting RPG for Android, built in Godot 4. It plays like the GBA-era classics,
with a few modern battle mechanics, and all of its content is original. It supports on-screen
touch controls and gamepads such as the Backbone.

## Running

1. Install [Godot 4.3+](https://godotengine.org/download) (the standard build; C# is not needed).
2. Open `project.godot` in the editor and press **F5**, or run `godot --path .` from the repo root.

The current slice:
1. Start at home in Hollowmere Village.
2. Choose a starter in Professor Wren's lab and battle your rival.
3. Travel Route 1, where there are wild monsters and two trainers.
4. Heal at the Fenwick Rest Stop.
5. Win the Bedrock Badge from Leader Brenna.

Save from the menu. The game also autosaves whenever the app goes to the background.

## Controls

| | Touch | Gamepad (Backbone, Xbox-style) | Keyboard |
|---|---|---|---|
| Move | On-screen D-pad | D-pad / left stick | Arrows / WASD |
| Confirm (A) | On-screen A, or tap menu buttons | A | Z / Enter / Space |
| Back (B) | On-screen B, Android back | B | X / Backspace / Esc |
| Run (hold B) | Hold on-screen B | Hold B | Hold X / Shift |
| Menu (Start) | On-screen MENU | Start / Menu | Tab |

The on-screen controls show while you use touch and hide when a gamepad or keyboard is used.
They come back on the next touch. To try touch on desktop, run `godot --path . -- --touch`
and click with the mouse.

## Building for Android

1. In Godot: **Editor → Manage Export Templates → Download** (4.3).
2. Install OpenJDK 17 and the Android SDK (command-line tools, platform-tools, build-tools 34),
   then set their paths in **Editor Settings → Export → Android**. Godot creates a debug keystore automatically.
3. **Project → Export → Android** (preset included in `export_presets.cfg`). Then either **Export Project** to
   `export/monstros.apk`, or use the one-click deploy button with a phone connected over USB debugging.

For Play Store releases, set a release keystore in the preset and enable the Gradle build to export an `.aab`.

## Tests

The battle engine is pure logic, separate from the scenes, so it is tested headlessly:

```sh
godot --headless --import          # first run only: builds the script class cache
godot --headless -s tests/run_tests.gd
```

## Layout

```
data/            All game content as JSON: types, moves, species, temperaments, encounters, trainers
data/maps/       One file per map: layout, warps, NPCs, signs, triggers and event scripts
scripts/core/    Dex (data access), Monster, Stats, Growth, Game (autoload: state + saving)
scripts/battle/  Battle engine, DamageCalc, Capture, trainer AI, and the battle screen
scripts/overworld/  Map rendering, player/NPC movement, EventRunner (event scripts), MapRules
scripts/ui/      Title screen, dialogue box, start menu
assets/          Artwork (see docs/ART_SPEC.md); anything missing falls back to placeholders
tools/           Art checklist generator and spec diagram generator
scripts/input/   Input map, device detection (Controls autoload), on-screen touch controls
scenes/          Godot scenes
tests/           Headless test runner
docs/            Design notes and content rules
```

New monsters, moves, trainers, maps and story events can be added by editing JSON alone.
No code changes are needed. See [docs/CONTENT.md](docs/CONTENT.md).

`data/*.json` is listed in the export preset's non-resource filter. Keep it there, or the data files won't ship.

## Docs

- [Design and mechanics](docs/DESIGN.md)
- [Adding content: maps, NPCs, events](docs/CONTENT.md)
- [Art specification: sprite formats](docs/ART_SPEC.md) and the [art checklist](docs/ART_CHECKLIST.md)
- [Content guidelines: staying original](docs/CONTENT_GUIDELINES.md)
