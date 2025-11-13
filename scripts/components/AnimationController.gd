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
@export var die_anim_up := "die_up"
@export var die_anim_down := "die_down"
@export var die_anim_side := "die_side"

var _sprite: AnimatedSprite2D
var _character: Character
var _move: MovementController
var _hurt_animation_counter:= 0.0
var _death_animation_counter:= 0.0

const HURT_TIME=0.1
const DEATH_ANIMATION_TIME=0.8

func _ready() -> void:
	_character = get_parent() as Character
	_sprite = get_node_or_null(sprite_path) as AnimatedSprite2D
	SignalBus.damaged.connect(_on_damaged)
	SignalBus.start_dieing.connect(_on_death)
	if _character:
		_move = _character.movement_controller if _character.movement_controller != null else (_character.get_node_or_null("MovementController") as MovementController)

func _physics_process(_delta: float) -> void:
	if not _sprite or not _character:
		return

	var moving := _move != null and _move.is_moving()
	var d := _character.facing_dir
	_play_4dir(moving, _hurt_animation_counter>0, _death_animation_counter>0, d)
	_sprite.position = Vector2.ZERO
	
	if _hurt_animation_counter>0:
		_sprite.position =- Directions.dir_to_vec(_character.facing_dir)
		_hurt_animation_counter-=_delta
	
	if _death_animation_counter>0:
		_death_animation_counter-=_delta
		if(_death_animation_counter<=0):
			SignalBus.died.emit(_character)

func _on_damaged(who: Node, _amount: float):
	if(who==_character): _hurt_animation_counter=HURT_TIME

func _on_death(who: Node):
	if(who==_character): _death_animation_counter=DEATH_ANIMATION_TIME

func _play_4dir(moving: bool, hurt: bool, death:bool, d: int) -> void:
	var anim_name := ""
	if moving:
		match d:
			Directions.Dir.UP: anim_name = walk_anim_up
			Directions.Dir.DOWN: anim_name = walk_anim_down
			Directions.Dir.LEFT: anim_name = walk_anim_side
			Directions.Dir.RIGHT: anim_name = walk_anim_side
			_ : anim_name = walk_anim_down
	elif death:
		match d:
			Directions.Dir.UP: anim_name = die_anim_up
			Directions.Dir.DOWN: anim_name = die_anim_down
			Directions.Dir.LEFT: anim_name = die_anim_side
			Directions.Dir.RIGHT: anim_name = die_anim_side
			_ : anim_name = die_anim_down
		anim_name = die_anim_down
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
