extends Node2D

## Avalanche lanes (the Himalayas twist). Each avalanche in the mission's
## `avalanches` is (start time in s, lane centre 0-1 across the playfield, lane
## width in px). For `telegraph_duration` before it, chevrons blink at the top
## of the lane and snow trickles down it. Then a slab of snow (`slide_length`
## tall, drawn by the dither shader on one of the Slide ColorRects) sweeps down
## the lane. It hits the player once for `damage`, destroys regular enemies and
## clears enemy bullets inside it. Bosses are unaffected.

@export var mission: MissionData
@export var telegraph_duration: float = 1.6
@export var slide_speed: float = 420.0
@export var slide_length: float = 150.0
@export var damage: float = 3.0
@export var enemy_damage: float = 999.0
@export var warning_texture: Texture2D = preload("res://art/sprites/enemies/flanker_warning.png")
@export var warning_blink_interval: float = 0.12
@export var trickle_count: int = 24
@export var trickle_color: Color = Color("c7dcd0")
@export var feather_px: float = 36.0

var _elapsed: float = 0.0
var _rect: Rect2 = Rect2()
var _hit: Dictionary = {}
var _slides: Array[ColorRect] = []

func _ready() -> void:
	_rect = get_node("/root/Playfield").rect
	var game_state: Node = get_node("/root/GameState")
	_elapsed = mission.get_section_start_time(game_state.restart_section)
	for child: Node in get_children():
		if child is ColorRect:
			_slides.append(child as ColorRect)
			(child as ColorRect).visible = false

func _physics_process(delta: float) -> void:
	_elapsed += delta
	var slide_index: int = 0
	for i in range(mission.avalanches.size()):
		var a: Vector3 = mission.avalanches[i]
		var t: float = _elapsed - a.x
		var travel: float = t * slide_speed
		var top: float = travel - slide_length
		if t < 0.0 or top > _rect.size.y:
			continue
		if slide_index >= _slides.size():
			break
		var lane_x: float = roundf(_rect.size.x * a.y - a.z * 0.5)
		var band: Rect2 = Rect2(lane_x, top, a.z, slide_length)
		_show_slide(_slides[slide_index], band)
		slide_index += 1
		_apply_slide(i, Rect2(_rect.position + band.position, band.size))
	for j in range(slide_index, _slides.size()):
		_slides[j].visible = false
	queue_redraw()

func _show_slide(slide: ColorRect, band: Rect2) -> void:
	var origin: Vector2 = to_local(_rect.position)
	var clipped: Rect2 = band.intersection(Rect2(Vector2.ZERO, _rect.size))
	slide.visible = clipped.size.y > 0.0
	if not slide.visible:
		return
	slide.position = origin + clipped.position
	slide.size = clipped.size
	var mat: ShaderMaterial = slide.material as ShaderMaterial
	mat.set_shader_parameter("rect_size", clipped.size)
	# Dense core with a soft leading and trailing edge, in the slide's own pixels.
	var top_in_rect: float = band.position.y - clipped.position.y
	var banks: Array[Vector4] = [Vector4(top_in_rect, top_in_rect + band.size.y, 1.0, feather_px), Vector4.ZERO, Vector4.ZERO, Vector4.ZERO]
	mat.set_shader_parameter("banks", banks)
	mat.set_shader_parameter("bank_count", 1)

func _apply_slide(index: int, band: Rect2) -> void:
	var bullets: Node = get_node("/root/BulletManager")
	bullets.clear_enemy_bullets_in_rect(band)
	var player: Node2D = bullets.get_registered_player()
	if player != null and player.visible and not _hit.has(index) and band.has_point(player.global_position):
		_hit[index] = true
		player.take_hit(damage)
	for child: Node in get_parent().get_children():
		if child is EnemyBase and not ((child as EnemyBase).data is BossData):
			if band.has_point((child as Node2D).global_position):
				(child as EnemyBase).take_damage(enemy_damage)

func _draw() -> void:
	var origin: Vector2 = to_local(_rect.position)
	var blink_on: bool = int(_elapsed / warning_blink_interval) % 2 == 0
	for a: Vector3 in mission.avalanches:
		var until: float = a.x - _elapsed
		if until <= 0.0 or until > telegraph_duration:
			continue
		var lane_x: float = roundf(_rect.size.x * a.y - a.z * 0.5)
		# Snow trickling down the lane, thicker as the slide gets closer.
		var progress: float = 1.0 - until / telegraph_duration
		var count: int = int(trickle_count * progress) + 4
		for k in range(count):
			var h: int = absi((k * 73856093) ^ 83492791)
			var x: float = lane_x + float(h % int(a.z))
			var y: float = fposmod(float((h >> 4) % 360) + _elapsed * (90.0 + float((h >> 9) % 60)), _rect.size.y)
			draw_rect(Rect2(roundf(origin.x + x), roundf(origin.y + y), 1, 2), trickle_color)
		if blink_on and warning_texture != null:
			var size: Vector2 = warning_texture.get_size()
			for c in range(3):
				var cx: float = lane_x + a.z * (0.25 + 0.25 * float(c))
				# Chevron art points right; a quarter turn makes it point down, pixel-exact.
				draw_set_transform(Vector2(roundf(origin.x + cx), roundf(origin.y + 10.0)), PI * 0.5, Vector2.ONE)
				draw_texture(warning_texture, -size * 0.5)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
