extends Node2D

@onready var _player: Node = $PlayfieldRoot/PlayerShip
@onready var _hud: CanvasLayer = $HUD

func _ready() -> void:
	var game_state: Node = get_node("/root/GameState")
	game_state.start_new_run()
	game_state.mission_completed.connect(_on_mission_completed)
	_hud.bind_player(_player)

func _on_mission_completed(_results: Dictionary) -> void:
	get_tree().change_scene_to_file("res://scenes/menus/results_screen.tscn")
