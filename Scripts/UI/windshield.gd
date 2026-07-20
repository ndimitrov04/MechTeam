extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not PlayerData.current_planet == PlayerData.planets.GAIA:
		self.material = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
