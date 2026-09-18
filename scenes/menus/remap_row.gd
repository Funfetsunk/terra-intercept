extends Button
class_name RemapRow

signal rebind_requested(action: String)

var action: String = ""

@onready var _settings: Node = get_node("/root/Settings")

func setup(bound_action: String, display_name: String) -> void:
	action = bound_action
	refresh(display_name)
	pressed.connect(_on_pressed)

func refresh(display_name: String) -> void:
	text = "%s: %s" % [display_name, _settings.get_action_binding_text(action)]

func set_listening() -> void:
	text = "Press a key or pad button..."

func _on_pressed() -> void:
	rebind_requested.emit(action)
