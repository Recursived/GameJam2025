extends Node

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
var lives: int = 3
var time_scale: float = 1.0

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

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func set_level(level: int):
	current_level = level
		
func load_game():
	EventBus.emit_signal("game_loaded")

func load_level():
	TileMapManager.load_floor_scene(current_level)
	TileMapManager.load_walls_scene(current_level)
	TileMapManager.load_spawns_scene(current_level)
	TileMapManager.load_enemies_scene(current_level)
	TileMapManager.instanciate_tile_maps()
	PlayerManager.set_spawn_points()

func start_game():
	load_level()
	current_state = GameState.PLAYING
	score = 0
	lives = 3
	current_level = 1
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
