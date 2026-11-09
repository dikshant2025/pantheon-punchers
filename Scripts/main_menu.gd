extends Control

func _ready() -> void:
	# Keep your existing fullscreen + volume setup:
	$SettingsMenu/CenterContainer/SettingsButtons/Fullscreen.button_pressed = (
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	)
	$SettingsMenu/CenterContainer/SettingsButtons/MainVolSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	$SettingsMenu/CenterContainer/SettingsButtons/MusicVolSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	$SettingsMenu/CenterContainer/SettingsButtons/SFXVolSlider.value   = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))

	# Give focus to LOCAL GAME (Play) button when the menu appears
	var play_button := $CenterContainer/MainButtons/Play
	play_button.grab_focus()
	var stream: AudioStream = load("res://Audio/David Orr- Four Brave Champions (Castle Crashers Main Theme).mp3")
	MusicManager.play_music(stream)

func _on_play_pressed() -> void:
	UIAudio.play_click()
	get_tree().change_scene_to_file("res://Scene/user_selection.tscn")

func _on_settings_pressed() -> void:
	UIAudio.play_click()
	$SettingsMenu.visible = true
	$SettingsMenu/CenterContainer/SettingsButtons/Back.grab_focus()
	
func _on_quit_pressed() -> void:
	UIAudio.play_click()
	get_tree().quit()

func _on_back_pressed() -> void:
	UIAudio.play_click()
	$SettingsMenu.visible = false
	$CenterContainer/MainButtons/Play.grab_focus()

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	UIAudio.play_click()
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		
func _on_focus_entered() -> void:
	UIAudio.play_move()

func _on_main_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)

func _on_music_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), value)

func _on_sfx_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), value)
