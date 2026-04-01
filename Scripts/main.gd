extends Node2D

@onready var player = $Player
@onready var music = $Music
@onready var mech = $Mech

@onready var static_ui = $GUI/Control/StaticUI
@onready var minigame_result = $GUI/Control/StaticUI/MinigameResult
@onready var screen_border = $Foreground/Parallax1/ScreenBorder
@onready var screen_limit = $Foreground/Parallax1/ScreenBorder/ScreenLimit

const SPAWN_OFFSET = 750 # Next enemy offset in pixels
@warning_ignore("narrowing_conversion")
@onready var enemies_left : int = float(PlayerData.current_stage) * 1.5 + 9
@onready var triggered : bool = false

@onready var npc_deaths : int = 0
@onready var rewards_collected : int = 0

const MECH_1 = preload("uid://b8wn41m8pycq8")
const MECH_2 = preload("uid://c6itfhereaxo0")
const MECH_3 = preload("uid://j5p75yywprhn")
const MECH_4 = preload("uid://b6st1n1r2654j")

@onready var enemies = [MECH_1, MECH_2, MECH_3, MECH_4]

var end_text : String = ""


# Stage props
# Backgrounds
@onready var BG_1 = preload("uid://di1e18fc8a085")
@onready var BG_2 = preload("uid://d14axc4abnp8l")
@onready var BG_3 = preload("uid://ebasi4gf18tp")
@onready var BG_4 = preload("uid://b6puxakxfkx2h")
@onready var backgrounds = [BG_1, BG_2, BG_3, BG_4]
# Soundtracks
@onready var OST_1 = preload("uid://6xm4gvdu3qsl")
@onready var OST_2 = preload("uid://ce4508tlmtnyx")
@onready var OST_3 = preload("uid://m8uma6bexyvi")
@onready var OST_4 = preload("uid://byq36523c31uh")
@onready var soundtracks = [OST_1, OST_2, OST_3, OST_4]
func _ready():
	var stage_number = randi_range(0, backgrounds.size()-1)
	#stage_number = 0  # debug stage lock
	var current_background = backgrounds[stage_number].instantiate()
	add_child(current_background)
	move_child(current_background, 0)
	music.stream = soundtracks[stage_number]
	music.play()

func _process(_delta):
	if enemies_left <= 0 and not triggered:
		music.stream = preload("uid://bfjye4qxke0i")
		music.play()
		end_stage()
		triggered = true
	
	if enemies_left <= 0:
		minigame_result.modulate = Color(1,1,1,1)
		minigame_result.text = end_text
		minigame_result.add_theme_color_override("font_color", Color("green"))
		minigame_result.show()

func advance():
	if enemies_left > 0:
		player.camera.limit_right += SPAWN_OFFSET + 1800
		screen_limit.global_position.x = player.camera.limit_right
		#screen_border.position.x += SPAWN_OFFSET + 1500
		# The code below breaks the game due to enemy spawning 
		# too fast inside of the world border
		var tween = create_tween()
		tween.tween_property(
			screen_border,
			"position:x",
			screen_border.position.x + SPAWN_OFFSET + 1800,
			1.5 # duration in seconds
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		spawn_random_enemy()
		static_ui.display_advance_arrow()

func spawn_random_enemy():
	var enemy_instance = enemies.pick_random().instantiate()
	mech.add_sibling(enemy_instance)
	print("Mech X:" + str(mech.global_position.x))
	print("Enemy X:" + str(screen_limit.global_position.x - 950))
	enemy_instance.global_position.y = -650
	enemy_instance.global_position.x = screen_limit.global_position.x - 950
	enemy_instance.rotation = 0

func end_stage():
	await get_tree().create_timer(0.1).timeout
	minigame_result.position.y -= 550
	PlayerData.current_stage += 1
	PlayerData.money -= (mech.max_hp - mech.hp) * 0.5
	PlayerData.money -= npc_deaths * 10
	end_text = (
			"YOU WIN!\n\n\n" +
			"Rewards collected: " + str(rewards_collected) +
			"\n\nMech Status" +
			"\nDamage taken: " + str(mech.max_hp - mech.hp) + 
			"\n- Repair costs: " + str(int((mech.max_hp - mech.hp) * 0.5)) + 
			"\n\nCrew Status" +
			"\nCrew Wages: " + str(mech.npcs.get_child_count() * 5) +
			"\nCrew Injured: " + str(npc_deaths) + 
			"\n- Medical fees: " + str(npc_deaths * 10) +
			"\n\nTotal cash: " + str(PlayerData.money) +
			"\n\n\nGoing to next stage in 15 seconds..."
		)
	minigame_result.text = end_text
	minigame_result.add_theme_color_override("font_color", Color("green"))
	minigame_result.show()
	await get_tree().create_timer(16).timeout
	get_tree().change_scene_to_file("res://Scenes/mech_builder.tscn")
