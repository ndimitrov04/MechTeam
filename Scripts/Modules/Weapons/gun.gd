extends RigidBody2D

@onready var main = $"../../.."
@onready var mech = $"../.."

@onready var shoot_point = $ShootPoint

const DEBRIS = preload("uid://rg2m11gs0xex")

var bullet = preload("res://Scenes/Projectiles/bullet.tscn")

var repeat_rate : int = 10	# Number of bullets fired per volley
var recoil : float = 0.15	# Recoil rotation of gun module per shot in radians

var energy_cost : int = 30
var cooldown_time : float = 20

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass

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
		main.add_child(bullet_instance)
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
	await get_tree().create_timer(1.0).timeout
	queue_free()
