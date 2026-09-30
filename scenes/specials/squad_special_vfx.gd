extends Node2D

enum Shape { CIRCLE, RECT, CONE }

var _shape: Shape = Shape.CIRCLE
var _timer: float = 0.0
var _duration: float = 1.0
var _radius: float = 0.0
var _rect: Rect2 = Rect2()
var _cone_direction: Vector2 = Vector2.UP
var _cone_angle_degrees: float = 0.0
var _cone_range: float = 0.0

func play_circle(radius: float, duration: float) -> void:
	_shape = Shape.CIRCLE
	_radius = radius
	_start(duration)

func play_rect(rect: Rect2, duration: float) -> void:
	_shape = Shape.RECT
	_rect = rect
	_start(duration)

func play_cone(direction: Vector2, angle_degrees: float, max_range: float, duration: float) -> void:
	_shape = Shape.CONE
	_cone_direction = direction
	_cone_angle_degrees = angle_degrees
	_cone_range = max_range
	_start(duration)

func _start(duration: float) -> void:
	_duration = duration
	_timer = duration
	visible = true
	queue_redraw()

func _process(delta: float) -> void:
	if _timer <= 0.0:
		return
	_timer = max(0.0, _timer - delta)
	queue_redraw()
	if _timer <= 0.0:
		visible = false

## Palette colours for the effect, from the edge inward. Drawn as solid pixel lines
## (no alpha fade) so the effect stays on the game palette.
@export var edge_color: Color = Color("8fd3ff")
@export var band_colors: Array[Color] = [Color("ffffff"), Color("8fd3ff"), Color("4d9be6"), Color("484a77")]
## Spacing in pixels between the moving energy bands.
@export var band_spacing: float = 10.0
## Speed of the moving bands, in pixels per second.
@export var band_speed: float = 60.0
## The last part of the effect blinks before it vanishes (fraction of the duration).
@export var blink_fraction: float = 0.25

func _draw() -> void:
	var progress: float = 1.0 - clampf(_timer / _duration, 0.0, 1.0)
	if progress > 1.0 - blink_fraction and int(_timer * 20.0) % 2 == 0:
		return
	var phase: float = fmod((_duration - _timer) * band_speed, band_spacing)
	match _shape:
		Shape.CIRCLE:
			_draw_circle_effect(phase)
		Shape.RECT:
			_draw_rect_effect(phase)
		Shape.CONE:
			_draw_cone_effect(phase)

func _band_color(i: int) -> Color:
	return band_colors[i % band_colors.size()]

func _draw_circle_effect(phase: float) -> void:
	var r: float = roundf(_radius)
	var i: int = 0
	var ring: float = phase
	while ring < r - 2.0:
		draw_arc(Vector2.ZERO, roundf(ring), 0.0, TAU, 48, _band_color(i), 2.0)
		ring += band_spacing
		i += 1
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 64, edge_color, 2.0)
	draw_arc(Vector2.ZERO, r - 3.0, 0.0, TAU, 64, band_colors[0], 1.0)

func _draw_rect_effect(phase: float) -> void:
	# A solid energy beam: bright core, cooler bands outward, dithered outer band,
	# with bright pulses travelling along its length.
	var rect: Rect2 = Rect2(_rect.position.round(), _rect.size.round())
	var vertical: bool = rect.size.y >= rect.size.x
	var width: int = int(rect.size.x if vertical else rect.size.y)
	var length_start: float = rect.position.y if vertical else rect.position.x
	var length_end: float = rect.end.y if vertical else rect.end.x
	var across_start: float = rect.position.x if vertical else rect.position.y
	var half: float = width * 0.5
	for k in range(width):
		var d: float = absf((k + 0.5) - half) / half
		var col: Color
		if d < 0.15:
			col = band_colors[0]
		elif d < 0.4:
			col = band_colors[1]
		elif d < 0.7:
			col = band_colors[2]
		elif k % 2 == 0:
			col = band_colors[3]
		else:
			continue
		var a: float = across_start + k + 0.5
		if vertical:
			draw_line(Vector2(a, length_start), Vector2(a, length_end), col, 1.0)
		else:
			draw_line(Vector2(length_start, a), Vector2(length_end, a), col, 1.0)
	var pulse_gap: float = band_spacing * 3.0
	var pos: float = length_start + fmod(phase * 3.0, pulse_gap)
	while pos < length_end:
		var p0: float = roundf(pos)
		if vertical:
			draw_line(Vector2(rect.position.x, p0), Vector2(rect.end.x, p0), band_colors[0], 2.0)
		else:
			draw_line(Vector2(p0, rect.position.y), Vector2(p0, rect.end.y), band_colors[0], 2.0)
		pos += pulse_gap
	draw_rect(rect, edge_color, false, 2.0)

func _draw_cone_effect(phase: float) -> void:
	var half_angle: float = deg_to_rad(_cone_angle_degrees) * 0.5
	var base_angle: float = _cone_direction.angle()
	var from_a: float = base_angle - half_angle
	var to_a: float = base_angle + half_angle
	var i: int = 0
	var dist: float = phase + band_spacing
	while dist < _cone_range:
		draw_arc(Vector2.ZERO, roundf(dist), from_a, to_a, 24, _band_color(i), 2.0)
		dist += band_spacing
		i += 1
	draw_line(Vector2.ZERO, Vector2(cos(from_a), sin(from_a)) * _cone_range, edge_color, 2.0)
	draw_line(Vector2.ZERO, Vector2(cos(to_a), sin(to_a)) * _cone_range, edge_color, 2.0)
	draw_arc(Vector2.ZERO, _cone_range, from_a, to_a, 32, edge_color, 2.0)
