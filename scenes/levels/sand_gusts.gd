extends Node2D

## Sandstorm gusts (the Cairo twist). Each gust in the mission's `gusts` is
## (start time in s, duration in s, push in px/s; negative pushes left). For
## `telegraph_duration` before a gust, warning chevrons blink at the upwind edge
## and the first streaks of sand blow in. During the gust the player is pushed
## sideways (eased in and out) and sand streaks race across the playfield.
## Place this node after PlayerShip so the push applies after the player moves.

@export var mission: MissionData
@export var telegraph_duration: float = 1.2
@export var warning_blink_interval: float = 0.12
## Time to ease the push in and out at each end of a gust.
@export var ease_duration: float = 0.35
@export var streak_count: int = 150
@export var streak_speed_multiplier: float = 3.0
@export var streak_min_length: int = 6
@export var streak_max_length: int = 16
@export var streak_colors: PackedColorArray = PackedColorArray([Color("c7dcd0"), Color("ab947a"), Color("4c3e24"), Color("c7dcd0")])
## Chevron drawn at the upwind edge during the telegraph (it points right; it's mirrored for wind blowing left).
@export var warning_texture: Texture2D = preload("res://art/sprites/enemies/flanker_warning.png")
## Heights (0-1 down the playfield) of the warning chevrons.
@export var warning_rows: PackedFloat32Array = PackedFloat32Array([0.3, 0.5, 0.7])
@export var warning_inset: float = 16.0

var _elapsed: float = 0.0
var _rect: Rect2 = Rect2()
## Strength of the current gust's visuals, 0-1 (telegraph builds it up).
var _intensity: float = 0.0
var _direction: float = 1.0
var _warning_on: bool = false

func _ready() -> void:
	_rect = get_node("/root/Playfield").rect
	var game_state: Node = get_node("/root/GameState")
	_elapsed = mission.get_section_start_time(game_state.restart_section)

func _physics_process(delta: float) -> void:
	_elapsed += delta
	var push: float = 0.0
	var telegraph: bool = false
	_intensity = 0.0
	for gust: Vector3 in mission.gusts:
		var start: float = gust.x
		var end: float = gust.x + gust.y
		if _elapsed >= start - telegraph_duration and _elapsed < start:
			telegraph = true
			_direction = signf(gust.z)
			_intensity = maxf(_intensity, 0.25 * (1.0 - (start - _elapsed) / telegraph_duration))
		elif _elapsed >= start and _elapsed < end:
			var ramp: float = minf(1.0, minf((_elapsed - start) / ease_duration, (end - _elapsed) / ease_duration))
			push = gust.z * ramp
			_direction = signf(gust.z)
			_intensity = maxf(_intensity, ramp)
	# Chevrons point the way the wind will blow, from the upwind edge.
	_warning_on = telegraph and int(_elapsed / warning_blink_interval) % 2 == 0
	if push != 0.0:
		var player: Node2D = get_node("/root/BulletManager").get_registered_player()
		if player != null and player.visible:
			player.global_position.x = clampf(player.global_position.x + push * delta, _rect.position.x, _rect.end.x)
	queue_redraw()

func _draw() -> void:
	var origin: Vector2 = to_local(_rect.position)
	if _warning_on and warning_texture != null:
		var size: Vector2 = warning_texture.get_size()
		for row: float in warning_rows:
			var y: float = roundf(origin.y + _rect.size.y * row - size.y * 0.5)
			if _direction > 0.0:
				draw_texture_rect(warning_texture, Rect2(origin.x + warning_inset - size.x * 0.5, y, size.x, size.y), false)
			else:
				# Negative width mirrors the chevron (pixel-exact) to point left.
				draw_texture_rect(warning_texture, Rect2(origin.x + _rect.size.x - warning_inset + size.x * 0.5, y, -size.x, size.y), false)
	if _intensity <= 0.0:
		return
	var count: int = int(streak_count * _intensity)
	var w: float = _rect.size.x
	for i in range(count):
		# Deterministic pseudo-random lanes and lengths per streak.
		var h: int = absi((i * 73856093) ^ 19349663)
		var lane_y: float = float(h % int(_rect.size.y))
		var length: int = streak_min_length + (h >> 3) % maxi(1, streak_max_length - streak_min_length)
		var speed: float = (120.0 + float((h >> 4) % 80)) * streak_speed_multiplier * 0.5
		var x: float = fposmod(float(h % 997) + _elapsed * speed * _direction, w + 20.0) - 10.0
		var color: Color = streak_colors[(h >> 5) % streak_colors.size()]
		draw_rect(Rect2(roundf(origin.x + x), roundf(origin.y + lane_y), length, 1), color)
