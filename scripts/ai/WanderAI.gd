extends Node
class_name WanderAI

@export var interval := 0.75
var _timer := 0.0

func physics_tick(body: CharacterBody2D, movement: MovementController, delta: float) -> void:
	_timer -= delta
	if movement.is_moving() or _timer > 0.0:
		return
	_timer = interval
	var dirs = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2.ZERO]
	var d: Vector2 = dirs[randi() % dirs.size()]
	movement.request_dir(body, d)
