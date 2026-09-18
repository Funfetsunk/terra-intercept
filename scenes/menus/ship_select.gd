extends Control

@onready var _save_manager: Node = get_node("/root/SaveManager")

func _ready() -> void:
	var entries: Array[ShipSelectEntry] = []
	for child: Node in $ShipList.get_children():
		if child is ShipSelectEntry:
			var entry: ShipSelectEntry = child as ShipSelectEntry
			entry.ship_chosen.connect(_on_ship_chosen)
			entries.append(entry)
	for i in range(entries.size()):
		var prev_entry: ShipSelectEntry = entries[wrapi(i - 1, 0, entries.size())]
		var next_entry: ShipSelectEntry = entries[wrapi(i + 1, 0, entries.size())]
		entries[i].focus_neighbor_left = entries[i].get_path_to(prev_entry)
		entries[i].focus_neighbor_right = entries[i].get_path_to(next_entry)
		entries[i].focus_previous = entries[i].get_path_to(prev_entry)
		entries[i].focus_next = entries[i].get_path_to(next_entry)
	if not entries.is_empty():
		entries[0].grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("p1_ordnance"):
		var viewport: Viewport = get_viewport()
		var focused: Control = viewport.gui_get_focus_owner()
		if focused is ShipSelectEntry:
			viewport.set_input_as_handled()
			(focused as ShipSelectEntry).activate()

func _on_ship_chosen(ship: ShipData) -> void:
	_save_manager.begin_new_run(_save_manager.current_slot, ship)
	get_tree().change_scene_to_file("res://scenes/menus/map_screen.tscn")
