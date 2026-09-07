extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if PlayerData.dim_bg:
		self.visible = true
	else:
		self.visible = false
