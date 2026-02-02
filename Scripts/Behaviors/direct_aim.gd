extends Node2D

@onready var crosshair = null

var aim_speed : float

func _ready():
	if get_parent().get_parent().get_parent().name == "Mech":
		crosshair = $"../../../Crosshair"
	aim_speed = get_parent().get_meta("aim_speed")

func _process(delta):
	if crosshair:
		var target_angle = global_position.angle_to_point(crosshair.global_position)
		get_parent().global_rotation = lerp_angle(global_rotation, target_angle, aim_speed * delta)
