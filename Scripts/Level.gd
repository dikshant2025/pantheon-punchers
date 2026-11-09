extends Node2D

@export var player_scenes: Array[PackedScene] = []
@export var spawn_points: Array[Node2D] = []
@export var level_music: AudioStream   # 👈 NEW
@export var level_music_volume_db: float = 0.0  # default no change
@onready var game_over_ui := $GameOver  # CanvasLayer with game_over.gd

var host_player: Node2D = null
var leash_distance: float = 400.0   # how far others can go from host
var _last_positions := {}   

func _ready() -> void:
	_spawn_players()

	# use the exported audio from the inspector
	if level_music:
		MusicManager.play_music(level_music, true, level_music_volume_db)



func _spawn_players() -> void:
	host_player = null

	for slot_id in PlayerRegistry.slots.keys():
		var player_id = PlayerRegistry.slots[slot_id]
		if player_id == null:
			continue

		var info: Dictionary = PlayerRegistry.players[player_id]
		var device_id: int = info["device_id"]

		# WHICH PLAYER SCENE TO USE?
		# slot_id is 1..4, so convert to 0..3 index
		var scene_index: int = slot_id - 1
		var scene_to_use: PackedScene

		if scene_index >= 0 and scene_index < player_scenes.size():
			scene_to_use = player_scenes[scene_index]
		else:
			# Fallback so it never crashes if array is smaller
			scene_to_use = player_scenes[0]

		var p: Player = scene_to_use.instantiate()
		add_child(p)

		# Tell the player which controller it belongs to
		p.device_id = device_id
		p.add_to_group("players")

		# Position at the correct spawn point
		var spawn: Node2D = spawn_points[slot_id - 1]
		p.global_position = spawn.global_position

		# Register with InputRouter
		InputRouter.register_player(p, device_id)

		# First alive player becomes host
		if host_player == null:
			host_player = p



func _physics_process(delta: float) -> void:
	# Collect all player nodes
	var players: Array = []
	for child in get_children():
		if child is Node2D and child.is_in_group("players"):
			players.append(child)

	if players.is_empty():
		host_player = null
		return

	# Choose/repair host (also handles host dying)
	if host_player == null or not host_player.is_inside_tree():
		host_player = players[0]
		# if you have a CameraRig script, this is where you'd tell it
		# who the new host is, e.g. CameraRig.target = host_player

	# Compute how far apart players are horizontally
	var min_x = players[0].global_position.x
	var max_x = players[0].global_position.x
	for p in players:
		var x = p.global_position.x
		if x < min_x:
			min_x = x
		elif x > max_x:
			max_x = x

	var span = max_x - min_x

	if span > leash_distance:
		# Too far apart → revert everybody to last frame’s positions
		for p in players:
			if _last_positions.has(p):
				p.global_position = _last_positions[p]
	else:
		# Within leash → accept positions and remember them
		for p in players:
			_last_positions[p] = p.global_position



func _pick_new_host() -> void:
	host_player = null
	for child in get_tree().get_nodes_in_group("players"):
		var p := child as Player
		if p and p.is_inside_tree() and not p._dead:
			host_player = p
			break

	print("New host player:", host_player)

	# TODO: if you have a CameraRig that follows the host,
	# point it to the new host here, e.g.:
	# $CameraRig.set_target(host_player)

func on_player_died() -> void:
	var players = get_tree().get_nodes_in_group("players")
	if players.is_empty():
		print("All players dead – game over")
		game_over_ui.game_over()
