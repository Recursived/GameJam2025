extends CharacterBody2D

@export var movement_speed: float = 300.0
@export var max_health: int = 100

var health: int
var is_alive: bool = true

func _ready():
	health = max_health
	EventBus.connect("player_respawned", _on_respawned)

func _physics_process(delta):
	if not is_alive:
		return
	
	var previous_position = position
	
	velocity = _process_move()
	
	move_and_slide()
	
	position = position.clamp(Vector2.ZERO, GameManager.viewport_size)
	
	if position != previous_position:
		EventBus.emit_signal("player_position_changed", position)
	
func _process_move() -> Vector2:
	var movement = InputManager.get_movement_vector()
	return movement * movement_speed

func _process_position(delta, velocity):
	position += velocity * delta
	
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
