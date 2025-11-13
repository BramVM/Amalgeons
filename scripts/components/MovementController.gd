extends Node
class_name MovementController

@export var walk_speed: float = 4.0  # tiles/sec
@export var use_occupancy := true

signal step_started(dir: Vector2)
signal blocked_by_collision(dir: Vector2)
signal step_finished()

var _percent: float = 0.0
var _from: Vector2 = Vector2.ZERO
var _to: Vector2 = Vector2.ZERO
@onready var from_cell: Vector2i
@onready var to_cell: Vector2i
var moving: bool = false
var blocked: bool = false
var _queued_dir: Vector2 = Vector2.ZERO     # buffered intention (from input/AI)
var current_dir: Vector2 = Vector2.ZERO    # direction of the active step

func set_blocked(v: bool, body: CharacterBody2D) -> void:
	blocked = v
	if blocked:
		# finish the current step instantly so we're on-grid, then stop
		if moving:
			moving = false
			_percent = 1.0
			body.position = _to
			if use_occupancy:
				Occupancy.move(from_cell, to_cell)
			from_cell = to_cell
			step_finished.emit()
		_queued_dir = Vector2.ZERO

func is_moving() -> bool:
	return moving

func current_cell() -> Vector2i:
	# while moving, the logical cell is the destination
	return to_cell if moving else from_cell
	
# Call this EVERY FRAME with your intended direction (Vector2.ZERO if no input).
func request_dir(body: CharacterBody2D, dir_vec: Vector2) -> void:
	var destiny_cell = Grid.to_cell(body.global_position+dir_vec*GameGlobals.TILE_SIZE)
	if moving:
		if Occupancy.is_free(destiny_cell) or !use_occupancy:
			_queued_dir = dir_vec  # buffer; applied at tile boundary
		return
	if dir_vec != Vector2.ZERO:
		if Occupancy.is_free(destiny_cell) or !use_occupancy:
			_start_step(body, dir_vec)
		else:
			blocked_by_collision.emit(dir_vec)

func _start_step(body: CharacterBody2D, dir_vec: Vector2) -> void:
	current_dir = dir_vec
	_from = body.position
	_to = _from + dir_vec * GameGlobals.TILE_SIZE
	from_cell = Grid.to_cell(body.global_position)
	to_cell = from_cell + Vector2i(dir_vec)
	if use_occupancy:
		Occupancy.move(from_cell, to_cell)
	from_cell = to_cell
	_percent = 0.0
	moving = true
	step_started.emit(dir_vec)

func physics_tick(body: CharacterBody2D, delta: float) -> void:
	if blocked: return
	if not moving: return
	_percent = min(1.0, _percent + walk_speed * delta)
	body.position = _from.lerp(_to, _percent)
	if _percent >= 1.0:
		if use_occupancy:
			Occupancy.move(from_cell, to_cell)
		from_cell = to_cell
		step_finished.emit()
		# chain immediately if something is queued — do NOT drop _moving to false
		if _queued_dir != Vector2.ZERO:
			var next := _queued_dir
			var destiny_cell = Grid.to_cell(body.global_position+next*GameGlobals.TILE_SIZE)
			_queued_dir = Vector2.ZERO
			if Occupancy.is_free(destiny_cell) or !use_occupancy:
				_start_step(body, next)
			else:
				blocked_by_collision.emit(next)			
		else:
			moving = false
	
func set_occupancy_use(b:bool):
	use_occupancy = b
	Occupancy.release(to_cell)