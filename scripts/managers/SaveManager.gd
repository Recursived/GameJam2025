extends Node

const SAVE_FILE_PATH = "user://save_game.dat"
const SETTINGS_FILE_PATH = "user://settings.cfg"

var game_data = {}
var settings_data = {}

func _ready():
	load_settings()
	print("SaveManager initialized")

func save_data(key: String, value):
	game_data[key] = value
	save_to_file()

func load_data(key: String, default_value = null):
	if game_data.has(key):
		return game_data[key]
	return default_value

func save_to_file():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		var json = JSON.new()
		file.store_string(json.stringify(game_data))
		file.close()
		print("Game data saved")
	else:
		print("Error: Could not save game data")

func load_from_file():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_text)
			
			if parse_result == OK:
				game_data = json.data
				print("Game data loaded")
			else:
				print("Error parsing save file")
	else:
		print("No save file found, starting fresh")

func delete_save():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)
		game_data.clear()
		print("Save file deleted")

func save_settings():
	var config = ConfigFile.new()
	
	for section in settings_data:
		for key in settings_data[section]:
			config.set_value(section, key, settings_data[section][key])
	
	config.save(SETTINGS_FILE_PATH)
	print("Settings saved")

func load_settings():
	var config = ConfigFile.new()
	
	if config.load(SETTINGS_FILE_PATH) == OK:
		for section in config.get_sections():
			if not settings_data.has(section):
				settings_data[section] = {}
			
			for key in config.get_section_keys(section):
				settings_data[section][key] = config.get_value(section, key)
		
		print("Settings loaded")
	else:
		# Create default settings
		settings_data = {
			"audio": {
				"master_volume": 1.0,
				"music_volume": 0.7,
				"sfx_volume": 0.8
			},
			"graphics": {
				"fullscreen": false,
				"vsync": true
			},
			"controls": {
				# Custom key bindings could go here
			}
		}
		save_settings()

func get_setting(section: String, key: String, default_value = null):
	if settings_data.has(section) and settings_data[section].has(key):
		return settings_data[section][key]
	return default_value

func set_setting(section: String, key: String, value):
	if not settings_data.has(section):
		settings_data[section] = {}
	
	settings_data[section][key] = value
	save_settings()

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)
