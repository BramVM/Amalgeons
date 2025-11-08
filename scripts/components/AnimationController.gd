extends Node
class_name AnimationController

@export var sprite_path: NodePath = ^"AnimatedSprite2D"
@export var walk_anim_up := "walk_up"
@export var walk_anim_down := "walk_down"
@export var walk_anim_side := "walk_side"
@export var idle_anim_up := "idle_up"
@export var idle_anim_down := "idle_down"
@export var idle_anim_side := "idle_side"

var _sprite: AnimatedSprite2D
var _character: Character
var _move: MovementController

func _ready() -> void:
	_character = get_parent() as Character
	_sprite = get_node_or_null(sprite_path) as AnimatedSprite2D
	if _character:
		_move = _character.move if _character.move != null else (_character.get_node_or_null("MovementController") as MovementController)

func _physics_process(_delta: float) -> void:
	if not _sprite or not _character:
		return

	var moving := _move != null and _move.is_moving()
	var d := _character.facing_dir
	
	_play_4dir(moving, d)

func _play_4dir(moving: bool, d: int) -> void:
	#if!moving:
		# sprint("stopped")
	var anim_name := ""
	if moving:
		match d:
			Directions.Dir.UP: anim_name = walk_anim_up
			Directions.Dir.DOWN: anim_name = walk_anim_down
			Directions.Dir.LEFT: anim_name = walk_anim_side
			Directions.Dir.RIGHT: anim_name = walk_anim_side
			_ : anim_name = walk_anim_down
	else:
		match d:
			Directions.Dir.UP: anim_name = idle_anim_up
			Directions.Dir.DOWN: anim_name = idle_anim_down
			Directions.Dir.LEFT: anim_name = idle_anim_side
			Directions.Dir.RIGHT: anim_name = idle_anim_side
			_ : anim_name = idle_anim_down
	_sprite.flip_h = d==Directions.Dir.LEFT
	if _sprite.animation != anim_name:
		_sprite.play(anim_name)
