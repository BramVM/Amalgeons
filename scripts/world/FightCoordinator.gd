extends Node
class_name FightCoordinator

@export var player: NodePath
@export var pet: NodePath
@export var wild: NodePath
var player_node: Player
var pet_node: PetAmalgeon
var wild_node:WildAmalgeon

var _busy := false

func _ready() -> void:
	if !player_node: player_node = get_node_or_null(player)
	if !player_node: pet_node = get_node_or_null(pet)
	if !player_node: wild_node = get_node_or_null(wild)
	SignalBus.fight_ended.connect(_on_fight_ended)

func _on_fight_ended() -> void:
	for n in [player_node, pet_node, wild_node]:
		if n:
			var m: MovementController = n.get_node_or_null("MovementController") as MovementController
			if m: m.set_blocked(false, n)
		#var c := n as Character
		#if c: c.state = Character.CharState.IDLE

func set_player(p:Player):
	player_node=p

func set_pet(p:PetAmalgeon):
	pet_node=p

func request_engagement(w: WildAmalgeon) -> void:
	if _busy: return
	_busy = true
	_stage(w)
	_busy = false

func _stage(w: WildAmalgeon) -> void:
	if not pet_node: return
	
	# Freeze movement on all parties
	for n in [player_node, pet_node, w]:
		if n:
			var m: MovementController = n.get_node_or_null("MovementController") as MovementController
			if m: m.set_blocked(true, n)
	
	# 1) Swap player <-> pet tiles
	var p_cell := Grid.to_cell(player_node.global_position)
	var pet_cell := Grid.to_cell(pet_node.global_position)
	var wild_cell := Grid.to_cell(w.global_position)
	_teleport_to_cell(player_node, pet_cell)
	_teleport_to_cell(pet_node, p_cell)

	# 2) Find a free tile adjacent to pet for wild, not player's tile if not next to it
	var dist =(p_cell-wild_cell).length()
	if (dist>1):
		var player_cell := Grid.to_cell(player_node.global_position)
		var candidates := []
		for nb in Grid.neighbors4(Grid.to_cell(pet_node.global_position)):
			if nb != player_cell and Occupancy.is_free(nb):
				candidates.append(nb)
		if candidates.is_empty():
			for nb2 in Grid.neighbors4(Grid.to_cell(pet_node.global_position)):
				if nb2 != player_cell:
					candidates.append(nb2)
					break
		wild_cell = candidates[0]
	_teleport_to_cell(w, wild_cell)

	# 3) Set facings
	if player_node.has_method("set_facing_by_vec"):
		player_node.set_facing_by_vec(pet_node.global_position - player_node.global_position)
	if pet_node.has_method("set_facing_by_vec"):
		pet_node.set_facing_by_vec(w.global_position - pet_node.global_position)
	if w.has_method("set_facing_by_vec"):
		w.set_facing_by_vec(pet_node.global_position - w.global_position)
	

	# Wire up combat targets (example: player+pet vs wild)
	if player_node and player_node.combat:
		player_node.combat.set_target(w)
	if pet_node and pet_node.combat:
		pet_node.combat.set_target(w)
	if w and w.combat:
		# pick the player as primary target
		w.combat.set_target(pet_node)
	wild_node=w
	# 4) Signal fight start
	SignalBus.fight_started.emit(player_node, w)

func _teleport_to_cell(node: Node2D, cell: Vector2i) -> void:
	var current := Grid.to_cell(node.global_position)
	if Occupancy.is_free(current) == false:
		Occupancy.release(current)
	node.global_position = Grid.to_world(cell)
	Occupancy.take(cell)
