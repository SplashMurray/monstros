# Monstros

A monster-collecting RPG built in Godot 4. It plays like the GBA-era classics,
with a few modern battle mechanics, and all of its content is original.

## Running

1. Install [Godot 4.3+](https://godotengine.org/download) (the standard build; C# is not needed).
2. Open `project.godot` in the editor and press **F5**, or run `godot --path .` from the repo root.

Controls: arrow keys to move, Enter/Space to confirm. Walk into tall grass to find wild monsters.
Step on the pink pad to heal.

## Tests

The battle engine is pure logic, separate from the scenes, so it is tested headlessly:

```sh
godot --headless --import          # first run only: builds the script class cache
godot --headless -s tests/run_tests.gd
```

## Layout

```
data/            All game content as JSON: types, moves, species, temperaments, encounters
scripts/core/    Dex (data access), Monster, Stats, Growth, Game (autoload global state)
scripts/battle/  Battle engine, DamageCalc, Capture, and the placeholder battle screen
scripts/overworld/  Grid movement and the placeholder test route
scenes/          Godot scenes
tests/           Headless test runner
docs/            Design notes and content rules
```

New monsters and moves can be added by editing `data/*.json` alone. No code changes are needed.

Exporting: add `data/*.json` to the export preset's "Filters to export non-resource files".

## Docs

- [Design and mechanics](docs/DESIGN.md)
- [Content guidelines: staying original](docs/CONTENT_GUIDELINES.md)
