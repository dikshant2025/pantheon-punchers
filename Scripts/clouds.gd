extends ParallaxLayer

@export  var cloud_speed = -10;
func _process(delta: float) -> void:
	self.motion_offset.x += cloud_speed * delta
