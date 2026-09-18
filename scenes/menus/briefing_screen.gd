extends Control

@onready var _game_state: Node = get_node("/root/GameState")
@onready var _portrait_box: ColorRect = $PortraitBox
@onready var _speaker_label: Label = $SpeakerLabel
@onready var _text_label: Label = $TextLabel
@onready var _continue_button: Button = $ContinueButton

var _lines: Array = []
var _index: int = 0

func _ready() -> void:
	_lines = _game_state.pending_briefing_lines
	_continue_button.pressed.connect(_on_continue)
	_continue_button.grab_focus()
	if _lines.is_empty():
		_go_to_next_scene()
		return
	_show_line(0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("p1_ordnance"):
		var viewport: Viewport = get_viewport()
		var focused: Control = viewport.gui_get_focus_owner()
		if focused is Button:
			viewport.set_input_as_handled()
			(focused as Button).pressed.emit()

func _show_line(index: int) -> void:
	_index = index
	var line: BriefingLine = _lines[index]
	_portrait_box.color = line.portrait_color
	_speaker_label.text = line.speaker_name
	_text_label.text = line.text
	_continue_button.text = "Continue" if index < _lines.size() - 1 else "Go"

func _on_continue() -> void:
	if _index < _lines.size() - 1:
		_show_line(_index + 1)
	else:
		_go_to_next_scene()

func _go_to_next_scene() -> void:
	var next_scene: String = _game_state.pending_briefing_next_scene
	_game_state.pending_briefing_lines = [] as Array[Resource]
	_game_state.pending_briefing_next_scene = ""
	get_tree().change_scene_to_file(next_scene)
