extends "character.gd"
class_name Player

var inputBuffer: Array

var animatedSprite2D = AnimatedSprite2D.new()

func _ready() -> void:
	initial_position = position
	add_child(animatedSprite2D)
	animatedSprite2D.frames = load("res://player_sprite.tres")
	animatedSprite2D.set_offset(Vector2(0,-2))

func _physics_process(delta: float) -> void:
	var player_input = Direction.NONE
	if(!prep_fighting): player_input = capture_player_input()
	move(player_input,delta)
	animate(animatedSprite2D)
	#if(prep_fighting==true):
		#switch with pet
		#petPosition = position
		#wanted_dierection = direction

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
			
