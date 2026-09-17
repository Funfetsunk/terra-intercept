extends Node2D
class_name AlienTechDrop

@export var amount: int = 1
@export var drift_speed: float = 40.0
@export var pickup_radius: float = 10.0
@export var despawn_y: float = 400.0
@export var magnet_radius: float = 40.0
@export var magnet_speed: float = 220.0
@export var never_despawn: bool = false
@export var highlighted: bool = false
@export var highlight_pulse_speed: float = 4.0
@export var highlight_pulse_scale: float = 0.25

var _bullets: Node = null
var _collected: bool = false
var _pulse_elapsed: float = 0.0
var _base_sprite_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	_bullets = get_node("/root/BulletManager")
	_base_sprite_scale = $Sprite.scale

func _physics_process(delta: float) -> void:
	if _collected:
		return
	if highlighted:
		_pulse_elapsed += delta
		var scale_factor: float = 1.0 + sin(_pulse_elapsed * highlight_pulse_speed) * highlight_pulse_scale
		$Sprite.scale = _base_sprite_scale * scale_factor
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
