extends CharacterBody2D

@export var movement_speed: float = 600.0
@export var jump_speed: float = 900.0
@export var max_jump_time: float = 20.0
@export var max_health: int = 100

const GRAVITY = 400.0
var health: int
var current_jump_time: int = 0
var is_alive: bool = true

func _ready():
	health = max_health
	EventBus.connect("player_respawned", _on_respawned)
	EventBus.connect("input_buffer_action", _trigger_jump)

func _physics_process(delta):
	if not is_alive:
		return
	
	var previous_position = position
	
	velocity = Vector2.ZERO
	_process_move()
	_process_jump(delta)
	velocity.y += GRAVITY
	
	move_and_slide()
	
	position = position.clamp(Vector2.ZERO, get_parent().get_screen_size() - Vector2(40,40))
	
	if position != previous_position:
		EventBus.emit_signal("player_position_changed", position)
	
func _process_move():
	var movement = InputManager.get_movement_vector()
	movement.y = 0
	velocity += movement * movement_speed

func _process_jump(delta):
	current_jump_time -= (1 * delta)
	if current_jump_time <= 0:
		current_jump_time = 0
	else:
		velocity += Vector2(0, -jump_speed)
	
func _trigger_jump(action):
	if action == "ui_up" and is_on_floor():
		current_jump_time = max_jump_time
		EventBus.emit_signal("play_sfx", "click", 1.0)

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
