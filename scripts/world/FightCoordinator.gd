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
	if w.char_state == GameGlobals.CharState.IDLE:
		_initiate_staging(w)
	
func _initiate_staging(w: WildAmalgeon)->void:
	_staging = true
	wild_node = w
	# Freeze movement on all parties
	for n in [player_node, pet_node, w]:
		if n:
			if n: n.char_state = GameGlobals.CharState.STAGING
	player_node.movement_controller.set_occupancy_use(false)
	if pet_node: pet_node.movement_controller.set_occupancy_use(false)
	var ply_cell: Vector2i
	if (player_node.movement_controller.to_cell!=Vector2i.ZERO):
		ply_cell= player_node.movement_controller.to_cell
	else:
		ply_cell= Grid.to_cell(player_node.position)
	if(pet_node and !pet_node.char_state==GameGlobals.CharState.DIEING):
		pet_staging_destination=ply_cell
		player_staging_destination=ply_cell- (player_node.movement_controller.current_dir as Vector2i)
	else:
		player_staging_destination=ply_cell
	
	print(player_staging_destination)
	print(pet_staging_destination)
	print(w.movement_controller.to_cell)

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
			print("set pet as target")
			# pick the pet as primary target
			wild_node.combat.set_target(pet_node)
		else:
			print("set player as target")
			wild_node.combat.set_target(player_node)
	for n in [player_node, pet_node, wild_node]:
		if n:n.char_state=GameGlobals.CharState.FIGHTING
	SignalBus.fight_started.emit(player_node, w)
	_staging = false

func _stage() -> void:
	if not player_node: return
	
	if !player_node.movement_controller.moving:
		player_node.movement_controller.request_dir(player_staging_destination-Grid.to_cell(player_node.global_position))
	if pet_node and !pet_node.movement_controller.moving:
		pet_node.movement_controller.request_dir(pet_staging_destination-Grid.to_cell(pet_node.global_position))

	#if pet_node: 
	#	_teleport_to_cell(pet_node, pet_staging_destination)

	
	
	if(!player_node.movement_controller.moving and Grid.to_cell(player_node.global_position) == player_staging_destination):
		if pet_node:
			if(!pet_node.movement_controller.moving and Grid.to_cell(pet_node.global_position) == pet_staging_destination):
				pet_node.movement_controller.set_occupancy_use(true)
				player_node.movement_controller.set_occupancy_use(true)
				_end_staging(wild_node)
		else:
			player_node.movement_controller.use_occupancy=true
			_end_staging(wild_node)