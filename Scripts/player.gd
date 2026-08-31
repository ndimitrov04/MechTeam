extends CharacterBody2D

@onready var BULLET = preload("uid://blse43qjj8wf3")

@onready var hitbox = $Hitbox
@onready var sprite = $Sprite
@onready var camera = $Camera
@onready var hurt_sfx = $HurtSFX

@onready var jetpack = $Jetpack
@onready var jetpack_bar = $Jetpack/JetpackBar
@onready var jetpack_sfx = $Jetpack/SFX
@onready var jump_timer = $Jetpack/JumpTimer
@onready var floor_detector = $FloorDetector
@onready var shootpoint = $Shootpoint
@onready var gun_cooldown = $Shootpoint/GunCooldown
@onready var hp_regen = $HPRegen

@onready var debug_info = $DebugInfo

@onready var mech = $"../Mech"
@onready var game_over = $"../GUI/Control/GameOver"
@onready var static_ui = $"../GUI/Control/StaticUI"

@onready var minigames = $"../GUI/Control/Minigames"

@onready var friendly_unit : bool = true

# Consts
const SPEED = 170.0
const AIMSPEED = 750
const JUMP_VELOCITY = -350.0

# Internal game vars
var last_platform_velocity : Vector2 = Vector2.ZERO
var last_platform = null

var direction
var zoom : Vector2 = Vector2(2,2)
var last_zoom : Vector2 = zoom
var aim_mode : bool = false
var minigame_mode : bool = false
var on_cooldown : bool = false

# Player vars
var max_hp : int = 5
var hp : int = 5
var invincible : bool = false

# Jetpack vars
var max_thrust : float = -120
var jetpack_energy : float = 100
var jetpack_power : float = -1250
var jumping : bool = false

func _ready():
	jump_timer.timeout.connect(_on_jump_timeout)
	gun_cooldown.timeout.connect(_on_cooldown_timeout)
	sprite.animation_finished.connect(_on_sprite_animation_finished)
	hp_regen.timeout.connect(_on_hp_regen_timeout)

func _physics_process(delta):
	#debug_info.text = "Velocity: " + str(velocity)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		jumping = true
		jump_timer.start(0.1)
	else:
		if not floor_detector:
			return
		if floor_detector.is_colliding():
			if floor_detector.get_collider() == null:
				return
			if floor_detector.get_collider().name == "Frame":
				last_platform = floor_detector.get_collider().get_parent()
				last_platform_velocity = last_platform.linear_velocity
		if last_platform != null:
			last_platform_velocity = last_platform.linear_velocity
		jetpack_bar.hide()
		jetpack_energy = 100
		jumping = false

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		#last_platform_velocity = get_platform_velocity()
		velocity.y += JUMP_VELOCITY
		velocity.x += last_platform_velocity.x

	# Handle jetpack
	if Input.is_action_pressed("jump") and not is_on_floor() and jetpack_energy > 0:
		if velocity.y > max_thrust:
			if not jetpack_sfx.playing:
				jetpack_sfx.play()
			velocity.y += jetpack_power * delta
			jetpack_energy -= 75 * delta
			jetpack_bar.value = jetpack_energy
			if not jetpack.emitting:
				jetpack_bar.show()
				jetpack.emitting = true
	else:
		if jetpack.emitting: 
			jetpack_sfx.stop()
			jetpack.emitting = false

	if Input.is_action_just_pressed("shoot") and not on_cooldown:
		if sprite.animation == "run":
			sprite.play("punch_run")
		else:
			sprite.play("punch")
		var bullet_instance = BULLET.instantiate()
		add_child(bullet_instance)
		bullet_instance.global_position = shootpoint.global_position
		bullet_instance.global_rotation = shootpoint.global_rotation
		if sprite.flip_h:
			bullet_instance.sprite.flip_h = true
			bullet_instance.sprite.flip_v = true
		on_cooldown = true
		gun_cooldown.start()

	# Handle camera zoom
	if Input.is_action_just_pressed("zoom_in") and is_on_floor():
		zoom *= 2
	if Input.is_action_just_pressed("zoom_out") and is_on_floor():
		zoom /= 2
	zoom.x = clamp(zoom.x, 0.5, 4)
	zoom.y = clamp(zoom.y, 0.5, 4)
	camera.zoom_change(zoom)
	
	# Debug NPC summoning
	if Input.is_action_just_pressed("debug_summon_npc"):
		mech.summon_friendly_npc(self.global_position)

	if aim_mode:
		var aim_x = Input.get_axis("left", "right")
		var aim_y = Input.get_axis("up", "down")
		mech.crosshair.position += Vector2(aim_x*AIMSPEED*delta, aim_y*AIMSPEED*delta)

	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_axis("left", "right")
	if direction and not aim_mode and not minigame_mode:
		if direction > 0:
			sprite.flip_h = false
			shootpoint.position.x = 24
			shootpoint.rotation_degrees = 0
		else:
			sprite.flip_h = true
			shootpoint.position.x = -24
			shootpoint.rotation_degrees = 180
		if sprite.animation != "punch_run" and sprite.animation != "punch":
			sprite.play("run")
	else:
		if sprite.animation != "punch":
			sprite.play("default")
			
	if is_on_floor() and (aim_mode or minigame_mode):
		velocity.x = 0 * SPEED
	elif is_on_floor():
		velocity.x = direction * SPEED
	else:
		velocity.x = direction * SPEED + last_platform_velocity.x

	move_and_slide()

func start_minigame(mname : String, controlled_module):
	print("Player: " + controlled_module.name)
	#minigame_mode = true
	minigames.start_minigame(mname, controlled_module)
	#last_zoom = zoom
	#zoom = Vector2(1, 1)

func end_minigame():
	#minigame_mode = false
	minigames.end_minigame()
	#zoom = last_zoom

func screenshake(shake_position : Vector2, amount : int):
	var distance = self.global_position.distance_to(shake_position)
	var shake_brutality : float = 0.005 # Magic number
	var distance_attentuation : float = 64 # Magic number
	var trauma_amount = (amount * shake_brutality) / (distance / distance_attentuation)
	camera.add_trauma(trauma_amount)

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
	# Game over sequence here
	game_over.show()

func _on_jump_timeout():
	jumping = false

func _on_cooldown_timeout():
	on_cooldown = false

func _on_sprite_animation_finished() -> void:
	if sprite.animation == "punch_run":
		sprite.stop()
		sprite.play("run")
	if sprite.animation == "punch":
		sprite.stop()
		sprite.play("default")

func _on_hp_regen_timeout():
	if hp < max_hp:
		hp += 1
		
