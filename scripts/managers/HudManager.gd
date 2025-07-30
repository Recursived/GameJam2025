extends Node


func _ready():
	EventBus.connect("input_buffer_action", on_listen_for_debug_mode_pressed) 


var debug_hud_instance: Node = null

func on_listen_for_debug_mode_pressed(action: String):
	if action == "toggle_debug":
		var current_scene = get_tree().current_scene
		if debug_hud_instance and debug_hud_instance.get_parent():
			# Remove DebugHUD if it's already in the tree
			debug_hud_instance.queue_free()
			debug_hud_instance = null
		else:
			var debug_hud_scene = load("res://scenes/UI/DebugHUD.tscn")
			if debug_hud_scene:
				debug_hud_instance = debug_hud_scene.instantiate()
				get_tree().current_scene.add_child(debug_hud_instance)
			else:
				print("Error: Could not load DebugHUD.tscn!")

		
		
