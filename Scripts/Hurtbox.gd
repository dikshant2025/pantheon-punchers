extends Area2D
class_name Hurtbox

@export var owner_node:Node  # assign the Player / Enemy node in the editor

func get_damageable() -> Node:
	# Only return it if it actually behaves like a damageable object
	if owner_node and owner_node.has_method("apply_hit"):
		return owner_node
	return null
