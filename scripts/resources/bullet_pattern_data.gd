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
## Fire the burst from each of these points (relative to the enemy) instead of its
## centre, e.g. a boss's turrets. Aimed patterns aim from each point.
@export var emitter_offsets: PackedVector2Array = PackedVector2Array()
## Extra angle (degrees) added per emitter, matched by index to emitter_offsets,
## so emitters can fire out of step (e.g. dishes sweeping at different angles).
@export var emitter_angle_offsets: PackedFloat32Array = PackedFloat32Array()
## Repeat the burst at this many speeds, each `layer_speed_step` faster, so it
## arrives as stacked waves.
@export var layers: int = 1
@export var layer_speed_step: float = 0.0
## Swing the base angle back and forth by up to this many degrees, completing
## one swing every `sweep_period_bursts` bursts (0 = no sweep).
@export var sweep_degrees: float = 0.0
@export var sweep_period_bursts: int = 0
## Random +/- speed per bullet (seeded), for scattered shards rather than neat rings.
@export var speed_jitter: float = 0.0
