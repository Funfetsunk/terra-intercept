extends Node

@export var mission: MissionData
@export var player_path: NodePath
@export var dialogue_box_path: NodePath
@export var movement_threshold: float = 24.0

enum _Phase { BEATS, SQUAD, DONE }

var _player: Node = null
var _dialogue_box: Node = null
var _bullets: Node = null
var _game_state: Node = null

var _phase: _Phase = _Phase.BEATS
var _beat_index: int = 0
var _squad_index: int = 0
var _beat_active: bool = false
var _beat_start_position: Vector2 = Vector2.ZERO
var _current_squad_ship: ShipData = null

var _fired_since_beat: bool = false
var _focus_used_since_beat: bool = false
var _ordnance_fired_since_beat: bool = false
var _pickup_collected_since_beat: bool = false
var _tech_collected_since_beat: bool = false
var _special_fired_ships: Array[ShipData] = []

func _ready() -> void:
	_player = get_node(player_path)
	_dialogue_box = get_node(dialogue_box_path)
	_bullets = get_node("/root/BulletManager")
	_game_state = get_node("/root/GameState")
	_game_state.tutorial_active = true
	_player.grant_special_charge(_player.data.special_charge_max)
	_player.weapon_fired.connect(func() -> void: _fired_since_beat = true)
	_player.focus_used.connect(func() -> void: _focus_used_since_beat = true)
	_player.ordnance_fired.connect(func() -> void: _ordnance_fired_since_beat = true)
	_player.special_fired.connect(_on_special_fired)
	_game_state.weapon_level_changed.connect(func(_l: int) -> void: _pickup_collected_since_beat = true)
	_game_state.tech_changed.connect(func(_a: int) -> void: _tech_collected_since_beat = true)

func _physics_process(_delta: float) -> void:
	match _phase:
		_Phase.BEATS: _process_beats()
		_Phase.SQUAD: _process_squad()
		_Phase.DONE: pass

func _process_beats() -> void:
	if _beat_index >= mission.tutorial_beats.size():
		_phase = _Phase.SQUAD
		return
	if not _beat_active:
		if _bullets.has_active_threats():
			return
		_start_beat(mission.tutorial_beats[_beat_index])
		return
	if _beat_condition_met(mission.tutorial_beats[_beat_index]):
		_dialogue_box.hide_dialogue()
		_beat_active = false
		_beat_index += 1

func _start_beat(beat: TutorialBeat) -> void:
	_beat_active = true
	_beat_start_position = _player.global_position
	_fired_since_beat = false
	_focus_used_since_beat = false
	_ordnance_fired_since_beat = false
	_pickup_collected_since_beat = false
	_tech_collected_since_beat = false
	_dialogue_box.show_dialogue(beat)

func _beat_condition_met(beat: TutorialBeat) -> bool:
	match beat.action:
		TutorialBeat.Action.MOVEMENT:
			return _player.global_position.distance_to(_beat_start_position) >= movement_threshold
		TutorialBeat.Action.FIRING:
			return _fired_since_beat
		TutorialBeat.Action.PICKUP_AND_TECH:
			return _pickup_collected_since_beat and _tech_collected_since_beat
		TutorialBeat.Action.FOCUS:
			return _focus_used_since_beat
		TutorialBeat.Action.ORDNANCE:
			return _ordnance_fired_since_beat
	return false

func _process_squad() -> void:
	var squad: Array[ShipData] = _player.get_squad()
	if _squad_index >= squad.size():
		_finish_tutorial()
		return
	if not _beat_active:
		if _bullets.has_active_threats():
			return
		_current_squad_ship = squad[_squad_index]
		var beat: TutorialBeat = TutorialBeat.new()
		beat.speaker_name = _current_squad_ship.pilot_name
		beat.portrait_color = _current_squad_ship.ship_color
		beat.text = mission.squad_radio_text_format % _current_squad_ship.ship_name
		beat.action = TutorialBeat.Action.SPECIAL
		_beat_active = true
		_dialogue_box.show_dialogue(beat)
		return
	if _special_fired_ships.has(_current_squad_ship):
		_dialogue_box.hide_dialogue()
		_beat_active = false
		_squad_index += 1

func _finish_tutorial() -> void:
	_phase = _Phase.DONE
	_player.restore_full()
	_game_state.tutorial_active = false
	_game_state.tutorial_completed = true

func _on_special_fired(ship: ShipData) -> void:
	if not _special_fired_ships.has(ship):
		_special_fired_ships.append(ship)
