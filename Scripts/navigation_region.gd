extends NavigationRegion2D

@onready var screen_border: TextureRect = $"../Foreground/Parallax1/ScreenBorder"

@onready var rebake_navmesh: Timer = $RebakeNavmesh

@export var rebake_period : float = 3.0

func _ready():
	rebake_navmesh.wait_time = rebake_period

func _on_rebake_navmesh_timeout():
	self.global_position.x = screen_border.global_position.x - 1500
	if not self.is_baking():
		self.bake_navigation_polygon()
