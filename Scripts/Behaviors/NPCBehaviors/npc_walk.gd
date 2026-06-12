extends Node2D

@onready var edge_detector = $EdgeDetector
@onready var wall_detector = $WallDetector
@onready var turnaround_timer: Timer

@onready var current_direction : int = 1
@onready var moving : bool = true
@onready var turnarounds : int = 1
@onready var has_turnaround : bool = false
@onready var can_turnaround : bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	if is_instance_valid(get_node("TurnaroundTimer")):
		turnaround_timer = $TurnaroundTimer
		turnaround_timer.timeout.connect(_on_turnaround_timer_timeout)
		has_turnaround = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not moving:
		return
	
	if get_parent().is_on_floor():
		if not edge_detector.is_colliding():
			turn_around()
		elif wall_detector.is_colliding():
			turn_around()
	
	# If NPC spams turn-around, then just stop moving for a while.
	if turnarounds % 3 == 0 and has_turnaround:
		stop_moving(20)
	
	get_parent().direction = current_direction

func turn_around():
	if not can_turnaround:
		return
	can_turnaround = false
	current_direction *= -1
	edge_detector.position.x *= -1
	wall_detector.target_position.x *= -1
	turnarounds += 1
	await get_tree().create_timer(0.05).timeout
	can_turnaround = true

func stop_moving(time : float):
	var last_direction = current_direction
	moving = false
	current_direction = 0
	get_parent().direction = current_direction
	await get_tree().create_timer(time).timeout
	current_direction = last_direction
	moving = true

func _on_turnaround_timer_timeout() -> void:
	turnarounds = 1
