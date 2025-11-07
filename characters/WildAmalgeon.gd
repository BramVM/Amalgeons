extends Character
class_name WildAmalgeon

@export var wander_ai: WanderAI
@export var chase_ai: WildChaseAI

func _physics_process(delta: float) -> void:
	if chase_ai and move:
		chase_ai.physics_tick(self, move, delta)
	#if wander_ai and move and !(chase_ai and chase_ai.chasing):
		#wander_ai.physics_tick(self, move, delta)
	super(delta)
