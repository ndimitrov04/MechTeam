extends CharacterBody2D

@onready var sprite = $Sprite
@onready var hitbox = $Hitbox

const SPEED = 50.0
const JUMP_VELOCITY = -400.0

# NPC Sprites
const NPC_1 = preload("uid://bvy5i3vh6phgd")
const NPC_2 = preload("uid://yegkhjsxuydh")
const NPC_3 = preload("uid://cggtf67wajjhh")
const NPC_SPRITES = [NPC_1, NPC_2, NPC_3]

@onready var direction = 0

@onready var npc_walk = $NPCWalk
@onready var npc_engage = $NPCEngage
@onready var npc_cooldown = $NPCCooldown

func _ready():
	# Choose random NPC sprite
	sprite.sprite_frames = NPC_SPRITES.pick_random()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	if direction != 0:
		velocity.x = direction * SPEED
		if direction > 0:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
		sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		sprite.play("default")

	move_and_slide()

func make_busy(time : float):
	npc_walk.stop_moving(time)
	npc_engage.temp_disable(time)
	npc_cooldown.start(time)
