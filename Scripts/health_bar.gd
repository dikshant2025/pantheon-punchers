extends Node2D
class_name HealthBar 

@onready var bar: TextureProgressBar = $TextureProgressBar

func setup(max_health: int) -> void:
	bar.max_value = max_health
	bar.value = max_health

func set_health(value: int) -> void:
	bar.value = clamp(value, 0, bar.max_value)
