extends Node2D
class_name BackgroundLayer

@export var scroll_speed_multiplier: float = 1.0
@export var panel_height: float = 360.0
@export var panel_a_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var panel_b_color: Color = Color(0.82, 0.82, 0.92, 1.0)
## Art for each panel. The two alternate as they scroll, so B's top edge must
## continue A's bottom edge and vice versa. Leave empty to keep the scene's texture.
@export var panel_a_texture: Texture2D
@export var panel_b_texture: Texture2D

var base_speed: float = 0.0
# Exact scroll offsets; panels are drawn at these rounded to whole pixels so
# pixel art (and dithered layers) never sit between pixels and shimmer.
var _offsets: PackedFloat32Array = PackedFloat32Array([0.0, -360.0])

@onready var _panels: Array[Control] = [$PanelA, $PanelB]

func _ready() -> void:
	if panel_a_texture != null:
		($PanelA as TextureRect).texture = panel_a_texture
	if panel_b_texture != null:
		($PanelB as TextureRect).texture = panel_b_texture
	_offsets[0] = $PanelA.position.y
	_offsets[1] = $PanelB.position.y
	$PanelA.modulate = panel_a_color
	$PanelB.modulate = panel_b_color

func _physics_process(delta: float) -> void:
	var speed: float = base_speed * scroll_speed_multiplier
	for i in range(_panels.size()):
		_offsets[i] += speed * delta
		if _offsets[i] >= panel_height:
			_offsets[i] -= panel_height * 2.0
		_panels[i].position.y = roundf(_offsets[i])
