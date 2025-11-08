class_name Grid

static func to_cell(pos: Vector2, tile_size := 16) -> Vector2i:
	return Vector2i(round(pos.x / tile_size), round(pos.y / tile_size))

static func to_world(cell: Vector2i, tile_size := 16) -> Vector2:
	return Vector2(cell.x * tile_size, cell.y * tile_size)

static func neighbors4(cell: Vector2i) -> Array[Vector2i]:
	return [cell + Vector2i.LEFT, cell + Vector2i.RIGHT, cell + Vector2i.UP, cell + Vector2i.DOWN]
