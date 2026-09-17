extends EnemyBase

@export var drift_speed: float = 18.0
@export var screen_exit_margin: float = 20.0

var _drift_dir: float = 1.0

func _ready() -> void:
	super._ready()
	var to_player: Vector2 = _bullets.get_player_position() - global_position
	_drift_dir = -1.0 if to_player.x < 0.0 else 1.0

func _process_movement(delta: float) -> void:
	global_position.y += data.move_speed * delta
	global_position.x += _drift_dir * drift_speed * delta
	var bounds: Rect2 = get_node("/root/Playfield").rect
	if global_position.y > despawn_y or global_position.x < bounds.position.x - screen_exit_margin or global_position.x > bounds.position.x + bounds.size.x + screen_exit_margin:
		queue_free()
