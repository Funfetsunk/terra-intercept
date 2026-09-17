extends Control

@onready var _start_button: Button = $StartButton

func _ready() -> void:
	_start_button.pressed.connect(_on_start)
	_start_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("p1_ordnance"):
		var viewport: Viewport = get_viewport()
		var focused: Control = viewport.gui_get_focus_owner()
		if focused is Button:
			viewport.set_input_as_handled()
			(focused as Button).pressed.emit()

func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/ship_select.tscn")
