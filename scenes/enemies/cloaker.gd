extends EnemyBase

## Cloaker: nearly invisible (a dithered shimmer, `cloaked_visibility`) while it
## drifts into position. Before each attack it decloaks over `decloak_time`
## (the telegraph), fires its aimed spread at full visibility, then re-cloaks
## and repositions. It can be hit at any time, if you can find it.

enum State { MOVE, DECLOAK, RECLOAK }

@export var cloaked_visibility: float = 0.12
@export var decloak_time: float = 0.5
@export var recloak_time: float = 0.4
@export var move_time: float = 1.6
@export var attacks: int = 4
@export var reposition_px: float = 70.0
@export var top_band: Vector2 = Vector2(50.0, 170.0)
@export var exit_speed: float = 70.0

var _state: State = State.MOVE
var _timer: float = 0.0
var _attacks_done: int = 0
var _from: Vector2 = Vector2.ZERO
var _to: Vector2 = Vector2.ZERO
var _move_rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var _sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	super._ready()
	_move_rng.seed = int(absf(global_position.x) * 13.0 + absf(global_position.y) * 7.0) + 5
	_set_visibility(cloaked_visibility)
	_pick_target()

func _set_visibility(v: float) -> void:
	var mat: ShaderMaterial = _sprite.material as ShaderMaterial
	if mat != null:
		mat.set_shader_parameter("visibility", v)

func _pick_target() -> void:
	var rect: Rect2 = get_node("/root/Playfield").rect
	_from = global_position
	var x: float = clampf(_from.x + _move_rng.randf_range(-reposition_px, reposition_px), rect.position.x + 30.0, rect.end.x - 30.0)
	var y: float = rect.position.y + _move_rng.randf_range(top_band.x, top_band.y)
	_to = Vector2(x, y)
	_timer = 0.0
	_state = State.MOVE

func _process_movement(delta: float) -> void:
	_timer += delta
	if _attacks_done >= attacks and _state == State.MOVE:
		global_position.y -= exit_speed * delta
		if global_position.y < get_node("/root/Playfield").rect.position.y - 30.0:
			queue_free()
		return
	match _state:
		State.MOVE:
			var t: float = smoothstep(0.0, 1.0, minf(1.0, _timer / move_time))
			global_position = _from.lerp(_to, t).round()
			if _timer >= move_time:
				_state = State.DECLOAK
				_timer = 0.0
		State.DECLOAK:
			_set_visibility(lerpf(cloaked_visibility, 1.0, minf(1.0, _timer / decloak_time)))
			if _timer >= decloak_time:
				if data.pattern != null:
					_fire_burst(data.pattern)
				_attacks_done += 1
				_state = State.RECLOAK
				_timer = 0.0
		State.RECLOAK:
			_set_visibility(lerpf(1.0, cloaked_visibility, minf(1.0, _timer / recloak_time)))
			if _timer >= recloak_time:
				_pick_target()

func _process_pattern(_delta: float) -> void:
	pass
