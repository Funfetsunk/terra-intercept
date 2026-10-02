extends EnemyBase

## Mini drone: a Splitter fragment. Scatters along `direction` (set by the
## Splitter), slowing down and curving down the screen, and fires its pattern.

@export var direction: Vector2 = Vector2.DOWN
@export var start_speed: float = 110.0
@export var settle_speed: float = 45.0
@export var settle_rate: float = 2.5

var _speed: float = 0.0

func _ready() -> void:
	super._ready()
	_speed = start_speed

func _process_movement(delta: float) -> void:
	_speed = move_toward(_speed, settle_speed, start_speed * settle_rate * delta)
	direction = direction.lerp(Vector2.DOWN, delta * 0.8).normalized()
	global_position += direction * _speed * delta
	var rect: Rect2 = get_node("/root/Playfield").rect.grow(30.0)
	if not rect.has_point(global_position):
		queue_free()
