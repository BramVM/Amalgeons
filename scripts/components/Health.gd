extends Node
class_name Health

@export var max_hp := 100.0
@export var armor := 0
@export var healthBar: NodePath = ^"ProgressBar"
var healthBar_node:ProgressBar
var hp = max_hp

func _ready() -> void:
	healthBar_node=get_parent().get_node_or_null(healthBar)
	if healthBar_node: healthBar_node.max_value=max_hp
	if healthBar_node: healthBar_node.value=hp

func apply_damage(amount: float) -> void:
	var mitigated:float = max(0.0, amount - armor)
	hp = clamp(hp - mitigated, 0.0, max_hp)
	if healthBar_node:healthBar_node.value=hp
	SignalBus.damaged.emit(get_parent(), mitigated)
	if hp <= 0.0:
		SignalBus.died.emit(get_parent())
		

func heal(amount: float) -> void:
	hp = min(hp + amount, max_hp)
	if healthBar_node:healthBar_node.value=hp
