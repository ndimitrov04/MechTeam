extends RigidBody2D

const EXPLOSION_1 = preload("uid://buh5u6wul5uno")
const EXPLOSION_2 = preload("uid://otoyfe2et2x1")

@onready var explosions = [EXPLOSION_1, EXPLOSION_2]

@onready var tilemap = $Tilemap
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	timer.timeout.connect(_on_timeout)
	var explosion = explosions.pick_random().instantiate()
	add_sibling(explosion)
	await get_tree().process_frame
	explosion.global_position = self.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass

func _on_body_entered(_body):
	if timer.is_stopped():
		timer.start(1.5)

func _on_timeout():
	queue_free()

func set_sprite(atlas_coords : Vector2i):
	tilemap.set_cell(Vector2i(0,0), 0, atlas_coords)
