extends Node2D

signal shield_changed(current: float, max_value: float)
signal hull_changed(current: float, max_value: float)
signal hull_depleted
signal focus_changed(current: float, max_value: float)
signal special_charges_changed(current: int, max_value: int)
signal special_fired
signal respawned

@export var data: ShipData
@export var playfield_rect: Rect2 = Rect2(12, 12, 616, 336)

var shield_current: float = 0.0
var hull_current: float = 0.0
var special_charges: int = 0

var _spawn_origin: Vector2 = Vector2.ZERO
var _shield_recharge_timer: float = 0.0
var _hull_invincible_timer: float = 0.0
var _respawn_invincible_timer: float = 0.0
var _special_invincible_timer: float = 0.0
var _special_progress: float = 0.0
var _fire_cooldown: float = 0.0
var _focus_meter: float = 0.0
var _focus_refill_wait_timer: float = 0.0
var _is_focused: bool = false

@onready var _bullets: Node = get_node("/root/BulletManager")
@onready var _game_state: Node = get_node("/root/GameState")
@onready var _hitbox: Area2D = $Hitbox
@onready var _hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var _focus_visual: CanvasItem = $FocusHitboxVisual
@onready var _special_vfx: Node2D = $SpecialCircleVFX

func _ready() -> void:
	_spawn_origin = global_position
	shield_current = data.shield_max
	hull_current = data.hull_max
	_focus_meter = data.focus_meter_max
	_bullets.register_player(self, data.normal_hitbox_radius)
	_game_state.register_player(self)
	shield_changed.emit(shield_current, data.shield_max)
	hull_changed.emit(hull_current, data.hull_max)
	focus_changed.emit(_focus_meter, data.focus_meter_max)
	special_charges_changed.emit(special_charges, data.special_charge_max)

func _exit_tree() -> void:
	_bullets.unregister_player()

func _physics_process(delta: float) -> void:
	_process_focus(delta)
	_process_movement(delta)
	_process_timers(delta)
	_process_shield_recharge(delta)
	_process_fire(delta)
	if Input.is_action_just_pressed("p1_special"):
		_try_fire_special()

func _process_movement(delta: float) -> void:
	var move_vec: Vector2 = Input.get_vector("p1_move_left", "p1_move_right", "p1_move_up", "p1_move_down")
	var speed: float = data.focus_move_speed if _is_focused else data.move_speed
	global_position += move_vec * speed * delta
	global_position.x = clamp(global_position.x, playfield_rect.position.x, playfield_rect.end.x)
	global_position.y = clamp(global_position.y, playfield_rect.position.y, playfield_rect.end.y)

func _process_focus(delta: float) -> void:
	var held: bool = Input.is_action_pressed("p1_focus")
	if held and _focus_meter > 0.0:
		_is_focused = true
		_focus_meter = max(0.0, _focus_meter - data.focus_drain_rate * delta)
		_focus_refill_wait_timer = data.focus_refill_delay
	else:
		_is_focused = false
		if _focus_refill_wait_timer > 0.0:
			_focus_refill_wait_timer -= delta
		elif _focus_meter < data.focus_meter_max:
			_focus_meter = min(data.focus_meter_max, _focus_meter + data.focus_refill_rate * delta)
	_focus_visual.visible = _is_focused
	var hitbox_radius: float = data.focus_hitbox_radius if _is_focused else data.normal_hitbox_radius
	_bullets.set_player_hitbox_radius(hitbox_radius)
	if _hitbox_shape.shape is CircleShape2D:
		(_hitbox_shape.shape as CircleShape2D).radius = hitbox_radius
	focus_changed.emit(_focus_meter, data.focus_meter_max)

func _process_timers(delta: float) -> void:
	if _hull_invincible_timer > 0.0:
		_hull_invincible_timer = max(0.0, _hull_invincible_timer - delta)
	if _respawn_invincible_timer > 0.0:
		_respawn_invincible_timer = max(0.0, _respawn_invincible_timer - delta)
	if _special_invincible_timer > 0.0:
		_special_invincible_timer = max(0.0, _special_invincible_timer - delta)

func _process_shield_recharge(delta: float) -> void:
	if _shield_recharge_timer > 0.0:
		_shield_recharge_timer -= delta
	elif shield_current < data.shield_max:
		shield_current = min(data.shield_max, shield_current + data.shield_recharge_rate * delta)
		shield_changed.emit(shield_current, data.shield_max)

func _get_fire_input() -> Dictionary:
	var stick: Vector2 = Input.get_vector("p1_aim_left", "p1_aim_right", "p1_aim_up", "p1_aim_down")
	if stick.length() > 0.15:
		return {"firing": true, "direction": stick.normalized()}
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var to_mouse: Vector2 = get_global_mouse_position() - global_position
		if to_mouse.length() > 0.001:
			return {"firing": true, "direction": to_mouse.normalized()}
	return {"firing": false, "direction": Vector2.ZERO}

func _process_fire(delta: float) -> void:
	if _fire_cooldown > 0.0:
		_fire_cooldown -= delta
	var fire_input: Dictionary = _get_fire_input()
	if not fire_input["firing"]:
		return
	if _fire_cooldown > 0.0:
		return
	var direction: Vector2 = fire_input["direction"]
	_bullets.spawn_player_bullet(global_position, direction, data.bullet_speed, data.bullet_radius, data.bullet_color, 2.0, data.bullet_damage)
	_fire_cooldown = 1.0 / data.fire_rate

func take_hit(damage: float) -> void:
	if _is_invincible():
		return
	if shield_current > 0.0:
		shield_current = max(0.0, shield_current - damage)
		_shield_recharge_timer = data.shield_recharge_delay
		shield_changed.emit(shield_current, data.shield_max)
	else:
		hull_current = max(0.0, hull_current - damage)
		_hull_invincible_timer = data.hull_hit_invincibility_duration
		hull_changed.emit(hull_current, data.hull_max)
		if hull_current <= 0.0:
			hull_depleted.emit()

func _is_invincible() -> bool:
	return _hull_invincible_timer > 0.0 or _respawn_invincible_timer > 0.0 or _special_invincible_timer > 0.0

func respawn() -> void:
	global_position = _spawn_origin
	shield_current = data.shield_max
	hull_current = data.hull_max
	_respawn_invincible_timer = data.respawn_invincibility_duration
	_bullets.clear_enemy_bullets_in_circle(global_position, data.respawn_bullet_clear_radius)
	shield_changed.emit(shield_current, data.shield_max)
	hull_changed.emit(hull_current, data.hull_max)
	respawned.emit()

func on_damage_dealt(damage: float, was_kill: bool) -> void:
	if special_charges >= data.special_charge_max:
		return
	_special_progress += damage * data.special_charge_per_damage
	if was_kill:
		_special_progress += data.special_charge_per_kill_bonus
	var gained: bool = false
	while _special_progress >= 1.0 and special_charges < data.special_charge_max:
		_special_progress -= 1.0
		special_charges += 1
		gained = true
	if gained:
		special_charges_changed.emit(special_charges, data.special_charge_max)

func _try_fire_special() -> void:
	if special_charges <= 0:
		return
	special_charges -= 1
	special_charges_changed.emit(special_charges, data.special_charge_max)
	_bullets.clear_enemy_bullets_in_circle(global_position, data.special_radius)
	_bullets.damage_enemies_in_circle(global_position, data.special_radius, data.special_damage)
	_special_invincible_timer = data.special_duration
	_special_vfx.play(data.special_radius, data.special_duration)
	special_fired.emit()

func get_hitbox_radius() -> float:
	return data.focus_hitbox_radius if _is_focused else data.normal_hitbox_radius
