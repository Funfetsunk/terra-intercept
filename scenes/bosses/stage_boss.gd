extends EnemyBase

## Final boss of an Earth mission: moves into place, optionally locks the ground
## scroll so it reads as standing on the terrain, runs two phases (each with an
## optional secondary pattern) and completes the mission when destroyed.

@export var hover_y: float = 70.0
## Bosses that stand on the terrain (a bridge, a siphon in the river) lock the
## ground: while moving into place the ground scrolls at the boss's own speed,
## then stops once it arrives (presentation only).
@export var lock_background_scroll: bool = true

var _phase2_active: bool = false
var _audio: Node = null

func _ready() -> void:
	super._ready()
	_audio = get_node("/root/AudioManager")
	var bd: BossData = data as BossData
	($Sprite as AnimatedSprite2D).play("phase1")
	if bd != null:
		set_secondary_pattern(bd.secondary_pattern)
		_audio.play_music(bd.music)
	var shape := CircleShape2D.new()
	shape.radius = data.hitbox_radius
	$Hitbox/CollisionShape2D.shape = shape

func _process_movement(delta: float) -> void:
	if global_position.y < hover_y:
		global_position.y = min(hover_y, global_position.y + data.move_speed * delta)
		if lock_background_scroll:
			var speed: float = data.move_speed if global_position.y < hover_y else 0.0
			get_tree().call_group("scrolling_background", "set_scroll_speed", speed)

func take_damage(amount: float) -> bool:
	var was_kill: bool = super.take_damage(amount)
	var bd: BossData = data as BossData
	if not was_kill and not _phase2_active and bd != null and hull_current <= bd.hull_max * bd.phase_2_hp_threshold:
		_phase2_active = true
		_current_pattern = bd.phase_2_pattern
		_burst_index = 0
		if _current_pattern != null:
			_rng.seed = _current_pattern.rng_seed
		_audio.play_music(bd.music_phase2)
		set_secondary_pattern(bd.phase_2_secondary_pattern)
		($Sprite as AnimatedSprite2D).play("phase2")
	return was_kill

func _die() -> void:
	super._die()
	get_node("/root/GameState").complete_mission()
