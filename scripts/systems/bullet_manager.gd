extends Node2D

@export var max_player_bullets: int = 1024
@export var max_enemy_bullets: int = 4096
@export var despawn_margin: float = 40.0

signal bullet_pool_exhausted(is_player: bool)

class BulletPool:
	var positions: PackedVector2Array = PackedVector2Array()
	var velocities: PackedVector2Array = PackedVector2Array()
	var radii: PackedFloat32Array = PackedFloat32Array()
	var colors: PackedColorArray = PackedColorArray()
	var lifetimes: PackedFloat32Array = PackedFloat32Array()
	var damages: PackedFloat32Array = PackedFloat32Array()
	var active_count: int = 0
	var capacity: int = 0

	func setup(cap: int) -> void:
		capacity = cap
		positions.resize(cap)
		velocities.resize(cap)
		radii.resize(cap)
		colors.resize(cap)
		lifetimes.resize(cap)
		damages.resize(cap)
		active_count = 0

	func spawn(pos: Vector2, vel: Vector2, radius: float, color: Color, lifetime: float, damage: float) -> bool:
		if active_count >= capacity:
			return false
		var i: int = active_count
		positions[i] = pos
		velocities[i] = vel
		radii[i] = radius
		colors[i] = color
		lifetimes[i] = lifetime
		damages[i] = damage
		active_count += 1
		return true

	func kill(i: int) -> void:
		var last: int = active_count - 1
		positions[i] = positions[last]
		velocities[i] = velocities[last]
		radii[i] = radii[last]
		colors[i] = colors[last]
		lifetimes[i] = lifetimes[last]
		damages[i] = damages[last]
		active_count = last

var _player_pool: BulletPool = BulletPool.new()
var _enemy_pool: BulletPool = BulletPool.new()

var _registered_player: Node2D = null
var _registered_player_hitbox_radius: float = 0.0
var _registered_enemies: Array[Node2D] = []
var _enemy_bullet_time_scale: float = 1.0

func _ready() -> void:
	_player_pool.setup(max_player_bullets)
	_enemy_pool.setup(max_enemy_bullets)

func _physics_process(delta: float) -> void:
	_step_pool(_player_pool, delta, 1.0)
	_step_pool(_enemy_pool, delta, _enemy_bullet_time_scale)
	_check_enemy_bullets_vs_player()
	_check_player_bullets_vs_enemies()
	queue_redraw()

func _step_pool(pool: BulletPool, delta: float, time_scale: float) -> void:
	var bounds: Rect2 = get_viewport_rect().grow(despawn_margin)
	var i: int = 0
	while i < pool.active_count:
		pool.positions[i] += pool.velocities[i] * delta * time_scale
		pool.lifetimes[i] -= delta
		if pool.lifetimes[i] <= 0.0 or not bounds.has_point(pool.positions[i]):
			pool.kill(i)
		else:
			i += 1

func set_enemy_bullet_time_scale(time_scale: float) -> void:
	_enemy_bullet_time_scale = time_scale

func _check_enemy_bullets_vs_player() -> void:
	if _registered_player == null:
		return
	var player_pos: Vector2 = _registered_player.global_position
	var player_r: float = _registered_player_hitbox_radius
	var i: int = 0
	while i < _enemy_pool.active_count:
		var dist: float = _enemy_pool.positions[i].distance_to(player_pos)
		if dist <= _enemy_pool.radii[i] + player_r:
			var damage: float = _enemy_pool.damages[i]
			_enemy_pool.kill(i)
			if _registered_player.has_method("take_hit"):
				_registered_player.take_hit(damage)
		else:
			i += 1

func _check_player_bullets_vs_enemies() -> void:
	if _registered_enemies.is_empty():
		return
	var i: int = 0
	while i < _player_pool.active_count:
		var hit_enemy: Node2D = null
		for e: Node2D in _registered_enemies:
			if e == null or not is_instance_valid(e):
				continue
			var er: float = 0.0
			if e.has_method("get_hitbox_radius"):
				er = e.get_hitbox_radius()
			if _player_pool.positions[i].distance_to(e.global_position) <= _player_pool.radii[i] + er:
				hit_enemy = e
				break
		if hit_enemy != null:
			var damage: float = _player_pool.damages[i]
			_player_pool.kill(i)
			var was_kill: bool = false
			if hit_enemy.has_method("take_damage"):
				was_kill = hit_enemy.take_damage(damage)
			if _registered_player != null and _registered_player.has_method("on_damage_dealt"):
				_registered_player.on_damage_dealt(damage, was_kill)
		else:
			i += 1

func _draw() -> void:
	for i in range(_player_pool.active_count):
		_draw_bullet_square(_player_pool.positions[i], _player_pool.radii[i], _player_pool.colors[i])
	for i in range(_enemy_pool.active_count):
		_draw_bullet_square(_enemy_pool.positions[i], _enemy_pool.radii[i], _enemy_pool.colors[i])

func _draw_bullet_square(pos: Vector2, radius: float, color: Color) -> void:
	var half: float = radius
	draw_rect(Rect2(pos.x - half, pos.y - half, half * 2.0, half * 2.0), color, true)

func register_player(player: Node2D, hitbox_radius: float) -> void:
	_registered_player = player
	_registered_player_hitbox_radius = hitbox_radius

func set_player_hitbox_radius(hitbox_radius: float) -> void:
	_registered_player_hitbox_radius = hitbox_radius

func unregister_player() -> void:
	_registered_player = null

func register_enemy(enemy: Node2D) -> void:
	if not _registered_enemies.has(enemy):
		_registered_enemies.append(enemy)

func unregister_enemy(enemy: Node2D) -> void:
	_registered_enemies.erase(enemy)

func get_player_position() -> Vector2:
	if _registered_player == null:
		return Vector2.ZERO
	return _registered_player.global_position

func get_registered_player() -> Node2D:
	return _registered_player

func spawn_player_bullet(pos: Vector2, direction: Vector2, speed: float, radius: float, color: Color, lifetime: float, damage: float) -> void:
	if not _player_pool.spawn(pos, direction.normalized() * speed, radius, color, lifetime, damage):
		bullet_pool_exhausted.emit(true)

func spawn_enemy_bullet(pos: Vector2, direction: Vector2, speed: float, radius: float, color: Color, lifetime: float, damage: float) -> void:
	if not _enemy_pool.spawn(pos, direction.normalized() * speed, radius, color, lifetime, damage):
		bullet_pool_exhausted.emit(false)

func clear_enemy_bullets_in_circle(center: Vector2, radius: float) -> void:
	var i: int = 0
	while i < _enemy_pool.active_count:
		if _enemy_pool.positions[i].distance_to(center) <= radius:
			_enemy_pool.kill(i)
		else:
			i += 1

func damage_enemies_in_circle(center: Vector2, radius: float, damage: float) -> void:
	for e: Node2D in _registered_enemies:
		if e == null or not is_instance_valid(e):
			continue
		if e.global_position.distance_to(center) <= radius:
			if e.has_method("take_damage"):
				e.take_damage(damage)

func clear_enemy_bullets_in_rect(rect: Rect2) -> void:
	var i: int = 0
	while i < _enemy_pool.active_count:
		if rect.has_point(_enemy_pool.positions[i]):
			_enemy_pool.kill(i)
		else:
			i += 1

func damage_enemies_in_rect(rect: Rect2, damage: float) -> void:
	for e: Node2D in _registered_enemies:
		if e == null or not is_instance_valid(e):
			continue
		if rect.has_point(e.global_position) and e.has_method("take_damage"):
			e.take_damage(damage)

func clear_enemy_bullets_in_cone(origin: Vector2, direction: Vector2, angle_degrees: float, max_range: float) -> void:
	var i: int = 0
	while i < _enemy_pool.active_count:
		if _point_in_cone(_enemy_pool.positions[i], origin, direction, angle_degrees, max_range):
			_enemy_pool.kill(i)
		else:
			i += 1

func damage_enemies_in_cone(origin: Vector2, direction: Vector2, angle_degrees: float, max_range: float, damage: float) -> void:
	for e: Node2D in _registered_enemies:
		if e == null or not is_instance_valid(e):
			continue
		if _point_in_cone(e.global_position, origin, direction, angle_degrees, max_range) and e.has_method("take_damage"):
			e.take_damage(damage)

func _point_in_cone(point: Vector2, origin: Vector2, direction: Vector2, angle_degrees: float, max_range: float) -> bool:
	var to_point: Vector2 = point - origin
	if to_point.length() > max_range:
		return false
	var half_angle: float = deg_to_rad(angle_degrees) * 0.5
	return absf(direction.normalized().angle_to(to_point)) <= half_angle

func get_active_bullet_count() -> int:
	return _player_pool.active_count + _enemy_pool.active_count

func is_screen_clear() -> bool:
	return _registered_enemies.is_empty() and _enemy_pool.active_count == 0
