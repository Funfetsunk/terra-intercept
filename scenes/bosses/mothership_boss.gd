extends Node2D

## Alien mothership (Orbital boss), fought in two parts.
## Part 1: the `Hull` sprite (wider than the playfield; the HUD panels hide its
## ends) carries BossPart turrets. The hull itself can't be hurt.
## Part 2: when every turret is destroyed, the hull's hatch opens (`open`
## animation) and `core_scene` is spawned at `core_offset`. The core is a
## stage_boss with its own two phases; its death completes the mission and
## calls `destroy_hull()` here, and `portal_scene` opens at the top of the
## screen for the squad to fly into.

@export var core_scene: PackedScene
@export var core_offset: Vector2 = Vector2(0, 6)
@export var portal_scene: PackedScene
@export var portal_relative: Vector2 = Vector2(0.5, 0.12)
@export var hover_y: float = 64.0
@export var entry_speed: float = 18.0
@export var entry_scroll_speed: float = 20.0
@export var music: AudioStream
@export var explosion_scene: PackedScene
@export var hull_explosion_count: int = 9

var _arrived: bool = false
var _core_spawned: bool = false
var _hull_destroyed: bool = false

@onready var _hull: AnimatedSprite2D = $Hull

func _ready() -> void:
	if music != null:
		get_node("/root/AudioManager").play_music(music)
	get_tree().call_group("scrolling_background", "set_scroll_speed", entry_scroll_speed)
	_hull.play("closed")

func _physics_process(delta: float) -> void:
	if not _arrived:
		global_position.y = minf(hover_y, global_position.y + entry_speed * delta)
		if global_position.y >= hover_y:
			_arrived = true
			get_tree().call_group("scrolling_background", "set_scroll_speed", 0.0)
	if not _core_spawned and _arrived and _turrets_left() == 0:
		_open_hatch()

func _turrets_left() -> int:
	var n: int = 0
	for child: Node in get_children():
		if child is EnemyBase and child.has_method("explode") and not child.is_queued_for_deletion():
			n += 1
	return n

func _open_hatch() -> void:
	_core_spawned = true
	_hull.play("open")
	if core_scene == null:
		return
	var core: Node2D = core_scene.instantiate()
	core.position = core_offset
	core.set("hover_y", global_position.y + core_offset.y)
	add_child(core)

## Called by the core when it dies: blow the hull apart and open the portal.
func destroy_hull() -> void:
	if _hull_destroyed:
		return
	_hull_destroyed = true
	var root: Node = get_parent()
	if explosion_scene != null:
		var w: float = 300.0
		for i in range(hull_explosion_count):
			var boom: Node2D = explosion_scene.instantiate()
			var t: float = float(i) / float(maxi(1, hull_explosion_count - 1))
			boom.position = root.to_local(global_position + Vector2(lerpf(-w * 0.5, w * 0.5, t), float((i * 37) % 40) - 20.0))
			root.call_deferred("add_child", boom)
	if portal_scene != null:
		var portal: Node2D = portal_scene.instantiate()
		var rect: Rect2 = get_node("/root/Playfield").rect
		portal.position = root.to_local((rect.position + portal_relative * rect.size).round())
		portal.add_to_group("victory_target")
		root.call_deferred("add_child", portal)
	_hull.visible = false
