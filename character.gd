extends CharacterBody2D
class_name Character

const TILE_SIZE = 16

var walk_speed = 4.0
@export var petPosition: Vector2

var collisionShape2D = CollisionShape2D.new()

var initial_position = Vector2(0, 0)
var input_direction = Vector2(0,0)
var is_moving = false
var percent_moved_to_next_tile = 0.0
var destiny = Vector2.ZERO
var state: CharState
var moving_vector = Vector2.ZERO
var enemy: Character
var prep_fighting: bool

enum Direction {  
	NONE,
	UP,      
	DOWN,  
	RIGHT,
	LEFT  
}
enum CharState {
	WALKING,
	IDLE,
	FIGHTING,
}

var direction = Direction.DOWN


func _ready() -> void:
	initial_position = position
	#add_child(collisionShape2D)
	#collisionShape2D.shape = load("res://char_collosion_shape.tres")
	petPosition = position
		
func move(wanted_direction:Direction, delta: float)-> void:
	if(state==CharState.WALKING):
		percent_moved_to_next_tile += walk_speed * delta
	if percent_moved_to_next_tile >= 1.0:
		position = initial_position + (TILE_SIZE * moving_vector)
		petPosition = initial_position
		initial_position = position
		percent_moved_to_next_tile = 0.0
		state = CharState.IDLE
		
	else:
		if(state==CharState.WALKING):
			position = initial_position + (TILE_SIZE * moving_vector * percent_moved_to_next_tile)
		
	if state == CharState.IDLE:
		if (wanted_direction == Direction.RIGHT):
			direction = Direction.RIGHT
			moving_vector = Vector2(1,0)
		if (wanted_direction == Direction.LEFT):
			direction = Direction.LEFT
			moving_vector = Vector2(-1,0)
		if (wanted_direction == Direction.UP):
			direction = Direction.UP
			moving_vector = Vector2(0,-1)
		if (wanted_direction == Direction.DOWN):
			direction = Direction.DOWN
			moving_vector = Vector2(0,1)
		if (wanted_direction!= Direction.NONE):
			state = CharState.WALKING
		else: 
			moving_vector = Vector2.ZERO
		
			
		
func animate(animatedSprite2D:AnimatedSprite2D) -> void:
	if (direction==Direction.RIGHT||direction==Direction.LEFT):
		if(state==CharState.IDLE && animatedSprite2D.animation!="side" ):
			animatedSprite2D.play("side")
		if(state==CharState.WALKING && animatedSprite2D.animation!="walk side"):
			animatedSprite2D.play("walk side")
		animatedSprite2D.flip_h = (direction==Direction.LEFT)
	if (direction==Direction.UP):
		if(state==CharState.IDLE && animatedSprite2D.animation!="up"):
			animatedSprite2D.play("up")
		if(state==CharState.WALKING && animatedSprite2D.animation!="walk up"):
			animatedSprite2D.play("walk up")
	if (direction==Direction.DOWN):
		if(state==CharState.IDLE && animatedSprite2D.animation!="down"):
			animatedSprite2D.play("down")
		if(state==CharState.WALKING && animatedSprite2D.animation!="walk down"):
			animatedSprite2D.play("walk down")
		
