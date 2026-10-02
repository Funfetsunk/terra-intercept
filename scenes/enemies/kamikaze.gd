extends EnemyBase

## Kamikaze: drops to `hover_y`, then arms. Its sprite flashes (the `arming`
## animation) while a lock-on line tracks the player for `arm_time`; the line
## locks for `lock_time`, then it dives along it at `dive_speed`. It bursts
## into `burst_pattern` (a small ring) when shot down or when it reaches the
## player; a dive that misses flies off the screen.

enum State { ENTER, ARM, DIVE }

@export var hover_y: float = 70.0
@export var arm_time: float = 0.9
@export var lock_time: float = 0.25
@export var dive_speed: float = 230.0
@export var burst_pattern: BulletPatternData
@export var impact_radius: float = 10.0
@export var line_color: Color = Color("e83b3b")
@export var line_length: float = 90.0

var _state: State = State.ENTER
var _timer: float = 0.0
var _dir: Vector2 = Vector2.DOWN
var _burst_rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var _sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	super._ready()
	if burst_pattern != null:
		_burst_rng.seed = burst_pattern.rng_seed

func _process_movement(delta: float) -> void:
	match _state:
		State.ENTER:
			global_position.y = minf(hover_y, global_position.y + data.move_speed * delta)
			if global_position.y >= hover_y:
				_state = State.ARM
				_timer = 0.0
				_sprite.play("arming")
		State.ARM:
			_timer += delta
			if _timer < arm_time - lock_time:
				_dir = (_bullets.get_player_position() - global_position).normalized()
			if _timer >= arm_time:
				_state = State.DIVE
				_sprite.play("idle")
		State.DIVE:
			global_position += _dir * dive_speed * delta
			var player: Node2D = _bullets.get_registered_player()
			if player != null and player.visible and global_position.distance_to(player.global_position) <= impact_radius:
				player.take_hit(data.contact_damage)
				_die()
				return
			if not get_node("/root/Playfield").rect.grow(30.0).has_point(global_position):
				queue_free()
	queue_redraw()

func _process_pattern(_delta: float) -> void:
	pass

func _die() -> void:
	if burst_pattern != null:
		_fire_pattern(burst_pattern, 0, _burst_rng)
	super._die()

func _draw() -> void:
	if _state != State.ARM:
		return
	if _timer >= arm_time - lock_time and int(_timer / 0.05) % 2 == 1:
		return
	draw_line(Vector2.ZERO, (_dir * line_length).round(), line_color, 1.0)
