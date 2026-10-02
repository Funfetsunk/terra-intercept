extends Control

## Ending credits: the lines from `credits` scroll up over space at
## `scroll_speed` (hold confirm/ordnance to speed up). When the last line has
## passed, the epilogue (the sequel hook) types out, then the screen fades and
## returns to the title.

@export var credits: CreditsData
@export var scroll_speed: float = 22.0
@export var fast_multiplier: float = 5.0
@export var epilogue_char_time: float = 0.045
@export var epilogue_hold: float = 4.0
@export var title_scene: String = "res://scenes/menus/title_screen.tscn"
## The roll starts just below this line (the bottom of the 640x360 view).
@export var start_y: float = 360.0

var _done_scrolling: bool = false
var _leaving: bool = false
var _y: float = 0.0

@onready var _roll: Label = $Roll
@onready var _epilogue: Label = $Epilogue
@onready var _fade: CanvasLayer = $ScreenFade

func _ready() -> void:
	_roll.text = "\n".join(credits.lines)
	_y = start_y
	_roll.position.y = _y
	_epilogue.text = credits.epilogue
	_epilogue.visible_characters = 0
	_epilogue.visible = false

func _process(delta: float) -> void:
	if _done_scrolling:
		return
	var fast: bool = Input.is_action_pressed("p1_ordnance") or Input.is_action_pressed("ui_accept")
	_y -= scroll_speed * (fast_multiplier if fast else 1.0) * delta
	_roll.position.y = roundf(_y)
	if _y + _roll.size.y < 0.0:
		_done_scrolling = true
		_play_epilogue()

func _play_epilogue() -> void:
	_epilogue.visible = true
	var total: int = _epilogue.text.length()
	for i in range(total + 1):
		_epilogue.visible_characters = i
		await get_tree().create_timer(epilogue_char_time).timeout
	await get_tree().create_timer(epilogue_hold).timeout
	_leave()

func _leave() -> void:
	if _leaving:
		return
	_leaving = true
	await _fade.fade_out()
	get_tree().change_scene_to_file(title_scene)
