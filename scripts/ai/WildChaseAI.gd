extends Node
class_name WildChaseAI

@export var aggro_range_tiles := 5
@export var target_player: NodePath
@export var fight_coordinator: NodePath
@export var start_fight_when_adjacent := true
var chasing=false

var player := get_node_or_null(target_player)
var coord := get_node_or_null(fight_coordinator)

func _ready() -> void:
	SignalBus.player_spawned.connect(set_target_player)

func set_target_player(p: Player) -> void:
	player = p

func set_fight_coordinator(f: FightCoordinator) -> void:
	coord = f

func physics_tick(body: Character, movement: MovementController, _delta: float) -> void:
	if player == null or movement == null or body.is_queued_for_delete:
		chasing = false
		return
	if body.char_state!=GameGlobals.CharState.IDLE:
		chasing  = false
		return	
	if player.char_state!=GameGlobals.CharState.IDLE:
		chasing  = false
		return	
	
	# Work in cells so we’re tile-accurate
	var my_cell:Vector2i
	var ply_cell:Vector2i

	if (body.movement_controller.to_cell!=Vector2i.ZERO):
		my_cell= body.movement_controller.to_cell
	else:
		my_cell= Grid.to_cell(body.position)
	if (player.movement_controller.to_cell!=Vector2i.ZERO):
		ply_cell= player.movement_controller.to_cell
	else:
		ply_cell= Grid.to_cell(player.position)

	var dist = (my_cell-ply_cell).length()
	if dist > aggro_range_tiles:
		chasing = false
		return

	# Already adjacent? stop stepping into them and optionally start fight
	if dist == 1:
		# Make sure we are not still trying to move
		movement.request_dir(Vector2.ZERO)
		chasing = false
		if start_fight_when_adjacent and coord and player.char_state != GameGlobals.CharState.FIGHTING and player.char_state != GameGlobals.CharState.STAGING and player.char_state != GameGlobals.CharState.DIEING :
			coord.request_engagement(body)
		return

	var next = Pathfinder.next_step_a_star(my_cell,ply_cell,Occupancy.is_free,50)
	if next != null:
		var deltadir = next - my_cell
		movement.request_dir(deltadir)
