extends Character
class_name Player

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
	
func _physics_process(delta: float) -> void:
	var m := move if move != null else (get_node_or_null("MovementController") as MovementController)
	if m == null || m.blocked:
		super(delta); return

	var dir := _get_dir_from_ui()  # uses ui_left/right/up/down
	# Always send intention; controller will queue if still stepping
	m.request_dir(self, dir)

	super(delta)

static func _get_dir_from_ui()->Vector2:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("ui_right"): dir.x = 1
	elif Input.is_action_pressed("ui_left"): dir.x = -1
	elif Input.is_action_pressed("ui_up"): dir.y = -1
	elif Input.is_action_pressed("ui_down"): dir.y = 1
	return dir
