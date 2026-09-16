extends Resource
class_name MissionData

@export var mission_name: String = ""
@export var background_scroll_speed: float = 0.0
@export var spawn_entries: Array[SpawnEntry] = []
@export var dialogue_events: Array[DialogueEntry] = []
@export var section_markers: Array[MissionSectionMarker] = []

func get_section_start_time(section: String) -> float:
	if section.is_empty():
		return 0.0
	for marker: MissionSectionMarker in section_markers:
		if marker.section_name == section:
			return marker.start_time
	return 0.0
