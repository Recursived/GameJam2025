extends Node2D

signal enemy_collided(body)

#region common variables
@onready var area_entity: AreaEntity = $AreaEntity
var enemy_type : EnemyManager.EnemyType = EnemyManager.EnemyType.STATIC
var cooldown_move : int = 5
var current_wait_time: int = 0
var last_position : Vector2 = Vector2.ZERO
#endregion

#region moving type variable
var path_to_follow : Array[TileSet.CellNeighbor] = []
var path_index: int = 0
var path_forward: bool = true
#endregion

#region kamikaze type variables
var current_direction : TileSet.CellNeighbor = TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE
#endregion

func _ready():
	EventBus.connect("beat_triggered", on_trigger_next_move)	
	if area_entity:
		area_entity.connect("body_entered", Callable(self, "_on_area_entity_body_entered"))
		


func initialize(origin: Vector2, width: int, height: int, type: EnemyManager.EnemyType):
	if area_entity: # Public method to configure AreaEntity after node is ready
		area_entity.set_width(width)
		area_entity.set_height(height)
		area_entity.set_origin_offset(origin)
	
	enemy_type = type
	match enemy_type:
		EnemyManager.EnemyType.MOVING:
		# We generate an array of four direction that the enemy will always follow 
			for i in range(4):
				var direction_pick = get_random_direction()
				path_to_follow.append(direction_pick)
		EnemyManager.EnemyType.KAMIKAZE:
			current_direction = get_random_direction()
	
	change_color_by_type()
	


func change_color_by_type():
	if not area_entity:
		return
	var color_rect = area_entity.color_rect
	
	if not color_rect:
		return
	var color := Color.WHITE
	match enemy_type:
		EnemyManager.EnemyType.STATIC:
			color = Color(0.8, 0.8, 0.8) # light gray
		EnemyManager.EnemyType.MOVING:
			color = Color(0.2, 0.6, 1.0) # blue
		EnemyManager.EnemyType.RANDOM:
			color = Color(1.0, 0.8, 0.2) # yellow
		EnemyManager.EnemyType.KAMIKAZE:
			color = Color(1.0, 0.2, 0.2) # red
		_:
			color = Color.WHITE
	color_rect.color = color
		
func _on_area_entity_body_entered(body : Node2D):
	TileMapManager.position_to_cell(body.position)
	body.position
		# var color = Color(0.2, 1, 1) # cyan
		# area_entity.color_rect.color = color
	# emit_signal("enemy_collided", body)


func move():
	match enemy_type:
		EnemyManager.EnemyType.MOVING:
			move_enemy_type_moving()
		EnemyManager.EnemyType.RANDOM:
			move_enemy_type_random()
		EnemyManager.EnemyType.KAMIKAZE:
			move_enemy_type_kamikaze()
			
			


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

func on_trigger_next_move():
	# To be replaced by the tempo manager
	move()


func check_cooldown_is_good_for_move():
	if current_wait_time < cooldown_move:
		current_wait_time += 1
		return false  # Skip movement if still in cooldown
		
	return true
	
func get_area_position():
	return area_entity.origin_offset

#region Typed moving function
func move_enemy_type_moving():
	if not check_cooldown_is_good_for_move():
		return
	var selected
	if path_forward:
		selected = path_to_follow[path_index]
	else:
		selected = get_opposite_direction(path_to_follow[path_index])
	var neighbour = TileMapManager.get_neighbor_cell(area_entity.origin_offset, selected)
	area_entity.set_origin_offset(neighbour)
	last_position = neighbour
	current_wait_time = 0  # Reset cooldown after moving

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
	if not check_cooldown_is_good_for_move():
		return
	var selected = get_random_direction()
	var neighbour = TileMapManager.get_neighbor_cell(area_entity.origin_offset, selected)
	area_entity.set_origin_offset(neighbour)
	last_position = neighbour
	current_wait_time = 0  # Reset cooldown after moving
	
func move_enemy_type_kamikaze():
	if not check_cooldown_is_good_for_move():
		return
	var neighbour = TileMapManager.get_neighbor_cell(area_entity.origin_offset, current_direction)
	area_entity.set_origin_offset(neighbour)
	last_position = neighbour
	current_wait_time = 0  # Reset cooldown after moving

func rollback_move():
	area_entity.set_origin_offset(last_position)

#endregion
