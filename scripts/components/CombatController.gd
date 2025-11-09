extends Node
class_name CombatController

@export var attack_move: AttackMove
@export var target: NodePath
var _cooldown := 0.0
var target_node := get_node_or_null(target)

func set_target(t:Character) -> void:
	target_node=t

func physics_tick(delta: float) -> void:
	# Passive regen for the user if they have Health
	
	if not attack_move: return

	if _cooldown > 0.0:
		_cooldown -= delta
		return
	
	#var my_health: Health = get_parent().get_node_or_null("Health") as Health
	#if my_health and attack_move.regen != 0.0:
		#my_health.hp = clamp(my_health.hp + attack_move.regen * delta, 0.0, my_health.max_hp)


	if not target_node: return


	_perform_attack(target_node)

func _perform_attack(tgt: Character) -> void:
	var dmg: float = float(attack_move.damage)
	var th: Health = tgt.get_node_or_null("Health") as Health
	if th:
		var pre_hp: float = th.hp
		th.apply_damage(dmg)
		var dealt: float = pre_hp - th.hp

		# Lifesteal
		if attack_move.lifesteal != 0.0:
			var my_health: Health = get_parent().get_node_or_null("Health") as Health
			if my_health:
				my_health.hp = clamp(my_health.hp + dealt * attack_move.lifesteal, 0.0, my_health.max_hp)

	_cooldown = attack_move.cooldown()
