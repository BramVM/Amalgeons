extends Character
class_name PetAmalgeon

@export var follow_ai: FollowMasterAI

func _physics_process(delta: float) -> void:
	if follow_ai and move:
		follow_ai.physics_tick(self, move, delta)
	super(delta)
