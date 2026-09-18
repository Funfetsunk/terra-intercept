extends Node2D
class_name PlayfieldShake

@export var default_intensity: float = 4.0
@export var default_duration: float = 0.15

var _base_position: Vector2
var _shake_timer: float = 0.0
var _shake_intensity: float = 0.0

@onready var _settings: Node = get_node("/root/Settings")

func _ready() -> void:
	_base_position = position
	add_to_group("playfield_root")

func _process(delta: float) -> void:
	if _shake_timer <= 0.0:
		return
	_shake_timer -= delta
	if _shake_timer <= 0.0:
		position = _base_position
		return
	position = _base_position + Vector2(randf_range(-_shake_intensity, _shake_intensity), randf_range(-_shake_intensity, _shake_intensity))

func shake(intensity: float = -1.0, duration: float = -1.0) -> void:
	if not _settings.screen_shake_enabled:
		return
	_shake_intensity = intensity if intensity > 0.0 else default_intensity
	_shake_timer = duration if duration > 0.0 else default_duration
