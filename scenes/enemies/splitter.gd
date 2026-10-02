extends EnemyBase

## Splitter: drifts down like a drone and fires its pattern. Each hit flashes
## the crack frame (`hit` animation) briefly. When destroyed it splits into
## `split_count` mini drones (`split_scene`) fanned out across `split_spread`
## degrees, aimed away from the player.

@export var split_scene: PackedScene
@export var split_count: int = 3
@export var split_spread: float = 120.0
@export var drift_speed: float = 14.0
@export var hit_flash_time: float = 0.12

var _drift_dir: float = 1.0
var _flash: float = 0.0

@onready var _sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	super._ready()
	_drift_dir = -1.0 if _bullets.get_player_position().x < global_position.x else 1.0

func _process_movement(delta: float) -> void:
	global_position.y += data.move_speed * delta
	global_position.x += _drift_dir * drift_speed * delta
	if _flash > 0.0:
		_flash -= delta
		if _flash <= 0.0:
			_sprite.play("idle")
	if global_position.y > despawn_y:
		queue_free()

func take_damage(amount: float) -> bool:
	var killed: bool = super.take_damage(amount)
	if not killed:
		_flash = hit_flash_time
		_sprite.play("hit")
	return killed

func _die() -> void:
	if split_scene != null:
		var away: float = (global_position - _bullets.get_player_position()).angle()
		for i in range(split_count):
			var t: float = 0.5 if split_count == 1 else float(i) / float(split_count - 1)
			var angle: float = away + deg_to_rad(lerpf(-split_spread * 0.5, split_spread * 0.5, t))
			var fragment: Node2D = split_scene.instantiate()
			fragment.position = get_parent().to_local(global_position)
			fragment.set("direction", Vector2.from_angle(angle))
			get_parent().call_deferred("add_child", fragment)
	super._die()
