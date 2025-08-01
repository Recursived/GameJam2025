extends Node

# Direct path approach - most common
const HEAD_SCENE_PATH = "res://scenes/game/Head.tscn"
const TAIL_SCENE_PATH = "res://scenes/game/Tail.tscn"
var head_scene: PackedScene
var tail_scene: PackedScene
var current_head: Area2D
var tail_list: Array[Tail]
var spawn_points: Array[Vector2] = [Vector2(3,3)]
var current_spawn_index: int = 0
var reset_min_size: int = 3
var is_alive: bool
var default_health:int = 3
var health:int = 0

func _ready():
	# Load head scene at startup
	load_head_scene()
	load_tail_scene()
	
	tail_list = []
	is_alive = true
	
	EventBus.connect("game_started", _on_game_started)
	EventBus.connect("player_died", _on_player_died)
	EventBus.connect("head_cell_changed", _on_player_movement)
	EventBus.connect("game_started", _on_game_started)
	EventBus.connect("player_respawned", _on_respawned)
	EventBus.connect("head_on_tail_collision", _on_head_on_tail_collision)
	EventBus.connect("head_on_wall_collision", _on_head_on_wall_collision)
	EventBus.connect("size_changed", _on_size_changed)
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
	
	var current_spawn_cell: Vector2 = spawn_points[current_spawn_index]
	current_head.init_spawn_cell(current_spawn_cell)
	current_head.init_head()
	
	health = default_health
	is_alive = true
	print("Player spawned at: ", current_spawn_cell)

func _on_player_died():
	while not tail_list.is_empty():
		_remove_back_tail()
	current_head.queue_free()
	current_head = null

func _on_checkpoint_reached(checkpoint_index: int):
	if checkpoint_index < spawn_points.size():
		current_spawn_index = checkpoint_index

		
func _on_player_movement(previous_cell:Vector2, _current_cell:Vector2):
	if not tail_scene:
		push_error("PlayerManager: No tail scene assigned!")
		return
	
	var new_tail = tail_scene.instantiate()
	get_tree().current_scene.add_child(new_tail)
	new_tail.global_position = TileMapManager.cell_to_position(previous_cell)
	
	if tail_list.is_empty():
		EventBus.emit_signal("bell_changed", new_tail)
	
	tail_list.append(new_tail)

	print("Tail spawned at: ", previous_cell)

func _on_head_on_tail_collision(tail_object: Tail):
	print("head touched tail, bell status: ", tail_object.is_bell)

	# Reset the entire tail list
	if(tail_object.is_bell):
		EventBus.emit_signal("bell_touched")
		EventBus.emit_signal("size_changed", reset_min_size)
		
	# Reset to the tail behind the tail object touched
	else:
		EventBus.emit_signal("tail_touched")
		var index_to_reset: int = tail_list.find(tail_object) + 2
		EventBus.emit_signal("size_changed", tail_list.size() - index_to_reset)

func _on_size_changed(new_size: int):
	while tail_list.size() > new_size or tail_list.is_empty():
		_remove_back_tail()
	
	if tail_list.size() > 0:
		EventBus.emit_signal("bell_changed", tail_list[0])

func _on_head_on_wall_collision():
	take_damage(1)
	if is_alive:
		EventBus.emit_signal("wall_touched")
		var head_cell = TileMapManager.position_to_cell(_remove_front_tail().position)
		EventBus.emit_signal("rollback_head", head_cell)
		EventBus.emit_signal("size_changed", reset_min_size)
	
func _remove_back_tail() -> Tail:
	var old_bell: Tail = tail_list.pop_front()
	old_bell.queue_free()
	return old_bell

func get_last_tail_cell():
	if tail_list.is_empty():
		return null
	return TileMapManager.position_to_cell(tail_list[-1].position)

func _remove_front_tail() -> Tail:
	var old_bell: Tail = tail_list.pop_back()
	old_bell.queue_free()
	return old_bell

func get_player() -> Area2D:
	return current_head

func take_damage(amount: int):
	health-=1
	if health <= 0:
		die()

func die():
	is_alive = false
	EventBus.emit_signal("player_died")
	EventBus.emit_signal("play_sfx", "player_death")

func _on_respawned():
	spawn_player()
