extends Node2D
class_name AlienTechDrop

@export var amount: int = 1
@export var drift_speed: float = 40.0
@export var pickup_radius: float = 10.0
@export var despawn_y: float = 400.0

var _bullets: Node = null

func _ready() -> void:
	_bullets = get_node("/root/BulletManager")

func _physics_process(delta: float) -> void:
	global_position.y += drift_speed * delta
	if global_position.y > despawn_y:
		queue_free()
		return
	var player: Node2D = _bullets.get_registered_player()
	if player == null:
		return
	if global_position.distance_to(player.global_position) <= pickup_radius:
		get_node("/root/GameState").collect_tech(amount)
		queue_free()
