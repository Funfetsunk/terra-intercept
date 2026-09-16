extends Node

@export var rect: Rect2 = Rect2(140, 0, 360, 360)

func relative_to_world(relative_position: Vector2) -> Vector2:
	return rect.position + relative_position * rect.size

func world_to_relative(world_position: Vector2) -> Vector2:
	return (world_position - rect.position) / rect.size
