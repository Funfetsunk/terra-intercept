extends EnemyBase

## Shielder: drops to `hold_y`, drifts gently side to side, and projects a
## shield ring that absorbs player bullets for anything inside it, itself
## included. The ring cycles: up for `shield_up_time`, flickering for
## `flicker_time` (the telegraph), then down for `shield_down_time`, the window
## to kill it. Leaves off the bottom after `stay_time`.

@export var hold_y: float = 90.0
@export var shield_radius: float = 32.0
@export var shield_up_time: float = 3.2
@export var flicker_time: float = 0.7
@export var shield_down_time: float = 2.2
@export var flicker_interval: float = 0.06
@export var sway_px: float = 24.0
@export var sway_hz: float = 0.25
@export var stay_time: float = 14.0
@export var exit_speed: float = 40.0

var _cycle: float = 0.0
var _age: float = 0.0
var _base_x: float = 0.0
var _arrived: bool = false

@onready var _ring: AnimatedSprite2D = $Ring

func _ready() -> void:
	super._ready()
	_base_x = global_position.x
	_bullets.register_shield(self)
	_ring.play("on")

func _exit_tree() -> void:
	super._exit_tree()
	if _bullets != null:
		_bullets.unregister_shield(self)

func _process_movement(delta: float) -> void:
	_age += delta
	if not _arrived:
		global_position.y = minf(hold_y, global_position.y + data.move_speed * delta)
		_arrived = global_position.y >= hold_y
	elif _age > stay_time:
		global_position.y += exit_speed * delta
		if global_position.y > despawn_y:
			queue_free()
			return
	global_position.x = roundf(_base_x + sin(_age * TAU * sway_hz) * sway_px)
	_cycle = fposmod(_cycle + delta, shield_up_time + flicker_time + shield_down_time)
	if _cycle < shield_up_time:
		_ring.visible = true
	elif _cycle < shield_up_time + flicker_time:
		_ring.visible = int((_cycle - shield_up_time) / flicker_interval) % 2 == 0
	else:
		_ring.visible = false

func is_shield_active() -> bool:
	return _cycle < shield_up_time + flicker_time

func get_shield_radius() -> float:
	return shield_radius
