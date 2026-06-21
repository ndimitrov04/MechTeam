extends RigidBody2D

@onready var timer: Timer = $Timer
@onready var hurtbox: CollisionShape2D = $Hurtbox

@onready var SPEED : int = get_meta("speed")

@onready var damage_value : int = get_meta("damage_value")

@onready var knockback_force : int = get_meta("knockback")

@onready var lifetime : float = get_meta("lifetime")
@onready var pierce_rate : int = get_meta("pierce_rate")

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	timer.timeout.connect(_on_timeout)
	timer.start(lifetime)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var move_vector = transform.y * SPEED * delta
	var collision = move_and_collide(move_vector)
	
	if collision:
		_on_body_entered(collision.get_collider(), collision)

func _on_body_entered(body, collision = null):
	#print("Hit " + body.name)
	#print(body.name + ": ")
	#print("Parent: " + body.get_parent().name)
	if body.name == "Frame":
		#print("Damage Value: " + str(damage_value))
		#print("Collision:" + str(collision))
		#print("Knockback Force:" + str(knockback_force))
		pass
	if body.get_parent().name == "Modules" or body.get_parent().name == "Weapons":
		body.destroy()
		#print("Destroying" + body.name)
	if body.name == "Player":
		body.take_damage(1, 0, 0)
	if body.has_method("take_damage"):
		body.take_damage(damage_value, collision, knockback_force)
	if get_meta("hitflash"):
		flash_collisions()
	if get_meta("impact"):
		get_parent().player.screenshake(self.global_position, knockback_force)
	if pierce_rate == 0:
		queue_free()
	else:
		pierce_rate -= 1

func flash_collisions():
	hurtbox.set_deferred("disabled", true)
	await get_tree().create_timer(0.05).timeout
	hurtbox.set_deferred("disabled", false)

func _on_timeout():
	queue_free()
