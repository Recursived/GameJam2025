extends Node

func _ready():
	# Initialize the main scene
	EventBus.emit_signal("play_sfx", "intro_sound", 1.0)

func _on_play_pressed():
	GameManager.current_level=1
	SceneManager.change_scene("StartScreen", true)
	EventBus.emit_signal("play_sfx", "button_play", 1.0)
	pass # Replace with function body.
