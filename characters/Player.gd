extends Character
class_name Player

var pet : PetAmalgeon
var interaction_cell: Vector2i

func _ready() -> void:
	SignalBus.pet_spawned.connect(set_pet)
	char_type = GameGlobals.CharType.PLAYER
	movement_controller.step_finished.connect(_on_step_finished)
	movement_controller.blocked_by_collision.connect(_on_step_blocked)
	super._ready()

func set_pet(p:PetAmalgeon) -> void:
	pet=p
	if !p.master:p.set_master(self)
	
func _on_step_finished():
	interaction_cell = movement_controller.from_cell + (Directions.dir_to_vec(facing_dir) as Vector2i)
	SignalBus.player_interact_cell_changed.emit(interaction_cell)

func _on_step_blocked(d:Vector2):
	interaction_cell = movement_controller.from_cell + (d as Vector2i)
	SignalBus.player_interact_cell_changed.emit(interaction_cell)

func _physics_process(delta: float) -> void:

	if movement_controller == null || char_state == GameGlobals.CharState.FIGHTING || char_state == GameGlobals.CharState.STAGING:
		super._physics_process(delta); return

	var dir := _get_dir_from_ui()  # uses ui_left/right/up/down
	# Always send intention; controller will queue if still stepping
	movement_controller.request_dir(self, dir)

	super._physics_process(delta)

static func _get_dir_from_ui()->Vector2:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("ui_right"): dir.x = 1
	elif Input.is_action_pressed("ui_left"): dir.x = -1
	elif Input.is_action_pressed("ui_up"): dir.y = -1
	elif Input.is_action_pressed("ui_down"): dir.y = 1
	return dir
