extends Camera2D

var animation_counter:= 0.0
var target_zoom:= 0.0
var zoom_per_sec:=Vector2.ZERO

func _ready() -> void:
	SignalBus.fight_started.connect(_on_fight_start)
	SignalBus.fight_ended.connect(_on_fight_end)
	
func _on_fight_start() -> void:
	print("zoom")
	_zoom_over_time(2,0.5)

func _on_fight_end() -> void:
	_zoom_over_time(1,0.5)

func _process(delta: float) -> void:
	if (animation_counter > 0.0): _zoom(delta)
	else: zoom = Vector2(target_zoom,target_zoom)

func _zoom_over_time(z:float, sec:float)->void:
	target_zoom=z
	var current_zoom=(zoom.x)
	var inc_per_sec = (target_zoom-current_zoom)/2
	zoom_per_sec=Vector2(inc_per_sec,inc_per_sec)
	animation_counter=sec

func _zoom(delta)->void:
	zoom+=(zoom_per_sec*delta)
	animation_counter-=delta
	
