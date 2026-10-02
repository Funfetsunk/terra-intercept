extends "res://scenes/bosses/stage_boss.gd"

## Mining crawler (Grand Canyon boss): a huge excavator wedged across the
## canyon. Its drum cutters and turrets are BossPart children (shoot them off);
## the body is the core. Once in place it grinds forward towards the player to
## `advance_y` over `advance_time`, holds, then backs off to its start line,
## repeating; faster in phase 2. When it dies the remaining parts explode.

@export var advance_y: float = 150.0
@export var advance_time: float = 4.0
@export var hold_time: float = 1.5
@export var retreat_time: float = 3.0
@export var rest_time: float = 2.5
@export var phase2_time_scale: float = 0.7
@export var grind_shake_px: float = 1.0

var _cycle: float = 0.0
var _in_place: bool = false
var _base_x: float = 0.0

func _ready() -> void:
	super._ready()
	_base_x = global_position.x

func _process_movement(delta: float) -> void:
	if not _in_place:
		super._process_movement(delta)
		_in_place = global_position.y >= hover_y
		return
	var scale_t: float = phase2_time_scale if _phase2_active else 1.0
	var total: float = (advance_time + hold_time + retreat_time + rest_time) * scale_t
	_cycle = fposmod(_cycle + delta, total)
	var t: float = _cycle / scale_t
	var y: float = hover_y
	if t < advance_time:
		y = lerpf(hover_y, advance_y, smoothstep(0.0, 1.0, t / advance_time))
	elif t < advance_time + hold_time:
		y = advance_y
	elif t < advance_time + hold_time + retreat_time:
		y = lerpf(advance_y, hover_y, smoothstep(0.0, 1.0, (t - advance_time - hold_time) / retreat_time))
	global_position.y = roundf(y)
	# The cutters grinding make the whole rig judder a pixel side to side.
	global_position.x = roundf(_base_x + (grind_shake_px if int(t * 20.0) % 2 == 0 else -grind_shake_px))

func _die() -> void:
	for child: Node in get_children():
		if child.has_method("explode"):
			child.explode()
	super._die()
