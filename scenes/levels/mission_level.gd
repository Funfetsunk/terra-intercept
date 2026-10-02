extends Node2D

## Shared script for mission levels. `mission_id` must match the level's
## MapNodeData id: results, high scores and saves key off it.

@export var mission_id: String = ""
## True only for missions with a tutorial section (London), so the game-over
## screen knows whether to offer "Skip tutorial".
@export var has_tutorial: bool = false
## After the last life is lost: seconds to let the ship's explosion play out
## before the screen fades to the game-over screen.
@export var game_over_delay: float = 1.6

const RESULTS_SCENE: String = "res://scenes/menus/results_screen.tscn"
const GAME_OVER_SCENE: String = "res://scenes/menus/game_over_screen.tscn"

var _leaving: bool = false

@onready var _player: Node2D = $PlayfieldRoot/PlayerShip
@onready var _hud: CanvasLayer = $HUD
@onready var _fade: CanvasLayer = $ScreenFade

func _ready() -> void:
	var game_state: Node = get_node("/root/GameState")
	game_state.current_mission_name = mission_id
	game_state.current_level_path = scene_file_path
	game_state.current_level_has_tutorial = has_tutorial
	game_state.start_new_run()
	game_state.mission_completed.connect(_on_mission_completed)
	game_state.game_over_triggered.connect(_on_game_over)
	_hud.bind_player(_player)

## Boss down: clear the enemy fire, let the ship hover and fly off the top,
## then fade out to the results screen.
func _on_mission_completed(_results: Dictionary) -> void:
	if _leaving:
		return
	_begin_leaving()
	var bullets: Node = get_node("/root/BulletManager")
	bullets.clear_enemy_bullets_in_rect(get_node("/root/Playfield").rect.grow(bullets.despawn_margin))
	_player.play_victory_exit()
	await _player.victory_exit_finished
	await _fade.fade_out()
	get_tree().change_scene_to_file(RESULTS_SCENE)

## Last life lost: the ship has already exploded; hide it, let the explosion
## play, then fade out to the game-over screen.
func _on_game_over() -> void:
	if _leaving:
		return
	_begin_leaving()
	_player.visible = false
	_player.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(game_over_delay, false).timeout
	await _fade.fade_out()
	get_tree().change_scene_to_file(GAME_OVER_SCENE)

## Once an outro starts the pause menu is switched off, so the game can't be
## paused halfway through and carry the pause into the next screen.
func _begin_leaving() -> void:
	_leaving = true
	var pause_menu: Node = get_node_or_null("PauseMenu")
	if pause_menu != null:
		pause_menu.process_mode = Node.PROCESS_MODE_DISABLED
