extends Resource
class_name OrdnanceData

@export var ordnance_name: String = "Missile"
@export var starting_ammo: int = 5
@export var fire_cooldown: float = 0.4
@export var bullet_speed: float = 200.0
@export var bullet_radius: float = 5.0
@export var bullet_color: Color = Color(1.0, 0.6, 0.1)
## Sprite drawn at native size; leave empty for a plain coloured square.
@export var bullet_texture: Texture2D
## Optional: square frames side by side, one per facing, clockwise from straight
## up (8 frames = every 45 degrees). When set, the shot uses the frame nearest
## its flight direction instead of bullet_texture.
@export var bullet_direction_sheet: Texture2D

var _direction_frames: Array[Texture2D] = []

func texture_for_direction(direction: Vector2) -> Texture2D:
	if bullet_direction_sheet == null:
		return bullet_texture
	if _direction_frames.is_empty():
		var size: float = bullet_direction_sheet.get_height()
		for i in range(int(bullet_direction_sheet.get_width() / size)):
			var frame := AtlasTexture.new()
			frame.atlas = bullet_direction_sheet
			frame.region = Rect2(i * size, 0.0, size, size)
			_direction_frames.append(frame)
	# Angle clockwise from up, snapped to the nearest frame.
	var angle: float = fposmod(atan2(direction.x, -direction.y), TAU)
	var count: int = _direction_frames.size()
	return _direction_frames[int(roundf(angle / TAU * count)) % count]
@export var bullet_damage: float = 3.0
