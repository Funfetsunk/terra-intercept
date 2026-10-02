extends "res://scenes/bosses/stage_boss.gd"

## The Gate Core (homeworld final boss), fought in three phases.
## Shielded: shield emitters (BossPart children in group "gate_emitter") orbit
## the core and it takes no damage until every emitter is destroyed. Its
## BossData phase-1 patterns fire throughout.
## Exposed: the shield drops (`exposed` animation) and the normal stage-boss
## phase 2 follows at BossData.phase_2_hp_threshold.
## Meltdown: below `phase3_threshold` it switches to the phase-3 patterns,
## flickers, and warps in `reinforcement_scene` from the screen edges every
## `reinforcement_interval`.
## Its death doesn't complete the mission: it triggers the escape sequence
## (call_group "escape_sequence" "begin") after its explosion.

@export var orbit_radius: Vector2 = Vector2(86.0, 70.0)
@export var orbit_speed: float = 0.55
@export var phase3_threshold: float = 0.25
@export var phase3_pattern: BulletPatternData
@export var phase3_secondary_pattern: BulletPatternData
@export var reinforcement_scene: PackedScene
@export var reinforcement_data: EnemyData
@export var reinforcement_interval: float = 3.0
@export var shield_color: Color = Color("ffffff")
@export var shield_color_dim: Color = Color("9babb2")
@export var shield_radius: float = 60.0

var _orbit_t: float = 0.0
var _shielded: bool = true
var _phase3: bool = false
var _reinforce_timer: float = 2.0
var _reinforce_side: int = 0

func _ready() -> void:
	completes_mission = false
	super._ready()
	var slot: int = 0
	for child: Node in get_children():
		if child.is_in_group("gate_emitter"):
			child.set_meta("slot", slot)
			slot += 1

func _emitters() -> Array[Node2D]:
	var out: Array[Node2D] = []
	for child: Node in get_children():
		if child.is_in_group("gate_emitter") and not child.is_queued_for_deletion():
			out.append(child as Node2D)
	return out

func _process_movement(delta: float) -> void:
	super._process_movement(delta)
	_orbit_t += delta * (orbit_speed * (1.6 if _phase3 else 1.0))
	var em: Array[Node2D] = _emitters()
	var all: int = 0
	for child: Node in get_children():
		if child.is_in_group("gate_emitter"):
			all += 1
	for i in range(em.size()):
		var slot: int = int(em[i].get_meta("slot", i))
		var a: float = _orbit_t + TAU * float(slot) / 4.0
		em[i].position = Vector2(cos(a) * orbit_radius.x, sin(a) * orbit_radius.y).round()
	if _shielded and em.is_empty() and all == 0:
		_shielded = false
		($Sprite as AnimatedSprite2D).play("exposed")
	if _phase3:
		_process_reinforcements(delta)
		($Sprite as AnimatedSprite2D).visible = int(_orbit_t * 20.0) % 7 != 0
	queue_redraw()

func take_damage(amount: float) -> bool:
	if _shielded:
		return false
	var killed: bool = super.take_damage(amount)
	if not killed and not _phase3 and hull_current <= data.hull_max * phase3_threshold:
		_enter_phase3()
	return killed

func _enter_phase3() -> void:
	_phase3 = true
	_current_pattern = phase3_pattern
	_burst_index = 0
	if phase3_pattern != null:
		_rng.seed = phase3_pattern.rng_seed
		_burst_timer = 0.5
	set_secondary_pattern(phase3_secondary_pattern)
	($Sprite as AnimatedSprite2D).play("meltdown")

func _process_reinforcements(delta: float) -> void:
	if reinforcement_scene == null:
		return
	_reinforce_timer -= delta
	if _reinforce_timer > 0.0:
		return
	_reinforce_timer = reinforcement_interval
	var rect: Rect2 = get_node("/root/Playfield").rect
	var x: float = rect.position.x + (40.0 if _reinforce_side % 2 == 0 else rect.size.x - 40.0)
	_reinforce_side += 1
	var e: Node2D = reinforcement_scene.instantiate()
	if e is EnemyBase and reinforcement_data != null:
		(e as EnemyBase).data = reinforcement_data
	e.position = get_parent().to_local(Vector2(x, rect.position.y - 20.0))
	get_parent().call_deferred("add_child", e)

func _die() -> void:
	super._die()
	get_tree().call_group("escape_sequence", "begin", global_position)

func _draw() -> void:
	if not _shielded:
		return
	# Shield bubble: a dashed ring that rotates, bright and dim dashes alternating.
	var segs: int = 36
	for i in range(segs):
		if i % 2 == 1:
			continue
		var a0: float = TAU * float(i) / float(segs) + _orbit_t * 0.6
		var a1: float = a0 + TAU / float(segs)
		var p0: Vector2 = Vector2(cos(a0), sin(a0)) * shield_radius
		var p1: Vector2 = Vector2(cos(a1), sin(a1)) * shield_radius
		draw_line(p0.round(), p1.round(), shield_color if (i >> 1) % 2 == 0 else shield_color_dim, 2.0)
