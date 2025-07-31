# DebugHUD.gd
extends Control

# References to UI elements
var state_label: Label 
var score_label: Label
var high_score_label: Label  
var level_label: Label 
var lives_label: Label
var head_info_label: Label  
var time_scale_label: Label 
var viewport_label: Label 
var version_label: Label 
var head_label: Label

# Update frequency (in seconds)
var update_interval: float = 0.1
var time_since_update: float = 0.0

func _ready():
	# Connect to EventBus signals for real-time updates
	state_label = $VBoxContainer/StateLabel
	score_label = $VBoxContainer/ScoreLabel
	high_score_label = $VBoxContainer/HighScoreLabel
	level_label = $VBoxContainer/LevelLabel
	lives_label = $VBoxContainer/LivesLabel
	head_info_label = $VBoxContainer/HeadInfoLabel
	time_scale_label = $VBoxContainer/TimeScaleLabel
	viewport_label = $VBoxContainer/ViewportLabel
	version_label = $VBoxContainer/VersionLabel
	head_label = $VBoxContainer/HeadLabel
	
	EventBus.connect("game_started", _on_game_state_changed)
	EventBus.connect("game_over", _on_game_state_changed)
	EventBus.connect("game_paused", _on_game_state_changed)
	EventBus.connect("game_resumed", _on_game_state_changed)
	EventBus.connect("score_changed", _on_score_changed)
	EventBus.connect("viewport_size_changed", _on_viewport_changed)

func _process(delta):
	time_since_update += delta
	if time_since_update >= update_interval:
		update_debug_display()
		time_since_update = 0.0

func update_debug_display():
	if not GameManager:
		return
	
	# Update state
	var state_text = get_state_string(GameManager.current_state)
	state_label.text = "Engine State: " + state_text
	
	# Update score and high score
	score_label.text = "Score: " + str(GameManager.score)
	high_score_label.text = "High Score: " + str(GameManager.high_score)
	
	# Update level and lives
	level_label.text = "Level: " + str(GameManager.current_level)
	
	# Player info
	lives_label.text = "Size: " + str(PlayerManager.tail_list.size())
	if PlayerManager.current_head:
		var cell_pos = TileMapManager.position_to_cell(PlayerManager.current_head.position)
		head_info_label.text = "Cell position: " + str(cell_pos)
	else:
		head_info_label.text = "Size: " + str(Vector2i.ZERO)
	# Update time scale
	time_scale_label.text = "Time Scale: " + str(GameManager.time_scale)
	
	# Update viewport size
	viewport_label.text = "Viewport: " + str(GameManager.viewport_size)
	
	# Update version from game data
	version_label.text = "Version: " + str(GameManager.game_data.version)
	
	# Update head instance status
	var head_status = "None"
	if PlayerManager.current_head:
		if is_instance_valid(PlayerManager.current_head):
			var pos = PlayerManager.current_head.global_position
			head_status = "Active at " + str(pos)
		else:
			head_status = "Invalid Reference"
	head_label.text = "pixel position: " + head_status

func get_state_string(state) -> String:
	match state:
		GameManager.GameState.MENU:
			return "MENU"
		GameManager.GameState.PLAYING:
			return "PLAYING"
		GameManager.GameState.PAUSED:
			return "PAUSED"
		GameManager.GameState.GAME_OVER:
			return "GAME_OVER"
		GameManager.GameState.LOADING:
			return "LOADING"
		_:
			return "UNKNOWN"

# Signal handlers for real-time updates
func _on_game_state_changed():
	update_debug_display()

func _on_score_changed(new_score: int):
	score_label.text = "Score: " + str(new_score)

func _on_viewport_changed(size: Vector2):
	viewport_label.text = "Viewport: " + str(size)
