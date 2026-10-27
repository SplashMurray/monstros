class_name DamageCalc
extends RefCounted
## Damage formula. Modelled on Gen 5+ with the Gen 4 physical/special split:
## each move's own category decides whether Attack/Defence or Sp. Atk/Sp. Def are used.

const STAB := 1.5
const CRIT_MULTIPLIER := 1.5
const CRIT_ODDS := [24, 8, 2, 1]   # 1-in-N chance by crit stage
const BURN_MULTIPLIER := 0.5


## forced_crit: -1 random, 0 never, 1 always. forced_roll: -1 random, else 85..100.
static func compute(attacker: Monster, attacker_stages: Dictionary, defender: Monster, defender_stages: Dictionary,
		move: Dictionary, rng: RandomNumberGenerator, forced_crit: int = -1, forced_roll: int = -1) -> Dictionary:
	var physical: bool = move["category"] == "physical"
	var attack_key := "atk" if physical else "spa"
	var defence_key := "def" if physical else "spd"

	var crit_stage := clampi(int(move.get("crit_stage", 0)), 0, CRIT_ODDS.size() - 1)
	var crit: bool
	if forced_crit == -1:
		crit = rng.randi_range(1, CRIT_ODDS[crit_stage]) == 1
	else:
		crit = forced_crit == 1

	var attack_stage: int = attacker_stages.get(attack_key, 0)
	var defence_stage: int = defender_stages.get(defence_key, 0)
	if crit:
		# Critical hits ignore the attacker's drops and the defender's boosts.
		attack_stage = maxi(attack_stage, 0)
		defence_stage = mini(defence_stage, 0)
	var attack := maxi(1, floori(attacker.stats[attack_key] * Stats.stage_multiplier(attack_stage)))
	var defence := maxi(1, floori(defender.stats[defence_key] * Stats.stage_multiplier(defence_stage)))

	var power := int(move.get("power", 0))
	var level_factor := floori(2 * attacker.level / 5.0) + 2
	var damage := float(floori(floori(level_factor * power * attack / float(defence)) / 50.0) + 2)

	if crit:
		damage = floorf(damage * CRIT_MULTIPLIER)
	var roll := forced_roll if forced_roll != -1 else rng.randi_range(85, 100)
	damage = floorf(damage * roll / 100.0)

	var move_type: String = move.get("type", "")
	if move_type != "" and attacker.types().has(move_type):
		damage = floorf(damage * STAB)
	var effectiveness := Dex.effectiveness(move_type, defender.types())
	damage = floorf(damage * effectiveness)
	if physical and attacker.status == "burn":
		damage = floorf(damage * BURN_MULTIPLIER)

	var final_damage := int(damage)
	if effectiveness > 0.0:
		final_damage = maxi(final_damage, 1)
	return { "damage": final_damage, "crit": crit, "effectiveness": effectiveness }
