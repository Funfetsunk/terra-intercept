extends CanvasLayer

@export var special_fire_flash_color: Color = Color(1.0, 1.0, 0.3, 1.0)
@export var special_fire_flash_duration: float = 0.4
@export var digit_textures: Array[Texture2D] = []
@export var lives_digit_box_center_x: float = 69.5
@export var lives_digit_box_top: float = 241.0

@onready var _lives_label: Label = $HUDRoot/LeftPanel/LivesLabel
@onready var _lives_digit: TextureRect = $HUDRoot/LeftPanelBg/LivesDigit
@onready var _shield_bar: ProgressBar = $HUDRoot/LeftPanelBg/ShieldBar
@onready var _hull_bar: ProgressBar = $HUDRoot/LeftPanelBg/HullBar
@onready var _focus_bar: ProgressBar = $HUDRoot/LeftPanelBg/FocusBar
@onready var _ordnance_badges: Array[TextureRect] = [
	$HUDRoot/LeftPanelBg/OrdnanceBadgeR1Left,
	$HUDRoot/LeftPanelBg/OrdnanceBadgeR1Mid,
	$HUDRoot/LeftPanelBg/OrdnanceBadgeR1Right,
	$HUDRoot/LeftPanelBg/OrdnanceBadgeR2Left,
	$HUDRoot/LeftPanelBg/OrdnanceBadgeR2Mid,
	$HUDRoot/LeftPanelBg/OrdnanceBadgeR2Right,
]
@onready var _special_label: Label = $HUDRoot/RightPanel/SpecialChargesLabel
@onready var _special_progress_bar: ProgressBar = $HUDRoot/RightPanel/SpecialProgressBar
@onready var _squad_label: Label = $HUDRoot/RightPanel/SquadLabel
@onready var _special_bar: ProgressBar = $HUDRoot/RightPanelBg/SpecialBar
@onready var _special_charge_icons: Array[TextureRect] = [
	$HUDRoot/RightPanelBg/SpecialCharge1,
	$HUDRoot/RightPanelBg/SpecialCharge2,
	$HUDRoot/RightPanelBg/SpecialCharge3,
]
@onready var _squad_icon: TextureRect = $HUDRoot/RightPanelBg/SquadIcon
@onready var _squad_name: Label = $HUDRoot/RightPanelBg/SquadName
@onready var _ordnance_label: Label = $HUDRoot/LeftPanel/OrdnanceLabel
@onready var _tech_label: Label = $HUDRoot/LeftPanel/TechLabel
@onready var _score_label: Label = $HUDRoot/LeftPanel/ScoreLabel
@onready var _chain_label: Label = $HUDRoot/LeftPanel/ChainLabel

var _game_state: Node = null

func bind_player(player: Node) -> void:
	player.shield_changed.connect(_on_shield_changed)
	player.hull_changed.connect(_on_hull_changed)
	player.focus_changed.connect(_on_focus_changed)
	player.special_charges_changed.connect(_on_special_changed)
	player.special_progress_changed.connect(_on_special_progress_changed)
	player.squad_selection_changed.connect(_on_squad_selection_changed)
	player.ordnance_ammo_changed.connect(_on_ordnance_ammo_changed)
	player.special_fired.connect(_on_special_fired)
	if player.has_method("get_armed_squad_ship"):
		var armed: ShipData = player.get_armed_squad_ship()
		if armed != null:
			_on_squad_selection_changed(armed)
	_on_shield_changed(player.shield_current, player.data.shield_max)
	_on_hull_changed(player.hull_current, player.data.hull_max)
	_on_focus_changed(player.get_focus_meter(), player.data.focus_meter_max)
	_on_special_changed(player.special_charges, player.data.special_charge_max)
	_game_state = get_node("/root/GameState")
	_on_ordnance_ammo_changed(_game_state.ordnance_ammo)
	_game_state.life_lost.connect(_on_life_lost)
	_game_state.tech_changed.connect(_on_tech_changed)
	_game_state.score_changed.connect(_on_score_changed)
	_game_state.kill_chain_changed.connect(_on_kill_chain_changed)
	_lives_label.text = "Lives: %d" % _game_state.lives_remaining
	_update_lives_digit(_game_state.lives_remaining)
	_tech_label.text = "Tech: %d" % _game_state.mission_tech
	_score_label.text = "Score: %d" % _game_state.score
	_chain_label.text = "Chain: x%d" % _game_state.kill_chain

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
	for i in range(_special_charge_icons.size()):
		_special_charge_icons[i].visible = i < current

func _on_special_progress_changed(progress: float) -> void:
	_special_progress_bar.value = progress
	_special_bar.value = progress

func _on_squad_selection_changed(ship: ShipData) -> void:
	_squad_label.text = "Squad: %s" % ship.pilot_name
	_squad_icon.texture = ship.icon_sprite
	_squad_name.text = ship.pilot_name

func _on_special_fired(_ship: ShipData) -> void:
	_squad_name.modulate = special_fire_flash_color
	create_tween().tween_property(_squad_name, "modulate", Color.WHITE, special_fire_flash_duration)

func _on_ordnance_ammo_changed(current: int) -> void:
	var game_state: Node = get_node("/root/GameState")
	var max_ammo: int = game_state.ordnance.starting_ammo if game_state.ordnance != null else 0
	_ordnance_label.text = "Ordnance: %d/%d" % [current, max_ammo]
	_update_ordnance_badges(current)

func _update_ordnance_badges(current: int) -> void:
	for i in range(_ordnance_badges.size()):
		_ordnance_badges[i].visible = i < current

func _on_life_lost(lives_remaining: int) -> void:
	_lives_label.text = "Lives: %d" % lives_remaining
	_update_lives_digit(lives_remaining)

func _update_lives_digit(lives_remaining: int) -> void:
	var digit_index: int = clampi(lives_remaining, 0, digit_textures.size() - 1)
	var texture: Texture2D = digit_textures[digit_index]
	_lives_digit.texture = texture
	if texture == null:
		return
	var texture_size: Vector2 = texture.get_size()
	_lives_digit.size = texture_size
	_lives_digit.position = Vector2(lives_digit_box_center_x - texture_size.x * 0.5, lives_digit_box_top)

func _on_tech_changed(current: int) -> void:
	_tech_label.text = "Tech: %d" % current

func _on_score_changed(current: int) -> void:
	_score_label.text = "Score: %d" % current

func _on_kill_chain_changed(multiplier: int) -> void:
	_chain_label.text = "Chain: x%d" % multiplier
