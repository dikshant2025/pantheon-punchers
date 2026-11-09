extends Node

const MAX_PLAYERS := 4

# slot_id -> player_id (or null)
var slots: Dictionary = {
	1: null,
	2: null,
	3: null,
	4: null,
}

# player_id -> info (including device_id)
var players: Dictionary = {}
var _next_player_id: int = 1


# --- Helper: find existing player for a device ------------------------------
func _get_player_for_device(device_id: int) -> int:
	for player_id in players.keys():
		var info: Dictionary = players[player_id]
		if info.get("device_id") == device_id:
			return player_id
	return -1


# --- Reserve a slot for this device ----------------------------------------
func reserve_slot(device_id: int, preferred_slot_id: int = -1) -> int:
	# 0) If this device already owns a player, just reuse it.
	#    (This prevents one controller creating 2 players.)
	var existing_player: int = _get_player_for_device(device_id)
	if existing_player != -1:
		return existing_player

	# 1) Try the preferred slot first, if given and free
	if preferred_slot_id != -1 \
	and slots.has(preferred_slot_id) \
	and slots[preferred_slot_id] == null:

		var player_id: int = _next_player_id
		_next_player_id += 1

		slots[preferred_slot_id] = player_id
		players[player_id] = {
			"device_id": device_id,
			"color": Color.WHITE,
			"archetype": "knight",
			"stats": {},
		}

		print("PlayerRegistry: reserved preferred slot ",
			  preferred_slot_id, " for device ", device_id,
			  " (player_id=", player_id, ")")
		return player_id

	# 2) Fall back to the first free slot
	for slot_id in slots.keys():
		if slots[slot_id] == null:
			var player_id2: int = _next_player_id
			_next_player_id += 1

			slots[slot_id] = player_id2
			players[player_id2] = {
				"device_id": device_id,
				"color": Color.WHITE,
				"archetype": "knight",
				"stats": {},
			}

			print("PlayerRegistry: reserved slot ", slot_id,
				  " for device ", device_id,
				  " (player_id=", player_id2, ")")
			return player_id2

	print("PlayerRegistry: no free slots!")
	return -1


# --- Free the slot and player for this device ------------------------------
func release_slot_by_device(device_id: int) -> void:
	var player_id: int = _get_player_for_device(device_id)
	if player_id == -1:
		return

	# Clear the slot that has this player
	for slot_id in slots.keys():
		if slots[slot_id] == player_id:
			print("PlayerRegistry: releasing slot ", slot_id, " for device ", device_id)
			slots[slot_id] = null
			break

	# Remove the player entry
	players.erase(player_id)


# --- Find which slot a player is in ----------------------------------------
func get_slot_for_player(player_id: int) -> int:
	for slot_id in slots.keys():
		if slots[slot_id] == player_id:
			return slot_id
	return -1
