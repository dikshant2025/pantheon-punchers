# MusicManager.gd

extends Node

@onready var player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	add_child(player)
	player.bus = "Music"

func play_music(stream: AudioStream, loop: bool = true, volume_db: float = 0.0) -> void:
	if stream == null:
		return

	if player.stream == stream and player.playing:
		return

	if stream is AudioStreamOggVorbis:
		var ogg_stream := stream as AudioStreamOggVorbis
		ogg_stream.loop = loop

	player.stop()
	player.stream = stream
	player.stream_paused = false
	player.autoplay = false
	player.volume_db = volume_db      # 🔹 set loudness for this track
	player.play()
