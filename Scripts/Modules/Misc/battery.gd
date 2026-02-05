extends RigidBody2D

@onready var main = $"../../.."
@onready var mech = $"../.."

@onready var charge = $Charge
@onready var energy_regen = $EnergyRegen

const DEBRIS = preload("uid://rg2m11gs0xex")

var energy_cost : int = 5
var regen_value : int = 50 # Active regeneration value
var regen_rate : int = 1 # Passive regeneration value
var max_energy : int = 100
var current_energy : int = max_energy
var cooldown_time : float = 10

@onready var is_friendly : bool = false
@onready var type : MechData.ObjectType = MechData.ObjectType.MODULE

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
	energy_regen.timeout.connect(_regenerate_energy)
	self.body_entered.connect(_on_body_entered)
	charge.value = current_energy
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
	current_energy += regen_value
	if current_energy > max_energy:
		current_energy = max_energy
	charge.value = current_energy

func drain(amount : int) -> int:
	current_energy -= amount
	var leftover = 0
	if current_energy < 0:
		leftover = current_energy * -1
		current_energy = 0
	charge.value = current_energy
	return leftover

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
	
	freeze = false

func _on_body_entered(_body):
	var debris_instance = DEBRIS.instantiate()
	main.call_deferred("add_child", debris_instance)
	debris_instance.global_position = global_position
	await get_tree().create_timer(1.0).timeout
	queue_free()
	
func _regenerate_energy():
	if current_energy + regen_rate < max_energy:
		current_energy += regen_rate
	else:
		current_energy = max_energy
	charge.value = current_energy
