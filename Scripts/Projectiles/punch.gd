extends Area2D

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
func _process(_delta):
	pass

func _on_body_entered(body):
	#print("Hit " + body.name)
	#print(body.name + ": ")
	#print("Parent: " + body.get_parent().name)
	#if body.name == "Frame":
		#print("Damage Value: " + str(damage_value))
		#print("Collision:" + str(collision))
		#print("Knockback Force:" + str(knockback_force))
	if body.get_parent().name == "Modules" or body.get_parent().name == "Weapons" or body.name == "Frame":
		if body.has_meta("mod"):
			body._on_body_entered(null)
		return
		#print("Destroying" + body.name)
	elif body.has_method("take_damage"):
		body.take_damage(damage_value, null, 0)
		

func flash_collisions():
	hurtbox.set_deferred("disabled", true)
	await get_tree().create_timer(0.05).timeout
	hurtbox.set_deferred("disabled", false)

func _on_timeout():
	queue_free()
