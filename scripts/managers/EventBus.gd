extends Node

# Global event bus for decoupled communication between systems

# Game Events
signal game_started
signal game_paused
signal game_resumed
signal game_over
signal level_completed
signal score_changed(new_score: int)

# Player Events
signal player_died
signal player_respawned
signal player_health_changed(health: int, max_health: int)
signal player_position_changed(position: Vector2)

# UI Events
signal ui_button_pressed(button_name: String)
signal menu_opened(menu_name: String)
signal menu_closed(menu_name: String)

# Viewport Events
signal viewport_size_changed(size: Vector2)

# Audio Events
signal play_sfx(sound_name: String, volume: float)
signal play_music(track_name: String, fade_in: bool)
signal stop_music(fade_out: bool)

# Scene Events
signal scene_transition_started(from_scene: String, to_scene: String)
signal scene_transition_completed(scene_name: String)

# Item/Collectible Events
signal item_collected(item_type: String, value: int)
signal powerup_activated(powerup_type: String)

func _ready():
	print("EventBus initialized")
