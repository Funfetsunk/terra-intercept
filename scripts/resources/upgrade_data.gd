extends Resource
class_name UpgradeData

@export var id: String = ""
@export var upgrade_name: String = ""
@export var description: String = ""
## Price of the first level.
@export var cost: int = 0
## Added to the price for each level already owned (level 2 costs
## cost + cost_increase_per_level, and so on).
@export var cost_increase_per_level: int = 0
## A ShipData property to add to, or one of the run stats GameState reads at
## mission start: "starting_weapon_level", "ordnance_capacity",
## "pickup_magnet_radius".
@export var stat_name: String = ""
@export var value_per_level: float = 0.0
@export var max_level: int = 1
@export var unlock_column: int = 1
## 16x16 icon shown in the hangar list.
@export var icon: Texture2D

## Price of the next level, given how many levels are already owned.
func cost_for_level(owned_level: int) -> int:
	return cost + cost_increase_per_level * owned_level
