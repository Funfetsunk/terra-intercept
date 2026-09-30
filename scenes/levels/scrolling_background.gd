extends Node2D

@export var mission: MissionData

func _ready() -> void:
	for child: Node in get_children():
		if child is BackgroundLayer:
			(child as BackgroundLayer).base_speed = mission.background_scroll_speed

## Overrides every layer's base speed (layers keep their own multipliers).
func set_scroll_speed(speed: float) -> void:
	for child: Node in get_children():
		if child is BackgroundLayer:
			(child as BackgroundLayer).base_speed = speed

## Current scroll speed of the ground layer (the first layer), in pixels per second.
func get_ground_speed() -> float:
	for child: Node in get_children():
		if child is BackgroundLayer:
			var layer: BackgroundLayer = child as BackgroundLayer
			return layer.base_speed * layer.scroll_speed_multiplier
	return 0.0
