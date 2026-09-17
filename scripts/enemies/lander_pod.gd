extends EnemyBase

@export var fall_speed: float = 30.0
@export var land_y: float = 160.0
@export var unfold_delay: float = 0.1
@export var active_color: Color = Color(0.9, 0.3, 0.15, 1.0)

enum _State { FALLING, UNFOLDING, ACTIVE }
var _state: _State = _State.FALLING
var _unfold_timer: float = 0.0

func _process_movement(delta: float) -> void:
	if _state == _State.FALLING:
		global_position.y += fall_speed * delta
		if global_position.y >= land_y:
			global_position.y = land_y
			_state = _State.UNFOLDING
			_unfold_timer = unfold_delay
	elif _state == _State.UNFOLDING:
		_unfold_timer -= delta
		if _unfold_timer <= 0.0:
			_state = _State.ACTIVE
			$Sprite.modulate = active_color

func _process_pattern(delta: float) -> void:
	if _state != _State.ACTIVE:
		return
	super._process_pattern(delta)
