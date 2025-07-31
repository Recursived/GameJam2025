class_name AreaEntity
extends Area2D

@export var width: int = 2 : set = set_width
@export var height: int = 2 : set = set_height
@export var origin_offset: Vector2i = Vector2i.ZERO : set = set_origin_offset
@export var display_square_size: float = 60.0 : set = set_display_square_size

# References to child nodes
@onready var color_rect: ColorRect = $ColorRect
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

func set_origin_offset(value: Vector2i):
	if value != origin_offset:
		origin_offset = value
		update_visual()

func set_display_square_size(value: float):
	if value != display_square_size:
		display_square_size = value
		update_visual()

func update_visual():
	# Calculate the actual pixel size based on grid dimensions and display square size
	var pixel_width = width * display_square_size
	var pixel_height = height * display_square_size
	
	# Calculate position based on origin offset
	var offset_position = Vector2(origin_offset.x * display_square_size, origin_offset.y * display_square_size)
	
	# Update ColorRect if it exists
	if color_rect:
		color_rect.size = Vector2(pixel_width, pixel_height)
		color_rect.position = offset_position
	
	# Update CollisionShape2D if it exists
	if collision_shape and collision_shape.shape:
		# Assuming the collision shape is a RectangleShape2D
		if collision_shape.shape is RectangleShape2D:
			var rect_shape = collision_shape.shape as RectangleShape2D
			rect_shape.size = Vector2(pixel_width, pixel_height)
			# Position the collision shape at the center of the rectangle
			collision_shape.position = offset_position + Vector2(pixel_width * 0.5, pixel_height * 0.5)
