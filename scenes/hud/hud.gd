extends CanvasLayer

@onready var _lives_label: Label = $HUDRoot/LeftPanel/LivesLabel
@onready var _shield_bar: ProgressBar = $HUDRoot/LeftPanel/ShieldBar
@onready var _hull_bar: ProgressBar = $HUDRoot/LeftPanel/HullBar
@onready var _focus_bar: ProgressBar = $HUDRoot/LeftPanel/FocusBar
@onready var _special_label: Label = $HUDRoot/RightPanel/SpecialChargesLabel

var _game_state: Node = null

func bind_player(player: Node) -> void:
	player.shield_changed.connect(_on_shield_changed)
	player.hull_changed.connect(_on_hull_changed)
	player.focus_changed.connect(_on_focus_changed)
	player.special_charges_changed.connect(_on_special_changed)
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

func _on_life_lost(lives_remaining: int) -> void:
	_lives_label.text = "Lives: %d" % lives_remaining
