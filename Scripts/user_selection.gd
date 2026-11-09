extends Control

# Map slot_id -> the frame nodes in the scene
@onready var player_frames = {
	1: $CenterContainer/HBoxContainer/PlayerOneFrame,
	2: $CenterContainer/HBoxContainer/PlayerTwoFrame,
	3: $CenterContainer/HBoxContainer/PlayerThreeFrame,
	4: $CenterContainer/HBoxContainer/PlayerFourFrame,
}

# device_id -> slot_id
var device_to_slot: Dictionary = {}


func _get_player_registry() -> Node:
	# Get the autoload node **by path**, not via global variable
	var pr := get_node_or_null("/root/PlayerRegistry")
	if pr == null:
		push_error("PlayerRegistry node not found at /root/PlayerRegistry. Check Project Settings → Autoload.")
	return pr


func _ready() -> void:
	var pr = _get_player_registry()
	if pr == null:
		return
	_refresh_ui()
	if player_frames.has(1):
		var frame = player_frames[1]
		var btn: Button = frame.get_node("Button")
		btn.grab_focus()
	var stream: AudioStream = load("res://Audio/David Orr- Four Brave Champions (Castle Crashers Main Theme).mp3")
	MusicManager.play_music(stream)

func _refresh_ui() -> void:
	var pr = _get_player_registry()
	if pr == null:
		return

	# Update texts and portraits based on who has joined
	for slot_id in player_frames.keys():
		var frame = player_frames[slot_id]
		var bg: TextureRect = frame.get_node("TextureRect")
		var portrait: TextureRect = bg.get_node_or_null("PlayerPortrait")
		var btn: Button = frame.get_node("Button")

		var player_id = pr.slots[slot_id]

		if player_id == null:
			if portrait:
				portrait.visible = false
			btn.text = ""
			btn.button_pressed = false
			btn.disabled = false
		else:
			if portrait:
				portrait.visible = true
			btn.text = ""
			btn.button_pressed = true
			btn.disabled = false


func _on_slot_button_pressed(slot_id: int) -> void:
	# Mouse click / button press should ONLY grab focus.
	# All join/leave/start logic is handled in _input() with real device_ids.
	UIAudio.play_click()
	var frame = player_frames[slot_id]
	var btn: Button = frame.get_node("Button")
	btn.grab_focus()

func _on_focus_entered() -> void:
	UIAudio.play_move()

func _input(event: InputEvent) -> void:
	# Controller join / leave / start
	if event is InputEventJoypadButton and event.pressed:
		var did: int = event.device
		var button: int = event.button_index

		if button == JOY_BUTTON_A:
			# Which slot's button is focused?
			var focused: Control = get_viewport().gui_get_focus_owner()
			var desired_slot_id: int = -1

			if focused:
				# Find which frame owns this focused button
				for slot_id in player_frames.keys():
					var frame = player_frames[slot_id]
					var btn: Button = frame.get_node("Button")
					if btn == focused:
						desired_slot_id = slot_id
						break

			_handle_join_or_start(did, desired_slot_id)

		elif button == JOY_BUTTON_B:
			# B always means "leave my current slot"
			_handle_leave(did)





func _handle_join_or_start(device_id: int, desired_slot_id: int = -1) -> void:
	var pr = _get_player_registry()
	if pr == null:
		return

	# 1) If this device is already in a slot:
	if device_to_slot.has(device_id):
		var current_slot: int = device_to_slot[device_id]

		# If it's in slot 1 (host), A starts the game.
		if current_slot == 1:
			_start_game()

		# IMPORTANT:
		# No matter what slot it's in, once joined it CANNOT join any
		# other slot until it presses B to leave.
		return

	# 2) Not in any slot yet -> try to join the focused / desired slot
	var player_id: int = pr.reserve_slot(device_id, desired_slot_id)
	if player_id == -1:
		print("No free player slots left")
		return

	# Which slot did we actually end up in?
	var slot_id: int = pr.get_slot_for_player(player_id)
	if slot_id == -1:
		return

	# Remember which slot this device owns
	device_to_slot[device_id] = slot_id

	# VISUAL: press the button and show portrait
	var frame = player_frames[slot_id]
	var btn: Button = frame.get_node("Button")
	btn.button_pressed = true

	var bg: TextureRect = frame.get_node("TextureRect")
	var portrait: TextureRect = bg.get_node_or_null("PlayerPortrait")
	if portrait:
		portrait.visible = true

	_refresh_ui()




func _handle_leave(device_id: int) -> void:
	var pr = _get_player_registry()
	if pr == null:
		return

	# If this device doesn't own a slot, nothing to do
	if not device_to_slot.has(device_id):
		return

	# Free the player + slot entry in the registry
	pr.release_slot_by_device(device_id)

	# Forget which slot this device had
	device_to_slot.erase(device_id)

	# This will hide the portrait, reset text to "PRESS A TO JOIN", etc.
	_refresh_ui()






func _start_game() -> void:
	# Only start if host slot is occupied
	if PlayerRegistry.slots[1] == null:
		print("Cannot start: host player not joined yet")
		return

	print("Starting game, PlayerRegistry.slots = ", PlayerRegistry.slots)
	get_tree().change_scene_to_file("res://Scene/Hades.tscn")
