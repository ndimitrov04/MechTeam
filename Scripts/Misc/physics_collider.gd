extends CollisionShape2D

const CRASH_RAY_L = preload("uid://bm0de82knqhp4")
const CRASH_RAY_R = preload("uid://vd3m6mpynv1")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent().name == "Mech":
		add_child(CRASH_RAY_R.instantiate())
	else:
		add_child(CRASH_RAY_L.instantiate())
