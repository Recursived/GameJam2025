class_name Head
extends Area2D

@onready var sprite = $AnimatedSprite2D

var previous_cell:Vector2 = Vector2.ZERO
var next_cell:Vector2 = Vector2.ZERO
var previous_input: String
var next_input: String
var is_moving: bool

func _ready():
	EventBus.connect("rollback_head", on_rollback_head)
	EventBus.connect("input_buffer_action", _trigger_next_move)
	EventBus.connect("quarter_beat_triggered", _on_quarter_beat)
	EventBus.connect("eight_beat_triggered", _on_movement)
	self.connect("area_entered", _on_head_collide)
	self.connect("body_entered", _on_head_collide)

func _physics_process(delta):
	if next_input != "none":
		sprite.rotation = InputManager.input_to_angle[next_input]

func init_head():
	previous_input = "none"
	next_input = "none"
	is_moving = false

func init_spawn_cell(cell: Vector2):
	position = TileMapManager.cell_to_position(cell)
	previous_cell = cell
	next_cell = cell

func _trigger_next_move(action: String):
	if action in InputManager.input_dict:
		var processed_cell = TileMapManager.get_neighbor_cell(
			previous_cell,
			InputManager.input_dict[action]["neighbor"]
		)
		if processed_cell not in [previous_cell, PlayerManager.get_last_tail_cell()]:
			is_moving = true
			next_input = action

func _on_movement():
	if PlayerManager.is_alive and is_moving:
		next_cell = TileMapManager.get_neighbor_cell(
			previous_cell,
			InputManager.input_dict[next_input]["neighbor"]
		)
		
		if previous_input == "none":
			previous_input = next_input
			
		position = TileMapManager.cell_to_position(next_cell)
		EventBus.emit_signal(
			"head_cell_changed",
			previous_cell,
			next_cell,
			previous_input,
			next_input
		)
		previous_input = next_input
		previous_cell = next_cell

func _on_quarter_beat(quarter_beat_modulo: int):
	sprite.frame = quarter_beat_modulo
	
func _on_head_collide(object):
	if is_instance_of(object, Tail):
		EventBus.emit_signal("head_on_tail_collision", object)
	else:
		EventBus.emit_signal("head_on_wall_collision")

func on_rollback_head(new_cell: Vector2):
	EventBus.emit_signal("head_rollbacked")
	is_moving = false
	position = TileMapManager.cell_to_position(new_cell)
	var last_tail_inputs = PlayerManager.get_last_tail_inputs()
	previous_input = last_tail_inputs["next_input"]
	next_input = last_tail_inputs["next_input"]
	previous_cell = new_cell
	next_cell = new_cell
