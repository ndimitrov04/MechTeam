extends RigidBody2D

@onready var main = $"../../.."
@onready var mech = $"../.."

@onready var shoot_point = $ShootPoint
@onready var smoke: GPUParticles2D = $ShootPoint/Smoke

@onready var pole: Sprite2D = $Pole
@onready var hitbox: CollisionShape2D = $Hitbox
@onready var hitbox_2: CollisionShape2D = $Hitbox2
@onready var self_control: Area2D = $Control

@onready var shoot_sfx: AudioStreamPlayer2D = $SFX/Shoot
@onready var drop_sfx: AudioStreamPlayer2D = $SFX/Drop

const DEBRIS = preload("uid://rg2m11gs0xex")

var bullet = preload("res://Scenes/Projectiles/bullet.tscn")

var repeat_rate : int = 5	# Number of bullets fired per volley
var recoil : float = 0.15	# Recoil rotation of gun module per shot in radians

var energy_cost : int = 10
var cooldown_time : float = 7
var aim_speed : float = 1.0
var target_angle : float = 0
var auto : bool = true

@onready var is_friendly : bool = false
@onready var type : MechData.ObjectType = MechData.ObjectType.MODULE

@onready var controller

# Used for saving and loading controller:weapon connection pairs
var index

#unfreeze gun physics on destruction
var destroyed : bool = false

# Frame tile to which this module is pinned
# (module will be destroyed when pinned tile is destroyed)
#var pinned_frame_tile : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	#if has_meta("pinned_tile"):
		#pinned_frame_tile = get_meta("pinned_tile")
	self.body_entered.connect(_on_body_entered)
	if get_parent().get_parent().name == "Mech":
		index = get_parent().get_child_count() - 1
		is_friendly = true
		set_collision_layer_value(2, 1)
		set_collision_mask_value(2, 1)
		set_collision_layer_value(4, 0)
		set_collision_mask_value(4, 0)
	else:
		set_collision_layer_value(2, 0)
		set_collision_mask_value(2, 0)
		set_collision_layer_value(4, 1)
		set_collision_mask_value(4, 1)
	# Set default angle of turret head
	if has_meta("default_angle"):
		target_angle = get_meta("default_angle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
# "Aim"
func _physics_process(delta):
	pole.global_position = self.global_position + Vector2(0,11)
	self_control.global_position = self.global_position
	hitbox.global_position = self.global_position
	hitbox_2.global_position = self.global_position
	global_rotation = lerp_angle(global_rotation, target_angle, aim_speed * delta)

# Gun logic
func _input_event(_viewport, event, _shape_idx):
	if get_parent().get_parent().name == "Mech":
		if event is InputEventMouseButton and event.pressed and mech.mech_edit:
			if event.button_index == MOUSE_BUTTON_LEFT and mech.current_terminal != null:
				print("Terminal " + mech.current_terminal.name + " has been connected to " + self.name)
				mech.current_terminal.arm(self)
				print("Deactivating terminal connection mode.")
				mech.current_terminal = null

func engage():
	for i in range(0, repeat_rate):
		await get_tree().create_timer(0.15).timeout
		var bullet_instance = bullet.instantiate()
		shoot_sfx.pitch_scale = randf_range(1, 1.4)
		shoot_sfx.play()
		smoke.emitting = true
		# Determine who the bullet will hurt
		if is_friendly:
			bullet_instance.set_collision_layer_value(1, 0)
			bullet_instance.set_collision_layer_value(2, 0)
			bullet_instance.set_collision_layer_value(9, 0)
			bullet_instance.set_collision_layer_value(3, 1)
			bullet_instance.set_collision_layer_value(4, 1)
			bullet_instance.set_collision_layer_value(10, 1)
			bullet_instance.set_collision_mask_value(1, 0)
			bullet_instance.set_collision_mask_value(2, 0)
			bullet_instance.set_collision_mask_value(9, 0)
			bullet_instance.set_collision_mask_value(3, 1)
			bullet_instance.set_collision_mask_value(4, 1)
			bullet_instance.set_collision_mask_value(10, 1)
		else:
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
		bullet_instance.global_rotation = self.global_rotation
		bullet_instance.global_position = shoot_point.global_position
		main.add_child(bullet_instance)
		if abs(bullet_instance.SPEED + mech.linear_velocity.x) > abs(bullet_instance.SPEED):
			bullet_instance.SPEED += mech.linear_velocity.x
		# Apply recoil per shot
		self.rotate(randf_range(-recoil, recoil))
		if get_parent().get_parent().name == "Mech":
			main.static_ui.set_status("Firing Machinegun!")

func destroy():
	# Spawn debris
	var debris_instance = DEBRIS.instantiate()
	main.add_child(debris_instance)
	debris_instance.global_position = global_position
	
	set_collision_layer_value(2, 0)
	set_collision_layer_value(4, 0)
	set_collision_mask_value(2, 0)
	set_collision_mask_value(4, 0)
	
	set_collision_layer_value(7, 1)
	set_collision_mask_value(7, 1)
	
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	destroyed = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
	if controller:
		controller.disarm()
	
	freeze = false

func _on_body_entered(_body):
	var debris_instance = DEBRIS.instantiate()
	main.call_deferred("add_child", debris_instance)
	debris_instance.global_position = global_position
	drop()
	await get_tree().create_timer(1.0).timeout
	queue_free()
	
func drop():
	const QUBODUP_PUNCH_01 = preload("uid://708qbmb1elfe")
	const QUBODUP_PUNCH_02 = preload("uid://3ym41o68s5hs")
	const QUBODUP_PUNCH_03 = preload("uid://kx7214pkd02j")
	const QUBODUP_PUNCH_04 = preload("uid://dmwuh6jgmxre1")
	const QUBODUP_PUNCH_05 = preload("uid://b1u8fhv870l5e")
	
	const drop_effects = [QUBODUP_PUNCH_01,QUBODUP_PUNCH_02,QUBODUP_PUNCH_03,QUBODUP_PUNCH_04,QUBODUP_PUNCH_05]
	
	drop_sfx.stream = drop_effects.pick_random()
	drop_sfx.play()
