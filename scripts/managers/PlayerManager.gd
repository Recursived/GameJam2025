extends Node

# Direct path approach - most common
const HEAD_SCENE_PATH = "res://scenes/game/Head.tscn"
const TAIL_SCENE_PATH = "res://scenes/game/Tail.tscn"
var head_scene: PackedScene
var tail_scene: PackedScene
var current_head: Area2D
var tail_list: Array[Tail]
var spawn_points: Array[Vector2] = [Vector2.ZERO]
var current_spawn_index: int = 0
var default_size: int = 12
var max_size: int
var size: int
var is_alive: bool

func _ready():
	# Load head scene at startup
	load_head_scene()
	load_tail_scene()
	
	tail_list = []
	max_size = default_size
	size = 0
	is_alive = true
	
	EventBus.connect("game_started", _on_game_started)
	EventBus.connect("player_died", _on_player_died)
	EventBus.connect("game_over", _on_game_over)
	EventBus.connect("head_position_changed", _on_player_movement)
	EventBus.connect("game_started", _on_game_started)
	EventBus.connect("player_respawned", _on_respawned)
	EventBus.connect("head_on_tail_collision", _on_head_on_tail_collision)
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
	if not tail_scene:
		push_error("PlayerManager: No tail scene assigned!")
		return
	
	var new_tail = tail_scene.instantiate()
	get_tree().current_scene.add_child(new_tail)
	new_tail.global_position = previous_position
	
	if tail_list.is_empty():
		EventBus.emit_signal("bell_changed", new_tail)
	
	tail_list.append(new_tail)
	size = tail_list.size()
	
	if size > max_size:
		var old_bell: Tail = tail_list.pop_front()
		old_bell.queue_free()
		EventBus.emit_signal("bell_changed", tail_list[0])
		max_size+=1
	
	print("Tail spawned at: ", new_tail.global_position)

func _on_head_on_tail_collision(tail_object: Tail):
	print("head touched tail, bell status: ", tail_object.is_bell)
	
	# Reset the entire tail list
	if(tail_object.is_bell):
		EventBus.emit_signal("bell_touched")
		while not tail_list.is_empty():
			var old_bell: Tail = tail_list.pop_front()
			old_bell.queue_free()
		
	# Reset to the tail behind the tail object touched
	else:
		EventBus.emit_signal("tail_touched")
		var index_to_reset: int = tail_list.find(tail_object) + 1
		var tail_to_reset: Tail = tail_list[min(max_size, index_to_reset)]
		
		var old_bell: Tail = tail_list.pop_front()
		while old_bell != tail_to_reset or tail_list.is_empty():
			old_bell.queue_free()
			old_bell = tail_list.pop_front()
		old_bell.queue_free()
		
		EventBus.emit_signal("bell_changed", tail_list[0])

	max_size = default_size
	size = tail_list.size()

func get_player() -> Area2D:
	return current_head

func take_damage(amount: int):
	max_size -= amount
	max_size = max(0, max_size)
	EventBus.emit_signal("player_health_changed", size, max_size)
	
	if max_size <= 0:
		die()

func die():
	is_alive = false
	EventBus.emit_signal("player_died")
	EventBus.emit_signal("play_sfx", "player_death")

func _on_respawned():
	size = 0
	is_alive = true
	# global_position = Vector2.ZERO  # Or spawn point
