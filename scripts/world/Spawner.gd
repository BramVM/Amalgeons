extends Node
class_name Spawner

@export var tile_size: int = 16

# Drag your .tscn scenes in the Inspector:
@export var PlayerScene: PackedScene
@export var PetAmalgeonScene: PackedScene
@export var WildAmalgeonScene: PackedScene

# Optional: set this to your FightCoordinator node in the World
@export var fight_coordinator: NodePath
var coord := get_node_or_null(fight_coordinator)

var player: Player
var pet: PetAmalgeon

func _ready() -> void:
	coord = get_node_or_null(fight_coordinator)
	spawn_player_at(Vector2i(1, 1))
	coord.set_player(player)
	spawn_pet_at(Vector2i(4, 5))    
	coord.set_pet(pet)     # auto-follows player
	spawn_wild_at(Vector2i(10, 7))        # auto-chases player

func _world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(round(pos.x / tile_size), round(pos.y / tile_size))

func _cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * tile_size, cell.y * tile_size)

func _place_on_grid(node: Node2D, cell: Vector2i) -> void:
	node.global_position = _cell_to_world(cell)

func _take(cell: Vector2i) -> void:
	if Occupancy.is_free(cell):
		Occupancy.take(cell)
	else:
		push_warning("Tile %s is occupied" % [cell])

# ----------------- Public API -----------------

func spawn_player_at(cell: Vector2i) -> Player:
	var inst := PlayerScene.instantiate() as Player
	add_child(inst)
	_place_on_grid(inst, cell)
	_take(cell)
	player = inst
	return inst

func spawn_pet_at(cell: Vector2i, master: Node = null) -> PetAmalgeon:
	var inst := PetAmalgeonScene.instantiate() as PetAmalgeon
	add_child(inst)
	_place_on_grid(inst, cell)
	_take(cell)

	# Wire follow AI
	var follow := inst.get_node_or_null("FollowMasterAI") as FollowMasterAI
	var m := master if master != null else player
	if follow and m:
		follow.set_master(m)  # uses the helper from earlier; otherwise set follow.master = inst.get_path_to(m)

	pet = inst
	return inst

func spawn_wild_at(cell: Vector2i) -> WildAmalgeon:
	if not Occupancy.is_free(cell):
		push_warning("Cannot spawn wild at %s (occupied)" % [cell])
		return null

	var inst := WildAmalgeonScene.instantiate() as WildAmalgeon
	add_child(inst)
	_place_on_grid(inst, cell)
	_take(cell)

	# Wire chase target + coordinator
	var chase := inst.get_node_or_null("WildChaseAI") as WildChaseAI
	if chase:
		if player:
			chase.set_target_player(player)
		if coord:
			chase.set_fight_coordinator(coord)

	# Cleanup occupancy on death
	SignalBus.died.connect(func(who, _amt := 0.0):
		if who == inst:
			var c := _world_to_cell(inst.global_position)
			Occupancy.release(c)
			inst.queue_free()
	)
	return inst
