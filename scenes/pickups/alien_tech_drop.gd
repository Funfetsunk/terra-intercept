extends Node2D
class_name AlienTechDrop

@export var amount: int = 1
## Drops worth at least this much use the large gem sprite.
@export var large_gem_threshold: int = 2
@export var drift_speed: float = 40.0
@export var pickup_radius: float = 10.0
@export var despawn_y: float = 400.0
@export var magnet_radius: float = 40.0
@export var magnet_speed: float = 220.0
## Upgrade stat whose bonus (GameState.upgrade_bonus) widens magnet_radius.
@export var magnet_upgrade_stat: String = "pickup_magnet_radius"
@export var never_despawn: bool = false
@export var highlighted: bool = false
@export var highlight_pulse_speed: float = 4.0
## Highlighted pickups bob up and down by up to this many whole pixels
## (pixel art is never scaled by fractions, so no size pulse).
@export var highlight_bob_pixels: float = 2.0

var _bullets: Node = null
var _collected: bool = false
var _pulse_elapsed: float = 0.0

func _ready() -> void:
	_bullets = get_node("/root/BulletManager")
	magnet_radius += get_node("/root/GameState").upgrade_bonus(magnet_upgrade_stat)
	($Sprite as AnimatedSprite2D).play("large" if amount >= large_gem_threshold else "small")

func _physics_process(delta: float) -> void:
	if _collected:
		return
	if highlighted:
		_pulse_elapsed += delta
		$Sprite.position.y = roundf(sin(_pulse_elapsed * highlight_pulse_speed) * highlight_bob_pixels)
	var player: Node2D = _bullets.get_registered_player()
	if player != null and global_position.distance_to(player.global_position) <= magnet_radius:
		global_position = global_position.move_toward(player.global_position, magnet_speed * delta)
	else:
		global_position.y += drift_speed * delta
	if not never_despawn and global_position.y > despawn_y:
		queue_free()
		return
	if player != null and global_position.distance_to(player.global_position) <= pickup_radius:
		_collected = true
		get_node("/root/GameState").collect_tech(amount)
		queue_free()
