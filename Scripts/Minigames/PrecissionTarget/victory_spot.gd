extends Area2D

var is_finish : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "MiniPlayer":
		get_parent().get_parent().get_parent().victory_check(true)
