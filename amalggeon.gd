extends CharacterBody2D

const TILE_SIZE = 16

@export var walk_speed = 4.0
@export var master: Player

var animatedSprite2D: AnimatedSprite2D
var initial_position = Vector2(0, 0)
var input_direction = Vector2(0,0)
var is_moving = false
var percent_moved_to_next_tile = 0.0
var destiny = Vector2.ZERO

enum Direction {  
	UP,      
	DOWN,  
	RIGHT,
	LEFT  
}

var direction = Direction.DOWN
var to_target: Vector2

func _ready() -> void:
	initial_position = position
	animatedSprite2D = get_node("AnimatedSprite2D")
	animatedSprite2D.play("down")

func _physics_process(delta: float) -> void:
	if !is_moving:process_destination(delta)
	if is_moving:move(delta)
		
func process_destination(delta:float) -> void:
	destiny = master.position
	if (master.direction==Direction.UP):
		destiny.y+=TILE_SIZE
	if (master.direction==Direction.DOWN):
		destiny.y-=TILE_SIZE
	if (master.direction==Direction.RIGHT):
		destiny.x-=TILE_SIZE
	if (master.direction==Direction.LEFT):
		destiny.x+=TILE_SIZE
	
	
	to_target = master.petPosition - position
	input_direction = to_target.normalized().round()
	
	if input_direction.y == 0:
		if (input_direction.x > 0):
			animatedSprite2D.flip_h = false
			animatedSprite2D.play("walk side")
			direction = Direction.LEFT
		if (input_direction.x < 0):
			animatedSprite2D.flip_h = true
			animatedSprite2D.play("walk side")
			direction = Direction.RIGHT
	if input_direction.x == 0:
		if (input_direction.y < 0):
			animatedSprite2D.play("walk up")
			direction = Direction.UP
		if (input_direction.y > 0):
			animatedSprite2D.play("walk down")
			direction = Direction.DOWN
	if input_direction != Vector2.ZERO:
		initial_position = position
		is_moving = true

func move(delta: float)-> void:
	percent_moved_to_next_tile += walk_speed * delta
	if percent_moved_to_next_tile >= 1.0:
		position = initial_position + (TILE_SIZE * input_direction)
		percent_moved_to_next_tile = 0.0
		is_moving = false
		if !isMovementPressed():
			animateIdle()
	else:
		position = initial_position+ (TILE_SIZE * input_direction * percent_moved_to_next_tile)

func isMovementPressed() -> bool:
	return Input.is_action_pressed("ui_right") || Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_down") || Input.is_action_pressed("ui_up")
	
func animateIdle() -> void:
	if (input_direction.x != 0):
		animatedSprite2D.play("side")
	if (input_direction.y < 0):
		animatedSprite2D.play("up")
	if (input_direction.y > 0):
		animatedSprite2D.play("down")
