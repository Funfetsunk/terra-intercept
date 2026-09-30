extends Button
class_name MapNodeButton

signal activated(node_data: Resource)

enum State { LOCKED, AVAILABLE, COMPLETED }

@export var icon_locked: Texture2D
## Two frames side by side (16x16 each); the button blinks between them.
@export var icon_available_sheet: Texture2D
@export var icon_completed: Texture2D
@export var blink_interval: float = 0.4
## Width the place-name label wraps at.
@export var label_width: float = 88.0
@export var name_color: Color = Color("c7dcd0")
@export var name_locked_color: Color = Color("7f708a")
@export var name_focus_color: Color = Color("f9c22b")

var node_data: Resource
var _state: State = State.LOCKED
var _blink_frames: Array[Texture2D] = []
var _blink_timer: float = 0.0
var _blink_index: int = 0

@onready var _name_label: Label = $NameLabel

func _ready() -> void:
	focus_entered.connect(_refresh_name_color)
	focus_exited.connect(_refresh_name_color)
	mouse_entered.connect(_refresh_name_color)
	mouse_exited.connect(_refresh_name_color)

## The button itself is just the icon; the name label sits beside it at
## label_offset (from the icon centre to the label centre).
func setup(data: Resource, label_text: String, state: State, label_offset: Vector2) -> void:
	node_data = data
	_state = state
	var is_enabled: bool = state != State.LOCKED
	disabled = not is_enabled
	focus_mode = Control.FOCUS_ALL if is_enabled else Control.FOCUS_NONE
	match state:
		State.LOCKED:
			icon = icon_locked
		State.COMPLETED:
			icon = icon_completed
		State.AVAILABLE:
			_build_blink_frames()
			icon = _blink_frames[0] if not _blink_frames.is_empty() else null
	_name_label.text = label_text
	_name_label.size = Vector2(label_width, 0.0)
	var label_size: Vector2 = Vector2(label_width, _name_label.get_minimum_size().y)
	_name_label.size = label_size
	_name_label.position = (size * 0.5 + label_offset - label_size * 0.5).round()
	_refresh_name_color()
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

func _refresh_name_color() -> void:
	var col: Color = name_color
	if _state == State.LOCKED:
		col = name_locked_color
	elif has_focus() or is_hovered():
		col = name_focus_color
	_name_label.add_theme_color_override("font_color", col)

func _build_blink_frames() -> void:
	_blink_frames.clear()
	if icon_available_sheet == null:
		return
	var h: float = icon_available_sheet.get_height()
	for i in range(int(icon_available_sheet.get_width() / h)):
		var frame := AtlasTexture.new()
		frame.atlas = icon_available_sheet
		frame.region = Rect2(i * h, 0.0, h, h)
		_blink_frames.append(frame)

func _process(delta: float) -> void:
	if _state != State.AVAILABLE or _blink_frames.size() < 2:
		return
	_blink_timer += delta
	if _blink_timer >= blink_interval:
		_blink_timer -= blink_interval
		_blink_index = (_blink_index + 1) % _blink_frames.size()
		icon = _blink_frames[_blink_index]

func _on_pressed() -> void:
	activated.emit(node_data)
