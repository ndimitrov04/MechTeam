extends Control

@onready var timed_game = $TimedGame

@onready var startpoints: Node2D = $Panel/Startpoints
@onready var endpoints: Node2D = $Panel/Endpoints

@onready var minigames = $".."

@onready var lose_sfx: AudioStreamPlayer = $SFX/Lose
@onready var win_sfx: AudioStreamPlayer = $SFX/Win
@onready var input_sfx: AudioStreamPlayer = $SFX/Input

@onready var mini_player: CharacterBody2D = $Panel/MiniPlayer

var game_ended : bool = false

func _ready():
	mini_player.global_position = startpoints.get_children().pick_random().global_position
	endpoints.get_children().pick_random().show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(_event):
	if game_ended:
		return

func start():
	timed_game.start(randi_range(25,35))

func victory_check(has_won : bool):
	if game_ended:
		return
	if has_won:
		print("You Win!")
		game_ended = true
		self.hide()
		win_sfx.play()
		minigames.win()
		minigames.player.end_minigame()
		queue_free()
	else:
		game_ended = true
		lose()

func lose():
	print("You Lose!")
	game_ended = true
	self.hide()
	lose_sfx.play()
	minigames.lose()
	minigames.player.end_minigame()
	queue_free()
