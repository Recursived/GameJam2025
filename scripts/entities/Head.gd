class_name Head
extends Area2D

var previous_cell:Vector2 = Vector2.ZERO
var next_cell:Vector2 = Vector2.ZERO
var current_input:String

func _ready():
	EventBus.connect("rollback_head", on_rollback_head)
	EventBus.connect("input_buffer_action", _trigger_next_move)
	EventBus.connect("eight_beat_triggered", _on_movement)
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

func init_head():
	current_input = "none"

func init_spawn_cell(cell: Vector2):
	position = TileMapManager.cell_to_position(cell)
	previous_cell = cell
	next_cell = cell

func _trigger_next_move(action: String):
	if action in InputManager.movement_inputs:
		current_input = action

func _on_movement():
	var input_dict = {
		"ui_up": TileSet.CELL_NEIGHBOR_TOP_SIDE,
		"ui_down": TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
		"ui_left": TileSet.CELL_NEIGHBOR_LEFT_SIDE,
		"ui_right": TileSet.CELL_NEIGHBOR_RIGHT_SIDE
	}
	if current_input in input_dict.keys():
		next_cell = TileMapManager.get_neighbor_cell(
			previous_cell,
			input_dict.get(current_input)
		)

func _on_head_collide(object):
	if is_instance_of(object, Tail):
		EventBus.emit_signal("head_on_tail_collision", object)
	else:
		EventBus.emit_signal("head_on_wall_collision")

func on_rollback_head(new_cell: Vector2):
	EventBus.emit_signal("head_rollbacked")
	current_input = "none"
	position = TileMapManager.cell_to_position(new_cell)
	previous_cell = new_cell
	next_cell = new_cell
