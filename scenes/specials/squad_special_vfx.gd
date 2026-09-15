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

func _draw() -> void:
	var alpha: float = clampf(_timer / _duration, 0.0, 1.0)
	var col: Color = Color(1.0, 1.0, 1.0, alpha)
	match _shape:
		Shape.CIRCLE:
			draw_arc(Vector2.ZERO, _radius, 0.0, TAU, 32, col, 2.0)
		Shape.RECT:
			draw_rect(_rect, col, false, 2.0)
		Shape.CONE:
			var half_angle: float = deg_to_rad(_cone_angle_degrees) * 0.5
			var base_angle: float = _cone_direction.angle()
			var points: PackedVector2Array = PackedVector2Array([Vector2.ZERO])
			var segments: int = 12
			for i in range(segments + 1):
				var a: float = base_angle - half_angle + (half_angle * 2.0) * (float(i) / float(segments))
				points.append(Vector2(cos(a), sin(a)) * _cone_range)
			draw_colored_polygon(points, col)
