extends "character.gd"
class_name WildAmalgeon

var animatedSprite2D = AnimatedSprite2D.new()
var pathDirection = Direction.NONE

@export var prey: Player

func _ready() -> void:
	initial_position = position
	add_child(animatedSprite2D)
	animatedSprite2D.frames = load("res://amalgeon_sprite.tres")
	animatedSprite2D.set_offset(Vector2(0,-2))

func _physics_process(delta: float) -> void:
	pathDirection = wanderDirection(pathDirection)
	#if( (position-prey.position).length() < 46):
		#var preyDirection = (position-prey.position).normalized().round()
		#pathDirection = Direction.NONE
		#if(preyDirection.x<0): pathDirection = Direction.RIGHT
		#if(preyDirection.x>0): pathDirection = Direction.LEFT
		#if(preyDirection.y>0): pathDirection = Direction.UP
		#if(preyDirection.y<0): pathDirection = Direction.DOWN
	#if((position-prey.position).length() < 32):
		#fight
		#enemy=prey
		#prey.enemy=self
		#prep_fighting=true
		#prey.prep_fighting=true
		#direction = pathDirection
		#pathDirection = Direction.NONE
	
	move(pathDirection,delta)
	animate(animatedSprite2D)

func wanderDirection(currentDirection:Direction) -> Direction:
	var rgn = randf()
	if (rgn>0.95):
		return Direction.NONE
	if (rgn>0.9):
		return randi_range(0, Direction.size()-1) as Direction
	return currentDirection

			
		
