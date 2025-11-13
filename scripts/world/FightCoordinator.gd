extends Node
class_name FightCoordinator


var player_node: Player
var pet_node: PetAmalgeon
var wild_node:WildAmalgeon
var pet_staging_destination: Vector2i
var player_staging_destination: Vector2i

var _busy := false
var _staging:= false

func _ready() -> void:
	SignalBus.player_spawned.connect(_set_player)
	SignalBus.pet_spawned.connect(_set_pet)
	SignalBus.fight_ended.connect(_on_fight_ended)

func _process(_delta: float) -> void:
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

func _set_player(p:Player):
	player_node=p

func _set_pet(p:PetAmalgeon):
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
			if n: n.char_state = GameGlobals.CharState.STAGING
			if m: m.set_blocked(true, n)
	if(pet_node and !pet_node.char_state==GameGlobals.CharState.DIEING):
		print("here wierd stuff")
		pet_staging_destination=player_node.movement_controller.to_cell
		player_staging_destination=player_node.movement_controller.to_cell- (player_node.movement_controller.current_dir as Vector2i)
	else:
		player_staging_destination=player_node.movement_controller.to_cell

func _end_staging(w: WildAmalgeon)->void:
	# Set facings
	if pet_node:
		if player_node.has_method("set_facing_by_vec"):
			player_node.set_facing_by_vec(pet_node.global_position - player_node.global_position)
		if pet_node.has_method("set_facing_by_vec"):
			pet_node.set_facing_by_vec(wild_node.global_position - pet_node.global_position)
		if wild_node.has_method("set_facing_by_vec"):
			wild_node.set_facing_by_vec(pet_node.global_position - wild_node.global_position)
	else:
		if player_node.has_method("set_facing_by_vec"):
			player_node.set_facing_by_vec(wild_node.global_position - player_node.global_position)
		if wild_node.has_method("set_facing_by_vec"):
			wild_node.set_facing_by_vec(player_node.global_position - wild_node.global_position)
	
	# Wire up combat targets (example: player+pet vs wild)
	if player_node and player_node.combat:
		player_node.combat.set_target(wild_node)
	if pet_node and pet_node.combat:
		pet_node.combat.set_target(wild_node)
	if wild_node and wild_node.combat:
		if pet_node:
			# pick the pet as primary target
			wild_node.combat.set_target(pet_node)
		else:
			wild_node.combat.set_target(player_node)
	for n in [player_node, pet_node, wild_node]:
		if n:n.char_state=GameGlobals.CharState.FIGHTING
	SignalBus.fight_started.emit(player_node, w)
	_staging = false

func _stage() -> void:
	if not player_node or not pet_node: return
	
	#movement_controller player and pet to destination
	#var next_player_step = Pathfinder.next_step_a_star(player_node.movement_controller.to_cell,player_staging_destination,Occupancy.is_free,50)
	#var next_pet_step = Pathfinder.next_step_a_star(pet_node.movement_controller.to_cell,pet_staging_destination,Occupancy.is_free,50)
	#print(player_node.movement_controller.from_cell-next_player_step)
	#if next_player_step: player_node.movement_controller.request_dir(player_node, player_node.movement_controller.from_cell-next_player_step)
	#pet_node.movement_controller.request_dir(pet_node,  pet_node.movement_controller.from_cell-next_pet_step)

	#player_node.movement_controller.use_occupancy=false
	#pet_node.movement_controller.use_occupancy=false
	
	#var next = Pathfinder.next_step_a_star(player_node.movement_controller.to_cell,player_staging_destination,is_true,50)
	#if next: player_node.movement_controller.request_dir(player_node,next)
	#next = Pathfinder.next_step_a_star(pet_node.movement_controller.to_cell,pet_staging_destination,is_true,50)
	#if next: pet_node.movement_controller.request_dir(pet_node,next)
	_teleport_to_cell(player_node, player_staging_destination)
	if pet_node: _teleport_to_cell(pet_node, pet_staging_destination)
	
	
	if(Grid.to_cell(player_node.global_position) == player_staging_destination):
		if pet_node:
			if(Grid.to_cell(pet_node.global_position) == pet_staging_destination):
				_end_staging(wild_node)
		else:
			_end_staging(wild_node)	
	
func _teleport_to_cell(node: Node2D, cell: Vector2i) -> void:
	var current := Grid.to_cell(node.global_position)
	if Occupancy.is_free(current) == false:
		Occupancy.release(current)
	node.global_position = Grid.to_world(cell)
	Occupancy.take(cell)
