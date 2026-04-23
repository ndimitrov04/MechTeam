extends Node2D

@onready var player = $Player
@onready var mech = $Mech

@onready var static_ui = $GUI/Control/StaticUI
@onready var minigame_result = $GUI/Control/StaticUI/MinigameResult
@onready var screen_border = $Foreground/Parallax1/ScreenBorder
@onready var screen_limit = $Foreground/Parallax1/ScreenBorder/ScreenLimit

@onready var first_enemy : RigidBody2D = $EnemyMech4
var SPAWN_OFFSET = 750 # Next enemy offset in pixels
@warning_ignore("narrowing_conversion")
@onready var enemies_left : int = clamp(0.75 * PlayerData.current_stage, 2, 10)
@onready var triggered : bool = false

@onready var npc_deaths : int = 0
@onready var rewards_collected : int = 0

const MECH_1 = preload("uid://b8wn41m8pycq8")
const MECH_2 = preload("uid://c6itfhereaxo0")
const MECH_3 = preload("uid://j5p75yywprhn")
const MECH_4 = preload("uid://b6st1n1r2654j")
const MECH_5 = preload("uid://cswrah0x8i0f4")
const MECH_6 = preload("uid://1wjcby4h5nyl")
const MECH_7 = preload("uid://bfhkp7r7o5oi4")
const MECH_8 = preload("uid://cpdelmkd6jtbm")
const MECH_9 = preload("uid://dh2noacyx7w6x")

@onready var enemies = [MECH_1, MECH_2, MECH_3, MECH_4, MECH_5, MECH_6, MECH_7, MECH_8, MECH_9]
@onready var planet_enemies = [
	# NEOS
	[
		MECH_1, MECH_2, MECH_4, MECH_5, MECH_6
	],
	# GAIA
	[
		MECH_1, MECH_2, MECH_3, MECH_4, MECH_5, MECH_6, MECH_8
	],
	# TERRA
	[
		MECH_2, MECH_3, MECH_7, MECH_8, MECH_9
	],
	# SELENE
	[
		MECH_1, MECH_2, MECH_3, MECH_4, MECH_5, MECH_6, MECH_7, MECH_8, MECH_9
	]
]
@onready var Y_SPAWN = -650 # Y-Level at which mechs will spawn

var end_text : String = ""

# Stage props
# Backgrounds
@onready var BG_1 = preload("uid://di1e18fc8a085")
@onready var BG_2 = preload("uid://d14axc4abnp8l")
@onready var BG_3 = preload("uid://ebasi4gf18tp")
@onready var BG_4 = preload("uid://b6puxakxfkx2h")
@onready var backgrounds = [BG_1, BG_2, BG_3, BG_4]
# Soundtracks
const OST_1 = "uid://6xm4gvdu3qsl"
const OST_2 = "uid://ce4508tlmtnyx"
const OST_3 = "uid://m8uma6bexyvi"
const OST_4 = "uid://byq36523c31uh"
@onready var soundtracks = [OST_1, OST_2, OST_3, OST_4]
func _ready():
	# Stage Number:  0 = NEOS, 1 = GAIA, 2 = TERRA, 3 = SELENA
	var stage_number = PlayerData.current_planet
	if stage_number == 2:
		Y_SPAWN = 0 # Stage with BG3 is a cave, accomodate for low celling
	#stage_number = 0  # debug stage lock
	var current_background = backgrounds[stage_number].instantiate()
	add_child(current_background)
	move_child(current_background, 0)
	GlobalMusic.queue_track(soundtracks[stage_number], 2)
	
	# Debug terrain test
	if PlayerData.terrain_test:
		print("NOTICE: TERRAIN TEST IS ON.")
		SPAWN_OFFSET = 99999
		if first_enemy:
			first_enemy.die()

func _process(_delta):
	if int(mech.global_position.x) % 500 == 0:
		print("Current Mech Position: " + str(mech.global_position.x))
	
	if enemies_left <= 0 and not triggered:
		GlobalMusic.queue_track("uid://bfjye4qxke0i", 0.5)
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
	#var enemy_instance = enemies.pick_random().instantiate()
	var enemy_instance = planet_enemies[PlayerData.current_planet].pick_random().instantiate()
	mech.add_sibling(enemy_instance)
	print("Mech X:" + str(mech.global_position.x))
	print("Enemy X:" + str(screen_limit.global_position.x - 950))
	enemy_instance.global_position.y = Y_SPAWN
	enemy_instance.global_position.x = screen_limit.global_position.x - 950
	enemy_instance.rotation = 0

func end_stage():
	await get_tree().create_timer(0.1).timeout
	minigame_result.position.y -= 550
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
			"\n\nTotal cash: " + str(PlayerData.money)
		)
	if PlayerData.current_stage % 3 == 0:
		end_text += "\n\n\nLeaving planet in 15 seconds..."
	else:
		end_text += "\n\n\nGoing to next stage in 15 seconds..."
	minigame_result.text = end_text
	minigame_result.add_theme_color_override("font_color", Color("green"))
	minigame_result.show()
	await get_tree().create_timer(16).timeout
	if PlayerData.current_stage % 3 == 0:
		PlayerData.planets_finished.append(PlayerData.current_planet)
		PlayerData.current_stage += 1
		IndieBlueprintSceneTransitioner.transition_to(
		"res://Scenes/planet_selector.tscn", 
			IndieBlueprintPremadeTransitions.Dissolve,
			IndieBlueprintPremadeTransitions.Dissolve,
			{ 
				"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("55648C")},
				"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("000418")}
			}
		)
	else:
		PlayerData.current_stage += 1
		IndieBlueprintSceneTransitioner.transition_to(
			"res://Scenes/mech_builder.tscn", 
			IndieBlueprintPremadeTransitions.Dissolve,
			IndieBlueprintPremadeTransitions.Dissolve,
			{ 
				"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("55648C")},
				"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
			}
		)
