extends CharacterBody2D
class_name Character

@onready var movement_controller: MovementController = $MovementController
@export var combat: CombatController
@export var health: Health
var char_type: GameGlobals.CharType
var stats:= Stats.new()
var char_state := GameGlobals.CharState.IDLE

var is_queued_for_delete:= false
var facing_dir: int = Directions.Dir.DOWN

func _ready() -> void:
	movement_controller.step_started.connect(set_facing_by_vec)
	movement_controller.blocked_by_collision.connect(set_facing_by_vec)
	if char_type == GameGlobals.CharType.WILD: movement_controller.walk_speed = 5
	# mark occupancy if you use it:
	# Occupancy.take(Grid.to_cell(global_position, 16))


func set_facing_by_vec(v: Vector2) -> void:
	if v == Vector2.ZERO: return
	facing_dir = Directions.vec_to_dir(v)

func _physics_process(delta: float) -> void:
	if movement_controller: movement_controller.physics_tick(self, delta)
	if combat: combat.physics_tick(delta)
