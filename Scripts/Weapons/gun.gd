extends RigidBody2D

@onready var main = $"../../.."

@onready var shoot_point = $ShootPoint

var bullet = preload("res://Scenes/Projectiles/bullet.tscn")

var repeat_rate : int = 10	# Number of bullets fired per volley
var recoil : float = 0.15	# Recoil rotation of gun module per shot in radians

#unfreeze gun physics on destruction

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func shoot():
	for i in range(0, repeat_rate):
		await get_tree().create_timer(0.15).timeout
		var bullet_instance = bullet.instantiate()
		main.add_child(bullet_instance)
		bullet_instance.global_rotation = self.global_rotation
		bullet_instance.global_position = shoot_point.global_position
		# Apply recoil per shot
		self.rotate(randf_range(-recoil, recoil))
