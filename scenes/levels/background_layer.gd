extends Node2D
class_name BackgroundLayer

@export var scroll_speed_multiplier: float = 1.0
@export var panel_height: float = 360.0
@export var panel_a_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var panel_b_color: Color = Color(1.0, 1.0, 1.0, 1.0)
## Art for each panel. The two alternate as they scroll, so B's top edge must
## continue A's bottom edge and vice versa. Leave empty to keep the scene's texture.
@export var panel_a_texture: Texture2D
@export var panel_b_texture: Texture2D
## Extra width drawn either side of the playfield so the layer can pan sideways
## (Great Wall). The art must tile seamlessly left to right. 0 = no panning.
@export var pan_margin: float = 0.0

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
	if pan_margin > 0.0:
		for panel: Control in _panels:
			panel.size.x = panel.size.x + pan_margin * 2.0
		set_pan(0.0)

## Shifts the layer sideways by `px` (clamped to pan_margin), on whole pixels.
func set_pan(px: float) -> void:
	if pan_margin <= 0.0:
		return
	var x: float = roundf(-pan_margin + clampf(px, -pan_margin, pan_margin))
	for panel: Control in _panels:
		panel.position.x = x

func _physics_process(delta: float) -> void:
	var speed: float = base_speed * scroll_speed_multiplier
	for i in range(_panels.size()):
		_offsets[i] += speed * delta
		if _offsets[i] >= panel_height:
			_offsets[i] -= panel_height * 2.0
		_panels[i].position.y = roundf(_offsets[i])
