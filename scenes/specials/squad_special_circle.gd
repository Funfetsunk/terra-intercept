extends Node2D

var _radius: float = 0.0
var _timer: float = 0.0
var _duration: float = 1.0

func play(radius: float, duration: float) -> void:
	_radius = radius
	_duration = max(duration, 0.001)
	_timer = _duration
	visible = true
	queue_redraw()

func _process(delta: float) -> void:
	if _timer > 0.0:
		_timer = max(0.0, _timer - delta)
		queue_redraw()
		if _timer <= 0.0:
			visible = false

func _draw() -> void:
	if _timer <= 0.0:
		return
	var alpha: float = clamp(_timer / _duration, 0.0, 1.0)
	draw_arc(Vector2.ZERO, _radius, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, alpha), 3.0, true)
