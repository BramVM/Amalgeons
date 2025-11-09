extends Node
class_name FollowMasterAI

@export var tile_size: int = 16
@export var follow_distance_tiles: int = 1
@export var movement_path: NodePath

var _master: Character
var _slot_cell: Vector2i
var _last_step_dir := Vector2.DOWN  # default for initial slot
var movement:MovementController

func _ready() -> void:
	movement=get_node_or_null(movement_path)

func physics_tick(body: CharacterBody2D, movement: MovementController, delta: float) -> void:
	if (_master.position-body.position).length()>tile_size*2:
		_move_to_target()
	if movement and movement.is_moving():
		_move_to_target()
	
func set_master(master: Character) -> void:
	_master = master
	if _master and _master.move:
		_master.move.step_started.connect(_on_master_step_started)
		_master.move.step_finished.connect(_on_master_step_finished)
		_seed_slot()

func _move_to_target()->void:
	if not _master or not movement: return
	var body:= get_parent()
	var me := Grid.to_cell(body.global_position, tile_size)
	var m := Grid.to_cell(_master.global_position, tile_size)

	# Stop if we're already in the desired slot
	if me == _slot_cell:
		movement.request_dir(body, Vector2.ZERO)
		return

	# Pick simple cardinal step toward target slot
	var step := _step_toward(me, _slot_cell)
	var next := me + Vector2i(step)

	# Always enforce occupancy
	#
	if not Occupancy.is_free(next):
		movement.request_dir(body, Vector2.ZERO)
		return

	movement.request_dir(body, step)
	
func _on_master_step_started(dir: Vector2) -> void:
	if dir != Vector2.ZERO:
		_last_step_dir = dir
	if not _master:
		return
	var m := Grid.to_cell(_master.global_position, tile_size)
	_slot_cell = m

func _on_master_step_finished() -> void:
	_move_to_target()
	
func _seed_slot() -> void:
	var m := Grid.to_cell(_master.global_position, tile_size)
	_slot_cell = m - Vector2i(_last_step_dir) * follow_distance_tiles

func _step_toward(from_cell: Vector2i, to_cell: Vector2i) -> Vector2:
	var dx := to_cell.x - from_cell.x
	var dy := to_cell.y - from_cell.y
	if abs(dx) >= abs(dy):
		return Vector2(sign(dx), 0) if dx != 0 else Vector2(0, sign(dy))
	else:
		return Vector2(0, sign(dy)) if dy != 0 else Vector2(sign(dx), 0)
