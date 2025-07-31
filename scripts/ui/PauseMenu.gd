extends Node

@onready var sfx_slider : Range = $VBoxContainer/SfxSlider
@onready var music_slider : Range = $VBoxContainer/MusicSlider
@onready var resume_button : Button = $VBoxContainer/ResumeButton

func _ready() -> void:
	sfx_slider.connect("value_changed", Callable(self, "_on_sfx_slider_value_changed"))
	music_slider.connect("value_changed", Callable(self, "_on_music_slider_value_changed"))
	resume_button.connect("pressed", Callable(self, "_on_resume_button_pressed"))
	sfx_slider.set_value_no_signal(AudioManager.sfx_volume)
	music_slider.set_value_no_signal(AudioManager.music_volume)

func _on_sfx_slider_value_changed(value :float):
	# Value goes from 0 to 100
	EventBus.emit_signal("set_sfx_volume", value )
	

func _on_music_slider_value_changed(value :float):
	EventBus.emit_signal("set_music_volume", value)


func _on_resume_button_pressed():
	EventBus.emit_signal("resume_music")
	EventBus.emit_signal("input_buffer_action", "ui_cancel") # We fake an escape click again
