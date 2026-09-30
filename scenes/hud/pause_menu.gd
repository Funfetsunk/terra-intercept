extends CanvasLayer

## In-mission pause menu (design summary: Resume, Options, Restart Mission,
## Quit to Hangar). Opens on p1_pause and freezes the game tree; this layer
## keeps processing while paused. Quit to Hangar applies the same refund rule
## as the game-over screen.

const OPTIONS_SCENE: PackedScene = preload("res://scenes/menus/options_screen.tscn")
const HANGAR_SCENE_PATH: String = "res://scenes/menus/hangar.tscn"

@onready var _root: Control = $Root
@onready var _resume_button: Button = $Root/Frame/Buttons/ResumeButton
@onready var _options_button: Button = $Root/Frame/Buttons/OptionsButton
@onready var _restart_button: Button = $Root/Frame/Buttons/RestartButton
@onready var _hangar_button: Button = $Root/Frame/Buttons/HangarButton
@onready var _game_state: Node = get_node("/root/GameState")

var _is_open: bool = false
var _options: Control = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root.visible = false
	_resume_button.pressed.connect(close)
	_options_button.pressed.connect(_on_options)
	_restart_button.pressed.connect(_on_restart)
	_hangar_button.pressed.connect(_on_hangar)

func _unhandled_input(event: InputEvent) -> void:
	if _options != null:
		return  # The options screen owns input (including rebinding the pause key).
	if event.is_action_pressed("p1_pause"):
		get_viewport().set_input_as_handled()
		if _is_open:
			close()
		elif not get_tree().paused:
			# Only open over live gameplay: a tutorial prompt already owns the pause.
			open()
		return
	if _is_open and event.is_action_pressed("p1_ordnance"):
		var focused: Control = get_viewport().gui_get_focus_owner()
		if focused is Button:
			get_viewport().set_input_as_handled()
			(focused as Button).pressed.emit()

func open() -> void:
	_is_open = true
	get_tree().paused = true
	_root.visible = true
	_resume_button.grab_focus()

func close() -> void:
	_is_open = false
	_root.visible = false
	get_tree().paused = false

func _on_options() -> void:
	_options = OPTIONS_SCENE.instantiate()
	_options.embedded = true
	_options.closed.connect(_on_options_closed)
	add_child(_options)
	_root.visible = false

func _on_options_closed() -> void:
	_options = null
	_root.visible = true
	_options_button.grab_focus()

func _on_restart() -> void:
	get_tree().paused = false
	_game_state.restart_section = ""
	get_tree().reload_current_scene()

func _on_hangar() -> void:
	get_tree().paused = false
	_game_state.refund_ledger()
	get_tree().change_scene_to_file(HANGAR_SCENE_PATH)
