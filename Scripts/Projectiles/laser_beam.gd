extends Area2D

const SPEED : int = 0

var damage_value : int = 25
var collision : KinematicCollision2D = null
var knockback_force : int = 300

@onready var sprite: AnimatedSprite2D = $Sprites/Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	sprite.animation_finished.connect(_on_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass

func _on_body_entered(body):
	print("Hit " + body.name)
	print(body.name + ": ")
	print("Parent: " + body.get_parent().name)
	#if body.name == "Frame":
		#print("Damage Value: " + str(damage_value))
		#print("Collision:" + str(collision))
		#print("Knockback Force:" + str(knockback_force))
	if body.get_parent().name == "Modules" or body.get_parent().name == "Weapons":
		body.destroy()
		print("Destroying" + body.name)
	if body.has_method("take_damage"):
		body.take_damage(damage_value, null, 0)

func _on_finished():
	await get_tree().create_timer(0.1).timeout
	queue_free()
