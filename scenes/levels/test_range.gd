extends Node2D

@onready var _player: Node = $PlayerShip
@onready var _hud: CanvasLayer = $HUD

func _ready() -> void:
	var game_state: Node = get_node("/root/GameState")
	game_state.start_new_run()
	_hud.bind_player(_player)
