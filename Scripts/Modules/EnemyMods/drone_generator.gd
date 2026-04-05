extends RigidBody2D

@onready var main = $"../../.."
@onready var mech = $"../.."

@onready var spawn_timer = $SpawnTimer

@onready var drain_sfx: AudioStreamPlayer2D = $SFX/Drain
@onready var charge_sfx: AudioStreamPlayer2D = $SFX/Charge
@onready var ambient: AudioStreamPlayer2D = $SFX/Ambient
@onready var drop_sfx: AudioStreamPlayer2D = $SFX/Drop

const DEBRIS = preload("uid://rg2m11gs0xex")

var energy_cost : int = 5
var max_energy : int = 100
var cooldown_time : float = 25

@onready var is_friendly : bool = false
@onready var type : MechData.ObjectType = MechData.ObjectType.MODULE

@onready var controller

# Enemy minions
@onready var MINION_1 = preload("res://Scenes/Enemies/EnemyMinion/Attacker/offensive_drone.tscn")

@onready var minions = [MINION_1]


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
	spawn_timer.timeout.connect(_spawn_enemy)
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
	await get_tree().create_timer(1).timeout
	_spawn_enemy()

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var interaction_label: Label = $InteractionLabel
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if Input.is_action_pressed("scan"):
		interaction_label.show()
		sprite.material.set_shader_parameter("color", Color(1, 0, 0))
	else:
		interaction_label.hide()
		sprite.material.set_shader_parameter("color", Color(1, 1, 1))

func _input_event(_viewport, event, _shape_idx):
	if get_parent().get_parent().name == "Mech":
		if event is InputEventMouseButton and event.pressed and mech.mech_edit:
			if event.button_index == MOUSE_BUTTON_LEFT and mech.current_terminal != null:
				print("Terminal " + mech.current_terminal.name + " has been connected to " + self.name)
				mech.current_terminal.arm(self)
				print("Deactivating terminal connection mode.")
				mech.current_terminal = null

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

# Manual enemy spawn via action
func engage():
	if spawn_timer.time_left > 4:
		return
	_spawn_enemy()
	spawn_timer.start()

func _on_body_entered(_body):
	var debris_instance = DEBRIS.instantiate()
	main.call_deferred("add_child", debris_instance)
	debris_instance.global_position = global_position
	drop()
	await get_tree().create_timer(1.0).timeout
	queue_free()
	

# Passive enemy spawn
func _spawn_enemy():
	var enemy_instance = minions.pick_random().instantiate()
	mech.npcs.add_child(enemy_instance)
	enemy_instance.global_position = self.global_position

func drop():
	const QUBODUP_PUNCH_01 = preload("uid://708qbmb1elfe")
	const QUBODUP_PUNCH_02 = preload("uid://3ym41o68s5hs")
	const QUBODUP_PUNCH_03 = preload("uid://kx7214pkd02j")
	const QUBODUP_PUNCH_04 = preload("uid://dmwuh6jgmxre1")
	const QUBODUP_PUNCH_05 = preload("uid://b1u8fhv870l5e")
	
	const drop_effects = [QUBODUP_PUNCH_01,QUBODUP_PUNCH_02,QUBODUP_PUNCH_03,QUBODUP_PUNCH_04,QUBODUP_PUNCH_05]
	
	drop_sfx.stream = drop_effects.pick_random()
	drop_sfx.play()
