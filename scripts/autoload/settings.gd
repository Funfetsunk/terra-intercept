extends Node

signal settings_changed

const SETTINGS_PATH: String = "user://settings.cfg"
const REMAPPABLE_ACTIONS: Array[String] = ["p1_focus", "p1_squad_prev", "p1_squad_next", "p1_special", "p1_ordnance", "p1_pause"]

@export var easy_damage_taken_multiplier: float = 0.6
@export var easy_shield_recharge_multiplier: float = 1.5
@export var easy_focus_refill_delay_multiplier: float = 0.5

var crt_filter_enabled: bool = false
var screen_shake_enabled: bool = true
var high_contrast_bullets: bool = false
var difficulty: String = "Normal"

var _default_events: Dictionary = {}

@onready var _crt_overlay: CanvasLayer = $CrtOverlay

func _ready() -> void:
	for action: String in REMAPPABLE_ACTIONS:
		_default_events[action] = InputMap.action_get_events(action).duplicate()
	load_settings()
	_crt_overlay.visible = crt_filter_enabled

func damage_taken_multiplier() -> float:
	return easy_damage_taken_multiplier if difficulty == "Easy" else 1.0

func shield_recharge_multiplier() -> float:
	return easy_shield_recharge_multiplier if difficulty == "Easy" else 1.0

func focus_refill_delay_multiplier() -> float:
	return easy_focus_refill_delay_multiplier if difficulty == "Easy" else 1.0

func set_crt_filter_enabled(value: bool) -> void:
	crt_filter_enabled = value
	_crt_overlay.visible = value
	save_settings()
	settings_changed.emit()

func set_screen_shake_enabled(value: bool) -> void:
	screen_shake_enabled = value
	save_settings()
	settings_changed.emit()

func set_high_contrast_bullets(value: bool) -> void:
	high_contrast_bullets = value
	save_settings()
	settings_changed.emit()

func set_difficulty(value: String) -> void:
	difficulty = value
	save_settings()
	settings_changed.emit()

func remap_action(action: String, event: InputEvent) -> void:
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	save_settings()
	settings_changed.emit()

func reset_action(action: String) -> void:
	InputMap.action_erase_events(action)
	for event: InputEvent in _default_events.get(action, []):
		InputMap.action_add_event(action, event)
	save_settings()
	settings_changed.emit()

func get_action_binding_text(action: String) -> String:
	var events: Array = InputMap.action_get_events(action)
	for event: InputEvent in events:
		if event is InputEventKey:
			var key_event: InputEventKey = event as InputEventKey
			var keycode: int = key_event.physical_keycode if key_event.physical_keycode != 0 else key_event.keycode
			return OS.get_keycode_string(keycode)
		if event is InputEventJoypadButton:
			return "Pad %d" % (event as InputEventJoypadButton).button_index
		if event is InputEventMouseButton:
			return "Mouse %d" % (event as InputEventMouseButton).button_index
	return "-"

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	crt_filter_enabled = config.get_value("display", "crt_filter_enabled", crt_filter_enabled)
	screen_shake_enabled = config.get_value("display", "screen_shake_enabled", screen_shake_enabled)
	high_contrast_bullets = config.get_value("display", "high_contrast_bullets", high_contrast_bullets)
	difficulty = config.get_value("gameplay", "difficulty", difficulty)
	for action: String in REMAPPABLE_ACTIONS:
		var event: InputEvent = config.get_value("bindings", action, null)
		if event != null:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("display", "crt_filter_enabled", crt_filter_enabled)
	config.set_value("display", "screen_shake_enabled", screen_shake_enabled)
	config.set_value("display", "high_contrast_bullets", high_contrast_bullets)
	config.set_value("gameplay", "difficulty", difficulty)
	for action: String in REMAPPABLE_ACTIONS:
		var events: Array = InputMap.action_get_events(action)
		if not events.is_empty():
			config.set_value("bindings", action, events[0])
	config.save(SETTINGS_PATH)
