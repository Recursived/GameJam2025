class_name Head
extends Area2D

var previous_cell:Vector2 = Vector2.ZERO
var next_cell:Vector2 = Vector2.ZERO

func _ready():
	EventBus.connect("rollback_head", on_rollback_head)
	EventBus.connect("movement_input_on_beat", trigger_next_move)
	self.connect("area_entered", _on_head_collide)
	self.connect("body_entered", _on_head_collide)

func _physics_process(delta):
	if not PlayerManager.is_alive:
		return
	
	if next_cell not in [previous_cell, PlayerManager.get_last_tail_cell()]:
		position = TileMapManager.cell_to_position(next_cell)
		EventBus.emit_signal(
			"head_cell_changed",
			previous_cell,
			next_cell
		)
		previous_cell = next_cell

func init_spawn_cell(cell: Vector2):
	position = TileMapManager.cell_to_position(cell)
	previous_cell = cell
	next_cell = cell

func trigger_next_move(action: String):
	var input_dict = {
		"ui_up": TileSet.CELL_NEIGHBOR_TOP_SIDE,
		"ui_down": TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
		"ui_left": TileSet.CELL_NEIGHBOR_LEFT_SIDE,
		"ui_right": TileSet.CELL_NEIGHBOR_RIGHT_SIDE
	}
	if action in input_dict.keys():
		next_cell = TileMapManager.get_neighbor_cell(
			previous_cell,
			input_dict.get(action)
		)

func _on_head_collide(object):
	if is_instance_of(object, Tail):
		EventBus.emit_signal("head_on_tail_collision", object)
	else:
		EventBus.emit_signal("head_on_wall_collision")

func on_rollback_head(new_cell: Vector2):
	EventBus.emit_signal("head_rollbacked")
	position = TileMapManager.cell_to_position(new_cell)
	previous_cell = new_cell
	next_cell = new_cell
