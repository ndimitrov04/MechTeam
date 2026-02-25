extends RigidBody2D

@onready var main = $"../../.."
@onready var mech = $"../.."

@onready var charge = $Charge
@onready var energy_drain = $EnergyDrain
@onready var shield_area = $ShieldArea

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
	if get_parent().get_parent().get_parent().name == "Main":
		get_parent().get_parent().get_parent().player.screenshake(self.global_position, knockback_force)
