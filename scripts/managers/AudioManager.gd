extends Node

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var max_sfx_players: int = 10

var master_volume: float = 1.0
var music_volume: float = 0.6
var sfx_volume: float = 0.9

var audio_library = {}

var current_music: String = ""
var paused_music_position: float = 0.0


const GROUP_SOUNDS = {
	"COW" : ["cow_1", "cow_2", "cow_3", "cow_4", "cow_5"],
	"MORDRE" : ["mordre_q1", "mordre_q2", "mordre_q3", "mordre_q4"],
}

func _ready():
	setup_audio_players()
	load_audio_library()
	
	EventBus.connect("play_sfx", _on_play_sfx)
	EventBus.connect("play_music", _on_play_music)
	EventBus.connect("stop_music", _on_stop_music)
	EventBus.connect("pause_music", pause_music)
	EventBus.connect("resume_music", resume_music)
	EventBus.connect("set_sfx_volume", set_sfx_volume)
	EventBus.connect("set_music_volume", set_music_volume)

	print("AudioManager initialized")

func setup_audio_players():
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)
	
	# Create SFX players pool
	for i in max_sfx_players:
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.name = "SFXPlayer" + str(i)
		sfx_player.bus = "SFX"
		add_child(sfx_player)
		sfx_players.append(sfx_player)

func load_audio_library():
	# Load your audio resources here
	audio_library["intro_sound"] = preload("res://resources/audio/sfx/SFX_Lancement_whoosh.mp3")
	
	audio_library["button_play"] = preload("res://resources/audio/sfx/sfx_play_button.mp3")
	audio_library["button_click"] = preload("res://resources/audio/sfx/button_click.wav")
	audio_library["button_hover"] = preload("res://resources/audio/sfx/sfx_button_hover.mp3")
	
	audio_library["game_music"] = preload("res://resources/audio/music/music_official.mp3")
	
	audio_library["cow_1"] = preload("res://resources/audio/sfx/COW_1.mp3")
	audio_library["cow_2"] = preload("res://resources/audio/sfx/COW_2.mp3")
	audio_library["cow_3"] = preload("res://resources/audio/sfx/COW_3.mp3")
	audio_library["cow_4"] = preload("res://resources/audio/sfx/COW_4.mp3")
	audio_library["cow_5"] = preload("res://resources/audio/sfx/COW_5.mp3")
	
	audio_library["wall_impact"] = preload("res://resources/audio/sfx/SFX_Wall_Impact.mp3")
	audio_library["good_loop_without_cow"] = preload("res://resources/audio/sfx/SFX_good_loop_without_cow.mp3")
	
	audio_library["mordre_q1"] = preload("res://resources/audio/sfx/SFX_zone_mordre_QUEUE_1.mp3")
	audio_library["mordre_q2"] = preload("res://resources/audio/sfx/SFX_zone_mordre_QUEUE_2.mp3")
	audio_library["mordre_q3"] = preload("res://resources/audio/sfx/SFX_zone_mordre_QUEUE_3.mp3")
	audio_library["mordre_q4"] = preload("res://resources/audio/sfx/SFX_zone_mordre_QUEUE_4.mp3")
	
	audio_library["mordre_too_short"] = preload("res://resources/audio/sfx/SFX_mordre_too_short.mp3")
	
	
func play_sfx(sound_name: String, volume: float = 1.0, pitch: float = 1.0):
	if not audio_library.has(sound_name):
		print("Warning: SFX '", sound_name, "' not found in audio library")
		return
	
	var available_player = get_available_sfx_player()
	if available_player:
		available_player.stream = audio_library[sound_name]
		available_player.volume_db = linear_to_db(volume * sfx_volume * master_volume)
		available_player.pitch_scale = pitch
		available_player.play()

func play_music(track_name: String, fade_in_duration: float = 0.0):
	if not audio_library.has(track_name):
		print("Warning: Music track '", track_name, "' not found in audio library")
		return
	
	if current_music == track_name and music_player.playing:
		return
	
	music_player.stream = audio_library[track_name]
	music_player.volume_db = linear_to_db(music_volume * master_volume)
	
	if fade_in_duration > 0.0:
		music_player.volume_db = -80
		music_player.play()
		
		var tween = create_tween()
		tween.tween_method(
			func(vol): music_player.volume_db = vol,
			-80,
			linear_to_db(music_volume * master_volume),
			fade_in_duration
		)
	else:
		music_player.play()
	
	current_music = track_name

func stop_music(fade_out_duration: float = 0.0):
	if not music_player.playing:
		return
	
	if fade_out_duration > 0.0:
		var tween = create_tween()
		tween.tween_method(
			func(vol): music_player.volume_db = vol,
			music_player.volume_db,
			-80,
			fade_out_duration
		)
		tween.tween_callback(music_player.stop)
	else:
		music_player.stop()
	
	current_music = ""

func get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	return sfx_players[0]  # Fallback to first player

func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	update_audio_volumes()

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	music_player.volume_db = linear_to_db(music_volume * master_volume)

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)

func update_audio_volumes():
	music_player.volume_db = linear_to_db(music_volume * master_volume)

func pause_music():
	if music_player.playing:
		paused_music_position = music_player.get_playback_position()
		music_player.stop()


func resume_music():
	if current_music != "" and audio_library.has(current_music):
		music_player.stream = audio_library[current_music]
		music_player.volume_db = linear_to_db(music_volume * master_volume)
		music_player.play(paused_music_position)

func _on_play_sfx(sound_name: String, volume: float = 1.0):
	play_sfx(sound_name, volume)

func _on_play_music(track_name: String, fade_in: bool = false):
	var fade_duration = 1.0 if fade_in else 0.0
	play_music(track_name, fade_duration)

func _on_stop_music(fade_out: bool = false):
	var fade_duration = 1.0 if fade_out else 0.0
	stop_music(fade_duration)
