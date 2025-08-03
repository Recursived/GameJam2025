extends Node

const string_to_type = {
	"static":EnemyType.STATIC,
	"moving":EnemyType.MOVING,
	"random":EnemyType.RANDOM,
	"kamikaze":EnemyType.KAMIKAZE,
}

const type_to_string = {
	EnemyType.STATIC:"static",
	EnemyType.MOVING:"moving",
	EnemyType.RANDOM:"random",
	EnemyType.KAMIKAZE:"kamikaze",
}

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
	EventBus.connect("game_over", _on_game_over)
	print("EnemyManager initialized")
	
func _on_game_started():
	list_enemies = []
	var enemy_scene = load("res://scenes/game/Enemy.tscn")
	var enemies = GameManager.enemies
	if enemy_scene:
		for enemy in enemies:
			add_enemy(
				enemy_scene,
				enemy["x"],
				enemy["y"], 
				string_to_type[enemy["type"]],
				enemy["args"]
			)

func add_enemy(enemy_scene, x, y, enemy_type, args):
	var instance_enemy = enemy_scene.instantiate() as Enemy
	list_enemies.append(instance_enemy)
	if instance_enemy is Enemy:
		get_tree().current_scene.add_child(instance_enemy)
		instance_enemy.initialize(Vector2(x, y), enemy_type, args)


func on_move_enemies():
	# sequential moves to avoid problems with collisions
	if not GameManager.get_movement_paused():
		for enemy in list_enemies:
			enemy.is_rollbacked=false
			enemy.move()

func _on_game_over():
	for enemy in list_enemies:
		enemy.queue_free()

func _on_bell_touched(polygon_2d: Polygon2D):
	var is_cow_captured:bool = false
	var new_enemy_list: Array[Enemy] = []
	var polygon: PackedVector2Array = polygon_2d.polygon
	var died_enemy_list: Array[Enemy] = []
	for enemy in list_enemies:
		var enemy_pos: Vector2 = enemy.get_area_position()
		if Geometry2D.is_point_in_polygon(enemy_pos, polygon):
			is_cow_captured = true
			EventBus.emit_signal("enemy_died", enemy)
			died_enemy_list.append(enemy)
			enemy.die()
		else:
			new_enemy_list.append(enemy)
		
	list_enemies = new_enemy_list
	EventBus.emit_signal("capture_result", is_cow_captured)
	
	for enemy in died_enemy_list:
		if not is_instance_valid(enemy):
			return
		if enemy.has_node("AnimationPlayer"):
			var anim_player: AnimationPlayer = enemy.get_node("AnimationPlayer")
			if anim_player.has_animation("tick"):
				anim_player.play("tick")
		await get_tree().create_timer(0.15).timeout
	died_enemy_list.clear()
