extends Node2D
class_name Pickup

@export var data: PickupData
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
		global_position.y += data.drift_speed * delta
	if not never_despawn and global_position.y > despawn_y:
		queue_free()
		return
	if player != null and global_position.distance_to(player.global_position) <= data.pickup_radius:
		_collected = true
		_apply(player)
		queue_free()

func _apply(player: Node2D) -> void:
	match data.pickup_type:
		PickupData.PickupType.WEAPON_LEVEL:
			get_node("/root/GameState").raise_weapon_level(int(data.amount))
		PickupData.PickupType.HULL_REPAIR:
			if player.has_method("repair_hull"):
				player.repair_hull(data.amount)
		PickupData.PickupType.SPECIAL_CHARGE:
			if player.has_method("grant_special_charge"):
				player.grant_special_charge(int(data.amount))
