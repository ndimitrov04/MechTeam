extends RigidBody2D

@onready var main = $"../../.."

var bullet = preload("res://Scenes/Projectiles/bullet.tscn")

var repeat_rate = 10

#unfreeze gun physics on destruction

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func shoot():
	for i in range(0, repeat_rate):
		await get_tree().create_timer(0.1).timeout
		var bullet_instance = bullet.instantiate()
		main.add_child(bullet_instance)
		bullet_instance.global_rotation = self.global_rotation
		bullet_instance.global_position = self.global_position
		
	# Start cooldown
