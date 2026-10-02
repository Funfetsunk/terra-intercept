extends "res://scenes/bosses/stage_boss.gd"

## Sugarloaf fortress (Rio boss): the mountain body is the core and runs the
## usual two phases. Armoured cable cars (CableCar children) shuttle along the
## cables strung between `cable_points` (relative to the body), firing as they
## go; they can be shot off. Phase 2 speeds the cars up. The cables are drawn
## here as two-tone lines. When it dies, the remaining cars explode.

## Each pair of points (0-1, 2-3, ...) is one cable.
@export var cable_points: PackedVector2Array = PackedVector2Array([Vector2(-62, 6), Vector2(58, -22), Vector2(-62, 22), Vector2(58, -6)])
@export var cable_color: Color = Color("2e222f")
@export var cable_highlight: Color = Color("7f708a")
@export var phase2_car_speed: float = 1.5

func _ready() -> void:
	super._ready()
	queue_redraw()

func take_damage(amount: float) -> bool:
	var was_phase2: bool = _phase2_active
	var killed: bool = super.take_damage(amount)
	if _phase2_active and not was_phase2:
		for child: Node in get_children():
			if "speed_scale" in child:
				child.set("speed_scale", phase2_car_speed)
	return killed

func _die() -> void:
	for child: Node in get_children():
		if child.has_method("explode"):
			child.explode()
	super._die()

func _draw() -> void:
	var i: int = 0
	while i + 1 < cable_points.size():
		var a: Vector2 = cable_points[i]
		var b: Vector2 = cable_points[i + 1]
		draw_line(a, b, cable_color, 2.0)
		draw_line(a + Vector2(0, -1), b + Vector2(0, -1), cable_highlight, 1.0)
		i += 2
