extends CanvasLayer

## Full-screen dithered fade. Instance it in any scene that should fade in on
## arrival, or that needs to fade out before changing scene. It keeps running
## while the tree is paused.

signal fade_finished

@export var fade_in_on_ready: bool = true
@export var fade_in_duration: float = 0.6
@export var fade_out_duration: float = 0.8

@onready var _rect: ColorRect = $Fade

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if fade_in_on_ready:
		_set_progress(1.0)
		fade_in()
	else:
		_set_progress(0.0)

## Dissolve from the fade colour to the scene.
func fade_in() -> void:
	await _tween_to(0.0, fade_in_duration)

## Dissolve from the scene to the fade colour. Await this before changing scene.
func fade_out() -> void:
	await _tween_to(1.0, fade_out_duration)

func _tween_to(target: float, duration: float) -> void:
	_rect.visible = true
	var tween: Tween = create_tween()
	tween.tween_method(_set_progress, _get_progress(), target, duration)
	await tween.finished
	_rect.visible = target > 0.0
	fade_finished.emit()

func _set_progress(value: float) -> void:
	(_rect.material as ShaderMaterial).set_shader_parameter("progress", value)
	_rect.visible = value > 0.0

func _get_progress() -> float:
	return (_rect.material as ShaderMaterial).get_shader_parameter("progress")
