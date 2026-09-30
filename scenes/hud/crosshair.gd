extends CanvasLayer

## Pixel crosshair for mouse aiming. The OS cursor isn't scaled with the
## game, so during missions it is hidden and this sprite is drawn at the mouse
## position in game pixels instead. It shows while the mouse is being used and
## hides when the pad is, and gives the OS cursor back whenever the game is
## paused (pause menu, tutorial prompts) or this node leaves the tree.

## Stick deflection that counts as the player switching to the pad.
@export var pad_switch_deadzone: float = 0.3

var _using_mouse: bool = true

@onready var _sprite: Sprite2D = $Crosshair

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_refresh()

func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		_using_mouse = true
	elif event is InputEventJoypadButton:
		_using_mouse = false
	elif event is InputEventJoypadMotion and absf((event as InputEventJoypadMotion).axis_value) > pad_switch_deadzone:
		_using_mouse = false

func _process(_delta: float) -> void:
	_refresh()

func _refresh() -> void:
	var paused: bool = get_tree().paused
	var show_crosshair: bool = _using_mouse and not paused
	_sprite.visible = show_crosshair
	_sprite.position = get_viewport().get_mouse_position().floor()
	var wanted: Input.MouseMode = Input.MOUSE_MODE_HIDDEN if (show_crosshair or not _using_mouse) and not paused else Input.MOUSE_MODE_VISIBLE
	if Input.mouse_mode != wanted:
		Input.mouse_mode = wanted
