extends Control

const MAP_NODE_BUTTON_SCENE: PackedScene = preload("res://scenes/menus/map_node_button.tscn")

const COLUMN_X: Dictionary = {1: 40, 2: 120, 3: 200, 4: 280, 5: 360, 6: 440, 7: 540}
const NORTH_Y: float = 90.0
const SOUTH_Y: float = 230.0
const CENTER_Y: float = 160.0

@onready var _game_state: Node = get_node("/root/GameState")
@onready var _tech_label: Label = $TechLabel
@onready var _node_container: Control = $NodeContainer
@onready var _lane_choice_overlay: Control = $LaneChoiceOverlay
@onready var _north_button: Button = $LaneChoiceOverlay/ChoiceButtons/NorthButton
@onready var _south_button: Button = $LaneChoiceOverlay/ChoiceButtons/SouthButton
@onready var _coming_soon_overlay: Control = $ComingSoonOverlay
@onready var _ok_button: Button = $ComingSoonOverlay/OkButton

var _frontier_button: MapNodeButton = null

func _ready() -> void:
	_tech_label.text = "Tech: %d" % _game_state.banked_tech
	_north_button.pressed.connect(_on_north_chosen)
	_south_button.pressed.connect(_on_south_chosen)
	_ok_button.pressed.connect(_on_coming_soon_dismissed)
	_build_nodes()
	if _game_state.pending_lane_choice:
		_lane_choice_overlay.visible = true
		_north_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("p1_ordnance"):
		var viewport: Viewport = get_viewport()
		var focused: Control = viewport.gui_get_focus_owner()
		if focused is Button:
			viewport.set_input_as_handled()
			(focused as Button).pressed.emit()

func _build_nodes() -> void:
	for child: Node in _node_container.get_children():
		child.queue_free()
	_frontier_button = null
	for map_node: MapNodeData in _game_state.all_map_nodes:
		var is_completed: bool = _game_state.completed_missions.has(map_node.id)
		var is_frontier: bool = map_node.column == _game_state.current_column and (map_node.lane.is_empty() or map_node.lane == _game_state.current_lane)
		var is_enabled: bool = is_completed or is_frontier
		var state_text: String = "Completed" if is_completed else ("Available" if is_frontier else "Locked")
		var button: MapNodeButton = MAP_NODE_BUTTON_SCENE.instantiate()
		_node_container.add_child(button)
		var y: float = CENTER_Y
		if map_node.lane == "north":
			y = NORTH_Y
		elif map_node.lane == "south":
			y = SOUTH_Y
		button.position = Vector2(COLUMN_X[map_node.column], y)
		button.setup(map_node, "%s\n(%s)" % [map_node.display_name, state_text], is_enabled)
		button.activated.connect(_on_node_activated)
		if is_frontier:
			_frontier_button = button
	if _frontier_button != null and not _game_state.pending_lane_choice:
		_frontier_button.grab_focus()

func _on_node_activated(node_data: Resource) -> void:
	var map_node: MapNodeData = node_data as MapNodeData
	if map_node.mission_scene_path.is_empty():
		_coming_soon_overlay.visible = true
		_ok_button.grab_focus()
		return
	_game_state.is_replay = _game_state.completed_missions.has(map_node.id) and not (map_node.column == _game_state.current_column and (map_node.lane.is_empty() or map_node.lane == _game_state.current_lane))
	_game_state.current_mission_name = map_node.id
	var lines: Array[Resource] = []
	if map_node.column == 4 and not _game_state.midgame_reveal_shown:
		lines.append_array(_game_state.midgame_reveal_lines)
		_game_state.midgame_reveal_shown = true
	if map_node.mission_data != null:
		lines.append_array(map_node.mission_data.pre_briefing_lines)
	if lines.is_empty():
		get_tree().change_scene_to_file(map_node.mission_scene_path)
		return
	_game_state.pending_briefing_lines = lines
	_game_state.pending_briefing_next_scene = map_node.mission_scene_path
	get_tree().change_scene_to_file("res://scenes/menus/briefing_screen.tscn")

func _on_coming_soon_dismissed() -> void:
	_coming_soon_overlay.visible = false
	if _frontier_button != null:
		_frontier_button.grab_focus()

func _on_north_chosen() -> void:
	_game_state.choose_lane("north")
	_lane_choice_overlay.visible = false
	_build_nodes()

func _on_south_chosen() -> void:
	_game_state.choose_lane("south")
	_lane_choice_overlay.visible = false
	_build_nodes()
