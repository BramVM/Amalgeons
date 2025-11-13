extends Character
class_name WildAmalgeon

@export var wander_ai: WanderAI
@export var chase_ai: WildChaseAI

func _ready() -> void:
	char_type = GameGlobals.CharType.WILD
	super._ready()

func _physics_process(delta: float) -> void:
	if chase_ai and movement_controller:
		chase_ai.physics_tick(self, movement_controller, delta)
	if wander_ai and movement_controller and !(chase_ai and chase_ai.chasing) and (char_state==GameGlobals.CharState.IDLE):
		wander_ai.physics_tick(self, movement_controller, delta)
	super._physics_process(delta)
