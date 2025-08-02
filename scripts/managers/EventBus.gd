extends Node

# Global event bus for decoupled communication between systems


#region Input Events
signal input_buffer_action(action: String)
#endregion

#region Game Events
signal game_load
signal game_started
signal game_paused
signal game_resumed
signal game_over
signal game_won
signal level_completed
signal score_changed(new_score: int)
#endregion

#region Player Events
signal player_died
signal player_respawned
signal default_size_changed(default_size: int)
signal size_changed(new_size: int)
signal head_cell_changed(
	previous_cell: Vector2,
	next_cell: Vector2,
	previous_input: String,
	next_input: String
)
signal bell_changed(tail_object: Tail)
signal head_on_tail_collision(tail_object: Tail)
signal head_on_wall_collision
signal rollback_head(new_cell: Vector2)
signal bell_touched(polygon: Polygon2D)
signal tail_touched
signal wall_touched
signal head_rollbacked
signal took_damage
#endregion

#region Player Events
signal enemy_died(enemy: Node2D)
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

#region Clock Events
signal beat_triggered
signal quarter_beat_triggered(quarter_beat_number: int)
signal eight_beat_triggered
signal movement_input_on_beat(input: String)
signal movement_input_not_on_beat(input: String)
#endregion

func _ready():
	print("EventBus initialized")
