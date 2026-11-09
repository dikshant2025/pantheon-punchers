extends CharacterBody2D
class_name Enemy

@export var next_scene: String = ""      # set this in Inspector per level
@export var move_speed: float = 40.0
@export var max_health: int = 50
@export var attack_damage: int = 25
@export var attack_cooldown: float = 0.5
@export var stop_distance: float = 40.0   # how close the enemy stops before player
@export var attack_range: float = 100.0    # must be <= AggroArea size

@onready var aggro_area: Area2D = $AggroArea
@onready var anim: AnimatedSprite2D = $AnimationEnemy  # <- your enemy AnimationPlayer
@onready var sfx_walk: AudioStreamPlayer2D = $SFX/Walk
@onready var sfx_attack: AudioStreamPlayer2D = $SFX/Attack
@onready var sfx_hurt: AudioStreamPlayer2D = $SFX/Hurt
@onready var sfx_die: AudioStreamPlayer2D = $SFX/Die

var health: int
var player: Player = null
var _attack_timer: float = 0.0
var _dead: bool = false


func _ready() -> void:
	health = max_health
	_dead = false
	_attack_timer = attack_cooldown      # so it can attack immediately

	aggro_area.body_entered.connect(_on_aggro_area_body_entered)
	aggro_area.body_exited.connect(_on_aggro_area_body_exited)

	if anim:
		anim.play("idle")


func _physics_process(delta: float) -> void:
	if _dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_attack_timer += delta

	if player and player.is_inside_tree() and not player._dead:
		var to_player: Vector2 = player.global_position - global_position
		var distance: float = to_player.length()
		print("Enemy dist to player = ", distance)

		# ------- MOVE TOWARDS PLAYER -------
		if distance > stop_distance:
			velocity = to_player.normalized() * move_speed
			if velocity.x != 0.0:
				anim.flip_h = velocity.x < 0.0 
			if anim and anim.animation != "walk":
				anim.play("walk")
				sfx_walk.play()
		else:
			velocity = Vector2.ZERO
			if anim and anim.animation != "idle":
				anim.play("idle")

		move_and_slide()

		# ------- TRY TO ATTACK WHEN CLOSE -------
		if distance <= attack_range:
			_try_attack(distance)
	else:
		# No valid player target
		velocity = Vector2.ZERO
		move_and_slide()
		if anim and anim.animation != "idle":
			anim.play("idle")


func _try_attack(distance: float) -> void:
	print("TRY ATTACK: dist=", distance,
		"  range=", attack_range,
		"  timer=", _attack_timer,
		"  cd=", attack_cooldown)

	if distance > attack_range:
		return
	if _attack_timer < attack_cooldown:
		return

	_attack_timer = 0.0

	# Play attack animation
	if anim:
		anim.play("attack")
		sfx_attack.play()

	if player and player.is_inside_tree() and not player._dead:
		player.take_damage(attack_damage)
		print("Enemy ATTACK! dealing ", attack_damage,
			"  damage at dist = ", distance)
	else:
		print("Enemy tried to attack but player invalid")


# ======= ENEMY TAKES DAMAGE =======

func take_damage(amount: int) -> void:
	if _dead:
		return

	health -= amount
	print("Enemy took ", amount, " damage. HP = ", health)

	if health > 0:
		# Hurt animation
		if anim:
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
	print("Enemy died")

	# Death animation
	if anim:
		anim.play("death")

	var scene_to_load: String = next_scene
	if scene_to_load != "":
		get_tree().change_scene_to_file(scene_to_load)

	queue_free()


# ======= AGGRO AREA SIGNALS =======

func _on_aggro_area_body_entered(body: Node) -> void:
	if body.is_in_group("players"):
		player = body as Player
		print("Enemy: player detected")


func _on_aggro_area_body_exited(body: Node) -> void:
	if body == player:
		player = null
		print("Enemy: player lost")
