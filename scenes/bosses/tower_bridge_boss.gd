extends EnemyBase

@export var hover_y: float = 70.0

var _phase2_active: bool = false

func _ready() -> void:
	super._ready()
	var bd: BossData = data as BossData
	if bd != null:
		$Sprite.color = bd.sprite_color
		$Sprite.offset_left = -bd.sprite_size / 2.0
		$Sprite.offset_top = -bd.sprite_size / 2.0
		$Sprite.offset_right = bd.sprite_size / 2.0
		$Sprite.offset_bottom = bd.sprite_size / 2.0
	var shape := CircleShape2D.new()
	shape.radius = data.hitbox_radius
	$Hitbox/CollisionShape2D.shape = shape

func _process_movement(delta: float) -> void:
	if global_position.y < hover_y:
		global_position.y = min(hover_y, global_position.y + data.move_speed * delta)

func take_damage(amount: float) -> bool:
	var was_kill: bool = super.take_damage(amount)
	var bd: BossData = data as BossData
	if not _phase2_active and bd != null and hull_current <= bd.hull_max * bd.phase_2_hp_threshold:
		_phase2_active = true
		_current_pattern = bd.phase_2_pattern
		_burst_index = 0
		if _current_pattern != null:
			_rng.seed = _current_pattern.rng_seed
	return was_kill

func _die() -> void:
	super._die()
	get_node("/root/GameState").complete_mission()
