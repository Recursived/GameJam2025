extends Node2D

signal enemy_collided(body)

@onready var area_entity: AreaEntity = $AreaEntity

func _ready():
	if area_entity:
		area_entity.connect("body_entered", Callable(self, "_on_area_entity_body_entered"))

# Public method to configure AreaEntity after node is ready
func initialize(origin: Vector2, width: int, height: int):
	if area_entity:
		area_entity.set_width(width)
		area_entity.set_height(height)
		area_entity.set_origin_offset(origin)

func _on_area_entity_body_entered(body):
	emit_signal("enemy_collided", body)
