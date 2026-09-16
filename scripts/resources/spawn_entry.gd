extends Resource
class_name SpawnEntry

@export var scene: PackedScene
@export var spawn_time: float = 0.0
@export var spawn_position_relative: Vector2 = Vector2.ZERO
@export var pattern_override: BulletPatternData = null
@export var data_override: EnemyData = null
