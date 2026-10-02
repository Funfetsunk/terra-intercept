extends EnemyBase

## Mine dropped by a mine layer. It drifts down slowly, arms after `arm_time`,
## then pops into a small ring (data.pattern) when its fuse runs out or the
## player comes within `trigger_radius`. It blinks faster as it's about to pop.
## Shooting it first destroys it safely.

@export var arm_time: float = 0.6
@export var fuse_time: float = 3.0
@export var trigger_radius: float = 44.0
## Once triggered, it waits this long (blinking fast) before popping.
@export var pop_delay: float = 0.45
@export var drift_speed: float = 14.0
@export var slow_blink: float = 0.3
@export var fast_blink: float = 0.06

var _age: float = 0.0
var _pop_timer: float = -1.0

@onready var _sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	super._ready()
	_sprite.stop()

func _process_movement(delta: float) -> void:
	_age += delta
	global_position.y += drift_speed * delta
	if global_position.y > despawn_y:
		queue_free()
		return
	if _age < arm_time:
		_sprite.frame = 0
		return
	if _pop_timer < 0.0:
		var near: bool = global_position.distance_to(_bullets.get_player_position()) <= trigger_radius
		if near or _age >= arm_time + fuse_time:
			_pop_timer = pop_delay
	var interval: float = fast_blink if _pop_timer >= 0.0 else slow_blink
	_sprite.frame = int(_age / interval) % 2
	if _pop_timer >= 0.0:
		_pop_timer -= delta
		if _pop_timer <= 0.0:
			_pop()

func _process_pattern(_delta: float) -> void:
	pass

func _pop() -> void:
	if data.pattern != null:
		_fire_pattern(data.pattern, 0, _rng)
	# A pop isn't a kill: no score, no tech, just the burst.
	queue_free()
