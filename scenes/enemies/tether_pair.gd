extends Node2D

## Tether pair: two emitter drones (`A` and `B`, TetherNode enemies) joined by a
## beam. Both travel from their start to their end positions (relative 0-1 in
## the playfield; values outside 0-1 are off screen) over `travel_time`, so the
## beam sweeps the screen. The beam flickers as a thin dashed line for
## `telegraph_time`, then goes solid and hurts on contact. Killing either drone
## drops the beam. The pair frees itself when the sweep ends.

@export var a_start: Vector2 = Vector2(0.1, -0.1)
@export var b_start: Vector2 = Vector2(0.9, -0.1)
@export var a_end: Vector2 = Vector2(0.1, 1.1)
@export var b_end: Vector2 = Vector2(0.9, 1.1)
@export var travel_time: float = 9.0
@export var telegraph_time: float = 0.6
@export var beam_damage: float = 1.0
@export var contact_cooldown: float = 0.6
@export var beam_half_width: float = 2.0
@export var beam_core_color: Color = Color("cddf6c")
@export var beam_edge_color: Color = Color("91db69")
@export var telegraph_color: Color = Color("239063")

var _t: float = 0.0
var _contact_timer: float = 0.0
var _rect: Rect2 = Rect2()

@onready var _a: Node2D = $A
@onready var _b: Node2D = $B

func _ready() -> void:
	_rect = get_node("/root/Playfield").rect
	_place()

func _physics_process(delta: float) -> void:
	_t += delta
	_contact_timer = maxf(0.0, _contact_timer - delta)
	_place()
	if _beam_live():
		_check_player()
	if _t >= travel_time:
		for n: Node2D in [_a, _b]:
			if is_instance_valid(n):
				n.queue_free()
		queue_free()
	queue_redraw()

func _place() -> void:
	var f: float = clampf(_t / travel_time, 0.0, 1.0)
	if is_instance_valid(_a):
		_a.global_position = (_rect.position + a_start.lerp(a_end, f) * _rect.size).round()
	if is_instance_valid(_b):
		_b.global_position = (_rect.position + b_start.lerp(b_end, f) * _rect.size).round()

func _both_alive() -> bool:
	return is_instance_valid(_a) and is_instance_valid(_b) and not _a.is_queued_for_deletion() and not _b.is_queued_for_deletion()

func _beam_live() -> bool:
	return _both_alive() and _t >= telegraph_time

func _check_player() -> void:
	if _contact_timer > 0.0:
		return
	var bullets: Node = get_node("/root/BulletManager")
	var player: Node2D = bullets.get_registered_player()
	if player == null or not player.visible:
		return
	var p: Vector2 = player.global_position
	var closest: Vector2 = Geometry2D.get_closest_point_to_segment(p, _a.global_position, _b.global_position)
	if p.distance_to(closest) <= beam_half_width + player.get_hitbox_radius():
		player.take_hit(beam_damage)
		_contact_timer = contact_cooldown

func _draw() -> void:
	if not _both_alive():
		return
	var a: Vector2 = to_local(_a.global_position)
	var b: Vector2 = to_local(_b.global_position)
	if _t < telegraph_time:
		# Thin dashed flicker: the warning before the beam goes solid.
		if int(_t / 0.06) % 2 == 0:
			var length: float = a.distance_to(b)
			var dir: Vector2 = (b - a) / maxf(length, 0.001)
			var d: float = 0.0
			while d < length:
				draw_line((a + dir * d).round(), (a + dir * minf(d + 4.0, length)).round(), telegraph_color, 1.0)
				d += 8.0
		return
	draw_line(a, b, beam_edge_color, beam_half_width * 2.0 + 1.0)
	draw_line(a, b, beam_core_color, 1.0)
