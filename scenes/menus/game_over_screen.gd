extends Control

const MISSION_SCENE_PATH: String = "res://scenes/levels/london.tscn"

@onready var _restart_button: Button = $ButtonList/RestartButton
@onready var _skip_tutorial_button: Button = $ButtonList/SkipTutorialButton
@onready var _quit_button: Button = $ButtonList/QuitButton
@onready var _game_state: Node = get_node("/root/GameState")

func _ready() -> void:
	_restart_button.pressed.connect(_on_restart)
	_skip_tutorial_button.pressed.connect(_on_skip_tutorial)
	_quit_button.pressed.connect(_on_quit)
	_skip_tutorial_button.visible = _game_state.tutorial_completed
	_restart_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("p1_ordnance"):
		var viewport: Viewport = get_viewport()
		var focused: Control = viewport.gui_get_focus_owner()
		if focused is Button:
			viewport.set_input_as_handled()
			(focused as Button).pressed.emit()

func _on_restart() -> void:
	_game_state.restart_section = ""
	get_tree().change_scene_to_file(MISSION_SCENE_PATH)

func _on_skip_tutorial() -> void:
	_game_state.restart_section = "thames_run"
	get_tree().change_scene_to_file(MISSION_SCENE_PATH)

func _on_quit() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/title_screen.tscn")
