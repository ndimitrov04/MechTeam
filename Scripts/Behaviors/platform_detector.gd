extends RayCast2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.is_colliding():
		var collider = self.get_collider()
		if not collider.name == "Frame":
			return
		var mech = collider.get_parent()
		get_parent().velocity.x = get_parent().direction * get_parent().SPEED + mech.linear_velocity.x
