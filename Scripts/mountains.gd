extends ParallaxLayer

@export  var mountain_speed = -15;
func _process(delta: float) -> void:
	self.motion_offset.x += mountain_speed * delta
