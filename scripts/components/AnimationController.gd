extends Node
class_name AnimationController

@export var sprite_path: NodePath = ^"AnimatedSprite2D"
@export var walk_anim_up := "walk_up"
@export var walk_anim_down := "walk_down"
@export var walk_anim_side := "walk_side"
@export var idle_anim_up := "idle_up"
@export var idle_anim_down := "idle_down"
@export var idle_anim_side := "idle_side"
@export var hurt_anim_up := "hurt_up"
@export var hurt_anim_down := "hurt_down"
@export var hurt_anim_side := "hurt_side"

var _sprite: AnimatedSprite2D
var _character: Character
var _move: MovementController
var _hurt_animation_counter:= 0.0
var _hurt:= false

const HURT_TIME=0.1

func _ready() -> void:
	_character = get_parent() as Character
	_sprite = get_node_or_null(sprite_path) as AnimatedSprite2D
	SignalBus.damaged.connect(_on_damaged)
	if _character:
		_move = _character.move if _character.move != null else (_character.get_node_or_null("MovementController") as MovementController)

func _physics_process(_delta: float) -> void:
	if not _sprite or not _character:
		return

	var moving := _move != null and _move.is_moving()
	var d := _character.facing_dir
	
	_play_4dir(moving, _hurt_animation_counter>0, d)
	_sprite.position = Vector2.ZERO
	
	if _hurt_animation_counter>0:
		_sprite.position =- Directions.dir_to_vec(_character.facing_dir)
		_hurt_animation_counter-=_delta

func _on_damaged(who: Node, amount: float):
	if(who==_character): _hurt_animation_counter=HURT_TIME

func _play_4dir(moving: bool, hurt: bool, d: int) -> void:
	var anim_name := ""
	if moving:
		match d:
			Directions.Dir.UP: anim_name = walk_anim_up
			Directions.Dir.DOWN: anim_name = walk_anim_down
			Directions.Dir.LEFT: anim_name = walk_anim_side
			Directions.Dir.RIGHT: anim_name = walk_anim_side
			_ : anim_name = walk_anim_down
	elif hurt:
		match d:
			Directions.Dir.UP: anim_name = hurt_anim_up
			Directions.Dir.DOWN: anim_name = hurt_anim_down
			Directions.Dir.LEFT: anim_name = hurt_anim_side
			Directions.Dir.RIGHT: anim_name = hurt_anim_side
			_ : anim_name = hurt_anim_down
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
