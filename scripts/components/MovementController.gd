extends Node
class_name MovementController

@export var tile_size: int = 16
@export var walk_speed: float = 4.0  # tiles/sec
@export var use_occupancy := true

signal step_started(dir: Vector2)
signal step_finished()

var _percent: float = 0.0
var _from: Vector2 = Vector2.ZERO
var _to: Vector2 = Vector2.ZERO
var _from_cell: Vector2i
var _to_cell: Vector2i
var _moving: bool = false
var blocked: bool = false
var _queued_dir: Vector2 = Vector2.ZERO     # buffered intention (from input/AI)
var _current_dir: Vector2 = Vector2.ZERO    # direction of the active step

func set_blocked(v: bool, body: CharacterBody2D) -> void:
	blocked = v
	if blocked:
		# finish the current step instantly so we're on-grid, then stop
		if _moving:
			_moving = false
			_percent = 1.0
			body.position = _to
			if use_occupancy:
				Occupancy.move(_from_cell, _to_cell)
			_from_cell = _to_cell
			step_finished.emit()
		_queued_dir = Vector2.ZERO

func is_moving() -> bool:
	return _moving

func current_cell() -> Vector2i:
	# while moving, the logical cell is the destination
	return _to_cell if _moving else _from_cell
	
# Call this EVERY FRAME with your intended direction (Vector2.ZERO if no input).
func request_dir(body: CharacterBody2D, dir_vec: Vector2) -> void:
	if _moving:
		_queued_dir = dir_vec  # buffer; applied at tile boundary
		return
	if dir_vec != Vector2.ZERO:
		_start_step(body, dir_vec)

func _start_step(body: CharacterBody2D, dir_vec: Vector2) -> void:
	_current_dir = dir_vec
	_from = body.position
	_to = _from + dir_vec * tile_size
	_from_cell = Grid.to_cell(body.global_position, tile_size)
	_to_cell = _from_cell + Vector2i(dir_vec)
	_percent = 0.0
	_moving = true
	step_started.emit(dir_vec)

func physics_tick(body: CharacterBody2D, delta: float) -> void:
	if blocked: return
	if not _moving: return
	_percent = min(1.0, _percent + walk_speed * delta)
	body.position = _from.lerp(_to, _percent)
	if _percent >= 1.0:
		_moving = false
		if use_occupancy:
			Occupancy.move(_from_cell, _to_cell)
		_from_cell = _to_cell
		step_finished.emit()
		# chain immediately to avoid idle flicker
		if _queued_dir != Vector2.ZERO:
			var next := _queued_dir
			_queued_dir = Vector2.ZERO
			_start_step(body, next)
