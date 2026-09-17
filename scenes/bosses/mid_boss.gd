extends EnemyBase

signal boss_defeated

@export var hover_y: float = 70.0

var _phase2_active: bool = false
var _audio: Node = null
var _music_before: AudioStream = null

func _ready() -> void:
	super._ready()
	_audio = get_node("/root/AudioManager")
	var bd: BossData = data as BossData
	if bd != null:
		$Sprite.color = bd.sprite_color
		$Sprite.offset_left = -bd.sprite_size / 2.0
		$Sprite.offset_top = -bd.sprite_size / 2.0
		$Sprite.offset_right = bd.sprite_size / 2.0
		$Sprite.offset_bottom = bd.sprite_size / 2.0
		_music_before = _audio.get_current_music()
		_audio.play_music(bd.music)
	var shape := CircleShape2D.new()
	shape.radius = data.hitbox_radius
	$Hitbox/CollisionShape2D.shape = shape

func _process_movement(delta: float) -> void:
	if global_position.y < hover_y:
		global_position.y = min(hover_y, global_position.y + data.move_speed * delta)

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
	return was_kill

func _die() -> void:
	super._die()
	_audio.play_music(_music_before)
	boss_defeated.emit()
