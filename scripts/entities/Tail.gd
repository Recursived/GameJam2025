class_name Tail 
extends Area2D


@onready var sprite = $AnimatedSprite2D
@export var is_bell:bool = false
var is_odd:bool
var input_state: String

func _ready():
	is_odd = false
	is_bell = false
	EventBus.connect("bell_changed", on_becoming_bell)
	EventBus.connect("quarter_beat_triggered", _on_quarter_beat)

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
