extends Node

func _ready():
	EventBus.connect("took_damage", _on_took_damage)
	EventBus.connect("took_damage", _on_bell_touched)

func _on_took_damage():
	pass
	
func _on_bell_touched(polygon: Polygon2D):
	pass
