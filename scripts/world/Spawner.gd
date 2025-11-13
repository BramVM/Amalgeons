extends Node
class_name Spawner

@export var PlayerScene: PackedScene
@export var PetAmalgeonScene: PackedScene
@export var WildAmalgeonScene: PackedScene
@export var MonumentScene: PackedScene
@export var fight_coordinator: NodePath
@onready var y_sort_node:Node2D = $"../YSort"
@onready var ui = $"../UI"
@onready var coord := $"../FightCoordinator"


var player: Player
var pet: PetAmalgeon
var wilds: Array
const NUMBER_OF_SPAWNS:= 4
const SPAWN_DISTANCE:= 10
const DESPAWN_DISTANCE:= 20
const PLAYER_SPAWN_LOCATION:= Vector2i(3, 4)
const PET_SPAWN_LOCATION:= Vector2i(3, 2)

func start():
	spawn_pet_at(PET_SPAWN_LOCATION)
	spawn_player_at(PLAYER_SPAWN_LOCATION)
	spawn_monument_at(Vector2i(4, 3))

func _ready() -> void:
	SignalBus.died.connect(_despawn)
	
	
func _process(_delta: float) -> void:
	if !player:
		return
	#spawn in when not enough
	if wilds.size() < NUMBER_OF_SPAWNS:
		var spawn_location=Vector2(0,SPAWN_DISTANCE*GameGlobals.TILE_SIZE)
		var random_radians=randf_range(0, PI*2)
		spawn_location = spawn_location.rotated(random_radians)+player.global_position
		spawn_location = Grid.to_cell(spawn_location)
		wilds.append(spawn_wild_at(spawn_location))
		for w in wilds :
			if(w):
				var dist = (Grid.to_cell(player.global_position) - Grid.to_cell(w.global_position)).length()
				if dist>DESPAWN_DISTANCE:
					_despawn(w)

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
	SignalBus.player_spawned.emit(inst)
	return inst

func spawn_monument_at(cell: Vector2i) -> Monument:
	var inst := MonumentScene.instantiate() as Monument
	y_sort_node.add_child(inst)
	_place_on_grid(inst, cell)
	_take(cell)
	return inst

func spawn_pet_at(cell: Vector2i) -> PetAmalgeon:
	var inst := PetAmalgeonScene.instantiate() as PetAmalgeon
	y_sort_node.add_child(inst)
	_place_on_grid(inst, cell)
	SignalBus.pet_spawned.emit(inst)
	_take(cell)
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
		if!pet:
			spawn_pet_at(PET_SPAWN_LOCATION)  
		spawn_player_at(PLAYER_SPAWN_LOCATION)  
		for w in wilds :
			if(w):
				var chase := w.get_node_or_null("WildChaseAI") as WildChaseAI
				if chase:
					chase.set_target_player(player)
	c.queue_free()
	
