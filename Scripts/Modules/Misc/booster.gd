extends RigidBody2D

@onready var main = $"../../.."
@onready var mech = $"../.."

@onready var boost_point = $BoostPoint
@onready var boost_particles: GPUParticles2D = $BoostPoint/BoostParticles
@onready var shoot_sfx: AudioStreamPlayer2D = $SFX/Shoot
@onready var drop_sfx: AudioStreamPlayer2D = $SFX/Drop

const DEBRIS = preload("uid://rg2m11gs0xex")

var energy_cost : int
var cooldown_time : float
var power : int

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

# Tutorial hooks
signal is_connected()

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
	
	# Initiate object parameters
	energy_cost = get_meta("energy_cost")
	cooldown_time = get_meta("cooldown_time")
	power = get_meta("power")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass

func _input_event(_viewport, event, _shape_idx):
	if get_parent().get_parent().name == "Mech":
		if event is InputEventMouseButton and event.pressed and mech.mech_edit:
			if event.button_index == MOUSE_BUTTON_LEFT and mech.current_terminal != null:
				print("Terminal " + mech.current_terminal.name + " has been connected to " + self.name)
				mech.current_terminal.arm(self)
				is_connected.emit()
				print("Deactivating terminal connection mode.")
				mech.current_terminal = null

func engage():
	var direction_vector = Vector2.RIGHT.rotated(global_rotation) * -1
	mech.apply_impulse(power * direction_vector * 10, self.position)
	boost_particles.process_material.direction = Vector3(direction_vector.x, direction_vector.y, 0)
	boost_particles.emitting = true
	shoot_sfx.play()
	if get_parent().get_parent().name == "Mech":
		main.static_ui.set_status("Firing Booster!")
	await get_tree().create_timer(0.2).timeout
	shoot_sfx.stop()

func destroy():
	# Spawn debris
	var debris_instance = DEBRIS.instantiate()
	main.call_deferred("add_child", debris_instance)
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
	
	call_deferred("set_freeze_enabled", false)

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
