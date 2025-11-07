class_name Directions

enum Dir { NONE = -1, DOWN, LEFT, RIGHT, UP }

static var DIR_TO_VEC := {
	Dir.DOWN: Vector2(0, 1),
	Dir.LEFT: Vector2(-1, 0),
	Dir.RIGHT: Vector2(1, 0),
	Dir.UP: Vector2(0, -1),
}

static func vec_to_dir(v: Vector2) -> int:
	if abs(v.x) > abs(v.y):
		return Dir.RIGHT if v.x > 0 else Dir.LEFT
	elif abs(v.y) > 0:
		return Dir.DOWN if v.y > 0 else Dir.UP
	return Dir.NONE

static func dir_to_vec(d: int) -> Vector2:
	return DIR_TO_VEC.get(d, Vector2.ZERO)
