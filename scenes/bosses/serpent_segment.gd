extends EnemyBase

## A serpent-dragon body segment. The parent SerpentBoss places it along the
## head's trail by `slot`. It fires its own pattern (staggered by slot) and can
## be shot off; when the head dies, `explode()` destroys it without score.

@export var slot: int = 1

func _ready() -> void:
	super._ready()
	add_to_group("serpent_segment")
	set_meta("slot", slot)
	_burst_timer += 0.35 * float(slot)

func explode() -> void:
	if data.explosion_scene != null:
		var boom: Node2D = data.explosion_scene.instantiate()
		boom.position = get_parent().to_local(global_position)
		get_parent().call_deferred("add_child", boom)
	queue_free()
