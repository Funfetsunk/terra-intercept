extends Node

## Changes the ground art between mission sections (the homeworld's scorched
## surface, then the foundry). Each switch is (time, tile A, tile B, seam set
## piece) at matching indices in the arrays below. When the mission clock passes
## a switch's time the FarLayer queues the new tiles and the seam piece hides the
## join. On a restart from a later section, the latest switch already passed is
## applied straight away.

@export var mission: MissionData
@export var switch_times: PackedFloat32Array = PackedFloat32Array()
@export var tiles_a: Array[Texture2D] = []
@export var tiles_b: Array[Texture2D] = []
@export var seam_scenes: Array[PackedScene] = []

var _elapsed: float = 0.0
var _next: int = 0

func _ready() -> void:
	var game_state: Node = get_node("/root/GameState")
	_elapsed = mission.get_section_start_time(game_state.restart_section)
	var layer: BackgroundLayer = _far_layer()
	while _next < switch_times.size() and switch_times[_next] <= _elapsed:
		if layer != null:
			layer.get_node("PanelA").texture = tiles_a[_next]
			layer.get_node("PanelB").texture = tiles_b[_next]
		_next += 1

func _physics_process(delta: float) -> void:
	_elapsed += delta
	if _next < switch_times.size() and _elapsed >= switch_times[_next]:
		var layer: BackgroundLayer = _far_layer()
		if layer != null:
			var seam: PackedScene = seam_scenes[_next] if _next < seam_scenes.size() else null
			layer.queue_textures(tiles_a[_next], tiles_b[_next], seam)
		_next += 1

func _far_layer() -> BackgroundLayer:
	var bg: Node = get_tree().get_first_node_in_group("scrolling_background")
	if bg == null:
		return null
	return bg.get_node_or_null("FarLayer") as BackgroundLayer
