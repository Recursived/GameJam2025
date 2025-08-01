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
var beats_before_time_damage: int = 12
var spawn_immunity: bool = true
var reset_min_size: int = 3
var is_alive: bool
var next_move:int = -1
var beat_count:int = 0

func _ready():
	# Load head scene at startup
	load_head_scene()
	load_tail_scene()
	
	tail_list = []
	is_alive = true
	
	EventBus.connect("game_started", _on_game_started)
	EventBus.connect("player_died", _on_player_died)
	EventBus.connect("game_over", _on_game_over)
	EventBus.connect("head_cell_changed", _on_player_movement)
	EventBus.connect("game_started", _on_game_started)
	EventBus.connect("player_respawned", _on_respawned)
	EventBus.connect("head_on_tail_collision", _on_head_on_tail_collision)
	EventBus.connect("head_on_wall_collision", _on_head_on_wall_collision)
	EventBus.connect("beat_triggered", _on_beat)
	EventBus.connect("movement_input_not_on_beat", _on_false_movement_damage)
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
	
	beat_count = -beats_before_time_damage
	spawn_immunity = true
	print("Player spawned at: ", current_spawn_cell)

func _on_player_died():
	while not tail_list.is_empty():
		_remove_back_tail()
	current_head.queue_free()
	current_head = null

func _on_checkpoint_reached(checkpoint_index: int):
	if checkpoint_index < spawn_points.size():
		current_spawn_index = checkpoint_index

func _on_game_over():
	if current_head and is_instance_valid(current_head):
		current_head.queue_free()
		current_head = null
	
	while not tail_list.is_empty():
		_remove_back_tail()
		
		
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
	
	spawn_immunity = false
	print("Tail spawned at: ", previous_cell)

func _on_head_on_tail_collision(tail_object: Tail):
	print("head touched tail, bell status: ", tail_object.is_bell)

	# Reset the entire tail list
	if(tail_object.is_bell):
		EventBus.emit_signal("bell_touched")
		EventBus.emit_signal("size_changed", reset_min_size)
		beat_count = -beats_before_time_damage
		
	# Reset to the tail behind the tail object touched
	else:
		EventBus.emit_signal("tail_touched")
		var index_to_reset: int = tail_list.find(tail_object) + 2
		EventBus.emit_signal("size_changed", tail_list.size() - index_to_reset)
		beat_count = 0

func _on_size_changed(new_size: int):
	while tail_list.size() > new_size or tail_list.is_empty():
		_remove_back_tail()
	
	if tail_list.size() > 0:
		EventBus.emit_signal("bell_changed", tail_list[0])

func _on_head_on_wall_collision():
	EventBus.emit_signal("wall_touched")
	var head_cell = TileMapManager.position_to_cell(_remove_front_tail().position)
	EventBus.emit_signal("rollback_head", head_cell)
	take_size_damage(1)
	
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

func _on_beat():
	beat_count +=1
	if beat_count>0 and beat_count % 4 == 0:
		pass
		#Removed this because it made the game too hard
		#take_size_damage(1)
	
func _on_false_movement_damage(_input):
	take_size_damage(1)

func take_default_size_damage(amount: int):
	beats_before_time_damage -= amount
	beats_before_time_damage = max(3, beats_before_time_damage)
	EventBus.emit_signal("default_size_changed", beats_before_time_damage)

func take_size_damage(amount: int):
	if not spawn_immunity:
		var next_size = tail_list.size() - amount
		next_size = max(0, next_size)
		if next_size <=0:
			die()
		else:
			beat_count=0
			EventBus.emit_signal("size_changed", next_size)

func die():
	is_alive = false
	EventBus.emit_signal("player_died")
	EventBus.emit_signal("play_sfx", "player_death")

func _on_respawned():
	is_alive = true
	spawn_player()
