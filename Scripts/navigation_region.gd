extends NavigationRegion2D

@onready var rebake_navmesh: Timer = $RebakeNavmesh

@export var rebake_period : float = 3.0

func _ready():
	rebake_navmesh.wait_time = rebake_period

func _on_rebake_navmesh_timeout():
	if not self.is_baking():
		self.bake_navigation_polygon()
