extends Node2D

## Cliff walls down both sides of the playfield that narrow and widen as the
## ground scrolls (the Fjords twist). The shape comes from the mission's
## `wall_keys`: each key is (distance scrolled in px, left wall width, right wall
## width), smoothly blended between keys. The walls scroll with the ground, stop
## when a boss locks the scroll, and push the player back into the channel with
## contact damage if they're touched.

@export var mission: MissionData
@export var rock_texture: Texture2D
## Height of each drawn strip. Edges step on this grid, so keep it a whole number.
@export var band_height: int = 4
## Random-looking (but deterministic) roughness of the cliff edge, in pixels.
@export var edge_jitter_px: int = 2
@export var shadow_width_px: int = 3
@export var shadow_color: Color = Color("2e222f")
@export var rim_color: Color = Color("9babb2")
@export var contact_damage: float = 1.0
@export var contact_cooldown: float = 0.6
## How far from the wall the player's centre is kept, so the ship sprite doesn't sink into the rock.
@export var push_margin: float = 8.0
## Smoothstep between wall keys (gentle Fjords bends). Off gives straight
## zigzag runs with sharp corners (the Grand Canyon).
@export var smooth_bends: bool = true

var _scrolled: float = 0.0
var _contact_timer: float = 0.0
var _ground: Node = null
var _rect: Rect2 = Rect2()

func _ready() -> void:
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_ground = get_tree().get_first_node_in_group("scrolling_background")
	_rect = get_node("/root/Playfield").rect
	var game_state: Node = get_node("/root/GameState")
	_scrolled = mission.get_section_start_time(game_state.restart_section) * mission.background_scroll_speed

func _physics_process(delta: float) -> void:
	if _ground != null:
		_scrolled += _ground.get_ground_speed() * delta
	_contact_timer = maxf(0.0, _contact_timer - delta)
	_push_player()
	queue_redraw()

## Wall widths (left, right) at a given screen y, in global coordinates.
func get_walls_at(screen_y: float) -> Vector2:
	var distance: float = _scrolled + (_rect.end.y - screen_y)
	return _widths_at_distance(distance)

func _widths_at_distance(distance: float) -> Vector2:
	var keys: PackedVector3Array = mission.wall_keys
	if keys.is_empty():
		return Vector2.ZERO
	if distance <= keys[0].x:
		return Vector2(keys[0].y, keys[0].z)
	for i in range(1, keys.size()):
		if distance <= keys[i].x:
			var a: Vector3 = keys[i - 1]
			var b: Vector3 = keys[i]
			var t: float = smoothstep(a.x, b.x, distance) if smooth_bends else inverse_lerp(a.x, b.x, distance)
			return Vector2(lerpf(a.y, b.y, t), lerpf(a.z, b.z, t))
	var last: Vector3 = keys[keys.size() - 1]
	return Vector2(last.y, last.z)

func _jitter(distance: float, side: int) -> int:
	if edge_jitter_px <= 0:
		return 0
	var cell: int = floori(distance / float(band_height))
	var h: int = (cell * 73856093) ^ (side * 19349663)
	return absi(h) % (edge_jitter_px * 2 + 1) - edge_jitter_px

func _push_player() -> void:
	var player: Node2D = get_node("/root/BulletManager").get_registered_player()
	if player == null:
		return
	var walls: Vector2 = get_walls_at(player.global_position.y)
	var min_x: float = _rect.position.x + walls.x + push_margin
	var max_x: float = _rect.end.x - walls.y - push_margin
	var touched: bool = false
	if player.global_position.x < min_x:
		player.global_position.x = min_x
		touched = true
	elif player.global_position.x > max_x:
		player.global_position.x = max_x
		touched = true
	if touched and _contact_timer <= 0.0 and walls.x + walls.y > 0.0:
		player.take_hit(contact_damage)
		_contact_timer = contact_cooldown

func _draw() -> void:
	if rock_texture == null:
		return
	var origin: Vector2 = to_local(_rect.position)
	var tex_h: float = rock_texture.get_size().y
	# Rock scrolls with the ground: shift the texture lookup by the scrolled distance.
	var scroll_offset: float = fposmod(-roundf(_scrolled), tex_h)
	var y: int = 0
	var height: int = int(_rect.size.y)
	while y < height:
		var distance: float = _scrolled + (_rect.size.y - float(y))
		var walls: Vector2 = _widths_at_distance(distance)
		var left_w: int = 0 if roundi(walls.x) <= 0 else maxi(0, roundi(walls.x) + _jitter(distance, 1))
		var right_w: int = 0 if roundi(walls.y) <= 0 else maxi(0, roundi(walls.y) + _jitter(distance, 2))
		var src_y: float = float(y) + scroll_offset
		if left_w > 0:
			draw_texture_rect_region(rock_texture, Rect2(origin.x, origin.y + y, left_w, band_height), Rect2(0, src_y, left_w, band_height))
			draw_rect(Rect2(origin.x + left_w, origin.y + y, shadow_width_px, band_height), shadow_color)
			draw_rect(Rect2(origin.x + left_w - 1, origin.y + y, 1, band_height), rim_color)
		if right_w > 0:
			var rx: float = origin.x + _rect.size.x - right_w
			draw_texture_rect_region(rock_texture, Rect2(rx, origin.y + y, right_w, band_height), Rect2(_rect.size.x - right_w, src_y, right_w, band_height))
			draw_rect(Rect2(rx - shadow_width_px, origin.y + y, shadow_width_px, band_height), shadow_color)
			draw_rect(Rect2(rx, origin.y + y, 1, band_height), rim_color)
		y += band_height
