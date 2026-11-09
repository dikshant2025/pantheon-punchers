extends Control

@onready var joinButton = $Button
@onready var portrait = $TextureRect/PlayerPortrait

var joinTexture = ResourceLoader.load("res://Assets/Join Game Button.png")
var joinedTexture = ResourceLoader.load("res://Assets/Ready Button.png")
var portraitTexture = ResourceLoader.load("portrait-path-here")

func _ready() -> void:
	joinButton.icon = joinTexture

func _on_button_pressed() -> void:
	joinButton.icon = joinedTexture
	portrait.texture = portraitTexture
