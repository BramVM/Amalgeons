class_name MathUtils

static func snap_to_grid(p: Vector2) -> Vector2:
	return Vector2(round(p.x / GameGlobals.TILE_SIZE) * GameGlobals.TILE_SIZE, round(p.y / GameGlobals.TILE_SIZE) * GameGlobals.TILE_SIZE)

static func manhattan(a: Vector2, b: Vector2) -> int:
	return int(abs(a.x - b.x) + abs(a.y - b.y))
