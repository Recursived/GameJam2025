class_name Head
extends Area2D

@export var movement_step: int = 60

var next_move:Vector2 = Vector2.ZERO

func _ready():
	EventBus.connect("input_buffer_action", set_next_move)

func _physics_process(delta):
	if not PlayerManager.is_alive:
		return
	
	var previous_position = position
	
	position += next_move*movement_step
	
	next_move = Vector2.ZERO
	
	if position != previous_position:
		EventBus.emit_signal("head_position_changed", previous_position, position)


func set_next_move(action: String):
	const input_dict = {
		"ui_up": Vector2(0, -1),
		"ui_down": Vector2(0, 1),
		"ui_left": Vector2(-1, 0),
		"ui_right": Vector2(1, 0)
	}
	if action in input_dict.keys():
		next_move = input_dict.get(action)
	else:
		next_move = Vector2.ZERO
