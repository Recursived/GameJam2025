extends Node

# Direct path approach - most common
const HEAD_SCENE_PATH = "res://scenes/game/Head.tscn"
const TAIL_SCENE_PATH = "res://scenes/game/Tail.tscn"
var head_scene: PackedScene
var tail_scene: PackedScene
var current_head: Area2D
var tail_list: Array[Area2D]
var spawn_points: Array[Vector2] = [Vector2.ZERO]
var current_spawn_index: int = 0

func _ready():
	# Load head scene at startup
	load_head_scene()
	load_tail_scene()
	
	EventBus.connect("game_started", _on_game_started)
	EventBus.connect("player_died", _on_player_died)
	EventBus.connect("game_over", _on_game_over)
	EventBus.connect("head_position_changed", _on_player_movement)
	EventBus.connect("game_started", _on_game_started)
	print("PlayerManager initialized")


func load_head_scene():
	head_scene = load(HEAD_SCENE_PATH)
	if not head_scene:
		push_error("PlayerManager: Failed to load head scene at " + HEAD_SCENE_PATH)

func load_tail_scene():
	tail_scene = load(TAIL_SCENE_PATH)
	if not tail_scene:
		push_error("PlayerManager: Failed to load head scene at " + TAIL_SCENE_PATH)

func set_spawn_points(points: Array[Vector2]):
	spawn_points = points
	current_spawn_index = 0

func _on_game_started():
	spawn_player()

func spawn_player():
	# Clean up existing head
	if current_head and is_instance_valid(current_head):
		current_head.queue_free()
	
	if not head_scene:
		push_error("PlayerManager: No head scene assigned!")
		return
		
	if spawn_points.is_empty():
		push_error("PlayerManager: No spawn points set!")
		return
	
	current_head = head_scene.instantiate()
	get_tree().current_scene.add_child(current_head)
	current_head.global_position = spawn_points[current_spawn_index]
	
	print("Player spawned at: ", spawn_points[current_spawn_index])

func respawn_player():
	if current_head and is_instance_valid(current_head):
		current_head.reset_to_spawn(spawn_points[current_spawn_index])
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
	if current_head and is_instance_valid(current_head):
		current_head.queue_free()
		current_head = null

func _on_player_movement(previous_position:Vector2, position:Vector2):
	print(previous_position)
	if not tail_scene:
		push_error("PlayerManager: No tail scene assigned!")
		return

func get_player() -> Area2D:
	return current_head
