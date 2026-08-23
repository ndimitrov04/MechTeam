extends NavigationRegion2D

@onready var screen_border: TextureRect = $"../Foreground/Parallax1/ScreenBorder"

@onready var rebake_navmesh: Timer = $RebakeNavmesh

@export var rebake_period : float = 3.0

func _ready():
	if PlayerData.current_stage > 13:
		self.scale = Vector2(2,2)
		self.global_position.x = -800
		self.global_position.y = -1900
	rebake_navmesh.wait_time = rebake_period

func _on_rebake_navmesh_timeout():
	if not PlayerData.current_stage > 13:
		self.global_position.x = screen_border.global_position.x - 1500
	if not self.is_baking():
		self.bake_navigation_polygon()
