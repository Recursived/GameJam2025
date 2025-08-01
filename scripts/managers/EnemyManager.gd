extends Node

const Enemy = preload("res://scripts/entities/Enemy.gd")

func _ready() -> void:
	EventBus.connect("game_started", _on_game_started)
	print("EnemyManager initialized")
	
	
	
func _on_game_started():
	var enemy_scene = load("res://scenes/game/Enemy.tscn")
	if enemy_scene:
		add_enemy(enemy_scene, 6, 12, 1, 1)
		add_enemy(enemy_scene, 6, 3, 1, 1)
		add_enemy(enemy_scene, 8, 5, 1, 1)
		add_enemy(enemy_scene, 20, 10, 1, 1)
		add_enemy(enemy_scene, 20, 7, 1, 1)
		add_enemy(enemy_scene, 25, 8, 1, 1)

func add_enemy(enemy_scene, x, y, width, height):
	var instance_enemy = enemy_scene.instantiate() as Enemy
	if instance_enemy is Enemy:
		get_tree().current_scene.add_child(instance_enemy)
		instance_enemy.initialize(Vector2(x, y), width, height)
