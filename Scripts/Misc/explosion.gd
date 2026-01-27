extends AnimatedSprite2D

const EXPLOSION_PARTICLES = preload("uid://vlhrywjv8hr6")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func spawn_particles():
	var particle_instance = EXPLOSION_PARTICLES.instantiate()
	add_sibling(particle_instance)
	particle_instance.global_position = self.global_position
