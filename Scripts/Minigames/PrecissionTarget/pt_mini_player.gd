extends CharacterBody2D


var primed : bool = false

const SPEED = 150.0

@onready var timer: Timer = $Timer
@onready var wall_check: Area2D = $WallCheck

func _ready():
	timer.timeout.connect(_on_grace_period_timeout)
	wall_check.body_entered.connect(_on_body_entered)
	wall_check.area_entered.connect(_on_area_entered)

func _physics_process(_delta: float) -> void:
	
	var direction_x := Input.get_axis("left", "right")
	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	var direction_y := Input.get_axis("up", "down")
	if direction_y:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()


func _on_grace_period_timeout():
	primed = true

func _on_body_entered(body):
	if body.name == "Maze":
		if primed:
			get_parent().get_parent().victory_check(false)

func _on_area_entered(area):
	if "is_finish" in area:
		if primed:
			get_parent().get_parent().victory_check(true)
