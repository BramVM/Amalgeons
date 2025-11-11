extends CharacterBody2D
class_name Character

@export var move: MovementController
@export var combat: CombatController
@export var health: Health
var char_type: GameGlobals.CharType
var stats:= Stats.new()
var char_state := GameGlobals.CharState.IDLE

var is_queued_for_delete:= false
var facing_dir: int = Directions.Dir.DOWN

func _ready() -> void:
	if move:
		move.step_started.connect(set_facing_by_vec)
		move.blocked_by_collision.connect(set_facing_by_vec)
		if char_type == GameGlobals.CharType.WILD: move.walk_speed = 6
	# mark occupancy if you use it:
	# Occupancy.take(Grid.to_cell(global_position, 16))


func set_facing_by_vec(v: Vector2) -> void:
	if v == Vector2.ZERO: return
	facing_dir = Directions.vec_to_dir(v)

func _physics_process(delta: float) -> void:
	if move: move.physics_tick(self, delta)
	if combat: combat.physics_tick(delta)
