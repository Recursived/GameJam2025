extends Node

# Global event bus for decoupled communication between systems


#region Input Events
signal input_buffer_action(action: String)
#endregion

#region Game Events
signal game_started
signal game_paused
signal game_resumed
signal game_over
signal level_completed
signal score_changed(new_score: int)
#endregion

#region Player Events
signal player_died
signal player_respawned
signal player_health_changed(health: int, max_size: int)
signal head_position_changed(previous_position: Vector2, position: Vector2)
signal bell_changed(tail_object: Tail)
signal head_on_tail_collision(tail_object: Tail)
signal head_on_wall_collision(area: Area2D)
signal rollback_head(new_position: Vector2)
signal bell_touched
signal tail_touched
signal wall_touched
signal head_rollbacked
#endregion

#region UI Events
signal ui_button_pressed(button_name: String)
signal menu_opened(menu_name: String)
signal menu_closed(menu_name: String)
#endregion

#region Viewport Events
signal viewport_size_changed(size: Vector2)
#endregion

#region Audio Events
signal play_sfx(sound_name: String, volume: float)
signal play_music(track_name: String, fade_in: bool)
signal stop_music(fade_out: bool)
signal set_sfx_volume(volume: float)
signal set_music_volume(volume: float)
signal pause_music
signal resume_music
#endregion

#region Scene Events
signal scene_transition_started(from_scene: String, to_scene: String)
signal scene_transition_completed(scene_name: String)
#endregion

#region Item/Collectible Events
signal item_collected(item_type: String, value: int)
signal powerup_activated(powerup_type: String)
#endregion

func _ready():
	print("EventBus initialized")
