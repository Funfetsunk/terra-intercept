extends CanvasLayer

## Palette backdrop behind real portrait art. portrait_color is only used for
## lines that have no portrait texture (placeholder swatch).
@export var portrait_backdrop_color: Color = Color("3e3546")

@onready var _portrait: ColorRect = $Panel/Portrait
@onready var _portrait_art: TextureRect = $Panel/Portrait/Art
@onready var _speaker_label: Label = $Panel/SpeakerLabel
@onready var _text_label: Label = $Panel/TextLabel

func _ready() -> void:
	visible = false

func show_dialogue(entry: DialogueEntry) -> void:
	_portrait.color = portrait_backdrop_color if entry.portrait != null else entry.portrait_color
	_portrait_art.texture = entry.portrait
	_speaker_label.text = entry.speaker_name
	_text_label.text = entry.text
	visible = true

func hide_dialogue() -> void:
	visible = false
