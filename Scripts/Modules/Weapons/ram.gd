extends RigidBody2D

@onready var main = $"../../.."
@onready var mech = $"../.."

@onready var charge = $Charge
@onready var energy_drain = $EnergyDrain
@onready var shield_area = $ShieldArea

@onready var ram_sfx: AudioStreamPlayer2D = $SFX/Ram
@onready var drop_sfx: AudioStreamPlayer2D = $SFX/Drop

const SPEED : int = 200
const DEBRIS = preload("uid://rg2m11gs0xex")

var damage_value : int = 1
var collision : KinematicCollision2D = null
var knockback_force : int = 300
var energy_cost : int = 0
var cooldown_time : float = 0

@onready var is_friendly : bool = false
@onready var type : MechData.ObjectType = MechData.ObjectType.MODULE

@onready var controller

# Used for saving and loading controller:weapon connection pairs
var index = null

#unfreeze gun physics on destruction
var destroyed : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var move_vector = transform.x * SPEED * delta
	collision = move_and_collide(move_vector, true)
	
	if collision:
		_on_body_entered(collision.get_collider())

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage_value * float(get_parent().get_parent().linear_velocity.x / 5), collision, knockback_force)
		ram_sfx.play()
	if get_parent().get_parent().get_parent().name == "Main":
		get_parent().get_parent().get_parent().player.screenshake(self.global_position, knockback_force)

func destroy():
	pass

func drop():
	const QUBODUP_PUNCH_01 = preload("uid://708qbmb1elfe")
	const QUBODUP_PUNCH_02 = preload("uid://3ym41o68s5hs")
	const QUBODUP_PUNCH_03 = preload("uid://kx7214pkd02j")
	const QUBODUP_PUNCH_04 = preload("uid://dmwuh6jgmxre1")
	const QUBODUP_PUNCH_05 = preload("uid://b1u8fhv870l5e")
	
	const drop_effects = [QUBODUP_PUNCH_01,QUBODUP_PUNCH_02,QUBODUP_PUNCH_03,QUBODUP_PUNCH_04,QUBODUP_PUNCH_05]
	
	drop_sfx.stream = drop_effects.pick_random()
	drop_sfx.play()
