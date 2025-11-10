extends Resource
class_name Stats

const MAX_POINTS_PER_STAT := 50
const ARMOR_MOD := 3 

const TIERS := [
	{ "size": 5, "mult": 1.00 }, # 1–5
	{ "size": 5, "mult": 0.90 }, # 6–10
	{ "size": 5, "mult": 0.80 }, # 11–15
	{ "size": 5, "mult": 0.70 }, # 16–20
	{ "size": 5, "mult": 0.60 }, # 21–25
	{ "size": 5, "mult": 0.50 }, # 26–30
	{ "size": 5, "mult": 0.40 }, # 31–45
	{ "size": 5, "mult": 0.30 }, # 36–40
	{ "size": 5, "mult": 0.20 }, # 41–45
	{ "size": 5, "mult": 0.10 }, # 46–50
]

@export var damage := 0
@export var speed := 0
@export var hit_points := 0

func attack_power() ->float:
	return 1+_effective_points(damage)*0.1
	
func attack_speed() ->float:
	return 1+_effective_points(speed)*0.1

func max_hit_points()->float:
	return 100*(1+_effective_points(hit_points)*0.1)
	
func armor()->int:
	return roundi(_effective_points(hit_points)/ARMOR_MOD)

static func _effective_points(p: int) -> float:
	# Clamp to [0, 50] and apply tiered weights
	var pts := clampi(p, 0, MAX_POINTS_PER_STAT)
	var remaining := pts
	var e := 0.0
	for t in TIERS:
		if remaining <= 0:
			break
		var take = min(remaining, t.size)
		e += float(take) * t.mult
		remaining -= take
	return e
