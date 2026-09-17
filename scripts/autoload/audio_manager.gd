extends Node

@onready var _music_player: AudioStreamPlayer = $MusicPlayer

func play_music(stream: AudioStream) -> void:
	if stream == null:
		stop_music()
		return
	if _music_player.stream == stream and _music_player.playing:
		return
	_music_player.stream = stream
	_music_player.play()

func stop_music() -> void:
	_music_player.stop()
	_music_player.stream = null

func get_current_music() -> AudioStream:
	return _music_player.stream
