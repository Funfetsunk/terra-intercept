extends Node2D
class_name EnemyBase

signal enemy_destroyed(enemy: Node2D, score_value: int)

const ALIEN_TECH_DROP_SCENE: PackedScene = preload("res://scenes/pickups/alien_tech_drop.tscn")

@export var data: EnemyData
@export var despawn_y: float = 400.0

var hull_current: float = 0.0
var pattern_override: BulletPatternData = null

var _bullets: Node = null
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _burst_timer: float = 0.0
var _burst_index: int = 0
var _current_pattern: BulletPatternData = null

func _ready() -> void:
	_bullets = get_node("/root/BulletManager")
	hull_current = data.hull_max
	_current_pattern = pattern_override if pattern_override != null else data.pattern
	if _current_pattern != null:
		_rng.seed = _current_pattern.rng_seed
		_burst_timer = _current_pattern.burst_interval
	_bullets.register_enemy(self)

func _exit_tree() -> void:
	if _bullets != null:
		_bullets.unregister_enemy(self)

func _physics_process(delta: float) -> void:
	_process_movement(delta)
	_process_pattern(delta)

func _process_movement(_delta: float) -> void:
	pass

func _process_pattern(delta: float) -> void:
	if _current_pattern == null:
		return
	_burst_timer -= delta
	if _burst_timer <= 0.0:
		_fire_burst(_current_pattern)
		_burst_timer += _current_pattern.burst_interval

func _fire_burst(pattern: BulletPatternData) -> void:
	var base_angle_deg: float = pattern.fixed_angle_degrees + pattern.rotation_per_burst_degrees * _burst_index
	if pattern.aim_at_player:
		var to_player: Vector2 = _bullets.get_player_position() - global_position
		base_angle_deg = rad_to_deg(to_player.angle())
	var count: int = max(1, pattern.burst_size)
	var full_ring: bool = is_equal_approx(pattern.angle_spread_degrees, 360.0)
	var angle_step: float = 0.0
	if count > 1:
		angle_step = pattern.angle_spread_degrees / float(count) if full_ring else pattern.angle_spread_degrees / float(count - 1)
	for i in range(count):
		var offset: float = angle_step * float(i) if full_ring else (-pattern.angle_spread_degrees / 2.0 + angle_step * float(i))
		var angle_deg: float = base_angle_deg + offset
		if pattern.jitter_degrees > 0.0:
			angle_deg += _rng.randf_range(-pattern.jitter_degrees, pattern.jitter_degrees)
		var rad: float = deg_to_rad(angle_deg)
		var dir: Vector2 = Vector2(cos(rad), sin(rad))
		_bullets.spawn_enemy_bullet(global_position, dir, pattern.bullet_speed, pattern.bullet_radius, pattern.bullet_color, pattern.bullet_lifetime, pattern.bullet_damage)
	_burst_index += 1

func take_damage(amount: float) -> bool:
	hull_current = max(0.0, hull_current - amount)
	if hull_current <= 0.0:
		_die()
		return true
	return false

func _die() -> void:
	enemy_destroyed.emit(self, data.score_value)
	get_node("/root/GameState").register_kill(data.score_value)
	if data.alien_tech_drop > 0:
		var drop: Node2D = ALIEN_TECH_DROP_SCENE.instantiate()
		drop.position = get_parent().to_local(global_position)
		get_parent().call_deferred("add_child", drop)
		(drop as AlienTechDrop).amount = data.alien_tech_drop
	queue_free()

func get_hitbox_radius() -> float:
	return data.hitbox_radius

func get_contact_damage() -> float:
	return data.contact_damage
