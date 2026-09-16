extends CanvasLayer

@onready var _portrait: ColorRect = $Panel/Portrait
@onready var _speaker_label: Label = $Panel/SpeakerLabel
@onready var _text_label: Label = $Panel/TextLabel

func _ready() -> void:
	visible = false

func show_dialogue(entry: DialogueEntry) -> void:
	_portrait.color = entry.portrait_color
	_speaker_label.text = entry.speaker_name
	_text_label.text = entry.text
	visible = true

func hide_dialogue() -> void:
	visible = false
