extends CanvasLayer

@onready var crt: CRT = $CRT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not PlayerData.post_fx_enabled:
		hide()
		crt.hide()
	else:
		show()
		crt.show()
