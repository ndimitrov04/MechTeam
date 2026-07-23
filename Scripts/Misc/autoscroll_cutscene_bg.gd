extends Node2D

@export var speed = 75
@onready var parallax: Node2D = $Parallax
@onready var started = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if started:
		for layer in parallax.get_children():
			# Move parallax opposite to the object's movement (tweak sign if needed)
			layer.screen_offset.x += speed * delta
