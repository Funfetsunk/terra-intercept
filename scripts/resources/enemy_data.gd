extends Resource
class_name EnemyData

@export var enemy_name: String = ""
@export var move_speed: float = 40.0
@export var hull_max: float = 2.0
@export var hitbox_radius: float = 8.0
@export var contact_damage: float = 1.0
@export var pattern: BulletPatternData
@export var score_value: int = 100
@export var alien_tech_drop: int = 0
## Effect spawned where the enemy dies (a scene whose root plays once and frees itself).
@export var explosion_scene: PackedScene
## Optional art override (e.g. a Mk II recolour). Must have the same animation
## names as the scene's own SpriteFrames. Leave empty to keep the scene's art.
@export var sprite_frames: SpriteFrames
