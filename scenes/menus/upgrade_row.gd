extends HBoxContainer
class_name UpgradeRow

signal purchased

@onready var _icon: TextureRect = $Icon
@onready var _info_label: Label = $InfoLabel
@onready var _action_button: Button = $ActionButton

var _upgrade: UpgradeData
var _game_state: Node

func setup(upgrade: UpgradeData, game_state: Node) -> void:
	_upgrade = upgrade
	_game_state = game_state
	_icon.texture = upgrade.icon
	_action_button.pressed.connect(_on_buy_pressed)
	refresh()

func refresh() -> void:
	var level: int = _game_state.upgrades_owned.get(_upgrade.id, 0)
	var price: int = _upgrade.cost_for_level(level)
	var locked: bool = _upgrade.unlock_column > _game_state.current_column
	var status: String = "Lv %d/%d" % [level, _upgrade.max_level]
	if locked:
		status = "Unlocks at column %d" % _upgrade.unlock_column
	elif level < _upgrade.max_level:
		status += "  Cost %d" % price
	_info_label.text = "%s  %s\n%s" % [_upgrade.upgrade_name, status, _upgrade.description]
	if locked:
		_action_button.text = "Locked"
		_action_button.disabled = true
	elif level >= _upgrade.max_level:
		_action_button.text = "Maxed"
		_action_button.disabled = true
	else:
		_action_button.text = "Buy"
		_action_button.disabled = _game_state.banked_tech < price

func _on_buy_pressed() -> void:
	if _game_state.purchase_upgrade(_upgrade.id):
		refresh()
		purchased.emit()

func get_action_button() -> Button:
	return _action_button
