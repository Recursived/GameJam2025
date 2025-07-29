extends Node

var current_scene_name: String = ""
var loading_screen_scene = preload("res://scenes/UI/LoadingScreen.tscn")

var scene_paths = {
	"Main": "res://scenes/Main.tscn",
	"StartScreen": "res://scenes/UI/StartScreen.tscn",
}

func _ready():
	var root = get_tree().current_scene
	current_scene_name = root.scene_file_path.get_file().get_basename()
	print("SceneManager initialized. Current scene: ", current_scene_name)

func change_scene(scene_name: String, use_loading_screen: bool = false):
	if not scene_paths.has(scene_name):
		print("Error: Scene '", scene_name, "' not found in scene_paths")
		return
	
	EventBus.emit_signal("scene_transition_started", current_scene_name, scene_name)
	
	if use_loading_screen:
		change_scene_with_loading(scene_name)
	else:
		change_scene_immediate(scene_name)

func change_scene_immediate(scene_name: String):
	var scene_path = scene_paths[scene_name]
	var result = get_tree().change_scene_to_file(scene_path)
	
	if result == OK:
		current_scene_name = scene_name
		EventBus.emit_signal("scene_transition_completed", scene_name)
		print("Scene changed to: ", scene_name)
	else:
		print("Error changing scene to: ", scene_name)

func change_scene_with_loading(scene_name: String):
	# Show loading screen first
	var loading_instance = loading_screen_scene.instantiate()
	get_tree().current_scene.add_child(loading_instance)
	
	# Load the target scene in the background
	var scene_path = scene_paths[scene_name]

	# Start threaded loading
	ResourceLoader.load_threaded_request(scene_path)
	# Wait for the resource to finish loading
	while ResourceLoader.load_threaded_get_status(scene_path) != ResourceLoader.THREAD_LOAD_LOADED:
		await get_tree().process_frame
		var new_scene = ResourceLoader.load_threaded_get(scene_path)
		if new_scene:
			get_tree().change_scene_to_packed(new_scene)
			current_scene_name = scene_name
			EventBus.emit_signal("scene_transition_completed", scene_name)
			break
		else:
			print("Error: Could not load scene: ", scene_path)

func reload_current_scene():
	change_scene(current_scene_name)

func get_current_scene_name() -> String:
	return current_scene_name
