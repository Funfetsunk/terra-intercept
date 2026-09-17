extends Resource
class_name BulletPatternData

@export var pattern_name: String = ""
@export var burst_size: int = 1
@export var angle_spread_degrees: float = 0.0
@export var burst_interval: float = 1.0
@export var rotation_per_burst_degrees: float = 0.0
@export var aim_at_player: bool = true
@export var fixed_angle_degrees: float = 90.0
@export var jitter_degrees: float = 0.0
@export var rng_seed: int = 1
@export var bullet_speed: float = 120.0
@export var bullet_radius: float = 3.0
@export var bullet_color: Color = Color(1.0, 0.3, 0.3)
@export var bullet_texture: Texture2D
@export var bullet_damage: float = 1.0
@export var bullet_lifetime: float = 4.0
