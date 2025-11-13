class_name Pathfinder

## Public: return the *next* grid cell from `start` toward `goal`, or null if no path.
## - `passable(cell)` should return true for walkable cells. Goal is auto-allowed.
static func next_step_a_star(
		start: Vector2i,
		goal: Vector2i,
		passable: Callable,
		max_iters: int = 10000
	) -> Variant:
	if start == goal:
		return start

	var open: Array[Vector2i] = [start]
	var came_from := {}                             # Dictionary<Vector2i, Vector2i>
	var g := { start: 0 }                           # Dictionary<Vector2i, int>
	var f := { start: _h(start, goal) }             # Dictionary<Vector2i, int>

	var iters := 0
	while open.size() > 0 and iters < max_iters:
		iters += 1

		# pick node in 'open' with lowest f-score (small list: O(n) is fine)
		var best_idx := 0
		var best_val = f.get(open[0], 1 << 30)
		for i in range(1, open.size()):
			var val = f.get(open[i], 1 << 30)
			if val < best_val:
				best_idx = i
				best_val = val

		var current: Vector2i = open[best_idx]
		open.remove_at(best_idx)

		if current == goal:
			var path := _reconstruct(came_from, current)
			# path includes [start, ..., goal]; return next step after start
			return path[1] if path.size() > 1 else start

		for n in _neighbors4(current):
			# allow the goal even if blocked so you can path *to* an occupied target
			if n != goal and not passable.call(n):
				continue

			var tentative_g = g.get(current, 1 << 30) + 1
			if tentative_g < g.get(n, 1 << 30):
				came_from[n] = current
				g[n] = tentative_g
				f[n] = tentative_g + _h(n, goal)
				if not open.has(n):
					open.push_back(n)

	# no path
	return null


# ----------------------
# Helpers
# ----------------------
static func _h(a: Vector2i, b: Vector2i) -> int:
	# Manhattan distance for 4-dir grids
	return abs(a.x - b.x) + abs(a.y - b.y)

static func _neighbors4(c: Vector2i) -> Array[Vector2i]:
	# Replace with Grid.neighbors4(c) if you have it.
	return [c + Vector2i.RIGHT, c + Vector2i.LEFT, c + Vector2i.DOWN, c + Vector2i.UP]

static func _reconstruct(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = [current]
	while came_from.has(current):
		current = came_from[current]
		path.push_front(current)
	return path
