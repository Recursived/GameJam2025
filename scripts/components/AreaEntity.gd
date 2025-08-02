class_name AreaEntity
extends Area2D

@export var width: int = 2 : set = set_width
@export var height: int = 2 : set = set_height
@export var origin_offset: Vector2 = Vector2.ZERO : set = set_origin_offset
@export var downsize_factor: float = 0.85
# References to child nodes
@onready var collision_shape: CollisionShape2D = $CollisionShape2D



func _ready() -> void:
	update_visual()
	

## Sets the width of the rectangle
func set_width(value: int):
	if value != width:
		width = max(0, value)
		update_visual()

## Sets the height of the rectangle
func set_height(value: int):
	if value != height:
		height = max(0, value)
		update_visual()

func set_origin_offset(value: Vector2):
	if value != origin_offset:
		origin_offset = value
		update_visual()

func update_visual():
	# Set the position
	var offset_position = TileMapManager.cell_to_position(origin_offset)
	var bottom_right = TileMapManager.cell_to_position(origin_offset + Vector2(width, height))
	
	# Get the size from the cells
	var visual_width = bottom_right.x - offset_position.x
	var visual_height = bottom_right.y - offset_position.y
	
	# Update CollisionShape2D if it exists
	if collision_shape and collision_shape.shape:
		if collision_shape.shape is RectangleShape2D:
			var rect_shape = collision_shape.shape as RectangleShape2D
			
			rect_shape.size = Vector2(visual_width * downsize_factor, visual_height * downsize_factor)
			# Position the collision shape at the center of the rectangle
			collision_shape.position = offset_position + Vector2(visual_width * 0.5, visual_height * 0.5)
