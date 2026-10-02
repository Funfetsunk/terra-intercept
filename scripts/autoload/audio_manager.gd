extends Node

## When music is disabled (Settings), the requested track is still remembered
## so turning music back on resumes it.
var music_enabled: bool = true

@onready var _music_player: AudioStreamPlayer = $MusicPlayer

func play_music(stream: AudioStream) -> void:
	if stream == null:
		stop_music()
		return
	if _music_player.stream == stream and (_music_player.playing or not music_enabled):
		return
	_music_player.stream = stream
	if music_enabled:
		_music_player.play()

func stop_music() -> void:
	_music_player.stop()
	_music_player.stream = null

func set_music_enabled(value: bool) -> void:
	music_enabled = value
	if not value:
		_music_player.stop()
	elif _music_player.stream != null and not _music_player.playing:
		_music_player.play()

func get_current_music() -> AudioStream:
	return _music_player.stream
