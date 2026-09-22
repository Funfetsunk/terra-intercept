extends Button
class_name ShipSelectEntry

signal ship_chosen(ship: ShipData)

@export var ship: ShipData
@export var stat_bar_max_width: float = 40.0

@onready var _art: TextureRect = $VBoxContainer/Swatch/Art
@onready var _name_label: Label = $VBoxContainer/NameLabel
@onready var _pilot_label: Label = $VBoxContainer/PilotLabel
@onready var _traits_label: Label = $VBoxContainer/TraitsLabel
@onready var _icon: TextureRect = $VBoxContainer/StatsRow/Icon
@onready var _speed_fill: ColorRect = $VBoxContainer/StatsRow/StatBars/SpeedRow/Track/Fill
@onready var _shield_fill: ColorRect = $VBoxContainer/StatsRow/StatBars/ShieldRow/Track/Fill
@onready var _hull_fill: ColorRect = $VBoxContainer/StatsRow/StatBars/HullRow/Track/Fill

func _ready() -> void:
	_art.texture = ship.select_art
	_name_label.text = ship.ship_name
	_pilot_label.text = ship.pilot_name
	_traits_label.text = ship.traits_description
	_icon.texture = ship.icon_sprite
	pressed.connect(_on_pressed)

func set_stat_ratios(speed_ratio: float, shield_ratio: float, hull_ratio: float) -> void:
	_speed_fill.size.x = stat_bar_max_width * clampf(speed_ratio, 0.0, 1.0)
	_shield_fill.size.x = stat_bar_max_width * clampf(shield_ratio, 0.0, 1.0)
	_hull_fill.size.x = stat_bar_max_width * clampf(hull_ratio, 0.0, 1.0)

func _on_pressed() -> void:
	ship_chosen.emit(ship)

func activate() -> void:
	_on_pressed()
