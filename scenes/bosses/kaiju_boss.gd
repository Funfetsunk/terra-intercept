extends "res://scenes/bosses/stage_boss.gd"

## Kaiju mech (Tokyo boss): the body is the core and runs the usual two phases.
## Its arms and back cannons are BossPart children that move with it, fire
## their own patterns and can be shot off. Once in place it stomps from side to
## side: a slow sway with a small bob on each step. When it dies, the remaining
## parts explode with it.

@export var sway_px: float = 70.0
@export var sway_hz: float = 0.12
@export var phase2_sway_hz: float = 0.2
@export var step_bob_px: float = 2.0
@export var steps_per_sway: float = 6.0

var _sway_t: float = 0.0
var _base_x: float = 0.0
var _in_place: bool = false

func _ready() -> void:
	super._ready()
	_base_x = global_position.x

func _process_movement(delta: float) -> void:
	if not _in_place:
		super._process_movement(delta)
		_in_place = global_position.y >= hover_y
		return
	_sway_t += (phase2_sway_hz if _phase2_active else sway_hz) * delta
	var phase: float = _sway_t * TAU
	global_position.x = roundf(_base_x + sin(phase) * sway_px)
	# A stomp: drop a couple of pixels at the start of each step.
	var step: float = fposmod(_sway_t * steps_per_sway, 1.0)
	global_position.y = roundf(hover_y + (step_bob_px if step < 0.15 else 0.0))

func _die() -> void:
	for child: Node in get_children():
		if child.has_method("explode"):
			child.explode()
	super._die()
