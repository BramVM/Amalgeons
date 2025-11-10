extends Character
class_name WildAmalgeon

@export var wander_ai: WanderAI
@export var chase_ai: WildChaseAI

func _ready() -> void:
	char_type = GameGlobals.CharType.WILD
	super._ready()

func _physics_process(delta: float) -> void:
	if chase_ai and move:
		chase_ai.physics_tick(self, move, delta)
	if wander_ai and move and !(chase_ai and chase_ai.chasing) and !(char_state==GameGlobals.CharState.FIGHTING||char_state==GameGlobals.CharState.STAGING):
		wander_ai.physics_tick(self, move, delta)
	super._physics_process(delta)
