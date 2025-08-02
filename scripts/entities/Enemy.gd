extends Node2D

signal enemy_collided(body)
@onready var sprite = $AnimatedSprite2D

#region common variables
var enemy_type : EnemyManager.EnemyType = EnemyManager.EnemyType.STATIC
var cooldown_move : int = 0
var current_wait_time: int = 0
var last_position : Vector2 = Vector2.ZERO
var is_alive: bool = true
#endregion

#region moving type variable
var path_to_follow : Array[TileSet.CellNeighbor] = []
var path_index: int = 0
var path_forward: bool = true
#endregion

#region kamikaze type variables
const turn_on_collide_options={
	"CLOCKWISE"="clockwise",
	"COUNTER_CLOCKWISE"="counter_clockwise",
	"REVERSE"="reverse"
}
var current_direction : TileSet.CellNeighbor = TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE
var turn_on_collide: String = turn_on_collide_options["REVERSE"]
#endregion

func _ready():
		self.connect("body_entered", Callable(self, "_on_area_entity_body_entered"))
		self.connect("area_entered", Callable(self, "_on_area_entity_body_entered"))
		EventBus.connect("quarter_beat_triggered", _on_quarter_beat)

func _process(delta: float) -> void:
	if not is_alive and not sprite.is_playing():
		self.queue_free()


func initialize(origin: Vector2, type: EnemyManager.EnemyType, args: Dictionary):
	position = TileMapManager.cell_to_position(origin)
	enemy_type = type
	is_alive= true
	
	var idle_animation= "idle_%s"
	sprite.animation = idle_animation % EnemyManager.type_to_string[type]
	
	match enemy_type:
		EnemyManager.EnemyType.MOVING:
		# We generate an array of four direction that the enemy will always follow 
			var pattern = args["pattern"]
			for move in pattern:
				path_to_follow.append(InputManager.input_code_to_direction[move])
		EnemyManager.EnemyType.KAMIKAZE:
			current_direction = InputManager.input_code_to_direction[args["direction"]]
			turn_on_collide = args["turn_on_collide"]
	
		
func _on_area_entity_body_entered(body : Node2D):		
	rollback_move()
	# emit_signal("enemy_collided", body)


func move():
	match enemy_type:
		EnemyManager.EnemyType.MOVING:
			move_enemy_type_moving()
		EnemyManager.EnemyType.RANDOM:
			move_enemy_type_random()
		EnemyManager.EnemyType.KAMIKAZE:
			move_enemy_type_kamikaze()
			
			

func _on_quarter_beat(quarter_beat_number: int):
	if is_alive:
		sprite.frame = quarter_beat_number%4

func die():
	var death_animation= "death_%s"
	sprite.animation = death_animation % EnemyManager.type_to_string[enemy_type]
	sprite.play()
	is_alive = false

#region utils enemy function 
func get_random_direction():
	var directions = [TileSet.CELL_NEIGHBOR_TOP_SIDE, TileSet.CELL_NEIGHBOR_LEFT_SIDE, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE, TileSet.CELL_NEIGHBOR_RIGHT_SIDE]
	var selected = directions[randi() % directions.size()]
	return selected


func get_opposite_direction(direction):
	match direction:
		TileSet.CELL_NEIGHBOR_TOP_SIDE:
			return TileSet.CELL_NEIGHBOR_BOTTOM_SIDE
		TileSet.CELL_NEIGHBOR_BOTTOM_SIDE:
			return TileSet.CELL_NEIGHBOR_TOP_SIDE
		TileSet.CELL_NEIGHBOR_LEFT_SIDE:
			return TileSet.CELL_NEIGHBOR_RIGHT_SIDE
		TileSet.CELL_NEIGHBOR_RIGHT_SIDE:
			return TileSet.CELL_NEIGHBOR_LEFT_SIDE
		_:
			return direction


func get_kamikaze_rollback_direction(direction: TileSet.CellNeighbor) -> TileSet.CellNeighbor:
	# Assumes directions are: TOP, RIGHT, BOTTOM, LEFT
	var directions = [TileSet.CELL_NEIGHBOR_TOP_SIDE, TileSet.CELL_NEIGHBOR_RIGHT_SIDE, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE, TileSet.CELL_NEIGHBOR_LEFT_SIDE]
	var idx = directions.find(direction)
	if idx == -1:
		return direction
	if turn_on_collide == "clockwise":
		return directions[(idx + 1) % directions.size()]
	elif turn_on_collide == "counter_clockwise":
		return directions[(idx - 1 + directions.size()) % directions.size()]
	else:
		return directions[(idx + 2) % directions.size()]
#endregion

func on_trigger_next_move():
	# To be replaced by the tempo manager
	move()


func check_cooldown_is_good_for_move():
	if current_wait_time < cooldown_move:
		current_wait_time += 1
		return false  # Skip movement if still in cooldown
		
	return true
	
func get_area_position():
	return position

#region Typed moving function
func move_enemy_type_moving():
	last_position = TileMapManager.position_to_cell(position)
	if not check_cooldown_is_good_for_move():
		return
	var selected
	if path_forward:
		selected = path_to_follow[path_index]
	else:
		selected = get_opposite_direction(path_to_follow[path_index])
	var neighbour = TileMapManager.get_neighbor_cell(TileMapManager.position_to_cell(position), selected)
	position = TileMapManager.cell_to_position(neighbour)
	current_wait_time = 0  # Reset cooldown after moving

	update_path_index()

func update_path_index():
	# Ping-pong path index
	if path_forward:
		path_index += 1
		if path_index >= path_to_follow.size():
			path_index -= 1
			path_forward = false
	else:
		path_index -= 1
		if path_index < 0:
			path_index += 1
			path_forward = true
			
func move_enemy_type_random():
	last_position = TileMapManager.position_to_cell(position)
	if not check_cooldown_is_good_for_move():
		return
	var selected = get_random_direction()
	var neighbour = TileMapManager.get_neighbor_cell(TileMapManager.position_to_cell(position), selected)
	position = TileMapManager.cell_to_position(neighbour)
	current_wait_time = 0  # Reset cooldown after moving
	
func move_enemy_type_kamikaze():
	last_position = TileMapManager.position_to_cell(position)
	if not check_cooldown_is_good_for_move():
		return
	var neighbour = TileMapManager.get_neighbor_cell(TileMapManager.position_to_cell(position), current_direction)
	position = TileMapManager.cell_to_position(neighbour)
	current_wait_time = 0  # Reset cooldown after moving

func rollback_move():
	if last_position:
		position =  TileMapManager.cell_to_position(last_position)
		current_wait_time = 0
		if enemy_type == EnemyManager.EnemyType.KAMIKAZE:
			current_direction = get_kamikaze_rollback_direction(current_direction)
			move()
	
	

#endregion
