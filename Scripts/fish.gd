extends ParallaxLayer

@export  var fish_speed = -8;
func _process(delta: float) -> void:
	self.motion_offset.x += fish_speed * delta
