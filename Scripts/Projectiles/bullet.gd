extends RigidBody2D

const SPEED : int = 200

var damage_value : int = 1

var collision : KinematicCollision2D = null
var knockback_force : int = 300

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var move_vector = transform.x * SPEED * delta
	collision = move_and_collide(move_vector)
	
	if collision:
		_on_body_entered(collision.get_collider())

func _on_body_entered(body):
	if body.name == "Frame":
		body.take_damage(damage_value, collision, knockback_force)
		
	# Explode
	queue_free()
