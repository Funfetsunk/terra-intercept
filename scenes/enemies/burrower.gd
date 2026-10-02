extends EnemyBase

## Burrower: spawns hidden under the terrain at its spawn position and rides
## the ground down the screen. A puff and a shadow mark the spot for
## `telegraph_duration`, then it surfaces, fires `surface_pattern` once (a burst
## ring) and keeps firing its aimed pattern while the ground carries it away.
## It can't be hit, and doesn't touch the player, until it surfaces.

enum State { TELEGRAPH, SURFACED }

@export var telegraph_duration: float = 0.8
## Fired once, the moment the burrower breaks the surface.
@export var surface_pattern: BulletPatternData
@export var puff_blink_interval: float = 0.1

var _state: State = State.TELEGRAPH
var _timer: float = 0.0
var _ground: Node = null
var _surface_rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _puff: AnimatedSprite2D = $Puff
@onready var _shadow: Sprite2D = $Shadow

func _ready() -> void:
	super._ready()
	_ground = get_tree().get_first_node_in_group("scrolling_background")
	_sprite.visible = false
	_puff.visible = true
	_puff.play("puff")
	_shadow.visible = true
	if surface_pattern != null:
		_surface_rng.seed = surface_pattern.rng_seed

func _process_movement(delta: float) -> void:
	var speed: float = 0.0
	if _ground != null:
		speed = _ground.get_ground_speed()
	global_position.y += speed * delta
	if global_position.y > despawn_y:
		queue_free()
		return
	if _state == State.TELEGRAPH:
		_timer += delta
		_shadow.visible = int(_timer / puff_blink_interval) % 2 == 0
		if _timer >= telegraph_duration:
			_surface()

func _surface() -> void:
	_state = State.SURFACED
	_puff.visible = false
	_shadow.visible = false
	_sprite.visible = true
	_sprite.play("idle")
	if surface_pattern != null:
		_fire_pattern(surface_pattern, 0, _surface_rng)

func _process_pattern(delta: float) -> void:
	if _state == State.SURFACED:
		super._process_pattern(delta)

func get_hitbox_radius() -> float:
	# Underground: out of reach of bullets and contact checks.
	return data.hitbox_radius if _state == State.SURFACED else -1000.0
