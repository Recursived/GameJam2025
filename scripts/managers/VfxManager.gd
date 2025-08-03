extends Node

@onready var animated_texture = load("res://resources/shaders/new_animated_texture.tres")

var original_position
var shake_intensity = 2.0
var shake_duration = 0.15
var camera
var tail_blink_color: Color = Color.GREEN_YELLOW

func _ready():
	EventBus.connect("took_damage", _on_took_damage)
	EventBus.connect("pause_cooldown_reduced", _on_pause_cooldown_reduced)
	EventBus.connect("enemy_died", _on_enemy_died)
	EventBus.connect("bell_touched", _on_bell_touched)
	EventBus.connect("tail_touched", _on_tail_touched)

func init():
	camera = GameManager.camera
	original_position = camera.position
	
func _on_took_damage():
	shake_camera()

func shake_camera():
	tail_blink_color = Color.DARK_RED
	
	var tween = create_tween()
	var shake_count = 10

	for i in shake_count:
		var random_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		tween.tween_property(camera, "position", original_position + random_offset, shake_duration / shake_count)
		print(camera.position)
	
	# Retour à la position originale
	tween.tween_property(camera, "position", original_position, 0.1)

func _on_bell_touched(polygon: Polygon2D):
	tail_blink_color = Color.GREEN_YELLOW
	
func _on_tail_touched():
	tail_blink_color = Color.DARK_ORANGE

func _on_pause_cooldown_reduced(pause_cooldown: int):
	EventBus.emit_signal("play_sfx", "button_click", 1.0)
	EventBus.emit_signal("glow_bell", tail_blink_color, 0.1)

func _on_enemy_died(enemy: EnemyManager.Enemy):
	EventBus.emit_signal("glow_enemy", Color.SANDY_BROWN, 2, enemy)
