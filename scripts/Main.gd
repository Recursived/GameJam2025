extends Node2D

# Main.gd
func _ready():
	# Initialize the main scene
	GameManager.start_game()

func get_screen_size() -> Vector2:
	return get_viewport_rect().size
