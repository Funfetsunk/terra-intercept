extends EnemyBase

## A tanker car in the harvester convoy. The parent ConvoyBoss moves it; it
## just fires its pattern and can be destroyed. `slot` is its place in the line
## behind the engine (1 = first car), so gaps stay where cars were destroyed.

@export var slot: int = 1

func _ready() -> void:
	super._ready()
	add_to_group("convoy_car")
	set_meta("slot", slot)
	# Stagger the first volley by slot so the cars don't all fire at once.
	_burst_timer += 0.3 * float(slot)
