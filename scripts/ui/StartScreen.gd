extends Node

func _ready():
	# Initialize the main scene
	pass


func _on_start_game_button_pressed():
	SceneManager.change_scene("Main", true)
	EventBus.emit_signal("play_sfx", "click", 1.0)
