extends Node2D
class_name InteractionController

@onready var body: CharacterBody2D = $"../"
@export var label_text: String
@export var input_key: String

signal interact()

var _label := Label.new()
var _interactable = false

func _ready() -> void:
	_label.text = label_text
	_label.add_theme_font_override("font",load("res://Assets/fs-pixel-sans-unicode-regular.ttf"))
	add_child(_label)
	var w = _label.size.x
	var h = _label.size.y
	_label.offset_left=-w/2
	_label.offset_top=-h-GameGlobals.TILE_SIZE
	
	_label.visible = false
	SignalBus.player_interact_cell_changed.connect(_on_player_interact_cell_changed)

func _physics_process(_delta: float) -> void:
	if _interactable: 
		if Input.is_action_just_pressed(input_key):
			interact.emit()

func _on_player_interact_cell_changed(c:Vector2i):
	if(c==Grid.to_cell(body.global_position)):
		_label.visible = true
		_interactable = true
	else:
		_label.visible = false
		_interactable = false
