extends Node2D

## Harvester convoy (Siberia boss): an engine pulling a line of tanker cars
## round an oval track in the top of the playfield. The cars and engine are
## separate enemies (`ConvoyCar` / `ConvoyEngine` children). The engine is
## shielded until every car is destroyed, then it speeds up and switches to its
## phase-2 patterns; destroying it completes the mission.
##
## Track: two straights joined by half-circles, centred on `track_center`
## (relative 0-1 in the playfield). The convoy drives in from the left on the
## top straight. Parts are placed by distance travelled along the track, so the
## cars follow the engine without bunching up.

@export var track_center_relative: Vector2 = Vector2(0.5, 0.24)
@export var track_half_length: float = 110.0
@export var track_radius: float = 34.0
@export var speed: float = 55.0
@export var phase2_speed: float = 80.0
## Gap along the track between the engine and each following car.
@export var car_spacing: float = 38.0
## How far before the track's top-left corner the engine starts (off screen).
@export var lead_in: float = 200.0
@export var music: AudioStream
@export var music_phase2: AudioStream
## Ground scroll speed while the convoy drives in; it stops once the engine reaches the track.
@export var entry_scroll_speed: float = 20.0

var _distance: float = 0.0
var _phase2: bool = false
var _center: Vector2 = Vector2.ZERO
var _audio: Node = null

@onready var _engine: Node2D = $Engine

func _ready() -> void:
	var rect: Rect2 = get_node("/root/Playfield").rect
	_center = rect.position + track_center_relative * rect.size
	_distance = -lead_in
	_audio = get_node("/root/AudioManager")
	if music != null:
		_audio.play_music(music)
	get_tree().call_group("scrolling_background", "set_scroll_speed", entry_scroll_speed)
	_place_parts()

func _physics_process(delta: float) -> void:
	_distance += (phase2_speed if _phase2 else speed) * delta
	if _distance >= 0.0:
		get_tree().call_group("scrolling_background", "set_scroll_speed", 0.0)
	_place_parts()
	if not _phase2 and is_instance_valid(_engine) and get_cars().is_empty():
		_enter_phase2()

func get_cars() -> Array[Node2D]:
	var cars: Array[Node2D] = []
	for child: Node in get_children():
		if child.is_in_group("convoy_car"):
			cars.append(child as Node2D)
	return cars

func is_engine_shielded() -> bool:
	return not get_cars().is_empty()

func _enter_phase2() -> void:
	_phase2 = true
	if music_phase2 != null:
		_audio.play_music(music_phase2)
	if _engine.has_method("enter_phase2"):
		_engine.enter_phase2()

func _place_parts() -> void:
	if is_instance_valid(_engine):
		_place(_engine, _distance)
	var index: int = 1
	for child: Node in get_children():
		if child.is_in_group("convoy_car"):
			_place(child as Node2D, _distance - car_spacing * float(child.get_meta("slot", index)))
		index += 1

func _place(part: Node2D, d: float) -> void:
	var here: Vector2 = _track_point(d)
	var ahead: Vector2 = _track_point(d + 1.0)
	part.global_position = here.round()
	var sprite: AnimatedSprite2D = part.get_node_or_null("Sprite") as AnimatedSprite2D
	if sprite != null and absf(ahead.x - here.x) > 0.01:
		# Art faces right; mirror (pixel-exact) when travelling left.
		sprite.flip_h = ahead.x < here.x

## Point on the track `d` px from the top-left corner, going clockwise.
## Negative distances are the lead-in straight off to the left.
func _track_point(d: float) -> Vector2:
	var straight: float = track_half_length * 2.0
	var arc: float = PI * track_radius
	var top_left: Vector2 = _center + Vector2(-track_half_length, -track_radius)
	if d < 0.0:
		return top_left + Vector2(d, 0.0)
	var loop: float = straight * 2.0 + arc * 2.0
	var s: float = fposmod(d, loop)
	if s < straight:
		return top_left + Vector2(s, 0.0)
	s -= straight
	if s < arc:
		var a: float = -PI * 0.5 + s / track_radius
		return _center + Vector2(track_half_length, 0.0) + Vector2(cos(a), sin(a)) * track_radius
	s -= arc
	if s < straight:
		return _center + Vector2(track_half_length - s, track_radius)
	s -= straight
	var b: float = PI * 0.5 + s / track_radius
	return _center + Vector2(-track_half_length, 0.0) + Vector2(cos(b), sin(b)) * track_radius
