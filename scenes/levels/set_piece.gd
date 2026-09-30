extends Node2D
class_name SetPiece

## A one-off landmark (the Eiffel Tower, for example) that scrolls past with the
## ground layer instead of being baked into a repeating background tile. Spawned
## through a SpawnEntry like an enemy, drawn under gameplay, and removed once it
## has scrolled off the bottom. It follows the ground's current speed, so it
## stops when a boss locks the scroll.

## Extra distance below the playfield before the set piece is removed.
@export var exit_margin: float = 200.0

var _ground: Node = null
var _y: float = 0.0

func _ready() -> void:
	_ground = get_tree().get_first_node_in_group("scrolling_background")
	_y = position.y

func _physics_process(delta: float) -> void:
	var speed: float = 0.0
	if _ground != null and _ground.has_method("get_ground_speed"):
		speed = _ground.get_ground_speed()
	_y += speed * delta
	position.y = roundf(_y)
	if global_position.y > get_node("/root/Playfield").rect.end.y + exit_margin:
		queue_free()
