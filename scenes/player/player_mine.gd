extends Node2D

## A mine dropped by the player's Mines ordnance. It drifts down slowly and
## goes off when an enemy comes within `ordnance.mine_trigger_radius` (plus the
## enemy's hitbox), or when `ordnance.mine_fuse` runs out. The blast damages
## every enemy inside `ordnance.blast_radius` and, if `mine_clears_bullets` is
## on, clears enemy bullets there too. The light blinks faster near the end.

## Set by PlayerShip before the mine is added to the tree.
var ordnance: OrdnanceData

@export var slow_blink: float = 0.3
@export var fast_blink: float = 0.08
## Blink fast for this long before the fuse runs out.
@export var warning_time: float = 1.0

var _age: float = 0.0
var _done: bool = false

@onready var _bullets: Node = get_node("/root/BulletManager")
@onready var _sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	_sprite.stop()

func _physics_process(delta: float) -> void:
	if _done or ordnance == null:
		return
	_age += delta
	global_position.y += ordnance.mine_drift_speed * delta
	var interval: float = fast_blink if _age >= ordnance.mine_fuse - warning_time else slow_blink
	_sprite.frame = int(_age / interval) % 2
	var target: Node2D = _bullets.get_nearest_enemy(global_position, ordnance.mine_trigger_radius)
	if target != null or _age >= ordnance.mine_fuse:
		_detonate()

func _detonate() -> void:
	_done = true
	var center: Vector2 = global_position
	_bullets.detonate_player_blast(center, ordnance.blast_radius, ordnance.blast_damage, ordnance.mine_clears_bullets)
	_bullets.ordnance_detonated.emit(center, ordnance)
	queue_free()
