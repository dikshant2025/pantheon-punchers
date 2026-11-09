extends Node2D

@export var move_smooth: float = 5.0  # how fast camera follows

var _targets: Array[Node2D] = []      # players being tracked
var _base_y: float = 0.0              # fixed Y of the camera

@onready var cam: Camera2D = $Camera2D

func _ready() -> void:
	_base_y = global_position.y

	# Auto-detect players in group "players"
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("players")
	for p in players:
		register_target(p)

func register_target(node: Node2D) -> void:
	if node not in _targets:
		_targets.append(node)

func unregister_target(node: Node2D) -> void:
	_targets.erase(node)

func _process(delta: float) -> void:
	if _targets.is_empty():
		return

	# Find one valid target
	var first: Node2D = null
	for t in _targets:
		if is_instance_valid(t):
			first = t
			break

	if first == null:
		return

	var min_x: float = first.global_position.x
	var max_x: float = first.global_position.x

	for t in _targets:
		if not is_instance_valid(t):
			continue
		var x := t.global_position.x
		min_x = min(min_x, x)
		max_x = max(max_x, x)

	var center_x := (min_x + max_x) * 0.5

	var target_pos := Vector2(center_x, _base_y)
	global_position = global_position.lerp(target_pos, move_smooth * delta)
