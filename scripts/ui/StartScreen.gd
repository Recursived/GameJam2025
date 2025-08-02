extends Node

func _ready():
	# Initialize the main scene
	pass


func _on_start_game_button_pressed():
	GameManager.current_level=1
	SceneManager.change_scene("Main", true)
	EventBus.emit_signal("play_sfx", "button_click", 1.0)

func _on_texture_button_pressed():
	GameManager.current_level=1
	SceneManager.change_scene("Main", true)
	EventBus.emit_signal("play_sfx", "button_click", 1.0)
