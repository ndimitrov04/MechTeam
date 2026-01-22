extends CharacterBody2D

@onready var hitbox = $Hitbox
@onready var sprite = $Sprite
@onready var camera = $Camera

@onready var mech = $"../Mech"

@onready var minigames = $"../GUI/Control/Minigames"


const SPEED = 150.0
const AIMSPEED = 750
const JUMP_VELOCITY = -400.0

var zoom : Vector2 = Vector2(2,2)
var last_zoom : Vector2 = zoom
var aim_mode : bool = false
var minigame_mode : bool = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func start_minigame(mname : String, controlled_weapon):
	print("Player: " + controlled_weapon.name)
	minigame_mode = true
	minigames.start_minigame(mname, controlled_weapon)
	last_zoom = zoom
	zoom = Vector2(1,1)
	
func end_minigame():
	minigame_mode = false
	minigames.end_minigame()
	zoom = last_zoom
