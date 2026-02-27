extends RigidBody2D

@onready var main = $"../../.."
@onready var mech = $"../.."

@onready var charge = $Charge
@onready var energy_drain = $EnergyDrain
@onready var shield_area = $ShieldArea

const DEBRIS = preload("uid://rg2m11gs0xex")

var energy_cost : int = 50
var max_shield_hp : int = 100
var shield_hp : int = 50 # How much damage the shield takes before turning off
var shield_regen_rate : int = 2 # Passive regeneration value
var shield_boost_rate : int = 25 # Active regeneration value
var energy_drain_rate : int = 5 # Passive energy drain value
var cooldown_time : float = 25
var force_disabled : bool = true

@onready var is_friendly : bool = false
@onready var type : MechData.ObjectType = MechData.ObjectType.MODULE

@onready var drain_sfx: AudioStreamPlayer2D = $SFX/Drain
@onready var disable_sfx: AudioStreamPlayer2D = $SFX/Disable
@onready var charge_sfx: AudioStreamPlayer2D = $SFX/Charge
@onready var ambient: AudioStreamPlayer2D = $SFX/Ambient

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
	energy_drain.timeout.connect(_drain_energy)
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
	force_disable()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if shield_hp >= max_shield_hp:
		shield_hp = max_shield_hp
	charge.value = shield_hp

func _input_event(_viewport, event, _shape_idx):
	if get_parent().get_parent().name == "Mech":
		if event is InputEventMouseButton and event.pressed and mech.mech_edit:
			if event.button_index == MOUSE_BUTTON_LEFT and mech.current_terminal != null:
				print("Terminal " + mech.current_terminal.name + " has been connected to " + self.name)
				mech.current_terminal.arm(self)
				print("Deactivating terminal connection mode.")
				mech.current_terminal = null

func engage():
	force_disabled = false
	shield_area.monitoring = true
	shield_area.show()
	shield_hp += shield_boost_rate
	charge.value = shield_hp
	charge_sfx.play()
	if get_parent().get_parent().name == "Mech":
		main.static_ui.set_status("Engaging Force Shield!\n-50 Energy")

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

func _drain_energy():
	if not force_disabled:
		if mech.drain_energy(energy_drain_rate):
			shield_hp += shield_regen_rate
			charge.value = shield_hp
			drain_sfx.play()
			if not ambient.playing:
				ambient.play()
			return
		force_disable()

func take_damage(damage_value : int, _collision, _knockback_force):
	shield_hp -= damage_value
	charge.value = shield_hp
	if shield_hp <= 0:
		force_disable()

func force_disable():
	force_disabled = true
	charge.value = shield_hp
	shield_area.monitoring = false
	shield_area.hide()
	disable_sfx.play()
	ambient.stop()
