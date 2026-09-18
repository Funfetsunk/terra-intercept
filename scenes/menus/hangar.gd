extends Control

const MAP_SCENE: String = "res://scenes/menus/map_screen.tscn"
const UPGRADE_ROW_SCENE: PackedScene = preload("res://scenes/menus/upgrade_row.tscn")

@onready var _game_state: Node = get_node("/root/GameState")
@onready var _tech_label: Label = $TechLabel
@onready var _upgrade_list: VBoxContainer = $UpgradeList
@onready var _back_button: Button = $BackButton

var _rows: Array[UpgradeRow] = []

func _ready() -> void:
	_back_button.pressed.connect(_on_back)
	for upgrade: UpgradeData in _game_state.all_upgrades:
		var row: UpgradeRow = UPGRADE_ROW_SCENE.instantiate()
		_upgrade_list.add_child(row)
		row.setup(upgrade, _game_state)
		row.purchased.connect(_on_any_purchased)
		_rows.append(row)
	_refresh_tech_label()
	_back_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("p1_ordnance"):
		var viewport: Viewport = get_viewport()
		var focused: Control = viewport.gui_get_focus_owner()
		if focused is Button:
			viewport.set_input_as_handled()
			(focused as Button).pressed.emit()

func _refresh_tech_label() -> void:
	_tech_label.text = "Tech: %d" % _game_state.banked_tech

func _on_any_purchased() -> void:
	_refresh_tech_label()
	for row: UpgradeRow in _rows:
		row.refresh()

func _on_back() -> void:
	get_tree().change_scene_to_file(MAP_SCENE)
