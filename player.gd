extends CharacterBody2D

@export var walk_speed = 4.0
const TILE_SIZE = 16

var initial_position = Vector2(0, 0)
var input_derection = Vector2(0,0)
var is_moving = false
var percent_moved_to_next_tile = 0.0

func _ready() -> void:
	initial_position = position

func _physics_process(delta: float) -> void:
	if !is_moving:
		process_player_input()
	elif input_derection != Vector2.ZERO:
		move(delta)
	else:
		is_moving = false

func process_player_input() -> void:
	if input_derection.y == 0:
		input_derection.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if input_derection.x == 0:
		input_derection.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	if input_derection != Vector2.ZERO:
		initial_position = position
		is_moving = true

func move(delta: float)-> void:
	percent_moved_to_next_tile += walk_speed * delta
	if percent_moved_to_next_tile >= 1.0:
		position = initial_position + (TILE_SIZE * input_derection)
		percent_moved_to_next_tile = 0.0
		is_moving = false
	else:
		position = initial_position+ (TILE_SIZE * input_derection * percent_moved_to_next_tile)
