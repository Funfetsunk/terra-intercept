extends Node

@export var mission: MissionData
@export var player_path: NodePath
@export var dialogue_box_path: NodePath
@export var enemy_spawner_path: NodePath
@export var movement_threshold: float = 24.0
@export var weapon_pickup_scene: PackedScene
@export var alien_tech_drop_scene: PackedScene
@export var pickup_spawn_offset: Vector2 = Vector2(-30.0, -80.0)
@export var tech_spawn_offset: Vector2 = Vector2(30.0, -80.0)

enum _Phase { BEATS, SQUAD, DONE }

var _player: Node = null
var _dialogue_box: Node = null
var _enemy_spawner: Node = null
var _bullets: Node = null
var _game_state: Node = null

var _phase: _Phase = _Phase.BEATS
var _beat_index: int = 0
var _squad_index: int = 0
var _beat_active: bool = false
var _beat_start_position: Vector2 = Vector2.ZERO
var _current_squad_ship: ShipData = null
var _pickup_control_taken: bool = false

var _fired_since_beat: bool = false
var _focus_used_since_beat: bool = false
var _ordnance_fired_since_beat: bool = false
var _pickup_collected_since_beat: bool = false
var _tech_collected_since_beat: bool = false
var _special_fired_ships: Array[ShipData] = []

func _ready() -> void:
	_player = get_node(player_path)
	_dialogue_box = get_node(dialogue_box_path)
	_enemy_spawner = get_node(enemy_spawner_path)
	_bullets = get_node("/root/BulletManager")
	_game_state = get_node("/root/GameState")
	if not _game_state.restart_section.is_empty():
		_phase = _Phase.DONE
		_game_state.tutorial_active = false
		return
	_game_state.tutorial_active = true
	_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_bullets.process_mode = Node.PROCESS_MODE_ALWAYS
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
	var beat: TutorialBeat = mission.tutorial_beats[_beat_index]
	if not _beat_active:
		if _bullets.has_active_threats():
			return
		_start_beat(beat)
		return
	if beat.action == TutorialBeat.Action.PICKUP_AND_TECH:
		_process_pickup_beat()
	if _beat_condition_met(beat):
		_end_beat()

func _start_beat(beat: TutorialBeat) -> void:
	_beat_active = true
	_beat_start_position = _player.global_position
	_fired_since_beat = false
	_focus_used_since_beat = false
	_ordnance_fired_since_beat = false
	_pickup_collected_since_beat = false
	_tech_collected_since_beat = false
	_pickup_control_taken = false
	get_tree().paused = true
	_dialogue_box.show_dialogue(beat)
	if beat.action == TutorialBeat.Action.PICKUP_AND_TECH:
		_spawn_pickup_beat_items()

func _end_beat() -> void:
	get_tree().paused = false
	_dialogue_box.hide_dialogue()
	_beat_active = false
	_beat_index += 1

func _process_pickup_beat() -> void:
	if _pickup_control_taken:
		return
	var move_vec: Vector2 = Input.get_vector("p1_move_left", "p1_move_right", "p1_move_up", "p1_move_down")
	if move_vec != Vector2.ZERO:
		_pickup_control_taken = true
		get_tree().paused = false

func _spawn_pickup_beat_items() -> void:
	var rect: Rect2 = get_node("/root/Playfield").rect
	var pickup: Pickup = weapon_pickup_scene.instantiate() as Pickup
	pickup.never_despawn = true
	pickup.highlighted = true
	var pickup_world: Vector2 = (_player.global_position + pickup_spawn_offset).clamp(rect.position, rect.end)
	pickup.position = get_parent().to_local(pickup_world)
	get_parent().call_deferred("add_child", pickup)
	var tech: AlienTechDrop = alien_tech_drop_scene.instantiate() as AlienTechDrop
	tech.never_despawn = true
	tech.highlighted = true
	var tech_world: Vector2 = (_player.global_position + tech_spawn_offset).clamp(rect.position, rect.end)
	tech.position = get_parent().to_local(tech_world)
	get_parent().call_deferred("add_child", tech)

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
		get_tree().paused = true
		_dialogue_box.show_dialogue(beat)
		return
	if _special_fired_ships.has(_current_squad_ship):
		get_tree().paused = false
		_dialogue_box.hide_dialogue()
		_beat_active = false
		_squad_index += 1

func _finish_tutorial() -> void:
	_phase = _Phase.DONE
	get_tree().paused = false
	_player.process_mode = Node.PROCESS_MODE_INHERIT
	_bullets.process_mode = Node.PROCESS_MODE_INHERIT
	_player.restore_full()
	_game_state.tutorial_active = false
	_game_state.tutorial_completed = true
	_enemy_spawner.jump_to_time(mission.get_section_start_time("thames_run"))

func _on_special_fired(ship: ShipData) -> void:
	if not _special_fired_ships.has(ship):
		_special_fired_ships.append(ship)
