extends Character
class_name PetAmalgeon

@export var follow_ai: FollowMasterAI

func _ready() -> void:
	char_type = GameGlobals.CharType.PET
	stats.hit_points=25
	stats.speed=25
	stats.damage=25
	super._ready()

func _physics_process(delta: float) -> void:
	if follow_ai and move:
		follow_ai.physics_tick(self, move, delta)
	super._physics_process(delta)
