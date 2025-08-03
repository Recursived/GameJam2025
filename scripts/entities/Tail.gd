class_name Tail 
extends Area2D

@onready var shader_capture = load("res://resources/shaders/crapture_shader_material.tres")

@onready var sprite = $AnimatedSprite2D
@export var is_bell:bool = false
var is_odd:bool
var input_state: String

func _ready():
	is_odd = false
	is_bell = false
	EventBus.connect("bell_changed", on_becoming_bell)
	EventBus.connect("quarter_beat_triggered", _on_quarter_beat)
	EventBus.connect("glow_bell", _on_glow_bell)
	sprite.material = shader_capture

func _physics_process(delta):
	pass

func on_becoming_bell(bell: Tail):
	if self == bell:
		is_bell = true
		sprite.animation = InputManager.input_code_to_sprite[input_state]["bell"]
		sprite.rotation = InputManager.input_code_to_sprite[input_state]["bell_angle"]

func get_center_point():
	var collision_rect: CollisionShape2D = get_node("CollisionShape2D")
	return collision_rect.global_position

func set_input_state(previous_input: String, current_input: String):
	var previous = InputManager.input_translation[previous_input]
	var current = InputManager.input_translation[current_input]
	input_state = previous+current
	sprite.animation = InputManager.input_code_to_sprite[input_state]["tail"]
	sprite.rotation = InputManager.input_code_to_sprite[input_state]["angle"]
	
func set_is_odd(odd: bool):
	is_odd = odd

func _on_quarter_beat(quarter_beat_number: int):
	if is_odd:
		sprite.frame = quarter_beat_number % 7
	else:
		sprite.frame = 7 - (quarter_beat_number%7)

func _on_glow_bell(color: Color, duration: float):
	if is_instance_valid(PlayerManager.current_polygon):
		var ground_color = Color(1,1,1,0.5)
		PlayerManager.current_polygon.color = ground_color
		PlayerManager.current_polygon.z_index = 0
		get_tree().current_scene.add_child(PlayerManager.current_polygon)
	
	shader_capture.set_shader_parameter("flash_strength", 0.5)
	shader_capture.set_shader_parameter("flash_color", color)
	await get_tree().create_timer(duration).timeout
	shader_capture.set_shader_parameter("flash_strength", 0.0)
	
	if is_instance_valid(PlayerManager.current_polygon):
		PlayerManager.current_polygon.color = Color(1,1,1,0)
		
