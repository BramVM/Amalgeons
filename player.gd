extends CharacterBody2D
class_name Player
const TILE_SIZE = 16

@export var walk_speed = 4.0
@export var direction = Direction.DOWN
@export var petPosition = Vector2(0, 0)
@export var state = CharState.IDLE

var animatedSprite2D: AnimatedSprite2D
var initial_position = Vector2(0, 0)
var input_derection = Vector2(0,0)
var is_moving = false
var percent_moved_to_next_tile = 0.0
var inputBuffer: Array



enum Direction {  
	UP,      
	DOWN,  
	RIGHT,
	LEFT  
}

enum CharState {
	WALKING,
	IDLE
}



func _ready() -> void:
	initial_position = position
	animatedSprite2D = get_node("AnimatedSprite2D")
	animatedSprite2D.play("down")

func _physics_process(delta: float) -> void:
	#press button
	if Input.is_action_just_pressed("move_right"):
		#inputBuffer.append(Direction.RIGHT)
		inputBuffer.append(Vector2(1,0))
	if Input.is_action_just_pressed("move_left"):
		#inputBuffer.append(Direction.LEFT)
		inputBuffer.append(Vector2(-1,0))
	if Input.is_action_just_pressed("move_down"):
		#inputBuffer.append(Direction.DOWN)
		inputBuffer.append(Vector2(0,1))
	if Input.is_action_just_pressed("move_up"):	
		#inputBuffer.append(Direction.UP)
		inputBuffer.append(Vector2(0,-1))
	#release button
	if Input.is_action_just_released("move_right"):
		#inputBuffer.erase(Direction.RIGHT)
		inputBuffer.erase(Vector2(1,0))
	if Input.is_action_just_released("move_left"):
		#inputBuffer.erase(Direction.LEFT)
		inputBuffer.erase(Vector2(-1,0))
	if Input.is_action_just_released("move_down"):
		#inputBuffer.erase(Direction.DOWN)
		inputBuffer.erase(Vector2(0,1))
	if Input.is_action_just_released("move_up"):
		#inputBuffer.erase(Direction.UP)
		inputBuffer.erase(Vector2(0,-1))
	
	if state==CharState.IDLE:process_player_input()
	animate()
	if state==CharState.WALKING:move(delta)
	
		
func process_player_input() -> void:
	if (inputBuffer.size()>0):
		input_derection = inputBuffer.back()
		animatedSprite2D.flip_h = input_derection.x > 0
	if (input_derection == Vector2(1,0)):
		#animatedSprite2D.play("walk side")
		direction = Direction.RIGHT
	if (input_derection == Vector2(-1,0)):
		#animatedSprite2D.play("walk side")
		direction = Direction.LEFT
	if (input_derection == Vector2(0,-1)):
		#animatedSprite2D.play("walk up")
		direction = Direction.UP
	if (input_derection == Vector2(0,1)):
		#animatedSprite2D.play("walk down")
		direction = Direction.DOWN
	if (inputBuffer.size()>0):
		initial_position = position
		petPosition = initial_position
		state = CharState.WALKING

func move(delta: float)-> void:
	percent_moved_to_next_tile += walk_speed * delta
	if percent_moved_to_next_tile >= 1.0:
		position = initial_position + (TILE_SIZE * input_derection)
		percent_moved_to_next_tile = 0.0
		state = CharState.IDLE
	else:
		position = initial_position+ (TILE_SIZE * input_derection * percent_moved_to_next_tile)

	
func animate() -> void:

	if (direction==Direction.RIGHT||direction==Direction.LEFT):
		if(state==CharState.IDLE && animatedSprite2D.animation!="side" ):
			animatedSprite2D.play("side")
		if(state==CharState.WALKING && animatedSprite2D.animation!="walk side"):
			print(animatedSprite2D.animation)
			print(animatedSprite2D.animation!="walk side")
			animatedSprite2D.play("walk side")
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
		
