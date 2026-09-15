extends Control

@onready var _game_state: Node = get_node("/root/GameState")

func _ready() -> void:
	var first_entry: ShipSelectEntry = null
	for child: Node in $ShipList.get_children():
		if child is ShipSelectEntry:
			var entry: ShipSelectEntry = child as ShipSelectEntry
			entry.ship_chosen.connect(_on_ship_chosen)
			if first_entry == null:
				first_entry = entry
	if first_entry != null:
		first_entry.grab_focus()

func _on_ship_chosen(ship: ShipData) -> void:
	_game_state.selected_ship = ship
	get_tree().change_scene_to_file("res://scenes/levels/vertical_slice.tscn")
