extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var visibility_tween = create_tween()
	visibility_tween.tween_property(
		self,
		"self_modulate",
		Color(1,0,0,0.3),
		2 # duration in seconds
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	visibility_tween.chain().tween_property(
		self,
		"self_modulate",
		Color(1,0,0,0),
		2 # duration in seconds
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
