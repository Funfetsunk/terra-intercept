extends Resource
class_name UpgradeData

@export var id: String = ""
@export var upgrade_name: String = ""
@export var description: String = ""
@export var cost: int = 0
@export var stat_name: String = ""
@export var value_per_level: float = 0.0
@export var max_level: int = 1
@export var unlock_column: int = 1
## 16x16 icon shown in the hangar list.
@export var icon: Texture2D
