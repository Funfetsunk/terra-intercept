extends Node

signal life_lost(lives_remaining: int)
signal game_over_triggered
signal weapon_level_dropped(new_level: int)
signal weapon_level_changed(new_level: int)
signal tech_changed(current: int)
signal score_changed(current: int)
signal kill_chain_changed(multiplier: int)
signal mission_completed(results: Dictionary)

@export var starting_lives: int = 3
@export var max_weapon_level: int = 5
@export var selected_ship: ShipData
@export var ship_roster: Array[ShipData] = []
@export var all_upgrades: Array[Resource] = []
@export var all_map_nodes: Array[Resource] = []
@export var ordnance: OrdnanceData
@export var chain_multiplier_max: int = 5
@export var completion_bonus: int = 1000
@export var life_bonus: int = 500
@export var hull_bonus_max: int = 300
@export var shield_bonus_max: int = 200
@export var grade_s_score: int = 10000
@export var grade_a_score: int = 7000
@export var grade_b_score: int = 5000
@export var grade_c_score: int = 3000

var current_mission_name: String = ""
var current_column: int = 1
var current_lane: String = ""
var completed_missions: Array[String] = []
var banked_tech: int = 0
var upgrades_owned: Dictionary = {}
var purchase_ledger: Array[Dictionary] = []
var pending_lane_choice: bool = false
var is_replay: bool = false
var difficulty: String = "Normal"
var restart_section: String = ""
var tutorial_active: bool = false
var tutorial_completed: bool = false
var is_game_over: bool = false
var lives_remaining: int = 0
var current_weapon_level: int = 1
var ordnance_ammo: int = 0
var mission_tech: int = 0
var score: int = 0
var kill_chain: int = 1
var last_mission_results: Dictionary = {}

var _player: Node = null

func _ready() -> void:
	lives_remaining = starting_lives

func start_new_run() -> void:
	is_game_over = false
	lives_remaining = starting_lives
	current_weapon_level = 1
	ordnance_ammo = ordnance.starting_ammo if ordnance != null else 0
	mission_tech = 0
	score = 0
	kill_chain = 1

func register_player(player: Node) -> void:
	_player = player
	if player.has_signal("hull_depleted"):
		player.hull_depleted.connect(_on_player_hull_depleted.bind(player))

func _on_player_hull_depleted(player: Node) -> void:
	if is_game_over:
		return
	lives_remaining = max(0, lives_remaining - 1)
	if lives_remaining > 0:
		life_lost.emit(lives_remaining)
		drop_weapon_level()
		if player.has_method("respawn"):
			player.respawn()
	else:
		is_game_over = true
		life_lost.emit(lives_remaining)
		game_over_triggered.emit()

func drop_weapon_level() -> void:
	current_weapon_level = max(1, current_weapon_level - 1)
	weapon_level_dropped.emit(current_weapon_level)

func raise_weapon_level(amount: int) -> void:
	current_weapon_level = min(max_weapon_level, current_weapon_level + amount)
	weapon_level_changed.emit(current_weapon_level)

func collect_tech(amount: int) -> void:
	mission_tech += amount
	tech_changed.emit(mission_tech)

func register_kill(base_score: int) -> void:
	score += base_score * kill_chain
	score_changed.emit(score)
	kill_chain = min(chain_multiplier_max, kill_chain + 1)
	kill_chain_changed.emit(kill_chain)

func break_chain() -> void:
	if kill_chain != 1:
		kill_chain = 1
		kill_chain_changed.emit(kill_chain)

func complete_mission() -> void:
	var hull_fraction: float = 0.0
	var shield_fraction: float = 0.0
	if _player != null:
		hull_fraction = _player.hull_current / _player.data.hull_max
		shield_fraction = _player.shield_current / _player.data.shield_max
	var lives_bonus: int = lives_remaining * life_bonus
	var hull_bonus: int = int(hull_fraction * hull_bonus_max)
	var shield_bonus: int = int(shield_fraction * shield_bonus_max)
	var total_score: int = score + completion_bonus + lives_bonus + hull_bonus + shield_bonus
	last_mission_results = {
		"base_score": score,
		"completion_bonus": completion_bonus,
		"lives_bonus": lives_bonus,
		"hull_bonus": hull_bonus,
		"shield_bonus": shield_bonus,
		"tech": mission_tech,
		"total_score": total_score,
		"grade": _compute_grade(total_score),
	}
	banked_tech += mission_tech
	if not current_mission_name.is_empty() and not completed_missions.has(current_mission_name):
		completed_missions.append(current_mission_name)
	purchase_ledger.clear()
	if not is_replay:
		var cleared_column: int = current_column
		current_column += 1
		if cleared_column == 1 or cleared_column == 3 or cleared_column == 5:
			pending_lane_choice = true
	is_replay = false
	mission_completed.emit(last_mission_results)

func choose_lane(lane: String) -> void:
	current_lane = lane
	pending_lane_choice = false

func find_upgrade(id: String) -> UpgradeData:
	for upgrade: UpgradeData in all_upgrades:
		if upgrade.id == id:
			return upgrade
	return null

func purchase_upgrade(id: String) -> bool:
	var upgrade: UpgradeData = find_upgrade(id)
	if upgrade == null:
		return false
	if upgrade.unlock_column > current_column:
		return false
	var owned_level: int = upgrades_owned.get(id, 0)
	if owned_level >= upgrade.max_level:
		return false
	if banked_tech < upgrade.cost:
		return false
	banked_tech -= upgrade.cost
	upgrades_owned[id] = owned_level + 1
	purchase_ledger.append({"id": id, "cost": upgrade.cost})
	return true

func refund_ledger() -> void:
	for i in range(purchase_ledger.size() - 1, -1, -1):
		var entry: Dictionary = purchase_ledger[i]
		var id: String = entry["id"]
		banked_tech += int(entry["cost"])
		var owned_level: int = upgrades_owned.get(id, 0) - 1
		if owned_level <= 0:
			upgrades_owned.erase(id)
		else:
			upgrades_owned[id] = owned_level
	purchase_ledger.clear()

func _compute_grade(total_score: int) -> String:
	if total_score >= grade_s_score:
		return "S"
	if total_score >= grade_a_score:
		return "A"
	if total_score >= grade_b_score:
		return "B"
	if total_score >= grade_c_score:
		return "C"
	return "D"
