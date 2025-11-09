class_name Grid

static func to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(round(pos.x / GameGlobals.TILE_SIZE), round(pos.y / GameGlobals.TILE_SIZE))

static func to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * GameGlobals.TILE_SIZE, cell.y * GameGlobals.TILE_SIZE)

static func neighbors4(cell: Vector2i) -> Array[Vector2i]:
	return [cell + Vector2i.LEFT, cell + Vector2i.RIGHT, cell + Vector2i.UP, cell + Vector2i.DOWN]
