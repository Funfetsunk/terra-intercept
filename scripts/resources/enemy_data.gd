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
