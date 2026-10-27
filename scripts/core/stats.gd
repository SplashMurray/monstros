class_name Stats
extends RefCounted
## Stat formulas (Gen 3 onwards).

const KEYS := ["hp", "atk", "def", "spa", "spd", "spe"]
const NAMES := {
	"hp": "HP", "atk": "Attack", "def": "Defence", "spa": "Sp. Atk", "spd": "Sp. Def",
	"spe": "Speed", "acc": "accuracy", "eva": "evasiveness",
}
const MAX_IV := 31


static func calc_hp(base: int, iv: int, ev: int, level: int) -> int:
	return floori((2 * base + iv + floori(ev / 4.0)) * level / 100.0) + level + 10


## temperament_tenths is 11 (boosted), 10 (neutral) or 9 (hindered). Integer maths
## avoids floating-point rounding surprises like 300 * 0.9 = 269.999...
static func calc_stat(base: int, iv: int, ev: int, level: int, temperament_tenths: int = 10) -> int:
	var raw := floori((2 * base + iv + floori(ev / 4.0)) * level / 100.0) + 5
	return floori(raw * temperament_tenths / 10.0)


static func temperament_tenths(temperament_id: String, stat: String) -> int:
	var t: Dictionary = Dex.temperaments.get(temperament_id, {})
	var up: String = t.get("up", "")
	var down: String = t.get("down", "")
	if up == down:
		return 10
	if stat == up:
		return 11
	if stat == down:
		return 9
	return 10


static func calc_all(base_stats: Dictionary, ivs: Dictionary, evs: Dictionary, level: int, temperament_id: String) -> Dictionary:
	var result := {}
	for key in KEYS:
		var base := int(base_stats.get(key, 1))
		var iv := int(ivs.get(key, 0))
		var ev := int(evs.get(key, 0))
		if key == "hp":
			result[key] = calc_hp(base, iv, ev, level)
		else:
			result[key] = calc_stat(base, iv, ev, level, temperament_tenths(temperament_id, key))
	return result


## Multiplier for an Attack/Defence/Sp. Atk/Sp. Def/Speed stage in [-6, 6].
static func stage_multiplier(stage: int) -> float:
	return (2.0 + maxi(stage, 0)) / (2.0 + maxi(-stage, 0))


## Multiplier for a combined accuracy-minus-evasion stage in [-6, 6].
static func accuracy_stage_multiplier(stage: int) -> float:
	return (3.0 + maxi(stage, 0)) / (3.0 + maxi(-stage, 0))
