extends Node

const Enemy = preload("res://scripts/entities/Enemy.gd")

func _ready() -> void:
	EventBus.connect("game_started", _on_game_started)
	print("EnemyManager initialized")
	
	
	
func _on_game_started():
	var enemy_scene = load("res://scenes/game/Enemy.tscn")
	if enemy_scene:
		var instance_enemy = enemy_scene.instantiate() as Enemy
		if instance_enemy is Enemy:
			get_tree().current_scene.add_child(instance_enemy)
			instance_enemy.initialize(Vector2(4, 3), 3, 2) # Example values
