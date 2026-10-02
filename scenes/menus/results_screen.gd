extends Control

@onready var _continue_button: Button = $ContinueButton
@onready var _names_label: Label = $Frame/NamesLabel
@onready var _values_label: Label = $Frame/ValuesLabel
@onready var _grade_label: Label = $Frame/GradeLabel

func _ready() -> void:
	var r: Dictionary = get_node("/root/GameState").last_mission_results
	_names_label.text = "Score\nCompletion\nLives\nHull\nShield\nTech\n\nTotal"
	_values_label.text = "%d\n+%d\n+%d\n+%d\n+%d\n%d\n\n%d" % [
		r.get("base_score", 0), r.get("completion_bonus", 0), r.get("lives_bonus", 0),
		r.get("hull_bonus", 0), r.get("shield_bonus", 0), r.get("tech", 0),
		r.get("total_score", 0),
	]
	_grade_label.text = str(r.get("grade", "-"))
	_continue_button.pressed.connect(_on_continue)
	_continue_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("p1_ordnance") and _continue_button.has_focus():
		get_viewport().set_input_as_handled()
		_on_continue()

func _on_continue() -> void:
	var game_state: Node = get_node("/root/GameState")
	var map_node: MapNodeData = game_state.find_map_node(game_state.current_mission_name)
	var next_scene: String = "res://scenes/menus/hangar.tscn"
	if map_node != null and map_node.mission_data != null and not map_node.mission_data.after_mission_scene.is_empty():
		next_scene = map_node.mission_data.after_mission_scene
	if map_node != null and map_node.mission_data != null and not map_node.mission_data.post_briefing_lines.is_empty():
		game_state.pending_briefing_lines = map_node.mission_data.post_briefing_lines
		game_state.pending_briefing_next_scene = next_scene
		get_tree().change_scene_to_file("res://scenes/menus/briefing_screen.tscn")
		return
	get_tree().change_scene_to_file(next_scene)
