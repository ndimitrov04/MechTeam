extends Node2D

@onready var player = $Player
@onready var music = $Music
@onready var mech = $Mech

@onready var static_ui = $GUI/Control/StaticUI
@onready var minigame_result = $GUI/Control/StaticUI/MinigameResult
@onready var screen_border = $Foreground/Parallax1/ScreenBorder

const SPAWN_OFFSET = 1000
@onready var enemies_left : int = 2
@onready var triggered : bool = false

@onready var npc_deaths : int = 0
@onready var rewards_collected : int = 0

var end_text : String = ""


# Instruction strings for current tutorial stage

var instruction_0 : String = "There are 2 enemy mechs between us and our spaceship. Destroy them so we can get off this planet!\n\nBy the way - this ship might MALFUNCTION. When that happens your or a crew member must interact with the malfunction to fix it."
var instruction_1 : String = "Outside of your jump, you have a jetpack as well. Press and hold SPACE while in mid-air to engage it."
var instruction_2 : String = "Good to see you aren't paralyzed. Now - go to the mech's AIM terminal and press F to interact with it.\n\nAim your mech's weapons at the wall by moving your crosshair with WASD. Press F once you've aimed."
var instruction_3 : String = "All right. Now, you have to connect your ENGAGE terminal to a weapon so that you can control that weapon.\n\nLeft click on the ENGAGE terminal with your mouse."
var instruction_4 : String = "Now click on your weapon."
var instruction_5 : String = "Well done. After years of combat experience you've managed to not mess the absolute basics up.\n\nInteract with the ENGAGE terminal with F. Then complete the quicktime event minigame to actually shoot."
var instruction_6 : String = "Terminals have cooldowns and most modules use energy. Batteries regenerate energy passively. You can also ENGAGE any battery via an ENGAGE terminal to give it a recharge boost.\n\nDestroy the wall to continue."
var instruction_7 : String = "Continue to the next mech and destroy it. Try not to crash into it, it'll hurt you more than it hurts it.\n\nUse F to interact with the GO RIGHT module."
var instruction_8 : String = "Enemy mechs have different control modules and things you can break by shooting them. Hold ALT to scan all of the control modules on the screen to see what they do."
var instruction_9 : String = "You can attack enemy mechs on foot. You can punch by pressing CTRL. Destroying enemy controls will cripple the systems of enemy mechs. Killing enemy mech operators will make enemy mechs act way slower than usual."
var instruction_10 : String = "The next mech will be way too tough to destroy with a basic machinegun.\n\nPark near it, abandon your mech and then destroy its main generator to blow the entire mech up from the inside out."
var instruction_11 : String = "Congratulations! You've passed basic combat training."


var instructions = [instruction_0, instruction_1, instruction_2,
					instruction_3, instruction_4, instruction_5,
					instruction_6, instruction_7, instruction_8,
					instruction_9, instruction_10, instruction_11,]

# Tutorial objects
@onready var highlight_1_1: ColorRect = $Mech/Modules/Battery/Highlight
@onready var highlight_1_2: ColorRect = $Mech/Modules/Gun/Highlight
@onready var highlight_2: ColorRect = $Mech/Controllers/Control1/Highlight
@onready var highlight_3 : ColorRect = $Mech/Controllers/Control2/Highlight
@onready var highlight_4: ColorRect = $GUI/Control/StaticUI/StatusPanel/Highlight
@onready var highlight_aim: ColorRect = $GUI/Control/StaticUI/CameraPanel/Highlight
@onready var highlight_5: ColorRect = $Mech/Controllers/Control3/Highlight

@onready var label_1: Label = $Mech/Controllers/Control2/Highlight/Label
@onready var label_2: Label = $Mech/Modules/Gun/Highlight/Label

# Specific tutorial instructions and triggers

@onready var tutorial_ui: CanvasLayer = $TutorialUI

var trigger_0 : bool = false
var trigger_1 : bool = false
var trigger_2 : bool = false
var trigger_3 : bool = false
var trigger_4 : bool = false
var trigger_5 : bool = false
var trigger_6 : bool = false
var trigger_7 : bool = false
var trigger_8 : bool = false
var trigger_9 : bool = false
var trigger_10 : bool = false
var trigger_11 : bool = false

var triggers = [trigger_0, trigger_1, trigger_2,
				trigger_3, trigger_4, trigger_5,
				trigger_6, trigger_7, trigger_8,
				trigger_9, trigger_10, trigger_11,]
				
@onready var gui_cooldown: Timer = $TutorialUI/GUICooldown
@onready var current_instruction : int = 0
@onready var current_trigger : int = 0
# Internal trigger engagement mechanism
func tutorial_script():
	var trigger_engaged : bool = false
			
	if trigger_engaged:
		update_trigger()

func update_trigger():
	current_instruction += 1
	current_trigger += 1
	tutorial_ui.load_instruction(instructions[current_instruction])

# External trigger engage mechanism
func advance_trigger():
	triggers[current_trigger] = true
	update_trigger()
	
@onready var wall: RigidBody2D = $Wall
@onready var enemy_mech_4: RigidBody2D = $EnemyMech4
@onready var enemy_mech_8: RigidBody2D = $EnemyMech8
func _ready():
	tutorial_ui.load_instruction(instruction_0)
	GlobalMusic.queue_track("res://Audio/Music/track_02.ogg", 0.5)

func _process(_delta):
	if enemies_left <= 0 and not triggered:
		#music.stream = preload("uid://bfjye4qxke0i")
		#music.play()
		end_stage()
		triggered = true
	
	if enemies_left <= 0:
		minigame_result.modulate = Color(1,1,1,1)
		minigame_result.text = end_text
		minigame_result.add_theme_color_override("font_color", Color("green"))
		minigame_result.show()
	
	tutorial_script()

# Edited MAIN functions
@onready var screen_limit: StaticBody2D = $Foreground/Parallax1/ScreenBorder/ScreenLimit
@onready var Y_SPAWN = -650 # Y-Level at which mechs will spawn
const MECH_2 = preload("uid://c6itfhereaxo0")
func spawn_random_enemy():
	#var enemy_instance = enemies.pick_random().instantiate()
	var enemy_instance = MECH_2.instantiate()
	mech.add_sibling(enemy_instance)
	#print("Mech X:" + str(mech.global_position.x))
	#print("Enemy X:" + str(screen_limit.global_position.x - 950))
	enemy_instance.global_position.y = Y_SPAWN
	enemy_instance.global_position.x = screen_limit.global_position.x - 950
	enemy_instance.rotation = 0

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
		await get_tree().create_timer(1.5).timeout
		spawn_random_enemy()
		static_ui.display_advance_arrow()
	else:
		GlobalMusic.queue_track("uid://bfjye4qxke0i", 0.5)
		triggered = true
		end_stage()
		minigame_result.modulate = Color(1,1,1,1)
		minigame_result.text = end_text
		minigame_result.add_theme_color_override("font_color", Color("green"))
		minigame_result.show()

func end_stage():
	await get_tree().create_timer(0.1).timeout
	minigame_result.position.y -= 550
	end_text =  (
			"This planet is done for!\nWe must leave immediately!\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" +
			"Leaving planet in 5 seconds..."
		)
	minigame_result.text = end_text
	minigame_result.add_theme_color_override("font_color", Color("green"))
	minigame_result.show()
	# Clear game data from tutorial
	PlayerData.reset()
	DirAccess.remove_absolute("user://mechteam_save.tres")
	MechData.load_from_file()
	MechData.mechs.clear()
	PlayerData.money += 25
	print("Game data cleared.")
	await get_tree().create_timer(5).timeout
	IndieBlueprintSceneTransitioner.transition_to(
		SceneCache.SCENES.get("comic_2"),
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
		{ 
			"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("55648C")},
			"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
		}
	)
