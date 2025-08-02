extends Node

const LEVEL_PATH = "res://scenes/level/%s/%s"
const FLOOR_SCENE_PATH = "Floor.tscn"
const WALLS_SCENE_PATH = "Walls.tscn"
const SPAWNS_SCENE_PATH = "Spawns.tscn"
const ENEMIES_SCENE_PATH = "Enemies.tscn"
var floor_scene: PackedScene
var walls_scene: PackedScene
var spawns_scene: PackedScene
var enemies_scene: PackedScene

var _tile_map_layer_floor: TileMapLayer
var _tile_set_floor: TileSet

var _tile_map_layer_walls: TileMapLayer
var _tile_set_walls: TileSet

var _tile_map_layer_spawns: TileMapLayer

var _tile_map_layer_enemies: TileMapLayer

func _ready():
	print("TileMapManager initialized")

func load_floor_scene(level: int):
	var floor_path = LEVEL_PATH % ["level"+str(level), FLOOR_SCENE_PATH]
	floor_scene = load(floor_path)
	if not floor_scene:
		push_error("TileMapManager: Failed to load floor scene at " + floor_path)

func load_walls_scene(level: int):
	var walls_path = LEVEL_PATH % ["level"+str(level), WALLS_SCENE_PATH]
	walls_scene = load(walls_path)
	if not walls_scene:
		push_error("TileMapManager: Failed to load walls scene at " + walls_path)

func load_spawns_scene(level: int):
	var spawns_path = LEVEL_PATH % ["level"+str(level), SPAWNS_SCENE_PATH]
	spawns_scene = load(spawns_path)
	if not spawns_scene:
		push_error("TileMapManager: Failed to load spawns scene at " + spawns_path)

func load_enemies_scene(level: int):
	var enemies_path = LEVEL_PATH % ["level"+str(level), ENEMIES_SCENE_PATH]
	enemies_scene = load(enemies_path)
	if not enemies_scene:
		push_error("TileMapManager: Failed to load enemies scene at " + enemies_path)

func instanciate_tile_maps():
	_tile_map_layer_floor = floor_scene.instantiate()
	_tile_set_floor = _tile_map_layer_floor.tile_set
	get_tree().current_scene.add_child(_tile_map_layer_floor)
	
	_tile_map_layer_walls = walls_scene.instantiate()
	_tile_set_walls = _tile_map_layer_walls.tile_set
	get_tree().current_scene.add_child(_tile_map_layer_walls)
	
	_tile_map_layer_spawns = spawns_scene.instantiate()
	_tile_map_layer_enemies = enemies_scene.instantiate()

func cell_to_position(cell: Vector2) -> Vector2:
	return _tile_map_layer_floor.map_to_local(cell) - Vector2(8,8)

func position_to_cell(position: Vector2) -> Vector2:
	return _tile_map_layer_floor.local_to_map(position)

func get_neighbor_cell(current_cell:Vector2 , direction: TileSet.CellNeighbor) -> Vector2:
	return _tile_map_layer_floor.get_neighbor_cell(
		current_cell,
		direction
	)

func get_spawns() -> Array[Vector2]:
	var spawns: Array[Vector2] = []
	for spawn in _tile_map_layer_spawns.get_used_cells():
		spawns.append(Vector2(spawn.x,spawn.y))
	return spawns

func get_enemies() -> Array:
	var enemies: Array = []
	for enemy in _tile_map_layer_enemies.get_used_cells():
		enemies.append({
			"x":enemy.x,
			"y":enemy.y,
			"width":1,
			"height":1,
			"type": EnemyManager.EnemyType.RANDOM
		})
	return enemies
