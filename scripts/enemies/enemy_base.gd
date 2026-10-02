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
## Optional second pattern fired alongside the main one (bosses), with its own
## timer and seeded RNG so both stay deterministic.
var _secondary_pattern: BulletPatternData = null
var _secondary_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _secondary_timer: float = 0.0
var _secondary_burst_index: int = 0

func _ready() -> void:
	_bullets = get_node("/root/BulletManager")
	_apply_sprite_frames()
	hull_current = data.hull_max
	_current_pattern = pattern_override if pattern_override != null else data.pattern
	if _current_pattern != null:
		_rng.seed = _current_pattern.rng_seed
		_burst_timer = _current_pattern.burst_interval
	_bullets.register_enemy(self)

## Swaps in data.sprite_frames (a variant's art), keeping the current animation.
func _apply_sprite_frames() -> void:
	if data.sprite_frames == null:
		return
	var sprite: AnimatedSprite2D = get_node_or_null("Sprite") as AnimatedSprite2D
	if sprite == null:
		return
	var anim: StringName = sprite.animation
	var was_playing: bool = sprite.is_playing() or not String(sprite.autoplay).is_empty()
	sprite.sprite_frames = data.sprite_frames
	if data.sprite_frames.has_animation(anim):
		sprite.animation = anim
		if was_playing:
			sprite.play(anim)

func _exit_tree() -> void:
	if _bullets != null:
		_bullets.unregister_enemy(self)

func _physics_process(delta: float) -> void:
	_process_movement(delta)
	_process_pattern(delta)

func _process_movement(_delta: float) -> void:
	pass

func _process_pattern(delta: float) -> void:
	if _current_pattern != null:
		_burst_timer -= delta
		if _burst_timer <= 0.0:
			_fire_burst(_current_pattern)
			_burst_timer += _current_pattern.burst_interval
	if _secondary_pattern != null:
		_secondary_timer -= delta
		if _secondary_timer <= 0.0:
			_fire_pattern(_secondary_pattern, _secondary_burst_index, _secondary_rng)
			_secondary_burst_index += 1
			_secondary_timer += _secondary_pattern.burst_interval

func set_secondary_pattern(pattern: BulletPatternData) -> void:
	_secondary_pattern = pattern
	_secondary_burst_index = 0
	if pattern != null:
		_secondary_rng.seed = pattern.rng_seed
		_secondary_timer = pattern.burst_interval

func _fire_burst(pattern: BulletPatternData) -> void:
	_fire_pattern(pattern, _burst_index, _rng)
	_burst_index += 1

func _fire_pattern(pattern: BulletPatternData, burst_index: int, rng: RandomNumberGenerator) -> void:
	var base_angle_deg: float = pattern.fixed_angle_degrees + pattern.rotation_per_burst_degrees * burst_index
	if pattern.sweep_period_bursts > 0:
		base_angle_deg += pattern.sweep_degrees * sin(TAU * float(burst_index) / float(pattern.sweep_period_bursts))
	var count: int = max(1, pattern.burst_size)
	var full_ring: bool = is_equal_approx(pattern.angle_spread_degrees, 360.0)
	var angle_step: float = 0.0
	if count > 1:
		angle_step = pattern.angle_spread_degrees / float(count) if full_ring else pattern.angle_spread_degrees / float(count - 1)
	var emitters: PackedVector2Array = pattern.emitter_offsets
	if emitters.is_empty():
		emitters = PackedVector2Array([Vector2.ZERO])
	var layer_count: int = max(1, pattern.layers)
	for e in range(emitters.size()):
		var origin: Vector2 = global_position + emitters[e]
		var emitter_angle_deg: float = base_angle_deg
		if pattern.aim_at_player:
			emitter_angle_deg = rad_to_deg((_bullets.get_player_position() - origin).angle())
		if e < pattern.emitter_angle_offsets.size():
			emitter_angle_deg += pattern.emitter_angle_offsets[e]
		for layer in range(layer_count):
			var speed: float = pattern.bullet_speed + pattern.layer_speed_step * float(layer)
			for i in range(count):
				var offset: float = angle_step * float(i) if full_ring else (-pattern.angle_spread_degrees / 2.0 + angle_step * float(i))
				var angle_deg: float = emitter_angle_deg + offset
				if pattern.jitter_degrees > 0.0:
					angle_deg += rng.randf_range(-pattern.jitter_degrees, pattern.jitter_degrees)
				var bullet_speed: float = speed
				if pattern.speed_jitter > 0.0:
					bullet_speed += rng.randf_range(-pattern.speed_jitter, pattern.speed_jitter)
				var rad: float = deg_to_rad(angle_deg)
				var dir: Vector2 = Vector2(cos(rad), sin(rad))
				_bullets.spawn_enemy_bullet(origin, dir, bullet_speed, pattern.bullet_radius, pattern.bullet_color, pattern.bullet_lifetime, pattern.bullet_damage, pattern.bullet_texture)

func take_damage(amount: float) -> bool:
	hull_current = max(0.0, hull_current - amount)
	if hull_current <= 0.0:
		_die()
		return true
	return false

func _die() -> void:
	enemy_destroyed.emit(self, data.score_value)
	if data.explosion_scene != null:
		var boom: Node2D = data.explosion_scene.instantiate()
		boom.position = get_parent().to_local(global_position)
		get_parent().call_deferred("add_child", boom)
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
