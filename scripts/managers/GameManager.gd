extends Node

const JSON_PATH = "res://scenes/level/%s/%s"
var enemies: Array = []

enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER,
	LOADING
}

var current_state: GameState = GameState.MENU
var score: int = 0
var high_score: int = 0
var current_level: int = 1
var lives: int = 1
var time_scale: float = 1.0
var is_movement_paused = false
var current_zoom:float = 1.00

var camera: Camera2D

# Store viewport size globally
var viewport_size: Vector2 = Vector2.ZERO

var game_data = {
	"version": "1.0.0",
	"settings": {},
	"progress": {}
}

func _ready():
	EventBus.connect("game_over", _on_game_over)
	EventBus.connect("score_changed", _on_score_changed)
	EventBus.connect("player_died", _on_player_died)
	EventBus.connect("viewport_size_changed", _on_viewport_size_changed)
	EventBus.connect("game_won", _on_game_won)
	
	load_high_score()
	print("GameManager initialized")

func set_level(level: int):
	current_level = level
		
func load_game():
	EventBus.emit_signal("game_loaded")

func load_json(level:int):
	if not FileAccess.file_exists(JSON_PATH % ["level"+str(level), "level_data.json"]):
		return
	var file = FileAccess.open(
		JSON_PATH % ["level"+str(level), "level_data.json"],
		FileAccess.READ
	)
	var data = JSON.parse_string(file.get_as_text())
	return data

func load_spawn_points(json_data):
	var first_input = json_data["first_input"]
	var spawns_data = json_data["spawns"]
	var spawns: Array[Vector2] = []
	for spawn in spawns_data:
		spawns.append(Vector2(spawn[0],spawn[1]))
	PlayerManager.set_spawn_points(spawns, first_input)

func load_enemies(json_data):
	enemies = []
	var enemies_data = json_data["enemies"]
	for enemy in enemies_data:
		enemies.append(enemy)

func load_camera(json_data):
	current_zoom = json_data["zoom"]
	if camera:
		camera.queue_free()
	camera = Camera2D.new()
	camera.position = Vector2(640/current_zoom, 360/current_zoom)
	camera.zoom = Vector2(current_zoom ,current_zoom)
	get_tree().current_scene.add_child(camera)

func load_bpm(json_data):
	var bpm = json_data["bpm"]
	RhythmManager.set_bpm(bpm)
	
func load_level():
	TileMapManager.load_floor_scene(current_level)
	TileMapManager.load_walls_scene(current_level)
	TileMapManager.instanciate_tile_maps()
	var json_data = load_json(current_level)
	load_bpm(json_data)
	load_camera(json_data)
	load_spawn_points(json_data)
	load_enemies(json_data)

func set_movement_paused(paused: bool):
	is_movement_paused = paused

func get_movement_paused():
	return is_movement_paused

func start_game():
	load_level()
	VfxManager.init()
	current_state = GameState.PLAYING
	is_movement_paused = false
	score = 0
	lives = 1
	EventBus.emit_signal("game_started")

func pause_game():
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		time_scale = 0.0
		Engine.time_scale = time_scale
		EventBus.emit_signal("game_paused")

func resume_game():
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		time_scale = 1.0
		Engine.time_scale = time_scale
		EventBus.emit_signal("game_resumed")

func toggle_pause():
	if current_state == GameState.PLAYING:
		pause_game()
	elif current_state == GameState.PAUSED:
		resume_game()

func game_over():
	current_state = GameState.GAME_OVER
	time_scale = 1.0
	Engine.time_scale = time_scale
	
	if score > high_score:
		high_score = score
		save_high_score()
	
	EventBus.emit_signal("game_over")

func _on_game_won():
	print("Game Won ! Final Score: ", score)
	
	current_level+=1
	if FileAccess.file_exists(JSON_PATH % ["level"+str(current_level), "level_data.json"]):
		SceneManager.change_scene("Main", true)
	else:
		current_state = GameState.MENU
		SceneManager.change_scene("StartScreen", true)

func add_score(points: int):
	score += points
	EventBus.emit_signal("score_changed", score)

func get_state() -> GameState:
	return current_state

func set_time_scale(scale: float):
	time_scale = scale
	Engine.time_scale = scale

func _on_game_over():
	print("Game Over! Final Score: ", score)
	camera.queue_free()
	current_state = GameState.MENU
	SceneManager.change_scene("StartScreen", true)

func _on_score_changed(new_score: int):
	print("Score: ", new_score)

func _on_player_died():
	lives -= 1
	if lives <= 0:
		game_over()
	else:
		# Respawn player
		await get_tree().create_timer(1.0).timeout
		EventBus.emit_signal("player_respawned")

func save_high_score():
	SaveManager.save_data("high_score", high_score)

func load_high_score():
	high_score = SaveManager.load_data("high_score", 0)

# Handle viewport size signal
func _on_viewport_size_changed(size: Vector2):
	viewport_size = size
