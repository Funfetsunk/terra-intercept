extends EnemyBase

## Carrier: a slow, armoured ship that drifts down the screen and launches
## smaller enemies from its bay. The bay doors open for `bay_open_duration`
## before each launch (the telegraph), then close again.

@export var launch_scene: PackedScene
@export var launch_interval: float = 3.0
@export var first_launch_delay: float = 1.5
@export var bay_open_duration: float = 0.6
@export var max_launches: int = 3
## Where launched enemies appear, relative to the carrier's centre.
@export var launch_offset: Vector2 = Vector2(0.0, 10.0)
## Y the carrier slows to a crawl at, so it hangs on screen long enough to launch.
@export var cruise_y: float = 110.0
@export var cruise_speed: float = 6.0

var _launch_timer: float = 0.0
var _launches: int = 0
var _bay_open: bool = false

@onready var _sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	super._ready()
	_launch_timer = first_launch_delay

func _process_movement(delta: float) -> void:
	var speed: float = data.move_speed if global_position.y < cruise_y or _launches >= max_launches else cruise_speed
	global_position.y += speed * delta
	if global_position.y > despawn_y:
		queue_free()
		return
	_process_launch(delta)

func _process_launch(delta: float) -> void:
	if _launches >= max_launches or launch_scene == null:
		return
	_launch_timer -= delta
	if not _bay_open and _launch_timer <= bay_open_duration:
		_bay_open = true
		_sprite.play("open")
	if _launch_timer <= 0.0:
		_launch()
		_launches += 1
		_launch_timer = launch_interval
		_bay_open = false
		_sprite.play("idle")

func _launch() -> void:
	var child: Node2D = launch_scene.instantiate()
	child.position = get_parent().to_local(global_position + launch_offset)
	get_parent().call_deferred("add_child", child)
