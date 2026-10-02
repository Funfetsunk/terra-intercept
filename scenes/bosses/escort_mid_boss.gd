extends "res://scenes/bosses/mid_boss.gd"

## Escort mothership: the column 4–6 mid-boss. Behaves like the Sentinel (two
## phases, hover, music) and also launches `launch_scene` from its side bays
## every `launch_interval`, alternating bays.

@export var launch_scene: PackedScene
@export var launch_interval: float = 3.5
@export var phase2_launch_interval: float = 2.5
@export var bay_offsets: PackedVector2Array = PackedVector2Array([Vector2(-24, 8), Vector2(24, 8)])

var _launch_timer: float = 2.0
var _bay: int = 0

func _process_pattern(delta: float) -> void:
	super._process_pattern(delta)
	if launch_scene == null or global_position.y < hover_y:
		return
	_launch_timer -= delta
	if _launch_timer <= 0.0:
		_launch_timer = phase2_launch_interval if _phase2_active else launch_interval
		var child: Node2D = launch_scene.instantiate()
		child.position = get_parent().to_local(global_position + bay_offsets[_bay % bay_offsets.size()])
		get_parent().call_deferred("add_child", child)
		_bay += 1
