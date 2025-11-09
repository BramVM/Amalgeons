extends Node
var _taken := {} # Dictionary<Vector2i,bool>

func is_free(cell: Vector2i) -> bool:
	return not _taken.has(cell)

func take(cell: Vector2i) -> void:
	_taken[cell] = true

func release(cell: Vector2i) -> void:
	_taken.erase(cell)

func move(from_cell: Vector2i, to_cell: Vector2i) -> void:
	release(from_cell)
	take(to_cell)
