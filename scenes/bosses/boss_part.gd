extends EnemyBase

## A destructible part of a larger boss (kaiju arms, back cannons). It sits as a
## child of the boss body, so it moves with it, fires its own pattern (the first
## volley delayed by `first_volley_delay`) and can be shot off. When the boss
## dies, `explode()` destroys it without awarding score.

@export var first_volley_delay: float = 0.0
## Mirror the art (pixel-exact) for the right-hand copy of a part.
@export var mirror: bool = false

func _ready() -> void:
	super._ready()
	_burst_timer += first_volley_delay
	var sprite: AnimatedSprite2D = get_node_or_null("Sprite") as AnimatedSprite2D
	if sprite != null:
		sprite.flip_h = mirror

func explode() -> void:
	if data.explosion_scene != null:
		var boom: Node2D = data.explosion_scene.instantiate()
		boom.global_position = global_position
		get_tree().current_scene.get_node("PlayfieldRoot").call_deferred("add_child", boom)
	queue_free()
