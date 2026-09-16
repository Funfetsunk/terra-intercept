extends Node

@export var mission: MissionData
@export var dialogue_box_path: NodePath

var _entries: Array[DialogueEntry] = []
var _elapsed: float = 0.0
var _next_index: int = 0
var _queue: Array[DialogueEntry] = []
var _active_entry: DialogueEntry = null
var _active_timer: float = 0.0

var _bullets: Node = null
var _dialogue_box: Node = null

func _ready() -> void:
	_bullets = get_node("/root/BulletManager")
	_dialogue_box = get_node(dialogue_box_path)
	_entries = mission.dialogue_events.duplicate()
	_entries.sort_custom(func(a: DialogueEntry, b: DialogueEntry) -> bool: return a.trigger_time < b.trigger_time)

func _physics_process(delta: float) -> void:
	_elapsed += delta
	while _next_index < _entries.size() and _entries[_next_index].trigger_time <= _elapsed:
		_queue.append(_entries[_next_index])
		_next_index += 1
	if _active_entry != null:
		_active_timer -= delta
		if _active_timer <= 0.0:
			_dialogue_box.hide_dialogue()
			_active_entry = null
	elif not _queue.is_empty() and _bullets.is_screen_clear():
		_active_entry = _queue.pop_front()
		_active_timer = _active_entry.duration
		_dialogue_box.show_dialogue(_active_entry)
