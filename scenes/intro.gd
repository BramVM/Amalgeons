extends Panel

@onready var spawner := $"../../Spawner"
var counter=1


func _process(delta: float) -> void:
	if counter>0:
		counter-=delta
		if counter<=0:
			visible=false
			spawner.start()
