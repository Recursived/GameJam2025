extends Node

var bpm: float = 85.000
var wait_time: float

const CLOCK_SCENE_PATH = "res://scenes/components/Clock.tscn"
var clock_scene: PackedScene
var clock_instance: Timer
var clock_instance_quarter: Timer
var clock_instance_eight: Timer
var last_beat_time: int
var clock_quarter_current_beat: int


func _ready():
	print("RhythmManager initialized")
	load_clock_scene()
	wait_time = 1/(bpm/60)
	EventBus.connect("game_started", _on_game_started)
	
func _process(delta: float) -> void:
	pass

func set_bpm(bpm_param: int):
	bpm = bpm_param
	wait_time = 1/(bpm/60)

func load_clock_scene():
	clock_scene = load(CLOCK_SCENE_PATH)
	if not clock_scene:
		push_error("TileMapManager: Failed to load clock scene at " + CLOCK_SCENE_PATH)
	
func _on_game_started():
	clock_quarter_current_beat = 0
	
	clock_instance = clock_scene.instantiate()
	get_tree().current_scene.add_child(clock_instance)
	clock_instance_eight = clock_scene.instantiate()
	get_tree().current_scene.add_child(clock_instance_eight)
	clock_instance_quarter = clock_scene.instantiate()
	get_tree().current_scene.add_child(clock_instance_quarter)
	
	clock_instance.wait_time = wait_time
	clock_instance_quarter.wait_time = wait_time/4
	clock_instance_eight.wait_time = wait_time/8
	
	clock_instance.start()
	clock_instance_quarter.start()
	clock_instance_eight.start()
	
	clock_instance.connect("timeout", _on_beat)
	clock_instance_quarter.connect("timeout", _on_quarter_beat)
	clock_instance_eight.connect("timeout", _on_eight_beat)

func _on_beat():
	EventBus.emit_signal("beat_triggered")

func _on_quarter_beat():
	clock_quarter_current_beat+=1
	EventBus.emit_signal("quarter_beat_triggered", clock_quarter_current_beat)

func _on_eight_beat():
	EventBus.emit_signal("eight_beat_triggered")
