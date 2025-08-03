extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
	if anim_name == "fade_to":
		EventBus.emit_signal("on_fade_finished")
		animation_player.play("fade_out")
	elif anim_name == "fade_out":
		color_rect.visible = false
	
func transition():
	color_rect.visible = true
	animation_player.play("fade_to")
