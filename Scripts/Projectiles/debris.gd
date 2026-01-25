extends RigidBody2D

@onready var tilemap = $Tilemap
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	timer.timeout.connect(_on_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func _on_body_entered(body):
	if timer.is_stopped():
		timer.start(3.0)

func _on_timeout():
	queue_free()

func set_sprite(atlas_coords : Vector2i):
	tilemap.set_cell(Vector2i(0,0), 0, atlas_coords)
