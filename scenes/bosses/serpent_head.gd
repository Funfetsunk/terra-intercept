extends EnemyBase

## The serpent-dragon's head and core. Uses its BossData's two phases (phase 2
## at phase_2_hp_threshold also speeds the serpent up). Its death destroys the
## remaining body and completes the mission. The parent SerpentBoss moves it.

var _phase2: bool = false

@onready var _serpent: Node = get_parent()
@onready var _sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	super._ready()
	var bd: BossData = data as BossData
	if bd != null:
		set_secondary_pattern(bd.secondary_pattern)
	_sprite.play("phase1")

func take_damage(amount: float) -> bool:
	var was_kill: bool = super.take_damage(amount)
	var bd: BossData = data as BossData
	if not was_kill and not _phase2 and bd != null and hull_current <= bd.hull_max * bd.phase_2_hp_threshold:
		_phase2 = true
		_current_pattern = bd.phase_2_pattern
		_burst_index = 0
		if _current_pattern != null:
			_rng.seed = _current_pattern.rng_seed
		set_secondary_pattern(bd.phase_2_secondary_pattern)
		_sprite.play("phase2")
		if _serpent.has_method("enter_phase2"):
			_serpent.enter_phase2()
	return was_kill

func _die() -> void:
	if _serpent.has_method("destroy_body"):
		_serpent.destroy_body()
	super._die()
	get_node("/root/GameState").complete_mission()
