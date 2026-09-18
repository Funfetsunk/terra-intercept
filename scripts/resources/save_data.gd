extends Resource
class_name SaveData

@export var save_version: int = 1
@export var ship_name: String = ""
@export var map_column: int = 1
@export var map_lane: String = ""
@export var pending_lane_choice: bool = false
@export var completed_missions: Array[String] = []
@export var banked_tech: int = 0
@export var upgrades_owned: Dictionary = {}
@export var purchase_ledger: Array[Dictionary] = []
@export var mission_results: Dictionary = {}
@export var high_scores: Dictionary = {}
@export var last_saved_unix_time: int = 0
