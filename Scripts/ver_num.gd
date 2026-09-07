extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.text = "Mech Team - Beta Ver. " + ProjectSettings.get_setting("application/config/version")
