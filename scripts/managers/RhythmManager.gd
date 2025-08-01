extends Node

var bpm: float = 85.000
var wait_time: float

const CLOCK_SCENE_PATH = "res://scenes/components/Clock.tscn"
var clock_scene: PackedScene
var clock_instance: Timer
var clock_instance_eight: Timer
var last_beat_time: int


func _ready():
	print("RhythmManager initialized")
	load_clock_scene()
	wait_time = 1/(bpm/60)
	EventBus.connect("game_started", _on_game_started)
	
	#Connect to use action on beat
	#EventBus.connect("input_buffer_action", _on_input)
	
func _process(delta: float) -> void:
	pass

func load_clock_scene():
	clock_scene = load(CLOCK_SCENE_PATH)
	if not clock_scene:
		push_error("TileMapManager: Failed to load clock scene at " + CLOCK_SCENE_PATH)
	
func _on_game_started():
	clock_instance = clock_scene.instantiate()
	get_tree().current_scene.add_child(clock_instance)
	clock_instance_eight = clock_scene.instantiate()
	get_tree().current_scene.add_child(clock_instance_eight)
	clock_instance.wait_time = wait_time
	#EventBus.emit_signal("play_music", "evlan", 0.0)
	clock_instance_eight.wait_time = wait_time/8
	clock_instance.start()
	clock_instance_eight.start()
	clock_instance.connect("timeout", _on_beat)
	clock_instance_eight.connect("timeout", _on_eight_beat)

func _on_beat():
	_set_beat_time()
	#EventBus.emit_signal("play_sfx", "button_click", 1.0)
	EventBus.emit_signal("beat_triggered")

func _on_eight_beat():
	_set_beat_time()
	#EventBus.emit_signal("play_sfx", "button_click", 1.0)
	EventBus.emit_signal("eight_beat_triggered")

func _set_beat_time():
	last_beat_time = Time.get_ticks_msec()
	
func get_offset_time() -> int:
	return Time.get_ticks_msec() - last_beat_time

func _on_input(input: String):
	var is_input_on_beat = _is_on_beat()
	print("is input on beat: ", is_input_on_beat)
	if input in InputManager.movement_inputs:
		if is_input_on_beat:
			EventBus.emit_signal("movement_input_on_beat", input)
		else:
			EventBus.emit_signal("movement_input_not_on_beat", input)

func _is_on_beat() -> bool:
	var delay = get_offset_time()
	print("Input delay with the beat: ", delay)
	var seconds_between_beats :int = wait_time * 1000
	var accepted_delay: int = seconds_between_beats/4
	var is_after_beat = delay < accepted_delay and delay >= 0
	var is_before_beat = delay > seconds_between_beats-accepted_delay and delay <= seconds_between_beats 
	return is_before_beat or is_after_beat
