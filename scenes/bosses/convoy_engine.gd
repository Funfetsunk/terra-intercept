extends EnemyBase

## Convoy engine: shielded (takes no damage) while any car is left. When the
## last car goes it switches to its BossData phase-2 patterns; destroying it
## completes the mission. The parent ConvoyBoss moves it along the track.

var _phase2: bool = false

@onready var _convoy: Node = get_parent()
@onready var _sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	super._ready()
	var bd: BossData = data as BossData
	if bd != null:
		set_secondary_pattern(bd.secondary_pattern)
	_sprite.play("shielded")

func take_damage(amount: float) -> bool:
	if _convoy.has_method("is_engine_shielded") and _convoy.is_engine_shielded():
		return false
	return super.take_damage(amount)

func enter_phase2() -> void:
	if _phase2:
		return
	_phase2 = true
	var bd: BossData = data as BossData
	if bd != null:
		_current_pattern = bd.phase_2_pattern
		_burst_index = 0
		if _current_pattern != null:
			_rng.seed = _current_pattern.rng_seed
			_burst_timer = _current_pattern.burst_interval
		set_secondary_pattern(bd.phase_2_secondary_pattern)
	_sprite.play("exposed")

func _die() -> void:
	super._die()
	get_node("/root/GameState").complete_mission()
