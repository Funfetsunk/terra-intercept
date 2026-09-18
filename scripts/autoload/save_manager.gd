extends Node

signal save_written(slot: int)
signal slot_deleted(slot: int)

const SLOT_COUNT: int = 3
const SAVE_DIR: String = "user://saves/"

var current_slot: int = -1

@onready var _game_state: Node = get_node("/root/GameState")

func _ready() -> void:
	_game_state.mission_completed.connect(_on_mission_completed)

func slot_path(slot: int) -> String:
	return "%sslot_%d.tres" % [SAVE_DIR, slot]

func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(slot_path(slot))

func load_slot(slot: int) -> SaveData:
	if not slot_exists(slot):
		return null
	return load(slot_path(slot)) as SaveData

func begin_new_run(slot: int, ship: ShipData) -> void:
	current_slot = slot
	_game_state.selected_ship = ship
	_game_state.restart_section = ""
	_game_state.tutorial_completed = false

func continue_slot(slot: int) -> SaveData:
	var data: SaveData = load_slot(slot)
	if data == null:
		return null
	current_slot = slot
	_game_state.restart_section = ""
	_game_state.tutorial_completed = false
	for ship: ShipData in _game_state.ship_roster:
		if ship.ship_name == data.ship_name:
			_game_state.selected_ship = ship
			break
	return data

func delete_slot(slot: int) -> void:
	if not slot_exists(slot):
		return
	DirAccess.remove_absolute(slot_path(slot))
	slot_deleted.emit(slot)

func _on_mission_completed(results: Dictionary) -> void:
	if current_slot == -1:
		return
	var dir: DirAccess = DirAccess.open("user://")
	if dir != null and not dir.dir_exists("saves"):
		dir.make_dir("saves")
	var data: SaveData = load_slot(current_slot)
	if data == null:
		data = SaveData.new()
	data.ship_name = _game_state.selected_ship.ship_name if _game_state.selected_ship != null else data.ship_name
	data.banked_tech += results.get("tech", 0)
	data.last_saved_unix_time = int(Time.get_unix_time_from_system())
	var mission_name: String = _game_state.current_mission_name
	if not mission_name.is_empty():
		if not data.completed_missions.has(mission_name):
			data.completed_missions.append(mission_name)
		data.mission_results[mission_name] = results
		_record_high_score(data, mission_name, results.get("total_score", 0))
	ResourceSaver.save(data, slot_path(current_slot))
	save_written.emit(current_slot)

func _record_high_score(data: SaveData, mission_name: String, score: int) -> void:
	var scores: Array = data.high_scores.get(mission_name, [])
	scores.append({"initials": "AAA", "score": score})
	scores.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["score"] > b["score"])
	scores = scores.slice(0, 5)
	data.high_scores[mission_name] = scores
