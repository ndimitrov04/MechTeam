extends Node2D

@onready var crosshair = null

var aim_speed : float
var inverted : bool

func _ready():
	if get_parent().get_parent().get_parent().name != "Editor":
		crosshair = $"../../../Crosshair"
	aim_speed = get_parent().get_meta("aim_speed")
	inverted = self.get_meta("inverted")

func _process(delta):
	if crosshair and get_parent().destroyed == false:
		var target_angle = global_position.angle_to_point(crosshair.global_position)
		if inverted:
			target_angle += PI
		get_parent().global_rotation = lerp_angle(global_rotation, target_angle, aim_speed * delta)
