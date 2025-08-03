extends Control

@onready var hearts_container := $HeartsContainer
@onready var levelLabel := $LevelLabel
@export var heart_scene: PackedScene
@export var max_life := PlayerManager.default_health  # nombre max de cœurs

func _ready():
	EventBus.connect("update_health", update_hearts)
	EventBus.connect("level_completed", update_level)
	
	levelLabel.text = "Level : " + str(GameManager.current_level) + "/6"
	levelLabel.scale.x = 2 / GameManager.current_zoom
	levelLabel.scale.y = 2 / GameManager.current_zoom

func update_hearts(current_life: int):
	hearts_container.scale.x = 2 / GameManager.current_zoom
	hearts_container.scale.y = 2 / GameManager.current_zoom
	for child in hearts_container.get_children():
		hearts_container.remove_child(child)
		child.queue_free()  # nettoie les anciens cœurs

	for i in max_life:
		var heart = heart_scene.instantiate()
		var texture_rect = heart as TextureRect

		if i < current_life:
			texture_rect.texture = preload("res://resources/assets/coeur_plein.png")
		else:
			texture_rect.texture = preload("res://resources/assets/coeur_vide.png")

		hearts_container.add_child(texture_rect)

func update_level():
	levelLabel.text = "Level : " + str(GameManager.current_level)
