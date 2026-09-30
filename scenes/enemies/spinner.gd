extends EnemyBase

@export var hover_y: float = 90.0
## Seconds the spinner holds position before sinking off the bottom of the
## screen. 0 holds forever (until destroyed).
@export var hover_duration: float = 0.0
@export var exit_speed: float = 45.0

var _hover_timer: float = 0.0

func _process_movement(delta: float) -> void:
	if global_position.y < hover_y and _hover_timer == 0.0:
		global_position.y = min(hover_y, global_position.y + data.move_speed * delta)
		return
	if hover_duration <= 0.0:
		return
	_hover_timer += delta
	if _hover_timer >= hover_duration:
		global_position.y += exit_speed * delta
		if global_position.y > despawn_y:
			queue_free()
