extends Control
class_name MapRoutes

## Draws the route lines between map nodes. After the columns listed in
## lane_choice_after_columns the route can switch lanes; elsewhere a lane
## continues straight on.

@export var lane_choice_after_columns: Array[int] = [1, 3, 5]
@export var line_width: float = 2.0
## Route the player has flown or can fly next.
@export var open_color: Color = Color("f9c22b")
@export var locked_color: Color = Color("3e3546")
## Locked routes are drawn as dashes: this many pixels on, then off.
@export var dash_length: float = 4.0

var _segments: Array[Dictionary] = []

func show_routes(nodes: Array, centers: Dictionary, states: Dictionary) -> void:
	_segments.clear()
	for a: MapNodeData in nodes:
		for b: MapNodeData in nodes:
			if b.column != a.column + 1:
				continue
			var connected: bool = lane_choice_after_columns.has(a.column) or a.lane.is_empty() or b.lane.is_empty() or a.lane == b.lane
			if not connected:
				continue
			var from_done: bool = states[a.id] == MapNodeButton.State.COMPLETED
			var to_open: bool = states[b.id] != MapNodeButton.State.LOCKED
			_segments.append({"from": centers[a.id], "to": centers[b.id], "open": from_done and to_open})
	queue_redraw()

func _draw() -> void:
	# Locked routes first so open routes sit on top where they share a node.
	for seg: Dictionary in _segments:
		if not seg["open"]:
			_draw_dashed(seg["from"], seg["to"])
	for seg: Dictionary in _segments:
		if seg["open"]:
			draw_line(seg["from"], seg["to"], open_color, line_width)

func _draw_dashed(from: Vector2, to: Vector2) -> void:
	var length: float = from.distance_to(to)
	var dir: Vector2 = (to - from) / length
	var t: float = 0.0
	while t < length:
		var end: float = minf(t + dash_length, length)
		draw_line((from + dir * t).round(), (from + dir * end).round(), locked_color, line_width)
		t += dash_length * 2.0
