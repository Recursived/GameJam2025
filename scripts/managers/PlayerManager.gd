extends Node

# Direct path approach - most common
const PLAYER_SCENE_PATH = "res://scenes/game/Player.tscn"
var player_scene: PackedScene
var current_player: CharacterBody2D
var spawn_points: Array[Vector2] = []
var current_spawn_index: int = 0

func _ready():
	# Load player scene at startup
	load_player_scene()
	
	EventBus.connect("game_started", _on_game_started)
	EventBus.connect("player_died", _on_player_died)
	EventBus.connect("game_over", _on_game_over)
	print("PlayerManager initialized")


func load_player_scene():
	player_scene = load(PLAYER_SCENE_PATH)
	if not player_scene:
		push_error("PlayerManager: Failed to load player scene at " + PLAYER_SCENE_PATH)

func set_spawn_points(points: Array[Vector2]):
	spawn_points = points
	current_spawn_index = 0

func _on_game_started():
	spawn_player()


func spawn_player():
	# Clean up existing player
	if current_player and is_instance_valid(current_player):
		current_player.queue_free()
	
	if not player_scene:
		push_error("PlayerManager: No player scene assigned!")
		return
		
	if spawn_points.is_empty():
		push_error("PlayerManager: No spawn points set!")
		return
	
	current_player = player_scene.instantiate()
	get_tree().current_scene.add_child(current_player)
	current_player.global_position = spawn_points[current_spawn_index]
	
	print("Player spawned at: ", spawn_points[current_spawn_index])

func respawn_player():
	if current_player and is_instance_valid(current_player):
		current_player.reset_to_spawn(spawn_points[current_spawn_index])
		EventBus.emit_signal("player_respawned")

func _on_player_died():
	# PlayerManager doesn't handle game logic, just respawning
	if GameManager.lives > 0:
		# Delay respawn slightly for death animation
		await get_tree().create_timer(1.0).timeout
		respawn_player()

func _on_checkpoint_reached(checkpoint_index: int):
	if checkpoint_index < spawn_points.size():
		current_spawn_index = checkpoint_index

func _on_game_over():
	if current_player and is_instance_valid(current_player):
		current_player.queue_free()
		current_player = null

func get_player() -> CharacterBody2D:
	return current_player
