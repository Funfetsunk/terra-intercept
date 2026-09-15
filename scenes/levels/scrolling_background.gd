extends Node2D

@export var mission: MissionData

func _ready() -> void:
	for child: Node in get_children():
		if child is BackgroundLayer:
			(child as BackgroundLayer).base_speed = mission.background_scroll_speed
