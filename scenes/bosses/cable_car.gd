extends "res://scenes/bosses/boss_part.gd"

## Armoured cable car on the Sugarloaf boss: a BossPart that rides back and
## forth along the cable between `from_point` and `to_point` (relative to the
## boss body), taking `trip_time` each way. `start_offset` (0-1) staggers cars.

@export var from_point: Vector2 = Vector2(-60, 10)
@export var to_point: Vector2 = Vector2(60, -10)
@export var trip_time: float = 3.0
@export var start_offset: float = 0.0
@export var speed_scale: float = 1.0

var _t: float = 0.0

func _ready() -> void:
	super._ready()
	_t = start_offset * trip_time * 2.0

func _process_movement(delta: float) -> void:
	_t += delta * speed_scale
	var phase: float = fposmod(_t, trip_time * 2.0) / trip_time
	var f: float = phase if phase <= 1.0 else 2.0 - phase
	position = from_point.lerp(to_point, smoothstep(0.0, 1.0, f)).round()
