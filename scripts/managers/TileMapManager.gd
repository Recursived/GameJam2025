extends Node

const FLOOR_SCENE_PATH = "res://scenes/tile/Floor.tscn"
const WALLS_SCENE_PATH = "res://scenes/tile/Walls.tscn"
var floor_scene: PackedScene
var walls_scene: PackedScene

var _tile_map_layer_floor: TileMapLayer
var _tile_set_floor: TileSet

var _tile_map_layer_walls: TileMapLayer
var _tile_set_walls: TileSet

func _ready():
	print("TileMapManager initialized")

func load_floor_scene():
	floor_scene = load(FLOOR_SCENE_PATH)
	if not floor_scene:
		push_error("TileMapManager: Failed to load floor scene at " + FLOOR_SCENE_PATH)

func load_walls_scene():
	walls_scene = load(WALLS_SCENE_PATH)
	if not walls_scene:
		push_error("TileMapManager: Failed to load walls scene at " + WALLS_SCENE_PATH)

func instanciate_tile_maps():
	_tile_map_layer_floor = floor_scene.instantiate()
	_tile_set_floor = _tile_map_layer_floor.tile_set
	get_tree().current_scene.add_child(_tile_map_layer_floor)
	
	_tile_map_layer_walls = walls_scene.instantiate()
	_tile_set_walls = _tile_map_layer_walls.tile_set
	get_tree().current_scene.add_child(_tile_map_layer_walls)

func cell_to_position(cell: Vector2) -> Vector2:
	return _tile_map_layer_floor.map_to_local(cell) - Vector2(30,30)

func position_to_cell(position: Vector2) -> Vector2:
	return _tile_map_layer_floor.local_to_map(position)

func get_neighbor_cell(current_cell:Vector2 , direction: TileSet.CellNeighbor) -> Vector2:
	return _tile_map_layer_floor.get_neighbor_cell(
		current_cell,
		direction
	)
