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
var reset_min_size: int = 1
var is_alive: bool
var default_health:int = 3
var health:int = 0
var first_input:String = "ui_right"

var previous_input: String
var current_input: String

func _ready():
	# Load head scene at startup
	load_head_scene()
	load_tail_scene()
	
	tail_list = []
	is_alive = true
	
	EventBus.connect("game_started", _on_game_started)
	EventBus.connect("game_won", _on_game_won)
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

func set_spawn_points(points: Array[Vector2], first_input_param: String):
	spawn_points = points
	first_input=first_input_param
	current_spawn_index = 0

func _on_game_started():
	previous_input = "none"
	current_input = "none"
	spawn_player()

func spawn_player():
	# Clean up existing head
	if current_head and is_instance_valid(current_head):
		current_head.queue_free()
	
	tail_list = []
	
	if not head_scene:
		push_error("PlayerManager: No head scene assigned!")
		return
	
	if not tail_scene:
		push_error("PlayerManager: No tail scene assigned!")
		return
		
	if spawn_points.is_empty():
		push_error("PlayerManager: No spawn points set!")
		return
	
	current_head = head_scene.instantiate()
	get_tree().current_scene.add_child(current_head)
	
	var current_spawn_cell: Vector2 = spawn_points[current_spawn_index]
	current_head.init_head(first_input)
	current_head.init_spawn_cell(current_spawn_cell)
	
	var previous_cell_direction = InputManager.input_contrary[current_head.previous_input]
	var bell_cell = TileMapManager.get_neighbor_cell(
		current_spawn_cell, 
		InputManager.input_dict[previous_cell_direction]["neighbor"]
	)
	
	var new_tail = tail_scene.instantiate()
	get_tree().current_scene.add_child(new_tail)
	new_tail.global_position = TileMapManager.cell_to_position(bell_cell)
	new_tail.set_input_state(current_head.previous_input, current_head.next_input)
	new_tail.set_is_odd(tail_list.size() % 2 == 0)
	tail_list.append(new_tail)
	EventBus.emit_signal("bell_changed", new_tail)
	
	health = default_health
	is_alive = true
	print("Player spawned at: ", current_spawn_cell)

func remove_player():
	while not tail_list.is_empty():
		_remove_back_tail()
	current_head.queue_free()
	current_head = null

func _on_player_died():
	remove_player()

func _on_game_won():
	current_head.queue_free()
	current_head = null

func _on_checkpoint_reached(checkpoint_index: int):
	if checkpoint_index < spawn_points.size():
		current_spawn_index = checkpoint_index

		
func _on_player_movement(
	previous_cell:Vector2,
	_current_cell:Vector2,
	previous_input:String,
	current_input:String
):
	if not tail_scene:
		push_error("PlayerManager: No tail scene assigned!")
		return
	
	var new_tail = tail_scene.instantiate()
	get_tree().current_scene.add_child(new_tail)
	new_tail.global_position = TileMapManager.cell_to_position(previous_cell)
	
	new_tail.set_input_state(previous_input, current_input)
	new_tail.set_is_odd(tail_list.size() % 2 == 0)
	
	if tail_list.is_empty():
		EventBus.emit_signal("bell_changed", new_tail)
	
	tail_list.append(new_tail)

	print("Tail spawned at: ", previous_cell)

func _on_head_on_tail_collision(tail_object: Tail):
	print("head touched tail, bell status: ", tail_object.is_bell)

	# Reset the entire tail list
	if(tail_object.is_bell):
		var polygon_2d: Polygon2D = _get_polygon_from_tail()
		EventBus.emit_signal("bell_touched", polygon_2d)
		EventBus.emit_signal("size_changed", reset_min_size)
		
	# Reset to the tail behind the tail object touched
	else:
		EventBus.emit_signal("tail_touched")
		EventBus.emit_signal("size_changed", reset_min_size)

func _get_polygon_from_tail() -> Polygon2D:
	var polygon: PackedVector2Array = []
	for tail in tail_list:
		var point: Vector2 = tail.get_center_point()
		polygon.append(point)
	
	var polygon_2d : Polygon2D = Polygon2D.new()
	polygon_2d.polygon = polygon
	return polygon_2d

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

func get_last_tail_inputs():
	if tail_list.is_empty():
		return {
			"previous_input":"none",
			"next_input":"none"
		}
	var last_tail = tail_list[-1]
	return InputManager.input_code_to_input_ui(last_tail.input_state)
	
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
