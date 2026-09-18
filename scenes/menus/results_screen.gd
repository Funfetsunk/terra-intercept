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
	var game_state: Node = get_node("/root/GameState")
	var map_node: MapNodeData = game_state.find_map_node(game_state.current_mission_name)
	if map_node != null and map_node.mission_data != null and not map_node.mission_data.post_briefing_lines.is_empty():
		game_state.pending_briefing_lines = map_node.mission_data.post_briefing_lines
		game_state.pending_briefing_next_scene = "res://scenes/menus/hangar.tscn"
		get_tree().change_scene_to_file("res://scenes/menus/briefing_screen.tscn")
		return
	get_tree().change_scene_to_file("res://scenes/menus/hangar.tscn")
