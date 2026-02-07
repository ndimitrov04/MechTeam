extends SubViewportContainer

@onready var crosshair = $"../../../../../Mech/Crosshair"

@onready var sub_viewport = $SubViewport

@onready var crosshair_camera = $SubViewport/CrosshairCamera

# Called when the node enters the scene tree for the first time.
func _ready():
	crosshair_camera.custom_viewport = sub_viewport
	sub_viewport.world_2d = get_viewport().world_2d

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	crosshair_camera.position = crosshair.global_position
