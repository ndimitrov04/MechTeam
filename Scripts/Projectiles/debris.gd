extends RigidBody2D

const EXPLOSION_1 = preload("uid://buh5u6wul5uno")
const EXPLOSION_2 = preload("uid://otoyfe2et2x1")

@onready var explosions = [EXPLOSION_1, EXPLOSION_2]

@onready var tilemap = $Tilemap
@onready var timer = $Timer
@onready var sfx = $SFX

@onready var explode : bool

@onready var explosion

const EXPLOSION_01 = preload("uid://w7445ct0jx4j")
const EXPLOSION_02 = preload("uid://cuddyjxpivdvd")
const EXPLOSION_03 = preload("uid://drqhf0dm2hltk")
const EXPLOSION_04 = preload("uid://c3mh2g2bd8sis")
const EXPLOSION_05 = preload("uid://dobdusbmot6cj")
const EXPLOSION_06 = preload("uid://b4pgtc3pjhvsl")
const EXPLOSION_07 = preload("uid://bwaqyoblhs8dy")
const EXPLOSION_08 = preload("uid://c0hywp7nisiml")
const EXPLOSION_09 = preload("uid://cfrt0wur7hvey")

var explosion_sounds = [EXPLOSION_01,EXPLOSION_02,EXPLOSION_03,EXPLOSION_04,
						EXPLOSION_05,EXPLOSION_06,EXPLOSION_07,EXPLOSION_08]

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	timer.timeout.connect(_on_timeout)
	explosion = explosions.pick_random().instantiate()
	add_sibling(explosion)
	await get_tree().process_frame
	explosion.global_position = self.global_position
	sfx.stream = explosion_sounds.pick_random()
	sfx.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass

func _on_body_entered(_body):
	sfx.play()
	if timer.is_stopped():
		timer.start(1.5)

func _on_timeout():
	queue_free()

func set_sprite(atlas_coords : Vector2i):
	if tilemap:
		tilemap.set_cell(Vector2i(0,0), 0, atlas_coords)
