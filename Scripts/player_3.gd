extends CharacterBody2D

var movementSpeed = 1;

func _process(delta):
	var velocity = Vector2(0,0);
	if Input.is_action_pressed("ui_right"):
		velocity += Vector2.RIGHT * movementSpeed
		#$AnimatedSprite2D.play('RunRight')
		#$AnimatedSprite2D.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		velocity += Vector2.LEFT * movementSpeed
		#$AnimatedSprite2D.play('RunRight')
		#$AnimatedSprite2D.flip_h = true
	elif Input.is_action_pressed("ui_up"):
		velocity += Vector2.UP * movementSpeed
		#$AnimatedSprite2D.play('RunUp')
	elif Input.is_action_pressed("ui_down"):
		velocity += Vector2.DOWN * movementSpeed
		#$AnimatedSprite2D.play('RunDown')
	position += velocity.normalized() * movementSpeed;
	#if velocity.is_zero_approx():
		#$AnimatedSprite2D.stop()
