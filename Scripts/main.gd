extends Node2D

@onready var player = $Player
@onready var music = $Music
@onready var mech = $Mech

@onready var static_ui = $GUI/Control/StaticUI
@onready var minigame_result = $GUI/Control/StaticUI/MinigameResult
@onready var screen_border = $Foreground/Parallax1/ScreenBorder

const SPAWN_OFFSET = 1000 # Next enemy offset in pixels
@onready var enemies_left = 3
@onready var triggered : bool = false


const MECH_1 = preload("uid://b8wn41m8pycq8")

@onready var enemies = [MECH_1]

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

func advance():
	if enemies_left > 0:
		player.camera.limit_right += SPAWN_OFFSET
		screen_border.position.x += SPAWN_OFFSET
		spawn_random_enemy()
		static_ui.display_advance_arrow()

func spawn_random_enemy():
	var enemy_instance = enemies.pick_random().instantiate()
	mech.add_sibling(enemy_instance)
	enemy_instance.global_position.x = screen_border.global_position.x - 250
