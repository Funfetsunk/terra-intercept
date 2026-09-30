extends Button
class_name MapNodeButton

signal activated(node_data: Resource)

enum State { LOCKED, AVAILABLE, COMPLETED }

@export var icon_locked: Texture2D
## Two frames side by side (16x16 each); the button blinks between them.
@export var icon_available_sheet: Texture2D
@export var icon_completed: Texture2D
@export var blink_interval: float = 0.4

var node_data: Resource
var _state: State = State.LOCKED
var _blink_frames: Array[Texture2D] = []
var _blink_timer: float = 0.0
var _blink_index: int = 0

func setup(data: Resource, label_text: String, state: State) -> void:
	node_data = data
	_state = state
	text = label_text
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
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

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
