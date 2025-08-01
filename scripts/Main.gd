extends Node2D


# Main.gd
func _ready():
	# Initialize the main scene
	GameManager.load_game()
	GameManager.start_game()
	# Send viewport size to GameManager
	var vsize = get_viewport().get_visible_rect().size
	EventBus.emit_signal("viewport_size_changed", vsize)
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed():
	var vsize = get_viewport().get_visible_rect().size
	EventBus.emit_signal("viewport_size_changed", vsize)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
