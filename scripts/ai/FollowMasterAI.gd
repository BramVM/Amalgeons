extends Node
class_name FollowMasterAI

@export var follow_distance_tiles: int = 1
@export var movement_path: NodePath

var _master: Character
var _slot_cell: Vector2i
var _last_step_dir := Vector2.DOWN  # default for initial slot
var movement:MovementController

func _ready() -> void:
	movement=get_node_or_null(movement_path)

func physics_tick(body: CharacterBody2D, m: MovementController, _delta: float) -> void:
	if _master and (_master.position-body.position).length()>GameGlobals.TILE_SIZE*2:
		_move_to_target()
	if m and m.is_moving():
		_move_to_target()
	
func set_master(master: Character) -> void:
	_master = master
	_master.movement_controller.step_started.connect(_on_master_step_started)
	_master.movement_controller.step_finished.connect(_on_master_step_finished)
	_seed_slot()

func _move_to_target()->void:
	if not _master or not movement: return
	if _master.char_state!=GameGlobals.CharState.IDLE: return	
	var body:= get_parent()
	var me := Grid.to_cell(body.global_position)

	# Stop if we're already in the desired slot
	if me == _slot_cell:
		movement.request_dir(Vector2.ZERO)
		return

	var next = Pathfinder.next_step_a_star(me,_slot_cell,Occupancy.is_free,50)
	if next != null:
		var delta = next - me
		movement.request_dir(delta)
	
func _on_master_step_started(dir: Vector2) -> void:
	if dir != Vector2.ZERO:
		_last_step_dir = dir
	if not _master:
		return
	var m := Grid.to_cell(_master.global_position)
	_slot_cell = m

func _on_master_step_finished() -> void:
	_move_to_target()
	
func _seed_slot() -> void:
	var m := Grid.to_cell(_master.global_position)
	_slot_cell = m - Vector2i(_last_step_dir) * follow_distance_tiles

func _step_toward(from_cell: Vector2i, to_cell: Vector2i) -> Vector2:
	var dx := to_cell.x - from_cell.x
	var dy := to_cell.y - from_cell.y
	if abs(dx) >= abs(dy):
		return Vector2(sign(dx), 0) if dx != 0 else Vector2(0, sign(dy))
	else:
		return Vector2(0, sign(dy)) if dy != 0 else Vector2(sign(dx), 0)
