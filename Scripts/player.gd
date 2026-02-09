extends CharacterBody2D

@onready var hitbox = $Hitbox
@onready var sprite = $Sprite
@onready var camera = $Camera

@onready var mech = $"../Mech"

@onready var minigames = $"../GUI/Control/Minigames"


const SPEED = 150.0
const AIMSPEED = 750
const JUMP_VELOCITY = -400.0

var last_platform_velocity : Vector2 = Vector2.ZERO

var zoom : Vector2 = Vector2(2,2)
var last_zoom : Vector2 = zoom
var aim_mode : bool = false
var minigame_mode : bool = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		last_platform_velocity = Vector2.ZERO

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		last_platform_velocity = get_platform_velocity()
		velocity = last_platform_velocity
		velocity.y += JUMP_VELOCITY

	# Handle camera zoom
	if Input.is_action_just_pressed("zoom_in") and is_on_floor():
		zoom *= 2
	if Input.is_action_just_pressed("zoom_out") and is_on_floor():
		zoom /= 2
	zoom.x = clamp(zoom.x, 0.25, 4)
	zoom.y = clamp(zoom.y, 0.25, 4)
	camera.zoom = zoom

	if aim_mode:
		var aim_x = Input.get_axis("left", "right")
		var aim_y = Input.get_axis("up", "down")
		mech.crosshair.position += Vector2(aim_x*AIMSPEED*delta, aim_y*AIMSPEED*delta)

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")
	if direction and not aim_mode and not minigame_mode:
		if direction > 0:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
		sprite.play("run")
		velocity.x = direction * SPEED
	else:
		sprite.play("default")
		velocity.x = move_toward(velocity.x, last_platform_velocity.x, SPEED)

	move_and_slide()

func start_minigame(mname : String, controlled_module):
	print("Player: " + controlled_module.name)
	minigame_mode = true
	minigames.start_minigame(mname, controlled_module)
	last_zoom = zoom
	zoom = Vector2(1, 1)
	
func end_minigame():
	minigame_mode = false
	minigames.end_minigame()
	zoom = last_zoom

func screenshake(shake_position : Vector2, amount : int):
	var distance = self.global_position.distance_to(shake_position)
	var shake_brutality : float = 0.005 # Magic number
	var distance_attentuation : float = 64 # Magic number
	var trauma_amount = (amount * shake_brutality) / (distance / distance_attentuation)
	camera.add_trauma(trauma_amount)
