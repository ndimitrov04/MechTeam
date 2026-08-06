extends RigidBody2D

@onready var tilemap = $Tilemap
@onready var timer = $Timer

@onready var explode : bool

@onready var explosion

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.timeout.connect(_on_timeout)
	timer.start(2.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass

func _on_timeout():
	queue_free()

func set_sprite(atlas_coords : Vector2i):
	if tilemap:
		tilemap.set_cell(Vector2i(0,0), 0, atlas_coords)
