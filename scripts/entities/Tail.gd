class_name Tail 
extends Area2D

@onready var sprite = $AnimatedSprite2D

@export var is_bell:bool = false

var is_odd = false

func _ready():
	is_bell = false
	EventBus.connect("bell_changed", on_becoming_bell)

func _physics_process(delta):
	pass

func on_becoming_bell(bell: Tail):
	if self == bell:
		is_bell = true
		var color_rect: ColorRect = get_node("ColorRect")
		if color_rect:
			color_rect.color = Color("green")
		else:
			print("ERROR: do not find a color rect to modify")

func play_animation(spriteAnimation, frameNumber):
	sprite.frame = frameNumber
	sprite.rotation = spriteAnimation["orientation"]
	if(is_odd):
		sprite.play(spriteAnimation["animation_name"])
	else:
		sprite.play_backwards(spriteAnimation["animation_name"])

	
