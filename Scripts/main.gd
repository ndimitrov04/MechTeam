extends Node2D

@onready var player = $Player
@onready var music = $Music

@onready var static_ui = $GUI/Control/StaticUI
@onready var minigame_result = $GUI/Control/StaticUI/MinigameResult

@onready var enemies_left = 1
@onready var triggered : bool = false

func _process(_delta):
	if enemies_left <= 0 and not triggered:
		music.stream = preload("uid://bfjye4qxke0i")
		music.play()
		triggered = true
	
	if enemies_left <= 0:
		minigame_result.text = "YOU WIN!"
		minigame_result.add_theme_color_override("font_color", Color("green"))
		minigame_result.show()
		minigame_result.modulate = Color("white")
