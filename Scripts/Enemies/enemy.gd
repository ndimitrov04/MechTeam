extends CharacterBody2D

@onready var crosshair = $Crosshair
@onready var movement_sprites = $MovementSprites

@onready var background = $Background
@onready var frame = $Frame

const SPEED = 25.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	var direction = 0
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if abs(velocity.x) > 0:
		for spr in movement_sprites.get_children():
			if not spr.is_playing():
				spr.play("default")
	else:
		for spr in movement_sprites.get_children():
			spr.stop()

	move_and_slide()
