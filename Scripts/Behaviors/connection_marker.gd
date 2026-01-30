extends Line2D

const OFFSET : Vector2 = Vector2(0, -15)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.set_point_position(1, get_global_mouse_position() - get_parent().global_position + OFFSET)
