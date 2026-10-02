extends EnemyBase

## Mine layer: crosses the screen slowly at its spawn height, dropping a mine
## behind it every `drop_interval`. It enters from the side it spawns on
## (relative x < 0.5 travels right, otherwise left) and leaves off the far side.

@export var mine_scene: PackedScene
@export var drop_interval: float = 1.2
@export var first_drop_delay: float = 0.8
@export var drift_down_speed: float = 8.0
@export var exit_margin: float = 30.0

var _direction: float = 1.0
var _drop_timer: float = 0.0

@onready var _sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	super._ready()
	var rect: Rect2 = get_node("/root/Playfield").rect
	_direction = 1.0 if global_position.x < rect.get_center().x else -1.0
	# Art faces right; mirror (pixel-exact) when crossing to the left.
	_sprite.flip_h = _direction < 0.0
	_drop_timer = first_drop_delay

func _process_movement(delta: float) -> void:
	global_position.x += _direction * data.move_speed * delta
	global_position.y += drift_down_speed * delta
	var rect: Rect2 = get_node("/root/Playfield").rect.grow(exit_margin)
	if (_direction > 0.0 and global_position.x > rect.end.x) or (_direction < 0.0 and global_position.x < rect.position.x):
		queue_free()
		return
	_drop_timer -= delta
	if _drop_timer <= 0.0 and mine_scene != null and get_node("/root/Playfield").rect.has_point(global_position):
		_drop_timer = drop_interval
		var mine: Node2D = mine_scene.instantiate()
		mine.position = get_parent().to_local(global_position - Vector2(_direction * 10.0, 0.0))
		get_parent().call_deferred("add_child", mine)
