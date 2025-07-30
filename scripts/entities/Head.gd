extends Area2D

@export var movement_step: int = 60
@export var max_size: int = 10

var size: int
var is_alive: bool = true
var next_move:Vector2 = Vector2.ZERO

func _ready():
	size = max_size
	EventBus.connect("player_respawned", _on_respawned)
	EventBus.connect("input_buffer_action", set_next_move)

func _physics_process(delta):
	if not is_alive:
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
	
	
func take_damage(amount: int):
	max_size -= amount
	max_size = max(0, max_size)
	EventBus.emit_signal("player_health_changed", size, max_size)
	
	if max_size <= 0:
		die()

func die():
	is_alive = false
	EventBus.emit_signal("player_died")
	EventBus.emit_signal("play_sfx", "player_death")

func _on_respawned():
	size = max_size
	is_alive = true
	# global_position = Vector2.ZERO  # Or spawn point
