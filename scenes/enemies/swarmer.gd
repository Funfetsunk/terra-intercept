extends EnemyBase

@export var strafe_amplitude_px: float = 40.0
@export var strafe_frequency_hz: float = 0.6

var _spawn_x: float = 0.0
var _elapsed: float = 0.0

func _ready() -> void:
	super._ready()
	_spawn_x = global_position.x

func _process_movement(delta: float) -> void:
	_elapsed += delta
	global_position.y += data.move_speed * delta
	global_position.x = _spawn_x + sin(_elapsed * TAU * strafe_frequency_hz) * strafe_amplitude_px
	if global_position.y > despawn_y:
		queue_free()
