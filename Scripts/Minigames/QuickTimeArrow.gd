extends Control

@onready var flow_container = $FlowContainer

var directions = []	# up, down, left, right
var direction_index = 0

func _ready():
	# Spawn 3 directions in a row
	# Spawn 3 labels in a row
	for i in range(2, randi_range(4,6)):
		var label = Label.new()
		match randi_range(0,3):
			0:
				label.text = "Up"
				directions.append(0)
			1:
				label.text = "Down"
				directions.append(1)
			2:
				label.text = "Left"
				directions.append(2)
			3:
				label.text = "Right"
				directions.append(3)
		flow_container.add_child(label)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(event):
	var current_direction = null
	if event.is_action_pressed("up"):
		current_direction = 0
		victory_check(current_direction)
	if event.is_action_pressed("down"):
		current_direction = 1
		victory_check(current_direction)
	if event.is_action_pressed("left"):
		current_direction = 2
		victory_check(current_direction)
	if event.is_action_pressed("right"):
		current_direction = 3
		victory_check(current_direction)
	
func victory_check(direction):
	if direction == directions[direction_index]:
		print("Correct!")
		if direction_index + 1 >= directions.size():
			print("You Win!")
			queue_free()
		else:
			direction_index += 1
	else:
		print("You Lose!")
		queue_free()
