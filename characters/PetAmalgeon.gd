extends Character
class_name PetAmalgeon

@export var follow_ai: FollowMasterAI

func _ready() -> void:
	char_type = GameGlobals.CharType.PET
	SignalBus.died.connect(_on_char_died)
	stats.level=2
	super._ready()

func _physics_process(delta: float) -> void:
	if follow_ai and move:
		follow_ai.physics_tick(self, move, delta)
	super._physics_process(delta)

func _on_char_died(c:Character) -> void:
	if(c.char_type==GameGlobals.CharType.WILD):
		stats.add_exp_by_enemy_level(c.stats.level)
		print(stats.level)
		#auto-assig-statpoints
		stats.hit_points+=stats.unspent_stat_points()
