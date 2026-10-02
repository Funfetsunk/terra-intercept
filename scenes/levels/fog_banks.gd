extends Node2D

## Ice-fog banks (the Siberia twist). The banks come from the mission's
## `fog_banks`: each is (distance in px where the bank's leading edge reaches the
## bottom of the screen at normal scroll, length in px, density 0-1). They drift
## down a little faster than the ground and are drawn over enemies and bullets
## by the `Fog` ColorRect's dither shader. Keep this node's z_index above the
## gameplay and the player's above this.

@export var mission: MissionData
## Fog drifts this much faster than the ground, so banks visibly roll past.
@export var drift_multiplier: float = 1.25
## Soft edge of each bank, in pixels.
@export var feather_px: float = 72.0
## Neon flicker (Tokyo): density pulses by up to this fraction...
@export var flicker_strength: float = 0.0
@export var flicker_hz: float = 1.3
## ...and briefly cuts out (to `dropout_density`) for `dropout_time` every `dropout_period` seconds.
@export var dropout_period: float = 0.0
@export var dropout_time: float = 0.12
@export var dropout_density: float = 0.3

const MAX_BANKS: int = 4

var _travel: float = 0.0
var _clock: float = 0.0
var _ground: Node = null
var _rect: Rect2 = Rect2()

@onready var _fog: ColorRect = $Fog

func _ready() -> void:
	_ground = get_tree().get_first_node_in_group("scrolling_background")
	_rect = get_node("/root/Playfield").rect
	var game_state: Node = get_node("/root/GameState")
	_travel = mission.get_section_start_time(game_state.restart_section) * mission.background_scroll_speed * drift_multiplier
	_fog.position = to_local(_rect.position)
	_fog.size = _rect.size
	(_fog.material as ShaderMaterial).set_shader_parameter("rect_size", _rect.size)

func _physics_process(delta: float) -> void:
	var ground_speed: float = 0.0
	if _ground != null:
		ground_speed = _ground.get_ground_speed()
	# Fog still drifts slowly while a boss has the ground locked.
	_travel += maxf(ground_speed, mission.background_scroll_speed * 0.25) * drift_multiplier * delta
	_clock += delta
	_update_banks()

func _update_banks() -> void:
	var visible_banks: Array[Vector4] = []
	for bank: Vector3 in mission.fog_banks:
		var bottom: float = _rect.size.y - (bank.x - _travel)
		var top: float = bottom - bank.y
		if bottom < 0.0 or top > _rect.size.y:
			continue
		visible_banks.append(Vector4(top, bottom, bank.z, feather_px))
		if visible_banks.size() >= MAX_BANKS:
			break
	var mat: ShaderMaterial = _fog.material as ShaderMaterial
	var packed: Array[Vector4] = []
	for i in range(MAX_BANKS):
		packed.append(visible_banks[i] if i < visible_banks.size() else Vector4.ZERO)
	mat.set_shader_parameter("banks", packed)
	mat.set_shader_parameter("bank_count", visible_banks.size())
	var density_mult: float = 1.0 - flicker_strength * (0.5 + 0.5 * sin(_clock * TAU * flicker_hz))
	if dropout_period > 0.0 and fposmod(_clock, dropout_period) < dropout_time:
		density_mult = dropout_density
	mat.set_shader_parameter("density_scale", density_mult)
	_fog.visible = not visible_banks.is_empty()
