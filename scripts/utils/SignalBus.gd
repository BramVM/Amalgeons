extends Node
signal damaged(who: Node, amount: float)
signal died(who: Character)
signal fight_started(a: Node, b: Node)
signal fight_ended(a: Node, b: Node)
signal player_interact_cell_changed(cell:Vector2i)
