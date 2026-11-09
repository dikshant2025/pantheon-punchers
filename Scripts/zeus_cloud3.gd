extends ParallaxLayer
@export  var cloud_speed1 = -8;
func _process(delta: float) -> void:
	self.motion_offset.x += cloud_speed1 * delta
