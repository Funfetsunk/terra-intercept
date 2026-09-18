extends Control

const REMAP_ROW_SCENE: PackedScene = preload("res://scenes/menus/remap_row.tscn")
const ACTION_DISPLAY_NAMES: Dictionary = {
	"p1_focus": "Focus",
	"p1_squad_prev": "Squad Prev",
	"p1_squad_next": "Squad Next",
	"p1_special": "Special",
	"p1_ordnance": "Ordnance",
	"p1_pause": "Pause",
}

@onready var _settings: Node = get_node("/root/Settings")
@onready var _crt_button: Button = $CrtButton
@onready var _shake_button: Button = $ShakeButton
@onready var _contrast_button: Button = $ContrastButton
@onready var _difficulty_button: Button = $DifficultyButton
@onready var _remap_list: VBoxContainer = $RemapList
@onready var _back_button: Button = $BackButton

var _rows: Array[RemapRow] = []
var _listening_action: String = ""

func _ready() -> void:
	_crt_button.pressed.connect(_on_crt_pressed)
	_shake_button.pressed.connect(_on_shake_pressed)
	_contrast_button.pressed.connect(_on_contrast_pressed)
	_difficulty_button.pressed.connect(_on_difficulty_pressed)
	_back_button.pressed.connect(_on_back)
	for action: String in _settings.REMAPPABLE_ACTIONS:
		var row: RemapRow = REMAP_ROW_SCENE.instantiate()
		_remap_list.add_child(row)
		row.setup(action, ACTION_DISPLAY_NAMES.get(action, action))
		row.rebind_requested.connect(_on_rebind_requested)
		_rows.append(row)
	_refresh_labels()
	_crt_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if not _listening_action.is_empty():
		if event is InputEventKey and event.pressed and not event.echo:
			_settings.remap_action(_listening_action, event)
			_finish_listening()
			get_viewport().set_input_as_handled()
		elif event is InputEventJoypadButton and event.pressed:
			_settings.remap_action(_listening_action, event)
			_finish_listening()
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("p1_ordnance"):
		var viewport: Viewport = get_viewport()
		var focused: Control = viewport.gui_get_focus_owner()
		if focused is Button:
			viewport.set_input_as_handled()
			(focused as Button).pressed.emit()

func _refresh_labels() -> void:
	_crt_button.text = "CRT Filter: %s" % ("On" if _settings.crt_filter_enabled else "Off")
	_shake_button.text = "Screen Shake: %s" % ("On" if _settings.screen_shake_enabled else "Off")
	_contrast_button.text = "High-Contrast Bullets: %s" % ("On" if _settings.high_contrast_bullets else "Off")
	_difficulty_button.text = "Difficulty: %s" % _settings.difficulty

func _on_crt_pressed() -> void:
	_settings.set_crt_filter_enabled(not _settings.crt_filter_enabled)
	_refresh_labels()

func _on_shake_pressed() -> void:
	_settings.set_screen_shake_enabled(not _settings.screen_shake_enabled)
	_refresh_labels()

func _on_contrast_pressed() -> void:
	_settings.set_high_contrast_bullets(not _settings.high_contrast_bullets)
	_refresh_labels()

func _on_difficulty_pressed() -> void:
	_settings.set_difficulty("Easy" if _settings.difficulty == "Normal" else "Normal")
	_refresh_labels()

func _on_rebind_requested(action: String) -> void:
	_listening_action = action
	for row: RemapRow in _rows:
		if row.action == action:
			row.set_listening()

func _finish_listening() -> void:
	_listening_action = ""
	for row: RemapRow in _rows:
		row.refresh(ACTION_DISPLAY_NAMES.get(row.action, row.action))

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/title_screen.tscn")
