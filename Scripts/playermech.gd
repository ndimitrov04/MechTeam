extends CharacterBody2D

@onready var crosshair = $Crosshair
@onready var movement_sprites = $MovementSprites

@onready var background = $Background
@onready var frame = $Frame

const SPEED = 50.0
const JUMP_VELOCITY = -600.0

var mech_edit : bool = false
var current_terminal

var direction : int = 0
var jump : bool = false

var energy : int = 100

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if jump and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump = false

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
	
func _unhandled_input(event):
	if event.is_action_pressed("debug_mech_edit"):
		if not mech_edit:
			mech_edit = true
			print("ENTERED DEBUG MECH EDIT MODE")
		else:
			mech_edit = false
			print("EXITED DEBUG MECH EDIT MODE")
