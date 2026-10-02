extends EnemyBase

## Sniper: drops to `hold_y` near the top and holds. Each shot is telegraphed by
## a laser line from the sniper towards the player: it tracks the player, thin
## at first, thickens, then locks for `lock_time` before a fast shot fires along
## it. After `shots` shots it climbs back off the top. Uses data.pattern for the
## shot's speed, size, texture and damage (burst_size bullets in a tight line).

enum State { ENTER, AIM, COOLDOWN, LEAVE }

@export var hold_y: float = 60.0
@export var aim_time: float = 0.8
## The line stops tracking this long before the shot, so a moving player can dodge.
@export var lock_time: float = 0.25
@export var cooldown_time: float = 1.1
@export var shots: int = 3
@export var exit_speed: float = 60.0
@export var line_color: Color = Color("f9c22b")
@export var line_length: float = 420.0
## Spacing in seconds between the bullets of one shot (they follow each other down the line).
@export var shot_spacing: float = 0.05

var _state: State = State.ENTER
var _timer: float = 0.0
var _aim_dir: Vector2 = Vector2.DOWN
var _shots_fired: int = 0
var _queued: int = 0
var _queue_timer: float = 0.0

func _process_movement(delta: float) -> void:
	match _state:
		State.ENTER:
			global_position.y = minf(hold_y, global_position.y + data.move_speed * delta)
			if global_position.y >= hold_y:
				_start_aim()
		State.AIM:
			_timer += delta
			if _timer < aim_time - lock_time:
				_aim_dir = (_bullets.get_player_position() - global_position).normalized()
			if _timer >= aim_time:
				_fire()
		State.COOLDOWN:
			_timer += delta
			if _timer >= cooldown_time:
				if _shots_fired >= shots:
					_state = State.LEAVE
				else:
					_start_aim()
		State.LEAVE:
			global_position.y -= exit_speed * delta
			if global_position.y < get_node("/root/Playfield").rect.position.y - 30.0:
				queue_free()
	_process_queue(delta)
	queue_redraw()

func _process_pattern(_delta: float) -> void:
	pass

func _start_aim() -> void:
	_state = State.AIM
	_timer = 0.0
	_aim_dir = (_bullets.get_player_position() - global_position).normalized()

func _fire() -> void:
	_shots_fired += 1
	_queued = maxi(1, data.pattern.burst_size if data.pattern != null else 1)
	_queue_timer = 0.0
	_state = State.COOLDOWN
	_timer = 0.0

func _process_queue(delta: float) -> void:
	if _queued <= 0 or data.pattern == null:
		return
	_queue_timer -= delta
	if _queue_timer <= 0.0:
		var p: BulletPatternData = data.pattern
		_bullets.spawn_enemy_bullet(global_position, _aim_dir, p.bullet_speed, p.bullet_radius, p.bullet_color, p.bullet_lifetime, p.bullet_damage, p.bullet_texture)
		_queued -= 1
		_queue_timer = shot_spacing

func _draw() -> void:
	if _state != State.AIM:
		return
	var t: float = _timer / aim_time
	var width: float = 1.0 if t < 0.5 else 2.0
	# Blink while locked so the "about to fire" moment is unmistakable.
	if _timer >= aim_time - lock_time and int(_timer / 0.05) % 2 == 1:
		return
	var end: Vector2 = _aim_dir * line_length
	draw_line(Vector2.ZERO, end.round(), line_color, width)
