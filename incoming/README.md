# Incoming art

Drop delivered monster sprites into `incoming/sprites/`, named by roster number:

    001_front.png   001_back.png   001_icon.png

Then run `python3 tools/import_sprites.py`. It checks each file and moves it to
`assets/monsters/<id>/front.png` (or `back.png` / `icon.png`). Files with problems stay here, with an explanation.
This folder is ignored by Godot.
