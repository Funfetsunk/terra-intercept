extends Node

@export var mission: MissionData

var _spawn_entries: Array[SpawnEntry] = []
var _elapsed: float = 0.0
var _next_index: int = 0

func _ready() -> void:
	_spawn_entries = mission.spawn_entries.duplicate()
	_spawn_entries.sort_custom(func(a: SpawnEntry, b: SpawnEntry) -> bool: return a.spawn_time < b.spawn_time)
	var game_state: Node = get_node("/root/GameState")
	_elapsed = mission.get_section_start_time(game_state.restart_section)
	while _next_index < _spawn_entries.size() and _spawn_entries[_next_index].spawn_time < _elapsed:
		_next_index += 1

func _physics_process(delta: float) -> void:
	_elapsed += delta
	while _next_index < _spawn_entries.size() and _spawn_entries[_next_index].spawn_time <= _elapsed:
		_spawn(_spawn_entries[_next_index])
		_next_index += 1

func jump_to_time(target_time: float) -> void:
	if target_time <= _elapsed:
		return
	_elapsed = target_time
	while _next_index < _spawn_entries.size() and _spawn_entries[_next_index].spawn_time < _elapsed:
		_next_index += 1

func _spawn(entry: SpawnEntry) -> void:
	if entry.scene == null:
		return
	var instance: Node2D = entry.scene.instantiate()
	if instance is EnemyBase:
		var enemy: EnemyBase = instance as EnemyBase
		if entry.data_override != null:
			enemy.data = entry.data_override
		if entry.pattern_override != null:
			enemy.pattern_override = entry.pattern_override
	var world_position: Vector2 = get_node("/root/Playfield").relative_to_world(entry.spawn_position_relative)
	instance.position = get_parent().to_local(world_position)
	get_parent().call_deferred("add_child", instance)
