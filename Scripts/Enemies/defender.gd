extends CharacterBody2D

@onready var main = $"../../.."

@onready var sprite = $Sprite
@onready var hitbox = $Hitbox
@onready var hurt_sfx = $HurtSFX

const SPEED = 50.0
const JUMP_VELOCITY = -400.0

# NPC Sprites
#const NPC_1 = preload("uid://bvy5i3vh6phgd")
#const NPC_2 = preload("uid://yegkhjsxuydh")
#const NPC_3 = preload("uid://cggtf67wajjhh")
#const NPC_SPRITES = [NPC_1, NPC_2, NPC_3]

const BULLET = preload("uid://7pvmbpigkpq1")

@onready var direction = 0

@onready var npc_walk = $NPCWalk
@onready var npc_cooldown = $NPCCooldown
@onready var npc_fight = $NPCFight

@onready var type : MechData.ObjectType = MechData.ObjectType.NPC
@onready var friendly_unit : bool = false

@onready var shoot_point = $ShootPoint

var hp : int = 2
var invincible : bool = false

func _ready():
	if get_parent().get_parent().get_parent().name == "Main":
		process_mode = Node.PROCESS_MODE_INHERIT
	if get_parent().get_parent().get_parent().name == "Menu":
		process_mode = Node.PROCESS_MODE_INHERIT
	# Choose random NPC sprite
	#sprite.sprite_frames = NPC_SPRITES.pick_random()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	if direction and sprite.animation != "attack":
		velocity.x = direction * SPEED - get_platform_velocity().x
		if direction > 0:
			sprite.flip_h = false
			shoot_point.position.x = 15
			shoot_point.rotation_degrees = 0
			npc_fight.face_right(true)
		else:
			sprite.flip_h = true
			shoot_point.position.x = -15
			shoot_point.rotation_degrees = 180
			npc_fight.face_right(false)
		sprite.play("run")
	else:
		if not sprite.is_playing():
			sprite.play("default")
		velocity.x = move_toward(velocity.x, -get_platform_velocity().x, SPEED)

	move_and_slide()

# Fighters should not stop moving ever
func make_busy(time : float):
	npc_walk.stop_moving(time)
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
	const inv_time : float = 0.2
	if not invincible:
		hurt_sfx.play()
		hp -= damage
	if hp <= 0:
		die()
		return
	invincible = true
	inv_frame_vfx(inv_time)
	await get_tree().create_timer(inv_time).timeout
	invincible = false

func die():
	get_parent().get_parent().update_decision_timer() # Notify mech of death
	queue_free()

func fight(stun_duration : float):
	print("RAWRGH!")
	sprite.stop()
	sprite.play("attack")
	shoot()
	make_busy(stun_duration)

func shoot():
	var bullet_instance = BULLET.instantiate()
	main.call_deferred("add_child", bullet_instance)
	bullet_instance.set_collision_layer_value(1, 1)
	bullet_instance.set_collision_layer_value(2, 1)
	bullet_instance.set_collision_layer_value(9, 1)
	bullet_instance.set_collision_layer_value(3, 0)
	bullet_instance.set_collision_layer_value(4, 0)
	bullet_instance.set_collision_layer_value(10, 0)
	bullet_instance.set_collision_mask_value(1, 1)
	bullet_instance.set_collision_mask_value(2, 1)
	bullet_instance.set_collision_mask_value(9, 1)
	bullet_instance.set_collision_mask_value(3, 0)
	bullet_instance.set_collision_mask_value(4, 0)
	bullet_instance.set_collision_mask_value(10, 0)
	bullet_instance.global_position = shoot_point.global_position
	bullet_instance.global_rotation = shoot_point.global_rotation
