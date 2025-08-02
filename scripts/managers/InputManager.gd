extends Node

var input_buffer: Array[String] = []
var buffer_time: float = 0.2
var buffer_timer: float = 0.0

var input_history: Array[Dictionary] = []
var max_history_size: int = 100

var input_enabled: bool = true
var input_context: String = "game"

const input_code_to_char = {
	"R":"ui_right",
	"L":"ui_left",
	"U":"ui_up",
	"D":"ui_down"
}

const input_code_to_sprite = {
	"RR":{"tail":"body_X", "bell":"tail_X", "angle":PI, "bell_angle":PI},
	"LL":{"tail":"body_X", "bell":"tail_X", "angle":0, "bell_angle":0},
	"DD":{"tail":"body_Y", "bell":"tail_Y", "angle":PI, "bell_angle":PI},
	"UU":{"tail":"body_Y", "bell":"tail_Y", "angle":0, "bell_angle":0},
	"RD":{"tail":"angle_up_right", "bell":"tail_Y", "angle":0, "bell_angle":PI},
	"RU":{"tail":"angle_down_right", "bell":"tail_Y", "angle":0, "bell_angle":0},
	"LD":{"tail":"angle_up_left", "bell":"tail_Y", "angle":0, "bell_angle":PI},
	"LU":{"tail":"angle_down_left", "bell":"tail_Y", "angle":0, "bell_angle":0},
	"DR":{"tail":"angle_down_left", "bell":"tail_X", "angle":0, "bell_angle":PI},
	"DL":{"tail":"angle_down_right", "bell":"tail_X", "angle":0, "bell_angle":0},
	"UR":{"tail":"angle_up_left", "bell":"tail_X", "angle":0, "bell_angle":PI},
	"UL":{"tail":"angle_up_right", "bell":"tail_X", "angle":0, "bell_angle":0},
}

const input_to_angle = {
	"ui_up": 0,
	"ui_down": PI,
	"ui_left": -PI/2,
	"ui_right": PI/2
}

const input_dict = {
	"ui_up": {
		"neighbor": TileSet.CELL_NEIGHBOR_TOP_SIDE
	},
	"ui_down": {
		"neighbor": TileSet.CELL_NEIGHBOR_BOTTOM_SIDE
	},
	"ui_left": {
		"neighbor": TileSet.CELL_NEIGHBOR_LEFT_SIDE
	},
	"ui_right": {
		"neighbor": TileSet.CELL_NEIGHBOR_RIGHT_SIDE
	}
}

const input_translation = {
	"ui_up": "U",
	"ui_down": "D",
	"ui_left": "L",
	"ui_right": "R"
}

func _ready():
	print("InputManager initialized")

func _process(delta):
	if buffer_timer > 0:
		buffer_timer -= delta
		if buffer_timer <= 0:
			clear_input_buffer()

func _input(event):
	if not input_enabled:
		return
	
	# Record input history
	record_input(event)
	
	# Handle buffered inputs
	if event.is_pressed():
		handle_buffered_input(event)

func handle_buffered_input(event: InputEvent):
	var action_name = ""
	
	# Check all defined input actions
	for action in InputMap.get_actions():
		if event.is_action_pressed(action):
			action_name = action
			break
	
	if action_name != "":
		add_to_buffer(action_name)

func add_to_buffer(action: String):
	input_buffer.append(action)
	buffer_timer = buffer_time
	EventBus.emit_signal("input_buffer_action", action)

func clear_input_buffer():
	input_buffer.clear()

func is_action_buffered(action: String) -> bool:
	return action in input_buffer

func consume_buffered_action(action: String) -> bool:
	if action in input_buffer:
		input_buffer.erase(action)
		return true
	return false

func record_input(event: InputEvent):
	var input_data = {
		"timestamp": Time.get_time_dict_from_system(),
		"event": event,
		"context": input_context
	}
	
	input_history.append(input_data)
	
	if input_history.size() > max_history_size:
		input_history.pop_front()

func set_input_enabled(enabled: bool):
	input_enabled = enabled

func set_input_context(context: String):
	input_context = context

func is_action_just_pressed_buffered(action: String) -> bool:
	return Input.is_action_just_pressed(action) or consume_buffered_action(action)

func input_code_to_input_ui(input_code: String):
	return {
		"previous_input": input_code_to_char[input_code[0]],
		"next_input": input_code_to_char[input_code[1]]
	}
