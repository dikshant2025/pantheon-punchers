extends Sprite2D

func _process(delta: float) -> void:
	var player = get_node_or_null("/root/Posiedon/player2")
	if player:
		position = player.position;
