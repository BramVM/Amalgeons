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

func physics_tick(body: CharacterBody2D, movement: MovementController, _delta: float) -> void:
	if player == null or movement == null or body.is_queued_for_delete:
		chasing = false
		return
	var player_movement := player.get_node_or_null("MovementController")
	
	# Work in cells so we’re tile-accurate
	var my_cell:Vector2i= movement.to_cell
	var ply_cell:Vector2i= player_movement.to_cell

	var dist = (my_cell-ply_cell).length()
	if dist > aggro_range_tiles:
		chasing = false
		return

	# Already adjacent? stop stepping into them and optionally start fight
	if dist == 1:
		
		# Make sure we are not still trying to move
		movement.request_dir(body, Vector2.ZERO)
		chasing = false
		if start_fight_when_adjacent and coord and body.char_state != GameGlobals.CharState.FIGHTING and body.char_state != GameGlobals.CharState.STAGING and body.char_state != GameGlobals.CharState.DIEING :
			print(my_cell)
			print(ply_cell)
			coord.request_engagement(body)
		return

	var next = Pathfinder.next_step_a_star(my_cell,ply_cell,Occupancy.is_free,50)
	if next != null:
		var deltadir = next - my_cell
		movement.request_dir(body,deltadir)
