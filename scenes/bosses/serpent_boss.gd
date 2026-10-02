extends Node2D

## Mechanical serpent-dragon (Great Wall boss). The `Head` (SerpentHead) dives
## in from the top, then weaves a figure-of-eight over the top of the playfield.
## The body segments (SerpentSegment children, `slot` 1..n) follow the head's
## trail at `segment_spacing` px apart. Segments can be shot off one by one;
## the head is the core, and killing it destroys whatever is left and
## completes the mission. The ground scroll locks once the head is in place.

@export var path_center_relative: Vector2 = Vector2(0.5, 0.3)
@export var path_size: Vector2 = Vector2(130.0, 55.0)
## Path speed in radians per second of the figure-of-eight's parameter.
@export var path_speed: float = 0.7
@export var phase2_path_speed: float = 1.05
@export var entry_speed: float = 70.0
@export var segment_spacing: float = 18.0
@export var music: AudioStream
@export var music_phase2: AudioStream
@export var entry_scroll_speed: float = 20.0
## How many trail points are kept (enough for the longest body).
@export var max_trail_points: int = 900

var _trail: PackedVector2Array = PackedVector2Array()
var _entering: bool = true
var _t: float = 0.0
var _phase2: bool = false
var _center: Vector2 = Vector2.ZERO
var _audio: Node = null

@onready var _head: Node2D = $Head

func _ready() -> void:
	var rect: Rect2 = get_node("/root/Playfield").rect
	_center = rect.position + path_center_relative * rect.size
	_head.global_position = Vector2(_path_point(0.0).x, rect.position.y - 40.0)
	_audio = get_node("/root/AudioManager")
	if music != null:
		_audio.play_music(music)
	get_tree().call_group("scrolling_background", "set_scroll_speed", entry_scroll_speed)
	_trail.append(_head.global_position)
	_place_segments()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_head):
		return
	if _entering:
		var target: Vector2 = _path_point(0.0)
		_head.global_position = _head.global_position.move_toward(target, entry_speed * delta)
		if _head.global_position.distance_to(target) < 0.5:
			_entering = false
			get_tree().call_group("scrolling_background", "set_scroll_speed", 0.0)
	else:
		_t += (phase2_path_speed if _phase2 else path_speed) * delta
		_head.global_position = _path_point(_t)
	_trail.append(_head.global_position)
	if _trail.size() > max_trail_points:
		_trail = _trail.slice(_trail.size() - max_trail_points)
	_place_segments()

## Figure-of-eight around the path centre.
func _path_point(t: float) -> Vector2:
	return _center + Vector2(sin(t) * path_size.x, sin(t * 2.0) * path_size.y * 0.5)

func _place_segments() -> void:
	for child: Node in get_children():
		if child.is_in_group("serpent_segment"):
			var seg: Node2D = child as Node2D
			seg.global_position = _point_back(segment_spacing * float(seg.get_meta("slot", 1))).round()

## Point `dist` px back along the head's trail (the oldest point if it's shorter).
func _point_back(dist: float) -> Vector2:
	var remaining: float = dist
	var i: int = _trail.size() - 1
	while i > 0:
		var step: float = _trail[i].distance_to(_trail[i - 1])
		if step >= remaining:
			return _trail[i].lerp(_trail[i - 1], remaining / maxf(step, 0.0001))
		remaining -= step
		i -= 1
	return _trail[0] - Vector2(0.0, remaining)

func enter_phase2() -> void:
	_phase2 = true
	if music_phase2 != null:
		_audio.play_music(music_phase2)

## Called by the head when it dies: blow up the rest of the body.
func destroy_body() -> void:
	for child: Node in get_children():
		if child.is_in_group("serpent_segment") and child.has_method("explode"):
			child.explode()
