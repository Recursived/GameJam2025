extends Node


enum EnemyType {
	STATIC,
	MOVING,
	RANDOM, # Moving randomly
	KAMIKAZE, # Straight line until you bump something 
}

const Enemy = preload("res://scripts/entities/Enemy.gd")


var list_enemies: Array[Enemy] = []

func _ready() -> void:
	EventBus.connect("game_started", _on_game_started)
	EventBus.connect("bell_touched", _on_bell_touched)
  EventBus.connect("beat_triggered", on_move_enemies)
	print("EnemyManager initialized")
	
	
func _on_game_started():
	var enemy_scene = load("res://scenes/game/Enemy.tscn")
	if enemy_scene:
		add_enemy(enemy_scene, 6, 12, 1, 1, EnemyType.STATIC)
		add_enemy(enemy_scene, 8, 5, 1, 1, EnemyType.MOVING)
		add_enemy(enemy_scene, 20, 2, 1, 1, EnemyType.KAMIKAZE)
		add_enemy(enemy_scene, 20, 3, 1, 1, EnemyType.KAMIKAZE)
		add_enemy(enemy_scene, 20, 7, 1, 1, EnemyType.KAMIKAZE)
		add_enemy(enemy_scene, 20, 5, 1, 1, EnemyType.KAMIKAZE)
		add_enemy(enemy_scene, 22, 2, 1, 1, EnemyType.KAMIKAZE)
		add_enemy(enemy_scene, 22, 3, 1, 1, EnemyType.KAMIKAZE)
		add_enemy(enemy_scene, 22, 7, 1, 1, EnemyType.KAMIKAZE)
		add_enemy(enemy_scene, 22, 5, 1, 1, EnemyType.KAMIKAZE)

func add_enemy(enemy_scene, x, y, width, height, enemy_type):
	var instance_enemy = enemy_scene.instantiate() as Enemy
	list_enemies.append(instance_enemy)
	if instance_enemy is Enemy:
		get_tree().current_scene.add_child(instance_enemy)
		instance_enemy.initialize(Vector2(x, y), width, height, enemy_type)


func on_move_enemies():
	# sequential moves to avoid problems with collisions
	for enemy in list_enemies:
		enemy.move()

func _on_bell_touched(polygon_2d: Polygon2D):
	var new_enemy_list: Array[Enemy] = []
	var polygon: PackedVector2Array = polygon_2d.polygon
	for enemy in list_enemies:
		var enemy_cell: Vector2 = enemy.get_area_position()
		var enemy_pos: Vector2 = TileMapManager.cell_to_position(enemy_cell)
		if Geometry2D.is_point_in_polygon(enemy_pos, polygon):
			EventBus.emit_signal("enemy_died", enemy)
			enemy.queue_free()
		else:
			new_enemy_list.append(enemy)
	list_enemies = new_enemy_list
	if list_enemies.is_empty():
		EventBus.emit_signal("game_won")

