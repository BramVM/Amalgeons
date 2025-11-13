extends Node
signal player_spawned(player:Player)
signal pet_spawned(pet:PetAmalgeon)
signal damaged(who: Node, amount: float)
signal start_dieing(who: Character)
signal died(who: Character)
signal fight_started(a: Node, b: Node)
signal fight_ended(a: Node, b: Node)
signal player_interact_cell_changed(cell:Vector2i)
