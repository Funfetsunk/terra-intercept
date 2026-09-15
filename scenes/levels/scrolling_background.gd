extends Node2D

@export var scroll_speed: float = 40.0
@export var panel_height: float = 360.0

@onready var _panels: Array[Control] = [$PanelA, $PanelB]

func _physics_process(delta: float) -> void:
	for panel: Control in _panels:
		panel.position.y += scroll_speed * delta
		if panel.position.y >= panel_height:
			panel.position.y -= panel_height * 2.0
