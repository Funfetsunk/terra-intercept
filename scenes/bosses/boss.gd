extends EnemyBase

@export var hover_y: float = 70.0

var _phase2_active: bool = false

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
