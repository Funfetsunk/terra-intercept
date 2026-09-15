extends Node

@export var mission: MissionData

var _spawn_entries: Array[SpawnEntry] = []
var _elapsed: float = 0.0
var _next_index: int = 0

func _ready() -> void:
	_spawn_entries = mission.spawn_entries.duplicate()
	_spawn_entries.sort_custom(func(a: SpawnEntry, b: SpawnEntry) -> bool: return a.spawn_time < b.spawn_time)

func _physics_process(delta: float) -> void:
	_elapsed += delta
	while _next_index < _spawn_entries.size() and _spawn_entries[_next_index].spawn_time <= _elapsed:
		_spawn(_spawn_entries[_next_index])
		_next_index += 1

func _spawn(entry: SpawnEntry) -> void:
	if entry.scene == null:
		return
	var instance: Node2D = entry.scene.instantiate()
	if entry.pattern_override != null and instance is EnemyBase:
		(instance as EnemyBase).pattern_override = entry.pattern_override
	get_parent().call_deferred("add_child", instance)
	instance.global_position = entry.spawn_position
