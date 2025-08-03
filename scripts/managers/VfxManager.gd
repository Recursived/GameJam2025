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
	EventBus.connect("head_on_wall_collision", _on_wall_touched)
	EventBus.connect("head_on_cow_collision", _on_cow_touched)
	EventBus.connect("capture_result", _on_capture_result)

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
	#TODO Bite bell sound
	
	tail_blink_color = Color.GREEN_YELLOW
	
	# Oblgié de verifier avant chaque await car l'objet peut être détruit entre temps
	if not is_instance_valid(polygon):
		return
	var ground_color = Color(1,1,1,0.5)
	polygon.color = ground_color
	polygon.z_index = 0
	get_tree().current_scene.add_child(polygon)
	await get_tree().create_timer(0.1).timeout
	if not is_instance_valid(polygon):
		return
	polygon.color = Color(1,1,1,0)
	await get_tree().create_timer(0.1).timeout
	if not is_instance_valid(polygon):
		return
	polygon.color = ground_color
	await get_tree().create_timer(0.1).timeout
	if not is_instance_valid(polygon):
		return
	get_tree().current_scene.remove_child(polygon)
	
func _on_tail_touched():
	#TODO Bite tail at wrong place sound
	tail_blink_color = Color.DARK_ORANGE

func _on_pause_cooldown_reduced(pause_cooldown: int):
	EventBus.emit_signal("play_sfx", "button_click", 1.0)
	EventBus.emit_signal("glow_bell", tail_blink_color, 0.1)

func _on_enemy_died(enemy: EnemyManager.Enemy):
	EventBus.emit_signal("glow_enemy", Color.SANDY_BROWN, 2, enemy)

func _on_wall_touched():
	#TODO Wall hit sound
	pass
	
func _on_cow_touched():
	#TODO Wall hit sound ?
	#TODO Cow sound
	pass

func _on_capture_result(capture_result:bool):
	if capture_result:
		#TODO Capture with cow sound
		pass
	else:
		#TODO Capture without cow sound
		pass
