extends Resource
class_name AttackMove

@export var name: String = "Quick Jab"
@export var icon: Texture2D
@export var damage: int = 5
@export var attack_speed: float = 1.0   # attacks per second
@export var lifesteal: float = 0.0      # 0..1 fraction of damage returned as HP
@export var regen: float = 0.0          # HP per second (passive while equipped)

func cooldown() -> float:
	return 1.0 / max(0.01, attack_speed)
