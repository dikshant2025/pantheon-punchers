extends CanvasLayer

func _ready() -> void:
	self.hide()

func _on_retry_pressed() -> void:
	UIAudio.play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/main_menu.tscn")  # or reload level

func game_over() -> void:
	get_tree().paused = true
	self.show()
	var stream: AudioStream = load("res://Audio/David Orr- Four Brave Champions (Castle Crashers Main Theme).mp3")
	MusicManager.play_music(stream)
