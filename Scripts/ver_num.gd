extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.text = "Mech Team - Alpha Ver. " + ProjectSettings.get_setting("application/config/version") + "
	All mechanics and assets are subject to change."
