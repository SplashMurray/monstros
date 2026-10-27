class_name Growth
extends RefCounted
## Experience curves: total experience needed to reach a given level.


static func exp_for_level(rate: String, n: int) -> int:
	if n <= 1:
		return 0
	match rate:
		"fast":
			return floori(4.0 * n * n * n / 5.0)
		"medium_slow":
			return floori(6.0 * n * n * n / 5.0) - 15 * n * n + 100 * n - 140
		"slow":
			return floori(5.0 * n * n * n / 4.0)
		_:  # "medium_fast"
			return n * n * n
