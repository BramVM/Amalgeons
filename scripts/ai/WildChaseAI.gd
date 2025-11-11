extends Node
class_name WildChaseAI

@export var aggro_range_tiles := 5
@export var target_player: NodePath
@export var fight_coordinator: NodePath
@export var start_fight_when_adjacent := true
var chasing=false

var player := get_node_or_null(target_player)
var coord := get_node_or_null(fight_coordinator)

func set_target_player(p: Player) -> void:
	player = p

func set_fight_coordinator(f: FightCoordinator) -> void:
	coord = f

func physics_tick(body: CharacterBody2D, movement: MovementController, delta: float) -> void:
	if player == null or movement == null or body.is_queued_for_delete:
		chasing = false
		return
	var player_movement := player.get_node_or_null("MovementController")
	
	# Work in cells so we’re tile-accurate
	var my_cell:Vector2i= movement.to_cell
	var ply_cell:Vector2i= player_movement.to_cell
	print(movement.to_cell)
	var dist = (my_cell-ply_cell).length()
	if dist > aggro_range_tiles:
		chasing = false
		return

	# Already adjacent? stop stepping into them and optionally start fight
	if dist == 1:
		# Make sure we are not still trying to move
		movement.request_dir(body, Vector2.ZERO)
		chasing = false
		if start_fight_when_adjacent and coord and body.char_state != GameGlobals.CharState.FIGHTING and body.char_state != GameGlobals.CharState.STAGING :
			coord.request_engagement(body)
		return

	# We need to move closer, but NEVER step into the player's cell.
	# Choose a cardinal step that reduces Manhattan distance.
	var step := _choose_step_toward(my_cell, ply_cell)

	# If our best step *would* enter the player's cell, cancel instead.
	if my_cell + step == ply_cell:
		step = Vector2.ZERO

	# Also respect occupancy if enabled: avoid stepping into taken cells
	if step != Vector2i.ZERO and movement.use_occupancy:
		var next_cell := my_cell + Vector2i(step)
		# treat the player's cell as blocked even if Occupancy hasn't been taken yet
		var blocked := (next_cell == ply_cell) or (not Occupancy.is_free(next_cell))
		if blocked:
			step = Vector2.ZERO
	chasing = true
	#movement.request_dir(body, step)

	var next = Pathfinder.next_step_a_star(my_cell,ply_cell,Occupancy.is_free,50)
	if next != null:
		var deltadir = next - my_cell
		movement.request_dir(body,deltadir)

func _choose_step_toward(from_cell: Vector2i, to_cell: Vector2i) -> Vector2i:
	var dx := to_cell.x - from_cell.x
	var dy := to_cell.y - from_cell.y

	# Try the axis with the larger gap first, then the other axis as a fallback.
	var primary: Vector2
	var secondary: Vector2
	if abs(dx) >= abs(dy):
		primary = Vector2(signi(dx), 0)
		secondary = Vector2(0, signi(dy))
	else:
		primary = Vector2(0, signi(dy))
		secondary = Vector2(signi(dx), 0)

	# Prefer a move that reduces distance AND is free (we’ll double-check occupancy above).
	if primary != Vector2.ZERO:
		return primary
	return secondary

static func signi(v: int) -> int:
	return 1 if v > 0 else (-1 if v < 0 else 0)
