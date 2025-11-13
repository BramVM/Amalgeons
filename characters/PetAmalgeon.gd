extends Character
class_name PetAmalgeon

@export var follow_ai: FollowMasterAI
var master:Player

func _ready() -> void:
	char_type = GameGlobals.CharType.PET
	SignalBus.player_spawned.connect(set_master)
	SignalBus.died.connect(_on_char_died)
	stats.level=1
	var _sprite = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	super._ready()

func _physics_process(delta: float) -> void:
	if follow_ai and movement_controller:
		follow_ai.physics_tick(self, movement_controller, delta)
	super._physics_process(delta)

func set_master(p):
	master = p
	if!p.pet: p.set_pet(self)
	follow_ai.set_master(p)

func _on_char_died(c:Character) -> void:
	if(c.char_type==GameGlobals.CharType.WILD):
		stats.add_exp_by_enemy_level(c.stats.level)
		var _sprite = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
		if stats.level>10:
			_sprite.sprite_frames=load("res://amalgeon2_sprite.tres")as SpriteFrames
		if stats.level>20:
			_sprite.sprite_frames=load("res://amalgeon3_sprite.tres")as SpriteFrames
		if stats.level>30:
			_sprite.sprite_frames=load("res://amalgeon4_sprite.tres")as SpriteFrames
