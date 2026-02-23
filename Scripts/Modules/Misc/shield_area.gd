extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_body_entered(body):
	if "damage_value" in body and not get_parent().force_disabled:
		get_parent().take_damage(body.damage_value, null, null)
		body.queue_free()
		# Play shield sound
