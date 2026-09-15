extends Resource
class_name PickupData

enum PickupType { WEAPON_LEVEL, HULL_REPAIR, SPECIAL_CHARGE }

@export var pickup_type: PickupType = PickupType.HULL_REPAIR
@export var pickup_color: Color = Color.WHITE
@export var amount: float = 1.0
@export var drift_speed: float = 40.0
@export var pickup_radius: float = 10.0
