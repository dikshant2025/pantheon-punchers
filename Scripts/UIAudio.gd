extends Node

@onready var click_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var move_player: AudioStreamPlayer  = AudioStreamPlayer.new()

func _ready() -> void:
	add_child(click_player)
	add_child(move_player)

	# Set your sounds here (change file paths to your actual click / move sounds)
	click_player.stream = load("res://Audio/Button Click - Sound Effect.mp3")
	move_player.stream  = load("res://Audio/Button Click - Sound Effect.mp3")

	# Optional: route to SFX bus if you have one
	# click_player.bus = "SFX"
	# move_player.bus  = "SFX"

func play_click() -> void:
	if click_player.stream:
		click_player.play()

func play_move() -> void:
	if move_player.stream:
		move_player.play()
