class_name MathUtils

static func snap_to_grid(p: Vector2, tile_size := 16) -> Vector2:
	return Vector2(round(p.x / tile_size) * tile_size, round(p.y / tile_size) * tile_size)

static func manhattan(a: Vector2, b: Vector2) -> int:
	return int(abs(a.x - b.x) + abs(a.y - b.y))
