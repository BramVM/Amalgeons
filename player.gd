extends "character.gd"
class_name Player

var inputBuffer: Array

var animatedSprite2D = AnimatedSprite2D.new()
var destination = Vector2.ZERO
var pet:PetAmalgeon

func _ready() -> void:
	initial_position = position
	add_child(animatedSprite2D)
	animatedSprite2D.frames = load("res://player_sprite.tres")
	animatedSprite2D.set_offset(Vector2(0,-2))

func _physics_process(delta: float) -> void:
	var	moving_direction = Direction.NONE
	if(!prep_fighting): 
		moving_direction = capture_player_input()
	else:
		moving_direction = get_direction_to_position(destination, position)	
	move(moving_direction, delta)
	animate(animatedSprite2D)
	if (prep_fighting && state != CharState.WALKING):
		direction = get_direction_to_position(petPosition, position)

func capture_player_input() -> Direction:
	#press button
	if Input.is_action_just_pressed("move_right"):
		inputBuffer.append(Direction.RIGHT)
	if Input.is_action_just_pressed("move_left"):
		inputBuffer.append(Direction.LEFT)
	if Input.is_action_just_pressed("move_down"):
		inputBuffer.append(Direction.DOWN)
	if Input.is_action_just_pressed("move_up"):	
		inputBuffer.append(Direction.UP)
	#release button
	if Input.is_action_just_released("move_right"):
		inputBuffer.erase(Direction.RIGHT)
	if Input.is_action_just_released("move_left"):
		inputBuffer.erase(Direction.LEFT)
	if Input.is_action_just_released("move_down"):
		inputBuffer.erase(Direction.DOWN)
	if Input.is_action_just_released("move_up"):
		inputBuffer.erase(Direction.UP)
	if(inputBuffer && inputBuffer.back() != null):
		return inputBuffer.back()
	else: return Direction.NONE

func prep_for_fight() -> void:
	#switch with pet
	prep_fighting=true
	if(pet): pet.prep_fighting=true
	if (percent_moved_to_next_tile>0):
		destination = initial_position
		petPosition = initial_position + (TILE_SIZE * moving_vector)
	else:
		destination = petPosition
		petPosition = position

func set_pet(p:PetAmalgeon) -> void:
	pet = p