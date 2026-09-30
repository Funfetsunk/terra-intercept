extends Node2D

## Shared script for mission levels. `mission_id` must match the level's
## MapNodeData id: results, high scores and saves key off it.

@export var mission_id: String = ""
## True only for missions with a tutorial section (London), so the game-over
## screen knows whether to offer "Skip tutorial".
@export var has_tutorial: bool = false

@onready var _player: Node = $PlayfieldRoot/PlayerShip
@onready var _hud: CanvasLayer = $HUD

func _ready() -> void:
	var game_state: Node = get_node("/root/GameState")
	game_state.current_mission_name = mission_id
	game_state.current_level_path = scene_file_path
	game_state.current_level_has_tutorial = has_tutorial
	game_state.start_new_run()
	game_state.mission_completed.connect(_on_mission_completed)
	game_state.game_over_triggered.connect(_on_game_over)
	_hud.bind_player(_player)

func _on_mission_completed(_results: Dictionary) -> void:
	get_tree().change_scene_to_file("res://scenes/menus/results_screen.tscn")

func _on_game_over() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/game_over_screen.tscn")
