extends "res://scenes/bosses/stage_boss.gd"

## Harbour leviathan (Sydney boss): a submarine that surfaces at one of
## `surface_spots` (relative 0-1 in the playfield), fires its BossData patterns
## for `surfaced_time`, then dives. Submerged it shows only a dark shadow, can't
## be hit and doesn't fire. It glides to the next spot over `travel_time`,
## bubbles there for `surface_warning` (the telegraph), then surfaces.

enum Dive { SURFACED, SUBMERGED, SURFACING }

@export var surface_spots: PackedVector2Array = PackedVector2Array([Vector2(0.5, 0.22), Vector2(0.28, 0.3), Vector2(0.72, 0.26), Vector2(0.5, 0.34)])
@export var surfaced_time: float = 6.0
@export var phase2_surfaced_time: float = 4.5
@export var travel_time: float = 2.2
@export var surface_warning: float = 0.9
@export var bubble_color: Color = Color("c7dcd0")

var _dive: Dive = Dive.SURFACED
var _timer: float = 0.0
var _spot: int = 0
var _from: Vector2 = Vector2.ZERO
var _to: Vector2 = Vector2.ZERO
var _entered: bool = false

@onready var _body: AnimatedSprite2D = $Sprite
@onready var _shadow: Sprite2D = $Shadow

func _ready() -> void:
	super._ready()
	_shadow.visible = false
	var rect: Rect2 = get_node("/root/Playfield").rect
	hover_y = (rect.position + surface_spots[0] * rect.size).y

func _process_movement(delta: float) -> void:
	if not _entered:
		super._process_movement(delta)
		_entered = global_position.y >= hover_y
		return
	_timer += delta
	match _dive:
		Dive.SURFACED:
			if _timer >= (phase2_surfaced_time if _phase2_active else surfaced_time):
				_go_under()
		Dive.SUBMERGED:
			var t: float = smoothstep(0.0, 1.0, minf(1.0, _timer / travel_time))
			global_position = _from.lerp(_to, t).round()
			if _timer >= travel_time:
				_dive = Dive.SURFACING
				_timer = 0.0
		Dive.SURFACING:
			if _timer >= surface_warning:
				_surface()
	queue_redraw()

func _go_under() -> void:
	_dive = Dive.SUBMERGED
	_timer = 0.0
	_body.visible = false
	_shadow.visible = true
	var rect: Rect2 = get_node("/root/Playfield").rect
	_spot = (_spot + 1) % surface_spots.size()
	_from = global_position
	_to = rect.position + surface_spots[_spot] * rect.size

func _surface() -> void:
	_dive = Dive.SURFACED
	_timer = 0.0
	_body.visible = true
	_shadow.visible = false

func _process_pattern(delta: float) -> void:
	if _dive == Dive.SURFACED:
		super._process_pattern(delta)

func take_damage(amount: float) -> bool:
	if _dive != Dive.SURFACED:
		return false
	return super.take_damage(amount)

func get_hitbox_radius() -> float:
	return data.hitbox_radius if _dive == Dive.SURFACED else -1000.0

func _draw() -> void:
	if _dive != Dive.SURFACING:
		return
	# Bubbles boiling up where it's about to surface.
	for i in range(14):
		var h: int = absi((i * 73856093) ^ 19349663)
		var r: float = float(h % 50)
		var a: float = float(h % 628) / 100.0 + _timer * 3.0
		var p: Vector2 = Vector2(cos(a) * r, sin(a) * r * 0.5).round()
		if int(_timer / 0.1 + float(i)) % 3 != 0:
			draw_rect(Rect2(p, Vector2(2, 2)), bubble_color)
