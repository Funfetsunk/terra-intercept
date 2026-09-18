extends Control

const SHIP_SELECT_SCENE: String = "res://scenes/menus/ship_select.tscn"
const LONDON_SCENE: String = "res://scenes/levels/london.tscn"

@onready var _save_manager: Node = get_node("/root/SaveManager")
@onready var _rows: Array[HBoxContainer] = [$SlotList/Slot1Row, $SlotList/Slot2Row, $SlotList/Slot3Row]
@onready var _confirm_overlay: Control = $ConfirmOverlay
@onready var _confirm_yes: Button = $ConfirmOverlay/ConfirmButtons/ConfirmYesButton
@onready var _confirm_no: Button = $ConfirmOverlay/ConfirmButtons/ConfirmNoButton

var _pending_delete_slot: int = -1

func _ready() -> void:
	for i in range(_rows.size()):
		var slot: int = i
		var row: HBoxContainer = _rows[i]
		var action_button: Button = row.get_node("ActionButton")
		var delete_button: Button = row.get_node("DeleteButton")
		action_button.pressed.connect(_on_action_pressed.bind(slot))
		delete_button.pressed.connect(_on_delete_pressed.bind(slot))
		_refresh_row(slot)
	_confirm_yes.pressed.connect(_on_confirm_yes)
	_confirm_no.pressed.connect(_on_confirm_no)
	_rows[0].get_node("ActionButton").grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("p1_ordnance"):
		var viewport: Viewport = get_viewport()
		var focused: Control = viewport.gui_get_focus_owner()
		if focused is Button:
			viewport.set_input_as_handled()
			(focused as Button).pressed.emit()

func _refresh_row(slot: int) -> void:
	var row: HBoxContainer = _rows[slot]
	var info_label: Label = row.get_node("InfoLabel")
	var action_button: Button = row.get_node("ActionButton")
	var delete_button: Button = row.get_node("DeleteButton")
	if _save_manager.slot_exists(slot):
		var data: SaveData = _save_manager.load_slot(slot)
		info_label.text = "Slot %d: %s — Column %d, Tech %d" % [slot + 1, data.ship_name, data.map_column, data.banked_tech]
		action_button.text = "Continue"
		delete_button.visible = true
	else:
		info_label.text = "Slot %d: Empty" % (slot + 1)
		action_button.text = "Create"
		delete_button.visible = false

func _on_action_pressed(slot: int) -> void:
	if _save_manager.slot_exists(slot):
		_save_manager.continue_slot(slot)
		get_tree().change_scene_to_file(LONDON_SCENE)
	else:
		_save_manager.current_slot = slot
		get_tree().change_scene_to_file(SHIP_SELECT_SCENE)

func _on_delete_pressed(slot: int) -> void:
	_pending_delete_slot = slot
	_confirm_overlay.visible = true
	_confirm_yes.grab_focus()

func _on_confirm_yes() -> void:
	_save_manager.delete_slot(_pending_delete_slot)
	_refresh_row(_pending_delete_slot)
	_pending_delete_slot = -1
	_confirm_overlay.visible = false

func _on_confirm_no() -> void:
	_pending_delete_slot = -1
	_confirm_overlay.visible = false
