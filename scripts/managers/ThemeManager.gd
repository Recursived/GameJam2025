extends Node

var current_theme: Theme
var theme_variants = {}

func _ready():
	load_themes()
	apply_theme("default")

func load_themes():
	theme_variants["default"] = preload("res://themes/main_theme.tres")
	# theme_variants["high_contrast"] = preload("res://themes/high_contrast_theme.tres")
	# theme_variants["colorblind"] = preload("res://themes/colorblind_theme.tres")

func apply_theme(theme_name: String):
	if theme_variants.has(theme_name):
		current_theme = theme_variants[theme_name]
		
		# Apply to all UI nodes
		var ui_nodes = get_tree().get_nodes_in_group("ui")
		for node in ui_nodes:
			if node.has_method("set_theme"):
				node.theme = current_theme

func get_theme_color(color_name: String) -> Color:
	# Return theme colors for custom controls
	match color_name:
		"accent_primary":
			return Color(0.4, 0.76, 1.0, 1.0)
		"accent_success":
			return Color(0.3, 0.8, 0.4, 1.0)
		# Add more colors...
		_:
			return Color.WHITE

func create_notification(text: String, type: String = "info"):
	
	# Create styled notification popup
	# var notification = preload("res://scenes/UI/Notification.tscn").instantiate()
	# notification.setup(text, type)
	# get_tree().current_scene.add_child(notification)
	pass
