extends Button
class_name ShipSelectEntry

signal ship_chosen(ship: ShipData)

@export var ship: ShipData

@onready var _swatch: ColorRect = $VBoxContainer/Swatch
@onready var _name_label: Label = $VBoxContainer/NameLabel
@onready var _pilot_label: Label = $VBoxContainer/PilotLabel
@onready var _traits_label: Label = $VBoxContainer/TraitsLabel

func _ready() -> void:
	_swatch.color = ship.ship_color
	_name_label.text = ship.ship_name
	_pilot_label.text = ship.pilot_name
	_traits_label.text = ship.traits_description
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	ship_chosen.emit(ship)

func activate() -> void:
	_on_pressed()
