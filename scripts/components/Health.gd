extends Node
class_name Health

@export var max_hp := 100.0
@export var armor := 0
@export var healthBar: NodePath = ^"ProgressBar"
var healthBar_node:ProgressBar
var hp = max_hp
const HIDE_DELAY = 2
var _hide_delay_counter: float

func set_max_health(h:float):
	max_hp = h
	if healthBar_node: healthBar_node.max_value=max_hp
	


func _is_critical()->bool:
	return max_hp/hp>3

func _is_damaged()->bool:
	return max_hp>hp

func _ready() -> void:
	healthBar_node= get_parent().get_node_or_null(healthBar)
	if healthBar_node: healthBar_node.max_value=max_hp
	if healthBar_node: healthBar_node.value=hp
	
func _process(delta: float) -> void:
	set_max_health(get_parent().stats.max_hit_points())
	if healthBar_node:
		if _hide_delay_counter>0: 
			_hide_delay_counter-=delta
			healthBar_node.visible=true
		elif _is_damaged():
			healthBar_node.visible=true
		else:
			healthBar_node.visible=false
	
func apply_damage(amount: float) -> void:
	var mitigated:float = max(0.0, amount - armor)
	hp = clamp(hp - mitigated, 0.0, max_hp)
	if healthBar_node:healthBar_node.value=hp
	SignalBus.damaged.emit(get_parent(), mitigated)
	_hide_delay_counter = HIDE_DELAY
	if hp <= 0.0:
		get_parent().char_state = GameGlobals.CharState.DIEING
		SignalBus.start_dieing.emit(get_parent())
		

func heal(amount: float) -> void:
	hp = min(hp + amount, max_hp)
	if healthBar_node:healthBar_node.value=hp
	_hide_delay_counter = HIDE_DELAY
