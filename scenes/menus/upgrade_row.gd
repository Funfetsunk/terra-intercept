extends HBoxContainer
class_name UpgradeRow

signal purchased

@onready var _info_label: Label = $InfoLabel
@onready var _action_button: Button = $ActionButton

var _upgrade: UpgradeData
var _game_state: Node

func setup(upgrade: UpgradeData, game_state: Node) -> void:
	_upgrade = upgrade
	_game_state = game_state
	_action_button.pressed.connect(_on_buy_pressed)
	refresh()

func refresh() -> void:
	var level: int = _game_state.upgrades_owned.get(_upgrade.id, 0)
	_info_label.text = "%s (Lv %d/%d) — %s — Cost %d" % [_upgrade.upgrade_name, level, _upgrade.max_level, _upgrade.description, _upgrade.cost]
	if _upgrade.unlock_column > _game_state.current_column:
		_action_button.text = "Locked — column %d" % _upgrade.unlock_column
		_action_button.disabled = true
	elif level >= _upgrade.max_level:
		_action_button.text = "Maxed"
		_action_button.disabled = true
	else:
		_action_button.text = "Buy"
		_action_button.disabled = _game_state.banked_tech < _upgrade.cost

func _on_buy_pressed() -> void:
	if _game_state.purchase_upgrade(_upgrade.id):
		refresh()
		purchased.emit()

func get_action_button() -> Button:
	return _action_button
