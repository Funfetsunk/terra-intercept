extends Node

## Playtest helpers, only active in builds exported with the "tester" feature
## tag (the "Windows Tester" export preset), or in the editor when
## `force_in_editor` is on. Normal builds are unaffected.
##  - Every mission on the map can be launched (as a replay, so it never moves
##    the save's progress).
##  - An FPS counter in the corner.
##  - The `tester_skip_boss` action (F2 / pad Back) restarts the current
##    mission at its boss section.

@export var force_in_editor: bool = false
@export var fps_refresh_interval: float = 0.5
@export var boss_section: String = "boss"

var enabled: bool = false

var _fps_timer: float = 0.0

@onready var _fps_label: Label = $Overlay/FpsLabel

func _ready() -> void:
	enabled = OS.has_feature("tester") or (OS.has_feature("editor") and force_in_editor)
	$Overlay.visible = enabled
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if not enabled:
		return
	_fps_timer -= delta
	if _fps_timer <= 0.0:
		_fps_timer = fps_refresh_interval
		_fps_label.text = "FPS %d" % Engine.get_frames_per_second()

func _unhandled_input(event: InputEvent) -> void:
	if not enabled or not event.is_action_pressed("tester_skip_boss"):
		return
	var scene: Node = get_tree().current_scene
	if scene == null or scene.get("mission_id") == null:
		return
	get_viewport().set_input_as_handled()
	var game_state: Node = get_node("/root/GameState")
	game_state.restart_section = boss_section
	get_tree().paused = false
	get_tree().reload_current_scene()
