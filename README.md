## 🚀 Quick Start

1. Open the project in Godot 4.x
2. Run the project - it should work out of the box
3. Read this README to understand the architecture
4. Start building your game features!

## 📁 Project Structure

Understanding our folder organization is crucial for maintaining clean code:

```
project/
├── scenes/           # All .tscn files organized by purpose
│   ├── UI/          # User interface scenes (menus, HUD, etc.)
│   ├── Game/        # Gameplay scenes (levels, game world)
│   └── Components/  # Reusable scene components
├── scripts/         # All .gd files organized by type
│   ├── managers/    # Singleton systems (autoloaded)
│   ├── entities/    # Game objects (player, enemies, etc.)
│   ├── components/  # Reusable script components
│   └── ui/          # UI-specific scripts
├── assets/          # All game assets
│   ├── textures/    # Images, sprites, icons
│   ├── audio/       # Music and sound effects
│   └── fonts/       # Text fonts
└── resources/       # Custom Godot resources (.tres files)
```

### 🎯 Why This Structure?

- **Easy Navigation**: Find files quickly by their purpose
- **Team Collaboration**: Everyone knows where to put new files
- **Scalability**: Structure grows naturally as project expands
- **Maintenance**: Easy to refactor and update related files

## 🏗️ Architecture Overview

Our project uses a **Manager-Based Architecture** with **Event-Driven Communication**. Here's what that means:

### Singleton Managers (The Brain of Your Game)

Managers are special scripts that exist throughout your entire game. They handle specific responsibilities:

```gdscript
# These are autoloaded - available everywhere as global variables
EventBus      # Communication system
GameManager   # Game rules, scoring, state
SceneManager  # Switching between scenes
AudioManager  # Music and sound effects
InputManager  # Player input handling
SaveManager   # Saving and loading data
```

### Event-Driven Communication

Instead of scripts talking directly to each other (which creates messy dependencies), we use **events**:

```gdscript
# ❌ Bad - Direct coupling
player.health_component.take_damage(10)
ui.health_bar.update_display(player.health)

# ✅ Good - Event-driven
EventBus.emit_signal("player_health_changed", health, max_health)
# Any script can listen for this event and react accordingly
```

## 🧠 Understanding the Managers

### EventBus - The Communication Hub

**What it does**: Allows different parts of your game to communicate without knowing about each other.

**When to use**: Whenever one system needs to tell other systems something happened.

```gdscript
# Sending an event
EventBus.emit_signal("player_died")
EventBus.emit_signal("score_changed", new_score)

# Listening for events
func _ready():
    EventBus.connect("player_died", _on_player_died)

func _on_player_died():
    # React to player death
    show_game_over_screen()
```

**Benefits**: 
- Scripts don't need references to each other
- Easy to add new reactions to events
- Makes debugging easier

### GameManager - The Game Rules

**What it does**: Manages the overall game state, scoring, lives, and game flow.

**Key responsibilities**:
- Track current game state (menu, playing, paused, game over)
- Handle scoring and high scores
- Manage player lives
- Control game pause/resume
- Handle game over conditions

```gdscript
# Examples of using GameManager
GameManager.start_game()           # Start a new game
GameManager.add_score(100)         # Add points
GameManager.pause_game()           # Pause the game
var state = GameManager.get_state() # Get current state
```

### SceneManager - Scene Transitions

**What it does**: Handles switching between different scenes (levels, menus, etc.).

**Why it's useful**: 
- Consistent way to change scenes
- Optional loading screens for large scenes
- Tracks scene history
- Handles transition effects

```gdscript
# Simple scene change
SceneManager.change_scene("MainMenu")

# With loading screen for heavy scenes
SceneManager.change_scene("Level1", true)
```

### AudioManager - Sound Control

**What it does**: Manages all music and sound effects with proper volume control.

**Features**:
- Separate volume controls for music and SFX
- Audio pooling (multiple sounds can play simultaneously)
- Fade in/out effects
- Audio library management

```gdscript
# Play sound effects
AudioManager.play_sfx("jump_sound")
AudioManager.play_sfx("explosion", 0.8)  # At 80% volume

# Control music
AudioManager.play_music("background_theme")
AudioManager.stop_music(2.0)  # Fade out over 2 seconds
```

### InputManager - Advanced Input Handling

**What it does**: Provides advanced input features beyond basic Godot input.

**Features**:
- Input buffering (stores inputs briefly for responsive gameplay)
- Input history (useful for combos or debugging)
- Context switching (different controls for menus vs gameplay)
- Easy movement vector calculation

```gdscript
# Get movement as Vector2
var movement = InputManager.get_movement_vector()

# Check for buffered inputs (great for fighting games, platformers)
if InputManager.is_action_just_pressed_buffered("jump"):
    player.jump()

# Enable/disable input based on context
InputManager.set_input_enabled(false)  # During cutscenes
```

### SaveManager - Data Persistence

**What it does**: Handles saving game progress and user settings.

**Two types of data**:
- **Game Data**: Progress, scores, unlocks (JSON format)
- **Settings**: Audio levels, graphics options (ConfigFile format)

```gdscript
# Save game data
SaveManager.save_data("level_progress", 5)
SaveManager.save_data("high_score", 1500)

# Load game data
var progress = SaveManager.load_data("level_progress", 1)  # Default to 1

# Settings
SaveManager.set_setting("audio", "master_volume", 0.8)
var volume = SaveManager.get_setting("audio", "master_volume", 1.0)
```

## 🎮 Best Practices Guide

### 1. Event-Driven Development

**Do this**: Use EventBus for communication between systems
```gdscript
# When player collects a coin
EventBus.emit_signal("item_collected", "coin", 10)
```

**Not this**: Direct references between unrelated scripts
```gdscript
# Avoid this - creates tight coupling
get_node("/UI/ScoreDisplay").update_score(new_score)
```

### 2. Proper Node Organization

**Scene Structure**:
```
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
├── HealthComponent (Node)
├── MovementComponent (Node)
└── AudioSource (AudioStreamPlayer2D)
```

**Why**: Each node has a single responsibility, making it easier to debug and modify.

### 3. Component-Based Design

Create reusable components that can be added to different entities:

```gdscript
# HealthComponent.gd - Can be used by player, enemies, destructible objects
extends Node
class_name HealthComponent

@export var max_health: int = 100
var current_health: int

func take_damage(amount: int):
    current_health -= amount
    EventBus.emit_signal("health_changed", current_health, max_health)
    
    if current_health <= 0:
        EventBus.emit_signal("entity_died", get_parent())
```

### 4. Resource Management

**Organize your assets**:
- Use consistent naming conventions
- Group related assets in folders
- Preload frequently used resources
- Use Godot's resource system for game data

```gdscript
# Good resource organization
const PLAYER_TEXTURE = preload("res://assets/textures/player.png")
const JUMP_SOUND = preload("res://assets/audio/sfx/jump.ogg")
```

### 5. Error Handling

Always check for potential errors:

```gdscript
# Check if resources exist
if not audio_library.has(sound_name):
    print("Warning: Sound '", sound_name, "' not found")
    return

# Validate scene changes
if not scene_paths.has(scene_name):
    print("Error: Scene '", scene_name, "' not found")
    return
```

### 6. Performance Considerations

**Object Pooling**: Reuse objects instead of creating/destroying them
```gdscript
# Instead of instantiating bullets constantly
# Use a pool of pre-created bullets
```

**Efficient Signals**: Connect signals in `_ready()`, disconnect when needed
```gdscript
func _ready():
    EventBus.connect("game_over", _on_game_over)

func _exit_tree():
    EventBus.disconnect("game_over", _on_game_over)
```

## 🔧 Adding New Features

### Adding a New Manager

1. Create script in `scripts/managers/`
2. Add to autoload in Project Settings
3. Initialize in `_ready()`
4. Connect to relevant EventBus signals

### Adding a New Game Entity

1. Create scene in appropriate folder (`scenes/Game/` or `scenes/Components/`)
2. Attach script in `scripts/entities/` or `scripts/components/`
3. Use existing components when possible
4. Emit events for important state changes

### Adding UI Elements

1. Create scene in `scenes/UI/`
2. Attach script in `scripts/ui/`
3. Connect to EventBus for game state updates
4. Use tweens for animations

## 🐛 Debugging Tips

### Using the EventBus for Debugging

Add debug prints to EventBus connections:
```gdscript
func _on_player_health_changed(health: int, max_health: int):
    print("DEBUG: Player health: ", health, "/", max_health)
```

### Manager State Inspection

Add debug methods to managers:
```gdscript
# In GameManager
func debug_print_state():
    print("Game State: ", current_state)
    print("Score: ", score)
    print("Lives: ", lives)
```

### Common Issues and Solutions

**Problem**: "Node not found" errors
**Solution**: Check node paths, ensure scenes are properly structured

**Problem**: Events not firing
**Solution**: Verify signal connections in `_ready()` functions

**Problem**: Audio not playing
**Solution**: Check audio library loading and file paths

## 📋 Code Style Guidelines

### Naming Conventions
- **Variables**: `snake_case` (e.g., `player_health`)
- **Functions**: `snake_case` (e.g., `take_damage()`)
- **Constants**: `UPPER_CASE` (e.g., `MAX_HEALTH`)
- **Classes**: `PascalCase` (e.g., `HealthComponent`)
- **Signals**: `snake_case` (e.g., `health_changed`)

### File Organization
- One class per file
- File name matches class name
- Group related functions together
- Use regions/comments for large files

### Comments
```gdscript
# Use comments to explain WHY, not WHAT
func calculate_damage(base_damage: int) -> int:
    # Apply critical hit multiplier based on luck stat
    if randf() < luck_percentage:
        return base_damage * 2
    return base_damage
```

## 🚀 Getting Started with Development

### Your First Feature

1. **Choose a simple feature** (e.g., collecting coins)
2. **Identify the components**:
   - Coin scene with collision detection
   - Player collision response
   - Score update
   - UI display update

3. **Implement using our architecture**:
   ```gdscript
   # In Coin.gd
   func _on_body_entered(body):
       if body.has_method("collect_coin"):
           EventBus.emit_signal("item_collected", "coin", 10)
           queue_free()
   
   # GameManager listens and updates score
   func _on_item_collected(item_type: String, value: int):
       if item_type == "coin":
           add_score(value)
   ```

4. **Test thoroughly**
5. **Document any new events or functions**

### Extending the Managers

Each manager is designed to be extended. For example, to add a new game state:

```gdscript
# In GameManager.gd, add to the enum
enum GameState {
    MENU,
    PLAYING,
    PAUSED,
    GAME_OVER,
    LOADING,
    CUTSCENE  # Your new state
}

# Add handling logic
func start_cutscene():
    current_state = GameState.CUTSCENE
    EventBus.emit_signal("cutscene_started")
```

## 🤝 Team Collaboration

### Before Starting Work
1. Pull latest changes
2. Check this README for updates
3. Understand the feature you're implementing

### While Working
1. Follow the established patterns
2. Use EventBus for communication
3. Test your changes thoroughly
4. Document new events or public functions

### Before Committing
1. Test the entire game flow
2. Check for console errors
3. Update documentation if needed
4. Follow our naming conventions

## 📚 Learning Resources

### Godot-Specific
- [Official Godot Documentation](https://docs.godotengine.org/)
- [Godot Signal System](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)
- [Scene System Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html)

### Game Architecture
- Understanding Component Systems
- Event-Driven Programming
- State Management Patterns

## ❓ FAQ

**Q: How do I add a new sound effect?**
A: Add the audio file to `assets/audio/sfx/`, then load it in AudioManager's `load_audio_library()` function.

**Q: How do I create a new scene transition?**
A: Add the scene path to SceneManager's `scene_paths` dictionary, then use `SceneManager.change_scene("YourScene")`

**Q: How do I add a new input action?**
A: Define it in Project Settings > Input Map, then use it through InputManager or standard Godot input functions.

**Q: How do I save custom game data?**
A: Use `SaveManager.save_data("key", value)` and `SaveManager.load_data("key", default_value)`

**Q: How do I make two systems communicate?**
A: Use EventBus! One system emits a signal, the other listens for it.

---

## Changelog