extends CharacterBody2D

@onready var crosshair = $Crosshair

const SPEED = 50.0
const JUMP_VELOCITY = -600.0

var direction : int = 0
var jump : bool = false

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

	move_and_slide()
