extends Node

@onready var animated_texture = load("res://resources/shaders/new_animated_texture.tres")

var original_position
var shake_intensity = 2.0
var shake_duration = 0.15
var camera

func _ready():
	EventBus.connect("took_damage", _on_took_damage)
	EventBus.connect("bell_touched", _on_bell_touched)

func init():
	camera = GameManager.camera
	original_position = camera.position

func _on_took_damage():
	shake_camera()
	
func _on_bell_touched(polygon: Polygon2D):
	EventBus.emit_signal("flash_snake", Color.GREEN, 0.1)

func shake_camera():
	var tween = create_tween()
	var shake_count = 10

	EventBus.emit_signal("flash_snake", Color.RED, 0.1)

	for i in shake_count:
		var random_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		tween.tween_property(camera, "position", original_position + random_offset, shake_duration / shake_count)
		print(camera.position)
	
	# Retour à la position originale
	tween.tween_property(camera, "position", original_position, 0.1)
