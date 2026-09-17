extends Control

@onready var _continue_button: Button = $ContinueButton
@onready var _results_label: Label = $ResultsLabel

func _ready() -> void:
	var r: Dictionary = get_node("/root/GameState").last_mission_results
	_results_label.text = "Score: %d\nCompletion: +%d\nLives: +%d\nHull: +%d\nShield: +%d\nTech: %d\n\nTotal: %d\nGrade: %s" % [
		r.get("base_score", 0), r.get("completion_bonus", 0), r.get("lives_bonus", 0),
		r.get("hull_bonus", 0), r.get("shield_bonus", 0), r.get("tech", 0),
		r.get("total_score", 0), r.get("grade", "-"),
	]
	_continue_button.pressed.connect(_on_continue)
	_continue_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("p1_ordnance") and _continue_button.has_focus():
		get_viewport().set_input_as_handled()
		_on_continue()

func _on_continue() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/title_screen.tscn")
