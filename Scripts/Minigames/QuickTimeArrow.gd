extends Control

const DOWN = preload("uid://dcrp6tppbsvl4")
const LEFT = preload("uid://ct452l4vvyn2i")
const RIGHT = preload("uid://cenobjevlni5")
const UP = preload("uid://bs2fqwxm2rdeq")

@onready var timed_game = $TimedGame

@onready var minigames = $".."

@onready var flow_container = $FlowContainer

@onready var lose_sfx: AudioStreamPlayer = $SFX/Lose
@onready var win_sfx: AudioStreamPlayer = $SFX/Win
@onready var input_sfx: AudioStreamPlayer = $SFX/Input

var directions = []	# up, down, left, right
var direction_index = 0

var game_ended : bool = false

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(event):
	if game_ended:
		return
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
	

func start():
	var input_count = randi_range(4,6)
	
	timed_game.start(float(input_count)/3)
	# Spawn 3 directions in a row
	# Spawn 3 labels in a row
	for i in range(2, input_count):
		var arrow_texture = TextureRect.new()
		match randi_range(0,3):
			0:
				arrow_texture.texture = UP
				directions.append(0)
			1:
				arrow_texture.texture = DOWN
				directions.append(1)
			2:
				arrow_texture.texture = LEFT
				directions.append(2)
			3:
				arrow_texture.texture = RIGHT
				directions.append(3)
		flow_container.add_child(arrow_texture)
	flow_container.get_child(0).self_modulate = Color(0, 255, 0)

func victory_check(direction):
	if direction == directions[direction_index]:
		flow_container.get_child(0).free() # Dangerous.
		print("Correct!")
		if direction_index + 1 >= directions.size():
			print("You Win!")
			game_ended = true
			self.hide()
			win_sfx.play()
			minigames.win()
			minigames.player.end_minigame()
			await get_tree().create_timer(0.2).timeout
			queue_free()
		else:
			input_sfx.play()
			direction_index += 1
			flow_container.get_child(0).self_modulate = Color(0, 255, 0)
	else:
		lose()

func lose():
	print("You Lose!")
	game_ended = true
	self.hide()
	lose_sfx.play()
	minigames.lose()
	minigames.player.end_minigame()
	await get_tree().create_timer(0.5).timeout
	queue_free()
