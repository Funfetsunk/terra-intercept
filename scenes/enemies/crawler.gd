extends EnemyBase

## Crawler: a ground tank locked to the terrain. It rides the ground scroll,
## follows the ground's sideways pan (the Great Wall, via the "ground_pan"
## group) and crawls slowly against the scroll. Its turret glows for
## `charge_time` before each burst of data.pattern.

@export var crawl_speed: float = 12.0
@export var charge_time: float = 0.5

var _ground: Node = null
var _pan: Node = null
## Horizontal offset from the playfield centre in ground space (before pan).
## The spawn x is read as ground space, so relative 0.5 is always the Wall.
var _ground_x: float = 0.0
var _charging: bool = false

@onready var _sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	super._ready()
	_ground = get_tree().get_first_node_in_group("scrolling_background")
	_pan = get_tree().get_first_node_in_group("ground_pan")
	var center_x: float = get_node("/root/Playfield").rect.get_center().x
	_ground_x = global_position.x - center_x
	global_position.x = roundf(center_x + _ground_x + _current_pan())
	_sprite.play("idle")

func _current_pan() -> float:
	return _pan.get_pan() if _pan != null else 0.0

func _process_movement(delta: float) -> void:
	var speed: float = 0.0
	if _ground != null:
		speed = _ground.get_ground_speed()
	global_position.y += (speed - crawl_speed) * delta
	global_position.x = roundf(get_node("/root/Playfield").rect.get_center().x + _ground_x + _current_pan())
	if global_position.y > despawn_y:
		queue_free()

func _process_pattern(delta: float) -> void:
	if _current_pattern == null:
		return
	_burst_timer -= delta
	if not _charging and _burst_timer <= charge_time:
		_charging = true
		_sprite.play("charge")
	if _burst_timer <= 0.0:
		_fire_burst(_current_pattern)
		_burst_timer += _current_pattern.burst_interval
		_charging = false
		_sprite.play("idle")
