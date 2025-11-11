extends Node
class_name Spawner

@export var PlayerScene: PackedScene
@export var PetAmalgeonScene: PackedScene
@export var WildAmalgeonScene: PackedScene
@export var MonumentScene: PackedScene
@export var fight_coordinator: NodePath
@onready var y_sort_node:Node2D = $"../YSort"
@onready var ui = $"../UI"

var coord := get_node_or_null(fight_coordinator)

var player: Player
var pet: PetAmalgeon
var wilds: Array
const NUMBER_OF_SPAWNS:= 1
const SPAWN_DISTANCE:= 10
const DESPAWN_DISTANCE:= 20
const PLAYER_SPAWN_LOCATION:= Vector2i(1, 1)
const PET_SPAWN_LOCATION:= Vector2i(1, 0)

func _ready() -> void:
	coord = get_node_or_null(fight_coordinator)
	spawn_player_at(PLAYER_SPAWN_LOCATION)
	coord.set_player(player)
	spawn_pet_at(PET_SPAWN_LOCATION,player)
	ui.set_pet(pet)   
	coord.set_pet(pet)
	var monument=spawn_monument_at(Vector2i(4, 3))
	monument.set_player(player)
	monument.set_pet(pet)
	SignalBus.died.connect(_despawn)
	
func _process(delta: float) -> void:
	#spawn in when not enough
	if wilds.size() < NUMBER_OF_SPAWNS:
		var spawn_location=Vector2(0,SPAWN_DISTANCE*GameGlobals.TILE_SIZE)
		var random_radians=randf_range(0, PI*2)
		spawn_location = spawn_location.rotated(random_radians)+player.global_position
		spawn_location = Grid.to_cell(spawn_location)
		wilds.append(spawn_wild_at(spawn_location))
	if player:
		for w in wilds :
			if(w):
				var dist = (Grid.to_cell(player.global_position) - Grid.to_cell(w.global_position)).length()
				if dist>DESPAWN_DISTANCE:
					_despawn(w)
		pass

func _cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * GameGlobals.TILE_SIZE, cell.y * GameGlobals.TILE_SIZE)

func _place_on_grid(node: Node2D, cell: Vector2i) -> void:
	node.global_position = _cell_to_world(cell)

func _take(cell: Vector2i) -> void:
	if Occupancy.is_free(cell):
		Occupancy.take(cell)
	else:
		push_warning("Tile %s is occupied" % [cell])

func spawn_player_at(cell: Vector2i) -> Player:
	var inst := PlayerScene.instantiate() as Player
	y_sort_node.add_child(inst)
	_place_on_grid(inst, cell)
	_take(cell)
	player = inst
	return inst

func spawn_monument_at(cell: Vector2i) -> Monument:
	var inst := MonumentScene.instantiate() as Monument
	y_sort_node.add_child(inst)
	_place_on_grid(inst, cell)
	_take(cell)
	return inst

func spawn_pet_at(cell: Vector2i, master: Node = null) -> PetAmalgeon:
	var inst := PetAmalgeonScene.instantiate() as PetAmalgeon
	y_sort_node.add_child(inst)
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
	y_sort_node.add_child(inst)
	_place_on_grid(inst, cell)
	_take(cell)

	# Wire chase target + coordinator
	var chase := inst.get_node_or_null("WildChaseAI") as WildChaseAI
	if chase:
		if player:
			chase.set_target_player(player)
		if coord:
			chase.set_fight_coordinator(coord)

	return inst

func _despawn(c:Character):
	var p = Grid.to_cell(c.global_position)
	Occupancy.release(p)
	c.is_queued_for_delete=true
	SignalBus.fight_ended.emit()
	if c.char_type==GameGlobals.CharType.WILD :
		wilds.erase(c)
	if c.char_type==GameGlobals.CharType.PLAYER :
		spawn_player_at(PLAYER_SPAWN_LOCATION)
		coord.set_player(player)
		if!pet:
			spawn_pet_at(PET_SPAWN_LOCATION,player)    
			coord.set_pet(pet)
		for w in wilds :
			var chase := w.get_node_or_null("WildChaseAI") as WildChaseAI
			if chase:
				chase.set_target_player(player)
	c.queue_free()
	
