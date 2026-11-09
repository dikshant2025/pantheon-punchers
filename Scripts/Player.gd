extends CharacterBody2D
class_name Player

@export var speed: float = 100.0
@export var max_health: int = 500
@export var attack_damage: int = 50
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1

# Which controller owns this player (set in Level.gd)
@export var device_id: int = -1
@onready var anim: AnimatedSprite2D = $AnimationPlayer
@onready var sfx_walk: AudioStreamPlayer2D = $SFX/Walk
@onready var sfx_attack: AudioStreamPlayer2D = $SFX/Attack
@onready var sfx_hurt: AudioStreamPlayer2D = $SFX/Hurt
@onready var sfx_die: AudioStreamPlayer2D = $SFX/Die

var health: int
var _attack_timer: float = 0.0
var _dead: bool = false
const HealthBarScene := preload("res://Scene/HealthBar.tscn")  # adjust path
var health_bar: Node2D

# Filled by _receive_input() for THIS player's controller
var move_input: Vector2 = Vector2.ZERO


func _ready() -> void:
	health = max_health
	_dead = false
	_attack_timer = 0.0

	# Register with InputRouter so controller events get routed here
	if Engine.has_singleton("InputRouter"):
		InputRouter.register_player(self, device_id)

	# For leash logic in Level.gd
	add_to_group("players")
	health_bar = HealthBarScene.instantiate()
	add_child(health_bar)
	health_bar.position = Vector2(0, -80) # adjust above head
	health_bar.setup(max_health)

func _physics_process(delta: float) -> void:
	if _dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_attack_timer += delta

	# existing movement code...
	var dir := move_input

	if device_id == -1:
		dir.x += Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		dir.y += Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if dir.length() > 0.1:
		dir = dir.normalized()
		velocity = dir * speed
		move_and_slide()
		if not anim.is_playing() or anim.animation != "walk":
			anim.play("walk")
			if not sfx_walk.playing:
				sfx_walk.play()
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		if not anim.is_playing() or anim.animation != "idle":
			anim.play("idle")



# ---------------- ATTACK / DAMAGE (unchanged from before) ----------------

func _try_attack() -> void:
	if _attack_timer < attack_cooldown:
		return
	_attack_timer = 0.0

	# play attack anim
	anim.play("attack")
	sfx_attack.play()
	# existing attack logic...
	var closest_enemy: Enemy = null
	var closest_dist := attack_range

	for node in get_tree().get_nodes_in_group("enemies"):
		if node is Enemy and not node._dead:
			var enemy := node as Enemy
			var d: float = enemy.global_position.distance_to(global_position)
			if d <= closest_dist:
				closest_dist = d
				closest_enemy = enemy

	if closest_enemy:
		closest_enemy.take_damage(attack_damage)
		print("Player hit Enemy for ", attack_damage, " damage. dist = ", closest_dist)
	else:
		print("Player attack missed. No enemy in range (", attack_range, " px)")



func take_damage(amount: int) -> void:
	if _dead:
		return

	health -= amount
	print("Player took ", amount, " damage. HP = ", health)
	(health_bar as HealthBar).set_health(health)

	if health > 0:
		anim.play("hurt")
		sfx_hurt.play()
	else:
		sfx_die.play()
		_die()

func _die() -> void:
	if _dead:
		return
	_dead = true
	velocity = Vector2.ZERO
	anim.play("death")
	print("Player died")

	# Let Level know a player died (for Game Over logic later)
	get_tree().call_group("level", "on_player_died")
	queue_free()



func _exit_tree() -> void:
	if Engine.has_singleton("InputRouter"):
		InputRouter.unbind_device(device_id)


# ---------------- CONTROLLER EVENTS FOR THIS PLAYER ----------------

func _receive_input(event: InputEvent) -> void:
	# LEFT STICK
	if event is InputEventJoypadMotion:
		var jm := event as InputEventJoypadMotion

		# Make sure the event is from THIS player's controller
		if jm.device != device_id:
			return

		if jm.axis == JOY_AXIS_LEFT_X:
			move_input.x = jm.axis_value
		elif jm.axis == JOY_AXIS_LEFT_Y:
			move_input.y = jm.axis_value
		return

	# BUTTONS (attack, etc.)
	if event is InputEventJoypadButton:
		var jb := event as InputEventJoypadButton

		if jb.device != device_id:
			return

		if jb.pressed:
			print("Player ", name, " got button ", jb.button_index, " from device ", jb.device)

			# Attack on A / south button
			if jb.button_index == JOY_BUTTON_A:
				_try_attack()
