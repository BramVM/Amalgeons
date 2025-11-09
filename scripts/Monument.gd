extends Node2D
class_name Monument

var player:Player
var pet:PetAmalgeon
var _cooldown := 0.0
var heal_speed = 0.2
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	var cell = Grid.to_cell(position)
	Occupancy.take(cell)

func _process(delta: float) -> void:
	if (player and _check_near(player)):
		anim.play("active")
	else:
		anim.play("idle")
	if(_cooldown>0.0):
		_cooldown-=delta
	else:
		_cooldown=heal_speed
		if (player and _check_near(player)):
			player.health.heal(player.health.max_hp/14)
			if pet: pet.health.heal(pet.health.max_hp/14)

func _check_near(p:Player) -> bool:
	var distance = (Grid.to_cell(p.global_position) - Grid.to_cell(global_position)).length()
	return (distance==1)
	

func set_player(p:Player) -> void:
	player = p
	
func set_pet(p:PetAmalgeon) -> void:
	pet = p
