extends SubViewportContainer

@onready var mech = $"../../../../../Mech"

@onready var sub_viewport = $SubViewport

@onready var mech_camera = $SubViewport/MechCamera

# Called when the node enters the scene tree for the first time.
func _ready():
	mech_camera.custom_viewport = sub_viewport
	sub_viewport.world_2d = get_viewport().world_2d

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	mech_camera.position = mech.global_position + Vector2(512,256)
