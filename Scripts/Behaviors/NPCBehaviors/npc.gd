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

@onready var type : MechData.ObjectType = MechData.ObjectType.NPC

var hp : int = 5
var invincible : bool = false

func _ready():
	if get_parent().get_parent().get_parent().name == "Main":
		process_mode = Node.PROCESS_MODE_INHERIT
	# Choose random NPC sprite
	sprite.sprite_frames = NPC_SPRITES.pick_random()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	if direction:
		velocity.x = direction * SPEED - get_platform_velocity().x
		if direction > 0:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
		sprite.play("run")
	else:
		sprite.play("default")
		velocity.x = move_toward(velocity.x, -get_platform_velocity().x, SPEED)

	move_and_slide()

func make_busy(time : float):
	npc_walk.stop_moving(time)
	npc_engage.temp_disable(time)
	npc_cooldown.start(time)

# Invincibility frame visual effect
func inv_frame_vfx(duration : float):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	# Flash sequence
	for i in range(0, duration * 10):
		tween.tween_property(sprite, "modulate:a", 0.0, 0.1)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.1)

func take_damage(damage, _collision, _knockback_force):
	const inv_time : float = 1
	if not invincible:
		hp -= damage
	if hp <= 0:
		die()
		return
	invincible = true
	inv_frame_vfx(inv_time)
	await get_tree().create_timer(inv_time).timeout
	invincible = false

func die():
	get_parent().get_parent().get_parent().npc_deaths += 1 # Main
	queue_free()
