extends AnimatedSprite2D
class_name Explosion

## One-shot effect: plays its "boom" animation once, then removes itself.

func _ready() -> void:
	animation_finished.connect(queue_free)
	play("boom")
