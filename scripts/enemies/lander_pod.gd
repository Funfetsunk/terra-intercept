extends EnemyBase

@export var fall_speed: float = 30.0
@export var land_y: float = 160.0
## How long the pod stays harmless while it unfolds. Matches the length of the
## "unfold" animation (3 frames at 8fps) so it starts firing as the legs lock.
@export var unfold_delay: float = 0.375

enum _State { FALLING, UNFOLDING, ACTIVE }
var _state: _State = _State.FALLING
var _unfold_timer: float = 0.0

@onready var _sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	super._ready()
	_sprite.play("falling")

func _process_movement(delta: float) -> void:
	if _state == _State.FALLING:
		global_position.y += fall_speed * delta
		if global_position.y >= land_y:
			global_position.y = land_y
			_state = _State.UNFOLDING
			_unfold_timer = unfold_delay
			_sprite.play("unfold")
	elif _state == _State.UNFOLDING:
		_unfold_timer -= delta
		if _unfold_timer <= 0.0:
			_state = _State.ACTIVE
			_sprite.play("active")

func _process_pattern(delta: float) -> void:
	if _state != _State.ACTIVE:
		return
	super._process_pattern(delta)
