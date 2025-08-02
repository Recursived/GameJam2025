extends Node

const LEVEL_PATH = "res://scenes/level/%s/%s"
const FLOOR_SCENE_PATH = "Floor.tscn"
const WALLS_SCENE_PATH = "Walls.tscn"
var floor_scene: PackedScene
var walls_scene: PackedScene
var _tile_map_layer_floor: TileMapLayer
var _tile_set_floor: TileSet

var _tile_map_layer_walls: TileMapLayer
var _tile_set_walls: TileSet

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

func instanciate_tile_maps():
	_tile_map_layer_floor = floor_scene.instantiate()
	_tile_set_floor = _tile_map_layer_floor.tile_set
	get_tree().current_scene.add_child(_tile_map_layer_floor)
	
	_tile_map_layer_walls = walls_scene.instantiate()
	_tile_set_walls = _tile_map_layer_walls.tile_set
	get_tree().current_scene.add_child(_tile_map_layer_walls)

func cell_to_position(cell: Vector2) -> Vector2:
	return _tile_map_layer_floor.map_to_local(cell) - Vector2(8,8)

func position_to_cell(position: Vector2) -> Vector2:
	return _tile_map_layer_floor.local_to_map(position)

func get_neighbor_cell(current_cell:Vector2 , direction: TileSet.CellNeighbor) -> Vector2:
	return _tile_map_layer_floor.get_neighbor_cell(
		current_cell,
		direction
	)
