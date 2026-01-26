extends RigidBody2D

@onready var main = $"../../.."
@onready var mech = $"../.."

@onready var shoot_point = $ShootPoint

var bullet = preload("res://Scenes/Projectiles/bullet.tscn")

var repeat_rate : int = 10	# Number of bullets fired per volley
var recoil : float = 0.15	# Recoil rotation of gun module per shot in radians

var energy_cost : int = 30
var cooldown_time : float = 20

#unfreeze gun physics on destruction

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and mech.mech_edit:
		if event.button_index == MOUSE_BUTTON_LEFT and mech.current_terminal != null:
			print("Terminal " + mech.current_terminal.name + " has been connected to " + self.name)
			mech.current_terminal.arm(self)
			print("Deactivating terminal connection mode.")
			mech.current_terminal = null

func shoot():
	for i in range(0, repeat_rate):
		await get_tree().create_timer(0.15).timeout
		var bullet_instance = bullet.instantiate()
		main.add_child(bullet_instance)
		bullet_instance.global_rotation = self.global_rotation
		bullet_instance.global_position = shoot_point.global_position
		# Apply recoil per shot
		self.rotate(randf_range(-recoil, recoil))
