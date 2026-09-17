extends Node2D
class_name BackgroundLayer

@export var scroll_speed_multiplier: float = 1.0
@export var panel_height: float = 360.0
@export var panel_a_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var panel_b_color: Color = Color(0.82, 0.82, 0.92, 1.0)

var base_speed: float = 0.0

@onready var _panels: Array[Control] = [$PanelA, $PanelB]

func _ready() -> void:
	$PanelA.modulate = panel_a_color
	$PanelB.modulate = panel_b_color

func _physics_process(delta: float) -> void:
	var speed: float = base_speed * scroll_speed_multiplier
	for panel: Control in _panels:
		panel.position.y += speed * delta
		if panel.position.y >= panel_height:
			panel.position.y -= panel_height * 2.0
