extends Resource
class_name MapNodeData

@export var id: String = ""
@export var display_name: String = ""
@export var column: int = 1
@export var lane: String = ""
@export var mission_scene_path: String = ""
@export var mission_data: MissionData = null
## Where the node's icon sits on the world-map background, in screen pixels.
@export var map_position: Vector2 = Vector2.ZERO
## Where the place name sits, as the offset from the icon centre to the label centre.
@export var label_offset: Vector2 = Vector2(0, 16)
