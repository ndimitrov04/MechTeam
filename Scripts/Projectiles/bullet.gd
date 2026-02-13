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
	#print("Hit " + body.name)
	#print(body.name + ": ")
	#print("Parent: " + body.get_parent().name)
	#if body.name == "Frame":
		#print("Damage Value: " + str(damage_value))
		#print("Collision:" + str(collision))
		#print("Knockback Force:" + str(knockback_force))
	if body.get_parent().name == "Modules" or body.get_parent().name == "Weapons":
		body.destroy()
		#print("Destroying" + body.name)
	if body.has_method("take_damage"):
		body.take_damage(damage_value, collision, knockback_force)
	get_parent().player.screenshake(self.global_position, knockback_force)
	queue_free()
