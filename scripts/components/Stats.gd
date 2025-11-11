extends Resource
class_name Stats

const MAX_POINTS_PER_STAT := 50
const MAX_LEVEL := 40
const ARMOR_MOD := 3 

const DEMINISHING_RETURN_TIERS := [
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

const STAT_GAIN_TIERS := [
	{ "size": 10, "mult": 1 }, # 1–10
	{ "size": 10, "mult": 2 }, # 11–20
	{ "size": 10, "mult": 3 }, # 21–30
	{ "size": 10, "mult": 4 }, # 31–40
]

@export var damage := 0
@export var speed := 0
@export var hit_points := 0
@export var level := 1
@export var exp := 0.0

func attack_power() ->float:
	return 1+_effective_points(damage, MAX_POINTS_PER_STAT, DEMINISHING_RETURN_TIERS)*0.1
	
func attack_speed() ->float:
	return 1+_effective_points(speed, MAX_POINTS_PER_STAT, DEMINISHING_RETURN_TIERS)*0.1

func max_hit_points()->float:
	return 100*(1+_effective_points(hit_points, MAX_POINTS_PER_STAT, DEMINISHING_RETURN_TIERS)*0.1)
	
func armor()->int:
	print(roundi(_effective_points(hit_points, MAX_POINTS_PER_STAT, DEMINISHING_RETURN_TIERS)/ARMOR_MOD))
	return roundi(_effective_points(hit_points, MAX_POINTS_PER_STAT, DEMINISHING_RETURN_TIERS)/ARMOR_MOD)

func unspent_stat_points()->int:
	var e = _effective_points(level, MAX_LEVEL, STAT_GAIN_TIERS) as int
	return e-damage-speed-hit_points

func add_exp_by_enemy_level(el):
	exp = exp+0.5*el/level
	if(exp>=1):
		level= min(level+1,MAX_LEVEL)
		exp=0

static func _effective_points(p: int, cap: int, tiers:Array) -> float:
	# Clamp to max and apply tiered weights
	var pts := clampi(p, 0, cap)
	var remaining := pts
	var e := 0.0
	for t in tiers:
		if remaining <= 0:
			break
		var take = min(remaining, t.size)
		e += float(take) * t.mult
		remaining -= take
	return e
