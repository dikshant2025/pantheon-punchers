extends Node

# device_id -> Player node
var device_to_player: Dictionary = {}


func register_player(player_node: Node, device_id: int) -> void:
	device_to_player[device_id] = player_node


func unbind_device(device_id: int) -> void:
	device_to_player.erase(device_id)


func _input(event: InputEvent) -> void:
	# Forward ALL controller events (buttons + stick motion)
	if not (event is InputEventJoypadButton or event is InputEventJoypadMotion):
		return

	var did := event.get_device()

	# If we don't have a player bound for this device, ignore it
	if not device_to_player.has(did):
		return

	# IMPORTANT: don't type-hint as Node here, so Godot won't complain
	var player_node = device_to_player[did]

	# If the player was freed, clean up this mapping and stop
	if not is_instance_valid(player_node):
		device_to_player.erase(did)
		return

	# Forward input only if the player is still in the tree and has the method
	if player_node.is_inside_tree() and player_node.has_method("_receive_input"):
		player_node._receive_input(event)
