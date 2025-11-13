extends CanvasLayer

class_name UI

@onready var pet_panel = $PetPanel
@onready var level = $PetPanel/HBoxContainer/VBoxContainer2/Level
@onready var available_stat_points = $PetPanel/HBoxContainer/VBoxContainer/AvailableStatPoints
@onready var damage_box = $PetPanel/HBoxContainer/VBoxContainer/HBoxContainer/DamageBox
@onready var speed_box = $PetPanel/HBoxContainer/VBoxContainer/HBoxContainer2/SpeedBox
@onready var vitality_box = $PetPanel/HBoxContainer/VBoxContainer/HBoxContainer3/Vitality
@onready var damage_calc = $PetPanel/HBoxContainer/VBoxContainer/HBoxContainer/DamageCalc
@onready var speed_calc = $PetPanel/HBoxContainer/VBoxContainer/HBoxContainer2/SpeedCalc
@onready var vitality_calc = $PetPanel/HBoxContainer/VBoxContainer/HBoxContainer3/VitCalc
@onready var assign_stats_button = $PetPanel/HBoxContainer/VBoxContainer/AvailableStatPoints
@onready var exp_bar = $PetPanel/HBoxContainer/VBoxContainer2/Exp


var _pet:PetAmalgeon

func _ready() -> void:
	SignalBus.pet_spawned.connect(_set_pet)

func _process(_delta: float) -> void:
	if _pet:
		level.visible=true
		level.text="level: "+str(_pet.stats.level)
		available_stat_points.text="Unspent statpoints: "+str(_pet.stats.unspent_stat_points())
		var _spent_on_vit = vitality_box.value - _pet.stats.hit_points
		var _spent_on_speed = damage_box.value - _pet.stats.speed
		var _spent_on_damage = speed_box.value - _pet.stats.damage
		var total_spent = _spent_on_vit +_spent_on_speed +_spent_on_damage
		vitality_box.max_value = min(vitality_box.value+_pet.stats.unspent_stat_points()-total_spent, 50)
		speed_box.max_value = min(speed_box.value+_pet.stats.unspent_stat_points()-total_spent, 50)
		damage_box.max_value = min(damage_box.value+_pet.stats.unspent_stat_points()-total_spent, 50)
		speed_calc.text = "+" + str(_pet.stats.get_effective_stat_points(speed_box.value)*10) + "%"
		damage_calc.text = "+" + str(_pet.stats.get_effective_stat_points(damage_box.value)*10) + "%"
		vitality_calc.text = "+" + str(_pet.stats.get_effective_stat_points(vitality_box.value)*10) + "%"
		exp_bar.value = _pet.stats.exp
		
func _on_petinteract():
	_init_panel()
	pet_panel.visible=true

func _init_panel():
	if _pet:
		damage_box.value = _pet.stats.damage
		speed_box.value = _pet.stats.speed 
		vitality_box.value = _pet.stats.hit_points
		damage_box.min_value = _pet.stats.damage
		speed_box.min_value = _pet.stats.speed
		vitality_box.min_value = _pet.stats.hit_points

func _set_pet(p:PetAmalgeon):
	_pet=p
	#if ready _init_panel()
	p.get_node("InteractionController").interact.connect(_on_petinteract)


func _on_assign_stat_points_pressed() -> void:
	if _pet:
		_pet.stats.damage = damage_box.value
		_pet.stats.speed = speed_box.value
		_pet.stats.hit_points = vitality_box.value
		_init_panel()

func _on_close_pet_panel_pressed() -> void:
	pet_panel.visible=false
