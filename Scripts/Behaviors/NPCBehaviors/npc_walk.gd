extends Node2D

@onready var edge_detector = $EdgeDetector
@onready var wall_detector = $WallDetector

@onready var current_direction : int = 1
@onready var moving : bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not moving:
		return
	
	if not edge_detector.is_colliding():
		current_direction *= -1
		edge_detector.position.x *= -1
		wall_detector.target_position.x *= -1
	
	if wall_detector.is_colliding():
		current_direction *= -1
		edge_detector.position.x *= -1
		wall_detector.target_position.x *= -1
	
	get_parent().direction = current_direction

func stop_moving(time : float):
	var last_direction = current_direction
	moving = false
	current_direction = 0
	get_parent().direction = current_direction
	await get_tree().create_timer(time).timeout
	current_direction = last_direction
	moving = true
