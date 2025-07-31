class_name Head
extends Area2D

@export var movement_step: int = 60

var next_move:Vector2 = Vector2.ZERO
var previous_position:Vector2 = Vector2.ZERO

func _ready():
	EventBus.connect("input_buffer_action", set_next_move)
	EventBus.connect("rollback_head", on_rollback_head)
	self.connect("area_entered", on_head_collide)
	previous_position = position

func _physics_process(delta):
	if not PlayerManager.is_alive:
		return
	
	previous_position = position
	
	var next_position = position + (next_move*movement_step)
	if next_position != PlayerManager.get_last_tail_position():
		position = next_position
	
	if position != previous_position:
		EventBus.emit_signal("head_position_changed", previous_position, position)
	
	next_move = Vector2.ZERO


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

func on_head_collide(area: Area2D):
	if is_instance_of(area, Tail):
		EventBus.emit_signal("head_on_tail_collision", area)
	else:
		EventBus.emit_signal("head_on_wall_collision", area)

func on_rollback_head(new_position: Vector2):
	EventBus.emit_signal("head_rollbacked")
	position = new_position
