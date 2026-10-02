extends Node2D

## Sea strike (Rio): a wave of enemies bursting out of the sea at one side of
## the screen. Splashes churn at that edge for `telegraph_duration` (the warning),
## then `count` copies of `enemy_scene` (with `data_override` if set) spawn there
## one after another, spread over `spread_y` around the strike's spawn height.
## The side comes from the spawn position: relative x < 0.5 is the left edge.

@export var enemy_scene: PackedScene
@export var data_override: EnemyData
@export var count: int = 4
@export var interval: float = 0.35
@export var spread_y: float = 0.25
@export var telegraph_duration: float = 1.0
@export var splash_colors: PackedColorArray = PackedColorArray([Color("c7dcd0"), Color("9babb2"), Color("ffffff")])
## How far in from the edge they surface (negative = outside the screen).
@export var edge_offset: float = -0.07

var _t: float = 0.0
var _spawned: int = 0
var _left: bool = true
var _rect: Rect2 = Rect2()
var _base_y: float = 0.0

func _ready() -> void:
	_rect = get_node("/root/Playfield").rect
	_left = global_position.x < _rect.get_center().x
	_base_y = (global_position.y - _rect.position.y) / _rect.size.y

func _physics_process(delta: float) -> void:
	_t += delta
	if _t >= telegraph_duration:
		while _spawned < count and _t >= telegraph_duration + interval * float(_spawned):
			_spawn_one()
	if _spawned >= count and _t > telegraph_duration + interval * float(count) + 0.5:
		queue_free()
	queue_redraw()

func _spawn_one() -> void:
	var f: float = 0.5 if count == 1 else float(_spawned) / float(count - 1)
	var rel: Vector2 = Vector2(-edge_offset if _left else 1.0 + edge_offset, _base_y + lerpf(-spread_y * 0.5, spread_y * 0.5, f))
	var enemy: Node2D = enemy_scene.instantiate()
	if enemy is EnemyBase and data_override != null:
		(enemy as EnemyBase).data = data_override
	enemy.position = get_parent().to_local(_rect.position + rel * _rect.size)
	get_parent().call_deferred("add_child", enemy)
	_spawned += 1

func _draw() -> void:
	if _t > telegraph_duration + interval * float(count):
		return
	# Splashes churning at the sea edge.
	var edge_x: float = _rect.position.x + (4.0 if _left else _rect.size.x - 4.0)
	for i in range(18):
		var h: int = absi((i * 73856093) ^ 49157)
		var y: float = _rect.position.y + (_base_y + (float(h % 100) / 100.0 - 0.5) * (spread_y + 0.1)) * _rect.size.y
		var x: float = edge_x + (1.0 if _left else -1.0) * float((h >> 4) % 18)
		var hop: float = absf(sin(_t * 9.0 + float(i))) * 4.0
		var c: Color = splash_colors[(h >> 6) % splash_colors.size()]
		draw_rect(Rect2(to_local(Vector2(x, y - hop)).round(), Vector2(2, 2)), c)
