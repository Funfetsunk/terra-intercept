extends Resource
class_name PickupData

enum PickupType { WEAPON_LEVEL, HULL_REPAIR, SPECIAL_CHARGE, ORDNANCE }

@export var pickup_type: PickupType = PickupType.HULL_REPAIR
@export var pickup_color: Color = Color.WHITE
@export var amount: float = 1.0
## ORDNANCE pickups: the type they carry. `amount` is the top-up when it
## matches the current type; a different type swaps the slot and refills it.
@export var ordnance: OrdnanceData
@export var drift_speed: float = 40.0
@export var pickup_radius: float = 10.0
