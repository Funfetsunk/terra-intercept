extends Node

signal life_lost(lives_remaining: int)
signal game_over_triggered
signal weapon_level_dropped(new_level: int)
signal weapon_level_changed(new_level: int)

@export var starting_lives: int = 3
@export var max_weapon_level: int = 5
@export var selected_ship: ShipData
@export var ship_roster: Array[ShipData] = []
@export var ordnance: OrdnanceData

var lives_remaining: int = 0
var current_weapon_level: int = 1
var ordnance_ammo: int = 0

func _ready() -> void:
	lives_remaining = starting_lives

func start_new_run() -> void:
	lives_remaining = starting_lives
	current_weapon_level = 1
	ordnance_ammo = ordnance.starting_ammo if ordnance != null else 0

func register_player(player: Node) -> void:
	if player.has_signal("hull_depleted"):
		player.hull_depleted.connect(_on_player_hull_depleted.bind(player))

func _on_player_hull_depleted(player: Node) -> void:
	lives_remaining -= 1
	if lives_remaining > 0:
		life_lost.emit(lives_remaining)
		drop_weapon_level()
		if player.has_method("respawn"):
			player.respawn()
	else:
		life_lost.emit(lives_remaining)
		game_over_triggered.emit()

func drop_weapon_level() -> void:
	current_weapon_level = max(1, current_weapon_level - 1)
	weapon_level_dropped.emit(current_weapon_level)

func raise_weapon_level(amount: int) -> void:
	current_weapon_level = min(max_weapon_level, current_weapon_level + amount)
	weapon_level_changed.emit(current_weapon_level)
