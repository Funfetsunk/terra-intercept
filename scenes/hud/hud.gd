extends CanvasLayer

@onready var _lives_label: Label = $HUDRoot/LeftPanel/LivesLabel
@onready var _shield_bar: ProgressBar = $HUDRoot/LeftPanel/ShieldBar
@onready var _hull_bar: ProgressBar = $HUDRoot/LeftPanel/HullBar
@onready var _focus_bar: ProgressBar = $HUDRoot/LeftPanel/FocusBar
@onready var _special_label: Label = $HUDRoot/RightPanel/SpecialChargesLabel
@onready var _special_progress_bar: ProgressBar = $HUDRoot/RightPanel/SpecialProgressBar
@onready var _squad_label: Label = $HUDRoot/RightPanel/SquadLabel
@onready var _ordnance_label: Label = $HUDRoot/LeftPanel/OrdnanceLabel

var _game_state: Node = null

func bind_player(player: Node) -> void:
	player.shield_changed.connect(_on_shield_changed)
	player.hull_changed.connect(_on_hull_changed)
	player.focus_changed.connect(_on_focus_changed)
	player.special_charges_changed.connect(_on_special_changed)
	player.special_progress_changed.connect(_on_special_progress_changed)
	player.squad_selection_changed.connect(_on_squad_selection_changed)
	player.ordnance_ammo_changed.connect(_on_ordnance_ammo_changed)
	if player.has_method("get_armed_squad_ship"):
		var armed: ShipData = player.get_armed_squad_ship()
		if armed != null:
			_on_squad_selection_changed(armed)
	_game_state = get_node("/root/GameState")
	_game_state.life_lost.connect(_on_life_lost)
	_lives_label.text = "Lives: %d" % _game_state.lives_remaining

func _on_shield_changed(current: float, max_value: float) -> void:
	_shield_bar.max_value = max_value
	_shield_bar.value = current

func _on_hull_changed(current: float, max_value: float) -> void:
	_hull_bar.max_value = max_value
	_hull_bar.value = current

func _on_focus_changed(current: float, max_value: float) -> void:
	_focus_bar.max_value = max_value
	_focus_bar.value = current

func _on_special_changed(current: int, max_value: int) -> void:
	_special_label.text = "Special: %d/%d" % [current, max_value]

func _on_special_progress_changed(progress: float) -> void:
	_special_progress_bar.value = progress

func _on_squad_selection_changed(ship: ShipData) -> void:
	_squad_label.text = "Squad: %s" % ship.ship_name

func _on_ordnance_ammo_changed(current: int) -> void:
	var game_state: Node = get_node("/root/GameState")
	var max_ammo: int = game_state.ordnance.starting_ammo if game_state.ordnance != null else 0
	_ordnance_label.text = "Ordnance: %d/%d" % [current, max_ammo]

func _on_life_lost(lives_remaining: int) -> void:
	_lives_label.text = "Lives: %d" % lives_remaining
