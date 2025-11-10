extends Node
class_name FightCoordinator

@export var player: NodePath
@export var pet: NodePath
@export var wild: NodePath
var player_node: Player
var pet_node: PetAmalgeon
var wild_node:WildAmalgeon
var pet_staging_destination: Vector2i
var player_staging_destination: Vector2i

var _busy := false
var _staging:= false

func _ready() -> void:
	if !player_node: player_node = get_node_or_null(player)
	if !player_node: pet_node = get_node_or_null(pet)
	if !player_node: wild_node = get_node_or_null(wild)
	SignalBus.fight_ended.connect(_on_fight_ended)

func _process(delta: float) -> void:
	if(_staging): _stage()
	
func _on_fight_ended() -> void:
	for n in [player_node, pet_node, wild_node]:
		if n:
			var m: MovementController = n.get_node_or_null("MovementController") as MovementController
			if m: m.set_blocked(false, n)
			n.char_state=GameGlobals.CharState.IDLE
			_busy=false
		#var c := n as Character
		#if c: c.char_state = Character.CharState.IDLE

func set_player(p:Player):
	player_node=p

func set_pet(p:PetAmalgeon):
	pet_node=p

func request_engagement(w: WildAmalgeon) -> void:
	if _busy: return
	_busy = true
	if w.char_state != GameGlobals.CharState.STAGING:
		_initiate_staging(w)
	
func _initiate_staging(w: WildAmalgeon)->void:
	_staging = true
	wild_node = w
	# Freeze movement on all parties
	for n in [player_node, pet_node, w]:
		if n:
			var m: MovementController = n.get_node_or_null("MovementController") as MovementController
			n.char_state = GameGlobals.CharState.STAGING
			if m: m.set_blocked(true, n)
	#player_node.get_node("Camera2D").zoom_over_time(2,0.5)
	pet_staging_destination=player_node.move.to_cell
	player_staging_destination=player_node.move.to_cell- (player_node.move.current_dir as Vector2i)

func _end_staging(w: WildAmalgeon)->void:
	for n in [player_node, pet_node, wild_node]:
		if n:n.char_state=GameGlobals.CharState.FIGHTING
	SignalBus.fight_started.emit(player_node, w)
	_staging = false

func _stage() -> void:
	if not pet_node: return
	
	#move player and pet to destination
	#var next_player_step = Pathfinder.next_step_a_star(player_node.move.to_cell,player_staging_destination,Occupancy.is_free,50)
	#var next_pet_step = Pathfinder.next_step_a_star(pet_node.move.to_cell,pet_staging_destination,Occupancy.is_free,50)
	#print(player_node.move.from_cell-next_player_step)
	#if next_player_step: player_node.move.request_dir(player_node, player_node.move.from_cell-next_player_step)
	#pet_node.move.request_dir(pet_node,  pet_node.move.from_cell-next_pet_step)
	
	_teleport_to_cell(player_node, player_staging_destination)
	_teleport_to_cell(pet_node, pet_staging_destination)


	# 3) Set facings
	if player_node.has_method("set_facing_by_vec"):
		player_node.set_facing_by_vec(pet_node.global_position - player_node.global_position)
	if pet_node.has_method("set_facing_by_vec"):
		pet_node.set_facing_by_vec(wild_node.global_position - pet_node.global_position)
	if wild_node.has_method("set_facing_by_vec"):
		wild_node.set_facing_by_vec(pet_node.global_position - wild_node.global_position)
	

	# Wire up combat targets (example: player+pet vs wild)
	if player_node and player_node.combat:
		player_node.combat.set_target(wild_node)
	if pet_node and pet_node.combat:
		pet_node.combat.set_target(wild_node)
	if wild_node and wild_node.combat:
		# pick the player as primary target
		wild_node.combat.set_target(pet_node)
	if(Grid.to_cell(player_node.global_position) == player_staging_destination && Grid.to_cell(pet_node.global_position) == pet_staging_destination):
		_end_staging(wild_node)	
	
func _teleport_to_cell(node: Node2D, cell: Vector2i) -> void:
	var current := Grid.to_cell(node.global_position)
	if Occupancy.is_free(current) == false:
		Occupancy.release(current)
	node.global_position = Grid.to_world(cell)
	Occupancy.take(cell)
