extends Resource
class_name Stats

@export var strength := 5
@export var agility := 5
@export var vitality := 5

func attack_power() -> float:
    return 3.0 + strength * 1.2
