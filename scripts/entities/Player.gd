extends CharacterBody2D

@export var speed: float = 300.0
@export var max_health: int = 100

var health: int
var is_alive: bool = true

func _ready():
	health = max_health
	EventBus.connect("player_respawned", _on_respawned)

func _physics_process(delta):
	if not is_alive:
		return
	
	var movement = InputManager.get_movement_vector()
	# velocity = movement * speed
	# move_and_slide()
	
	EventBus.emit_signal("player_position_changed", global_position)

func take_damage(amount: int):
	health -= amount
	health = max(0, health)
	EventBus.emit_signal("player_health_changed", health, max_health)
	
	if health <= 0:
		die()

func die():
	is_alive = false
	EventBus.emit_signal("player_died")
	EventBus.emit_signal("play_sfx", "player_death")

func _on_respawned():
	health = max_health
	is_alive = true
	# global_position = Vector2.ZERO  # Or spawn point
