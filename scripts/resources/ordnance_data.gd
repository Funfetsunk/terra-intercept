extends Resource
class_name OrdnanceData

enum Behaviour { MISSILE, SWARM, MINE }

@export var ordnance_name: String = "Missile"
## MISSILE: one straight shot. SWARM: `projectile_count` homing shots fanned
## across `spread_degrees`. MINE: drops `mine_scene` at the ship.
@export var behaviour: Behaviour = Behaviour.MISSILE
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
@export var bullet_lifetime: float = 3.0
## HUD badge art for this type (the 6-badge grid).
@export var badge_texture: Texture2D

@export_group("Blast")
## Radius of the burst on impact (0 = none). Damages every other enemy inside it.
@export var blast_radius: float = 0.0
@export var blast_damage: float = 0.0
## Effect scene played at each blast (an Explosion).
@export var blast_effect: PackedScene

@export_group("Swarm")
@export var projectile_count: int = 1
@export var spread_degrees: float = 0.0
## How fast homing shots turn towards the nearest enemy (0 = no homing).
@export var homing_turn_degrees_per_second: float = 0.0

@export_group("Mine")
@export var mine_scene: PackedScene
@export var mine_drift_speed: float = 30.0
@export var mine_fuse: float = 4.0
## An enemy this close (plus its hitbox) sets the mine off.
@export var mine_trigger_radius: float = 32.0
## The mine's blast also clears enemy bullets inside it.
@export var mine_clears_bullets: bool = true
