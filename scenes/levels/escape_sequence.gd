extends Node2D

## The homeworld escape: an enemy-free sprint back through the collapsing
## portal. Triggered by the Gate Core's death (group "escape_sequence").
## After `explosion_delay` the screen flashes white, the ground swaps to the
## portal tunnel and scrolls at `tunnel_scroll_speed`. A countdown starts at
## `time_limit`; collapsing debris falls through the tunnel and each hit costs
## `time_penalty` seconds (no damage). After `sprint_duration` the exit portal
## opens, the time left is paid out as a score bonus and the mission completes
## (the victory flyout steers into the portal).

@export var explosion_delay: float = 2.0
@export var tunnel_texture_a: Texture2D
@export var tunnel_texture_b: Texture2D
@export var tunnel_scroll_speed: float = 240.0
@export var time_limit: float = 40.0
@export var sprint_duration: float = 30.0
@export var time_penalty: float = 3.0
@export var bonus_per_second: int = 1000
@export var debris_scenes: Array[PackedScene] = []
@export var debris_interval: float = 0.45
@export var debris_hit_radius: float = 10.0
@export var debris_speed_range: Vector2 = Vector2(260.0, 380.0)
@export var exit_portal_scene: PackedScene
@export var flash_color: Color = Color("ffffff")
@export var rng_seed: int = 909

enum State { IDLE, WAIT, SPRINT, DONE }

var _state: State = State.IDLE
var _t: float = 0.0
var _time_left: float = 0.0
var _spawn_timer: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _debris: Array[Node2D] = []
var _speeds: Array[float] = []

@onready var _hud: CanvasLayer = $EscapeHud
@onready var _timer_label: Label = $EscapeHud/TimerLabel
@onready var _caption: Label = $EscapeHud/Caption

func _ready() -> void:
	add_to_group("escape_sequence")
	_hud.visible = false
	_rng.seed = rng_seed

func begin(_core_position: Vector2) -> void:
	if _state != State.IDLE:
		return
	_state = State.WAIT
	_t = 0.0

func _physics_process(delta: float) -> void:
	match _state:
		State.WAIT:
			_t += delta
			if _t >= explosion_delay:
				_start_sprint()
		State.SPRINT:
			_t += delta
			_time_left = maxf(0.0, _time_left - delta)
			_update_debris(delta)
			_spawn_timer -= delta
			if _spawn_timer <= 0.0 and _t < sprint_duration - 2.0:
				_spawn_timer = debris_interval
				_spawn_debris()
			_timer_label.text = "%05.2f" % _time_left
			if _t >= sprint_duration:
				_finish()

func _start_sprint() -> void:
	var fade: CanvasLayer = get_tree().current_scene.get_node_or_null("ScreenFade")
	var bullets: Node = get_node("/root/BulletManager")
	bullets.clear_enemy_bullets_in_rect(get_node("/root/Playfield").rect.grow(60.0))
	var fade_rect: ColorRect = null
	var old_color: Color = Color.BLACK
	if fade != null:
		fade_rect = fade.get_node("Fade")
		var mat: ShaderMaterial = fade_rect.material as ShaderMaterial
		old_color = mat.get_shader_parameter("fade_color")
		mat.set_shader_parameter("fade_color", flash_color)
		fade.set("fade_out_duration", 0.35)
		await fade.fade_out()
	# Into the tunnel.
	var bg: Node = get_tree().get_first_node_in_group("scrolling_background")
	for layer: Node in bg.get_children():
		if layer is BackgroundLayer and layer.name == "FarLayer":
			layer.set("_swaps_left", 0)
			(layer.get_node("PanelA") as TextureRect).texture = tunnel_texture_a
			(layer.get_node("PanelB") as TextureRect).texture = tunnel_texture_b
	bg.set_scroll_speed(tunnel_scroll_speed)
	for child: Node in get_parent().get_children():
		if child is EnemyBase:
			child.queue_free()
	_hud.visible = true
	_caption.text = "PORTAL COLLAPSING!"
	_time_left = time_limit
	_t = 0.0
	_state = State.SPRINT
	if fade != null:
		fade.set("fade_in_duration", 0.5)
		await fade.fade_in()
		(fade_rect.material as ShaderMaterial).set_shader_parameter("fade_color", old_color)

func _spawn_debris() -> void:
	if debris_scenes.is_empty():
		return
	var rect: Rect2 = get_node("/root/Playfield").rect
	var d: Node2D = debris_scenes[_rng.randi_range(0, debris_scenes.size() - 1)].instantiate()
	d.global_position = Vector2(_rng.randf_range(rect.position.x + 20.0, rect.end.x - 20.0), rect.position.y - 20.0).round()
	get_parent().add_child(d)
	_debris.append(d)
	_speeds.append(_rng.randf_range(debris_speed_range.x, debris_speed_range.y))

func _update_debris(delta: float) -> void:
	var rect: Rect2 = get_node("/root/Playfield").rect
	var player: Node2D = get_node("/root/BulletManager").get_registered_player()
	var i: int = 0
	while i < _debris.size():
		var d: Node2D = _debris[i]
		d.global_position.y = roundf(d.global_position.y + _speeds[i] * delta)
		var hit: bool = player != null and player.visible and d.global_position.distance_to(player.global_position) <= debris_hit_radius
		if hit:
			_time_left = maxf(0.0, _time_left - time_penalty)
			get_tree().call_group("playfield_root", "shake")
			_caption.text = "-%d SEC" % int(time_penalty)
		if hit or d.global_position.y > rect.end.y + 30.0:
			d.queue_free()
			_debris.remove_at(i)
			_speeds.remove_at(i)
		else:
			i += 1

func _finish() -> void:
	_state = State.DONE
	for d: Node2D in _debris:
		if is_instance_valid(d):
			d.queue_free()
	_debris.clear()
	var bonus: int = int(_time_left * float(bonus_per_second))
	_caption.text = "TIME BONUS %d" % bonus
	var game_state: Node = get_node("/root/GameState")
	game_state.add_score_bonus(bonus)
	if exit_portal_scene != null:
		var portal: Node2D = exit_portal_scene.instantiate()
		var rect: Rect2 = get_node("/root/Playfield").rect
		portal.position = get_parent().to_local(Vector2(rect.get_center().x, rect.position.y + 44.0))
		portal.add_to_group("victory_target")
		get_parent().add_child(portal)
	game_state.complete_mission()
