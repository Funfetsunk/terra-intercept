extends "res://scenes/bosses/stage_boss.gd"

## The mothership's core: a stage boss (two phases, completes the mission)
## spawned by MothershipBoss once the hull turrets are gone. It sits in the open
## hatch, so it doesn't lock or move the ground. Its death destroys the hull and
## opens the portal through the parent's destroy_hull().

func _ready() -> void:
	lock_background_scroll = false
	super._ready()

func _die() -> void:
	var ship: Node = get_parent()
	if ship != null and ship.has_method("destroy_hull"):
		ship.destroy_hull()
	super._die()
