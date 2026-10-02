extends Resource
class_name MissionData

@export var mission_name: String = ""
@export var background_scroll_speed: float = 0.0
@export var spawn_entries: Array[SpawnEntry] = []
@export var dialogue_events: Array[DialogueEntry] = []
@export var section_markers: Array[MissionSectionMarker] = []
@export var tutorial_beats: Array[TutorialBeat] = []
@export var squad_radio_text_format: String = "%s here. Special charged — try me out, pilot."
@export var tutorial_music: AudioStream
@export var stage_music: AudioStream
@export var pre_briefing_lines: Array[Resource] = []
@export var post_briefing_lines: Array[Resource] = []
## Scene shown after the post-mission briefing instead of the hangar (the
## finale goes to the ending credits). Empty means the hangar.
@export var after_mission_scene: String = ""
## Fjord-style side walls: each key is (distance scrolled in px, left wall
## width, right wall width). Empty means no walls.
@export var wall_keys: PackedVector3Array = PackedVector3Array()
## Ice-fog banks: each is (distance in px at which the bank's leading edge
## reaches the bottom of the screen, length in px, density 0-1).
@export var fog_banks: PackedVector3Array = PackedVector3Array()
## Sandstorm gusts: each is (start time in s, duration in s, sideways push in
## px/s; negative pushes left).
@export var gusts: PackedVector3Array = PackedVector3Array()
## Ground pan (Great Wall): each key is (distance scrolled in px, sideways pan in
## px), smoothstepped between keys. Empty means no pan.
@export var pan_keys: PackedVector2Array = PackedVector2Array()
## Avalanches: each is (start time in s, lane centre 0-1 across the playfield,
## lane width in px).
@export var avalanches: PackedVector3Array = PackedVector3Array()

func get_section_start_time(section: String) -> float:
	if section.is_empty():
		return 0.0
	for marker: MissionSectionMarker in section_markers:
		if marker.section_name == section:
			return marker.start_time
	return 0.0
