extends Node2D

@export var max_player_bullets: int = 1024
@export var max_enemy_bullets: int = 4096
@export var despawn_margin: float = 40.0
@export var contact_damage_cooldown: float = 0.5
## Colour of the high-contrast outline behind enemy bullets (palette darkest).
@export var high_contrast_outline_color: Color = Color("2e222f")

signal bullet_pool_exhausted(is_player: bool)
## A player ordnance blast went off (missile impact or mine), for effects.
signal ordnance_detonated(position: Vector2, ordnance: OrdnanceData)

class BulletPool:
	var positions: PackedVector2Array = PackedVector2Array()
	var velocities: PackedVector2Array = PackedVector2Array()
	var radii: PackedFloat32Array = PackedFloat32Array()
	var colors: PackedColorArray = PackedColorArray()
	var lifetimes: PackedFloat32Array = PackedFloat32Array()
	var damages: PackedFloat32Array = PackedFloat32Array()
	var textures: Array[Texture2D] = []
	## Ordnance extras (player pool only; 0 / null for plain bullets).
	var blast_radii: PackedFloat32Array = PackedFloat32Array()
	var blast_damages: PackedFloat32Array = PackedFloat32Array()
	var turn_rates: PackedFloat32Array = PackedFloat32Array()
	var ordnance: Array[OrdnanceData] = []
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
		textures.resize(cap)
		blast_radii.resize(cap)
		blast_damages.resize(cap)
		turn_rates.resize(cap)
		ordnance.resize(cap)
		active_count = 0

	func spawn(pos: Vector2, vel: Vector2, radius: float, color: Color, lifetime: float, damage: float, texture: Texture2D) -> bool:
		if active_count >= capacity:
			return false
		var i: int = active_count
		positions[i] = pos
		velocities[i] = vel
		radii[i] = radius
		colors[i] = color
		lifetimes[i] = lifetime
		damages[i] = damage
		textures[i] = texture
		blast_radii[i] = 0.0
		blast_damages[i] = 0.0
		turn_rates[i] = 0.0
		ordnance[i] = null
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
		textures[i] = textures[last]
		blast_radii[i] = blast_radii[last]
		blast_damages[i] = blast_damages[last]
		turn_rates[i] = turn_rates[last]
		ordnance[i] = ordnance[last]
		active_count = last
var _player_pool: BulletPool = BulletPool.new()
var _enemy_pool: BulletPool = BulletPool.new()

var _registered_player: Node2D = null
var _registered_player_hitbox_radius: float = 0.0
var _registered_enemies: Array[Node2D] = []
## Shielders: player bullets inside an active shield circle are absorbed.
var _registered_shields: Array[Node2D] = []
var _enemy_bullet_time_scale: float = 1.0
var _contact_cooldown: float = 0.0

func _ready() -> void:
	_player_pool.setup(max_player_bullets)
	_enemy_pool.setup(max_enemy_bullets)

func _physics_process(delta: float) -> void:
	_steer_homing_shots(delta)
	_step_pool(_player_pool, delta, 1.0)
	if not get_tree().paused:
		_step_pool(_enemy_pool, delta, _enemy_bullet_time_scale)
		_check_enemy_bullets_vs_player()
		_check_enemy_ships_vs_player(delta)
	_check_player_bullets_vs_enemies()
	queue_redraw()

func _step_pool(pool: BulletPool, delta: float, time_scale: float) -> void:
	var bounds: Rect2 = get_node("/root/Playfield").rect.grow(despawn_margin)
	var i: int = 0
	while i < pool.active_count:
		pool.positions[i] += pool.velocities[i] * delta * time_scale
		pool.lifetimes[i] -= delta
		if pool.lifetimes[i] <= 0.0 or not bounds.has_point(pool.positions[i]):
			pool.kill(i)
		else:
			i += 1

## Homing ordnance turns towards the nearest hittable enemy, up to its turn rate.
func _steer_homing_shots(delta: float) -> void:
	for i in range(_player_pool.active_count):
		var rate: float = _player_pool.turn_rates[i]
		if rate <= 0.0:
			continue
		var target: Node2D = get_nearest_enemy(_player_pool.positions[i])
		if target == null:
			continue
		var vel: Vector2 = _player_pool.velocities[i]
		var wanted: float = vel.angle_to(target.global_position - _player_pool.positions[i])
		_player_pool.velocities[i] = vel.rotated(clampf(wanted, -rate * delta, rate * delta))

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
			if _registered_player == null:
				return
			if _registered_player.has_method("take_hit"):
				_registered_player.take_hit(damage)
		else:
			i += 1

func _check_enemy_ships_vs_player(delta: float) -> void:
	_contact_cooldown = max(0.0, _contact_cooldown - delta)
	if _contact_cooldown > 0.0 or _registered_player == null:
		return
	var player_pos: Vector2 = _registered_player.global_position
	var player_r: float = _registered_player_hitbox_radius
	for e: Node2D in _registered_enemies:
		if e == null or not is_instance_valid(e):
			continue
		if not e.has_method("get_hitbox_radius") or not e.has_method("get_contact_damage"):
			continue
		if e.global_position.distance_to(player_pos) <= e.get_hitbox_radius() + player_r:
			if _registered_player.has_method("take_hit"):
				_registered_player.take_hit(e.get_contact_damage())
			_contact_cooldown = contact_damage_cooldown
			return

func _check_player_bullets_vs_enemies() -> void:
	if _registered_enemies.is_empty():
		return
	var i: int = 0
	while i < _player_pool.active_count:
		if _is_shielded(_player_pool.positions[i]):
			_player_pool.kill(i)
			continue
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
			var hit_pos: Vector2 = _player_pool.positions[i]
			var blast_radius: float = _player_pool.blast_radii[i]
			var blast_damage: float = _player_pool.blast_damages[i]
			var shot_ordnance: OrdnanceData = _player_pool.ordnance[i]
			_player_pool.kill(i)
			var was_kill: bool = false
			if hit_enemy.has_method("take_damage"):
				was_kill = hit_enemy.take_damage(damage)
			if _registered_player != null and _registered_player.has_method("on_damage_dealt"):
				_registered_player.on_damage_dealt(damage, was_kill)
			if blast_radius > 0.0:
				detonate_player_blast(hit_pos, blast_radius, blast_damage, false, hit_enemy)
			if shot_ordnance != null:
				ordnance_detonated.emit(hit_pos, shot_ordnance)
		else:
			i += 1

func _draw() -> void:
	var high_contrast: bool = get_node("/root/Settings").high_contrast_bullets
	for i in range(_player_pool.active_count):
		# The high-contrast outline is for reading threats, so it only goes behind enemy bullets.
		var texture: Texture2D = _player_pool.textures[i]
		if _player_pool.ordnance[i] != null:
			texture = _player_pool.ordnance[i].texture_for_direction(_player_pool.velocities[i])
		_draw_bullet(_player_pool.positions[i], _player_pool.radii[i], _player_pool.colors[i], texture, false)
	for i in range(_enemy_pool.active_count):
		_draw_bullet(_enemy_pool.positions[i], _enemy_pool.radii[i], _enemy_pool.colors[i], _enemy_pool.textures[i], high_contrast)

func _draw_bullet(pos: Vector2, radius: float, color: Color, texture: Texture2D, high_contrast: bool) -> void:
	if texture != null:
		# Real art draws at its native size on whole pixels (never stretched to the
		# hitbox), so the sprite stays pixel-perfect whatever the collision radius is.
		var size: Vector2 = texture.get_size()
		var top_left: Vector2 = (pos - size * 0.5).round()
		if high_contrast:
			draw_circle(top_left + size * 0.5, maxf(size.x, size.y) * 0.5 + 1.0, high_contrast_outline_color)
		draw_texture(texture, top_left, color)
		return
	var half: float = radius
	var rect: Rect2 = Rect2(pos.x - half, pos.y - half, half * 2.0, half * 2.0)
	if high_contrast:
		draw_rect(rect.grow(1.0), high_contrast_outline_color, true)
	draw_rect(rect, color, true)

func register_player(player: Node2D, hitbox_radius: float) -> void:
	_registered_player = player
	_registered_player_hitbox_radius = hitbox_radius

func set_player_hitbox_radius(hitbox_radius: float) -> void:
	_registered_player_hitbox_radius = hitbox_radius

func unregister_player() -> void:
	_registered_player = null

func _is_shielded(point: Vector2) -> bool:
	for sh: Node2D in _registered_shields:
		if sh == null or not is_instance_valid(sh):
			continue
		if sh.is_shield_active() and point.distance_to(sh.global_position) <= sh.get_shield_radius():
			return true
	return false

func register_shield(shield: Node2D) -> void:
	if not _registered_shields.has(shield):
		_registered_shields.append(shield)

func unregister_shield(shield: Node2D) -> void:
	_registered_shields.erase(shield)

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

func spawn_player_bullet(pos: Vector2, direction: Vector2, speed: float, radius: float, color: Color, lifetime: float, damage: float, texture: Texture2D = null) -> void:
	if not _player_pool.spawn(pos, direction.normalized() * speed, radius, color, lifetime, damage, texture):
		bullet_pool_exhausted.emit(true)

## An ordnance shot: a pooled player bullet that can home and burst on impact.
## Its sprite follows its flight direction (OrdnanceData.texture_for_direction).
func spawn_player_ordnance_shot(pos: Vector2, direction: Vector2, ordnance: OrdnanceData) -> void:
	var tex: Texture2D = ordnance.texture_for_direction(direction)
	if not _player_pool.spawn(pos, direction.normalized() * ordnance.bullet_speed, ordnance.bullet_radius, ordnance.bullet_color, ordnance.bullet_lifetime, ordnance.bullet_damage, tex):
		bullet_pool_exhausted.emit(true)
		return
	var i: int = _player_pool.active_count - 1
	_player_pool.blast_radii[i] = ordnance.blast_radius
	_player_pool.blast_damages[i] = ordnance.blast_damage
	_player_pool.turn_rates[i] = deg_to_rad(ordnance.homing_turn_degrees_per_second)
	_player_pool.ordnance[i] = ordnance

## Damages every hittable enemy in the circle (except `exclude`), credits the
## player for it, and optionally clears enemy bullets inside it.
func detonate_player_blast(center: Vector2, radius: float, damage: float, clears_bullets: bool, exclude: Node2D = null) -> void:
	if clears_bullets:
		clear_enemy_bullets_in_circle(center, radius)
	for e: Node2D in _registered_enemies.duplicate():
		if e == null or not is_instance_valid(e) or e == exclude:
			continue
		if not e.has_method("take_damage") or not e.has_method("get_hitbox_radius"):
			continue
		var er: float = e.get_hitbox_radius()
		if er < 0.0 or e.global_position.distance_to(center) > radius + er:
			continue
		var was_kill: bool = e.take_damage(damage)
		if _registered_player != null and _registered_player.has_method("on_damage_dealt"):
			_registered_player.on_damage_dealt(damage, was_kill)

## Nearest enemy that can currently be hit (a negative hitbox means hidden,
## such as an underground Burrower), or null.
func get_nearest_enemy(from: Vector2, max_distance: float = INF) -> Node2D:
	var best: Node2D = null
	var best_dist: float = max_distance
	for e: Node2D in _registered_enemies:
		if e == null or not is_instance_valid(e) or not e.has_method("get_hitbox_radius"):
			continue
		var er: float = e.get_hitbox_radius()
		if er < 0.0:
			continue
		var d: float = e.global_position.distance_to(from) - er
		if d < best_dist:
			best_dist = d
			best = e
	return best

func spawn_enemy_bullet(pos: Vector2, direction: Vector2, speed: float, radius: float, color: Color, lifetime: float, damage: float, texture: Texture2D = null) -> void:
	if not _enemy_pool.spawn(pos, direction.normalized() * speed, radius, color, lifetime, damage, texture):
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

func has_active_threats() -> bool:
	return not _registered_enemies.is_empty() or _enemy_pool.active_count > 0
