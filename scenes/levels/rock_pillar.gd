extends Node2D

## A free-standing rock pillar in the Grand Canyon channel: a ground-locked
## obstacle spawned through a SpawnEntry. It scrolls with the ground, pushes the
## player out of `radius` with contact damage (cooldown), and absorbs player
## bullets that hit it (it registers as an always-on "shield" with the bullet
## manager). Frees itself once off the bottom.

@export var radius: float = 16.0
@export var push_margin: float = 6.0
@export var contact_damage: float = 1.0
@export var contact_cooldown: float = 0.6
@export var exit_margin: float = 60.0

var _ground: Node = null
var _bullets: Node = null
var _y: float = 0.0
var _contact_timer: float = 0.0

func _ready() -> void:
	_ground = get_tree().get_first_node_in_group("scrolling_background")
	_bullets = get_node("/root/BulletManager")
	_bullets.register_shield(self)
	_y = position.y

func _exit_tree() -> void:
	if _bullets != null:
		_bullets.unregister_shield(self)

func _physics_process(delta: float) -> void:
	var speed: float = 0.0
	if _ground != null:
		speed = _ground.get_ground_speed()
	_y += speed * delta
	position.y = roundf(_y)
	_contact_timer = maxf(0.0, _contact_timer - delta)
	var player: Node2D = _bullets.get_registered_player()
	if player != null and player.visible:
		var offset: Vector2 = player.global_position - global_position
		var min_dist: float = radius + push_margin
		if offset.length() < min_dist:
			var dir: Vector2 = offset.normalized() if offset.length() > 0.01 else Vector2.DOWN
			player.global_position = global_position + dir * min_dist
			if _contact_timer <= 0.0:
				player.take_hit(contact_damage)
				_contact_timer = contact_cooldown
	if global_position.y > get_node("/root/Playfield").rect.end.y + exit_margin:
		queue_free()

func is_shield_active() -> bool:
	return true

func get_shield_radius() -> float:
	return radius
