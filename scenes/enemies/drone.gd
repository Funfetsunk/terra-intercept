extends EnemyBase

func _process_movement(delta: float) -> void:
	global_position.y += data.move_speed * delta
	if global_position.y > despawn_y:
		queue_free()
