extends CanvasLayer

class_name UI

@onready var level = $PetPanel/Level
@onready var available_stat_points = $PetPanel/AvailableStatPoints
@onready var damage_box = $PetPanel/DamageBox
@onready var speed_box = $PetPanel/SpeedBox
@onready var vitality_box = $PetPanel/Vitality

var _pet:PetAmalgeon

func _process(delta: float) -> void:
	if _pet:
		level.visible=true
		level.text="level: "+str(_pet.stats.level)
		available_stat_points.text="Unspent statpoints: "+str(_pet.stats.unspent_stat_points())
		var _spent_on_vit = vitality_box.value - _pet.stats.hit_points
		var _spent_on_speed = damage_box.value - _pet.stats.speed
		var _spent_on_damage = speed_box.value - _pet.stats.damage
		vitality_box.max_value = _pet.stats.hit_points+_pet.stats.unspent_stat_points()-_spent_on_speed-_spent_on_damage
		speed_box.max_value = _pet.stats.speed+_pet.stats.unspent_stat_points()-_spent_on_vit-_spent_on_damage
		damage_box.max_value = _pet.stats.damage+_pet.stats.unspent_stat_points()-_spent_on_speed-_spent_on_vit
		print( _pet.stats.damage+_pet.stats.unspent_stat_points()-_spent_on_speed-_spent_on_vit)
		
func _on_petinteract():
	_init_panel()
	visible=true

func _init_panel():
	if _pet:
		#damage_box.value = _pet.stats.damage
		#speed_box.value = _pet.stats.speed 
		#vitality_box.value = _pet.stats.hit_points
		damage_box.min_value = _pet.stats.damage
		speed_box.min_value = _pet.stats.speed
		vitality_box.min_value = _pet.stats.hit_points

func set_pet(p:PetAmalgeon):
	_pet=p
	p.get_node("InteractionController").interact.connect(_on_petinteract)
