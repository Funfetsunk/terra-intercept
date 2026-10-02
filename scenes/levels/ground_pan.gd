extends Node

## Pans the ground sideways as it scrolls (the Great Wall twist): the pan comes
## from the mission's `pan_keys` (distance scrolled, pan px), smoothstepped, and
## is pushed to every BackgroundLayer with a pan_margin. Ground-locked enemies
## (Crawlers) read get_pan() through the "ground_pan" group.

@export var mission: MissionData

var _scrolled: float = 0.0
var _pan: float = 0.0
var _ground: Node = null

func _ready() -> void:
	add_to_group("ground_pan")
	_ground = get_tree().get_first_node_in_group("scrolling_background")
	var game_state: Node = get_node("/root/GameState")
	_scrolled = mission.get_section_start_time(game_state.restart_section) * mission.background_scroll_speed
	_apply()

func _physics_process(delta: float) -> void:
	if _ground != null:
		_scrolled += _ground.get_ground_speed() * delta
	_apply()

func get_pan() -> float:
	return _pan

func _apply() -> void:
	_pan = _pan_at(_scrolled)
	if _ground != null:
		for child: Node in _ground.get_children():
			if child is BackgroundLayer:
				(child as BackgroundLayer).set_pan(_pan)

func _pan_at(distance: float) -> float:
	var keys: PackedVector2Array = mission.pan_keys
	if keys.is_empty():
		return 0.0
	if distance <= keys[0].x:
		return keys[0].y
	for i in range(1, keys.size()):
		if distance <= keys[i].x:
			var a: Vector2 = keys[i - 1]
			var b: Vector2 = keys[i]
			return lerpf(a.y, b.y, smoothstep(a.x, b.x, distance))
	return keys[keys.size() - 1].y
