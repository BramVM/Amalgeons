extends "character.gd"
class_name Amalgeon

@export var master: Player

var animatedSprite2D = AnimatedSprite2D.new()

func _ready() -> void:
	initial_position = position
	add_child(animatedSprite2D)
	animatedSprite2D.frames = load("res://amalgeon2_sprite.tres")
	animatedSprite2D.set_offset(Vector2(0,-6))

func _physics_process(delta: float) -> void:
	move(get_wanted_dierection(),delta)
	animate(animatedSprite2D)

func get_wanted_dierection() -> Direction:
	var wanted_direction_vector = (master.petPosition - position).normalized().round()
	print(wanted_direction_vector)
	if wanted_direction_vector.y == 0:
		if (wanted_direction_vector.x > 0):	
			return Direction.RIGHT
		if (wanted_direction_vector.x < 0):
			return Direction.LEFT
	if wanted_direction_vector.x == 0:
		if (wanted_direction_vector.y < 0):
			return Direction.UP
		if (wanted_direction_vector.y > 0):
			return Direction.DOWN
	return Direction.NONE
			
		
