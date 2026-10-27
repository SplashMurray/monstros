class_name Capture
extends RefCounted
## Catch formula (Gen 3/4 style, with modern status bonuses).

const STATUS_BONUS := { "sleep": 2.5, "freeze": 2.5, "paralysis": 1.5, "burn": 1.5, "poison": 1.5 }


static func catch_value(target: Monster, ball_bonus: float = 1.0) -> float:
	var max_hp := target.max_hp()
	var catch_rate := float(target.species().get("catch_rate", 45))
	var a := ((3.0 * max_hp - 2.0 * target.hp) * catch_rate * ball_bonus) / (3.0 * max_hp)
	return a * STATUS_BONUS.get(target.status, 1.0)


## Returns the number of successful shake checks (0-4). 4 means caught.
static func shake_count(a: float, rng: RandomNumberGenerator) -> int:
	if a >= 255.0:
		return 4
	if a <= 0.0:
		return 0
	var b := floori(1048560.0 / sqrt(sqrt(16711680.0 / a)))
	for i in 4:
		if rng.randi_range(0, 65535) >= b:
			return i
	return 4
