extends EnemyBase

## Flanker: enters from the left, right or from behind (below) and crosses the
## playfield on a gentle curve, firing aimed shots. The side it enters from is
## taken from its spawn position: relative x < 0 enters from the left, x > 1
## from the right, and y > 1 from below. Before it appears, a warning arrow
## blinks at that edge of the playfield for `telegraph_duration`.

@export var telegraph_duration: float = 0.6
@export var warning_blink_interval: float = 0.1
## Sideways sway while crossing, in pixels and cycles per second.
@export var curve_amplitude_px: float = 24.0
@export var curve_frequency_hz: float = 0.35
## Distance beyond the playfield edge at which a finished flanker is removed.
@export var exit_margin: float = 30.0
## How far inside the playfield edge the warning arrow sits.
@export var warning_inset: float = 10.0

var _direction: Vector2 = Vector2.RIGHT
var _telegraph_timer: float = 0.0
var _elapsed: float = 0.0
var _start: Vector2 = Vector2.ZERO
var _entered: bool = false

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _warning: Sprite2D = $Warning

func _ready() -> void:
	super._ready()
	var rect: Rect2 = get_node("/root/Playfield").rect
	if global_position.x < rect.position.x:
		_direction = Vector2.RIGHT
	elif global_position.x > rect.end.x:
		_direction = Vector2.LEFT
	else:
		_direction = Vector2.UP
	# The art points right; turn it by whole quarter turns so pixels stay exact.
	_sprite.rotation = _direction.angle()
	_start = global_position
	_telegraph_timer = telegraph_duration
	_sprite.visible = false
	_place_warning(rect)

func _place_warning(rect: Rect2) -> void:
	var p: Vector2 = global_position
	if _direction == Vector2.RIGHT:
		p.x = rect.position.x + warning_inset
	elif _direction == Vector2.LEFT:
		p.x = rect.end.x - warning_inset
	else:
		p.y = rect.end.y - warning_inset
	_warning.global_position = p.round()
	_warning.rotation = _direction.angle()
	_warning.visible = true

func _process_movement(delta: float) -> void:
	if _telegraph_timer > 0.0:
		_telegraph_timer -= delta
		_warning.visible = int(_telegraph_timer / warning_blink_interval) % 2 == 0
		if _telegraph_timer <= 0.0:
			_warning.visible = false
			_sprite.visible = true
		return
	_elapsed += delta
	var side: Vector2 = Vector2(-_direction.y, _direction.x)
	var along: Vector2 = _direction * data.move_speed * _elapsed
	var sway: Vector2 = side * sin(_elapsed * TAU * curve_frequency_hz) * curve_amplitude_px
	global_position = _start + along + sway
	var rect: Rect2 = get_node("/root/Playfield").rect
	var inside: bool = rect.has_point(global_position)
	if inside:
		_entered = true
	elif _entered and not rect.grow(exit_margin).has_point(global_position):
		queue_free()

func _process_pattern(delta: float) -> void:
	# Only fire once actually on screen, never while telegraphing off-screen.
	if not _entered:
		return
	super._process_pattern(delta)
