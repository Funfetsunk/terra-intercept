extends Node

@export var spawn_entries: Array[SpawnEntry] = [
	preload("res://data/missions/spawn_drone_01.tres"),
	preload("res://data/missions/spawn_drone_02.tres"),
	preload("res://data/missions/spawn_swarmer_01.tres"),
	preload("res://data/missions/spawn_swarmer_02.tres"),
	preload("res://data/missions/spawn_spinner_01.tres"),
	preload("res://data/missions/spawn_drone_03.tres"),
	preload("res://data/missions/spawn_boss_01.tres"),
]

var _elapsed: float = 0.0
var _next_index: int = 0

func _ready() -> void:
	spawn_entries.sort_custom(func(a: SpawnEntry, b: SpawnEntry) -> bool: return a.spawn_time < b.spawn_time)

func _physics_process(delta: float) -> void:
	_elapsed += delta
	while _next_index < spawn_entries.size() and spawn_entries[_next_index].spawn_time <= _elapsed:
		_spawn(spawn_entries[_next_index])
		_next_index += 1

func _spawn(entry: SpawnEntry) -> void:
	if entry.scene == null:
		return
	var instance: Node2D = entry.scene.instantiate()
	get_parent().call_deferred("add_child", instance)
	instance.global_position = entry.spawn_position
