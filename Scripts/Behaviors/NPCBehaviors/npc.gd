extends CharacterBody2D

@onready var mech = $"../.."

@onready var sprite = $Sprite
@onready var hitbox = $Hitbox

const SPEED = 50.0
const JUMP_VELOCITY = -400.0

@onready var direction = 0

# Generic NPC behaviors
@onready var npc_walk = $NPCWalk
@onready var npc_cooldown = $NPCCooldown
# Specialised NPC behaviors
@onready var npc_functions = []

@onready var type : MechData.ObjectType = MechData.ObjectType.NPC
@onready var friendly_unit : bool = true

var hp : int = 4
var invincible : bool = false

func _ready():
	if get_parent().get_parent().get_parent().name == "Main":
		process_mode = Node.PROCESS_MODE_INHERIT
	if get_parent().get_parent().get_parent().name == "Menu":
		sprite.material = null
		process_mode = Node.PROCESS_MODE_INHERIT
	# Add specialized NPC behaviors
	for i in range(6, get_child_count() - 1):
		npc_functions.append(get_child(i))
	await get_tree().create_timer(0.1).timeout
	if has_meta("is_pilot") and mech.name == "Mech":
		mech.pilots += 1

func _physics_process(delta):
	
	# Set as top level
	#if not top_level and not get_parent().get_parent().name == "FakeMech":
		#top_level = true
	
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
	npc_cooldown.start(time)
	for behavior in npc_functions:
		behavior.temp_disable(time)
	

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
	const inv_time : float = 0.5
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
	if has_meta("is_pilot"):
		mech.pilots -= 1
	queue_free()
