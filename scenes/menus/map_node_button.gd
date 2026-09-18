extends Button
class_name MapNodeButton

signal activated(node_data: Resource)

var node_data: Resource

func setup(data: Resource, label_text: String, is_enabled: bool) -> void:
	node_data = data
	text = label_text
	disabled = not is_enabled
	focus_mode = Control.FOCUS_ALL if is_enabled else Control.FOCUS_NONE
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

func _on_pressed() -> void:
	activated.emit(node_data)
