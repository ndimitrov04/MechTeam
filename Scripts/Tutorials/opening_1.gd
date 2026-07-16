extends Node2D

@onready var player = $Player
@onready var music = $Music
@onready var mech = $Mech

@onready var static_ui = $GUI/Control/StaticUI
@onready var minigame_result = $GUI/Control/StaticUI/MinigameResult
@onready var screen_border = $Foreground/Parallax1/ScreenBorder

const SPAWN_OFFSET = 1000
@onready var enemies_left : int = 3
@onready var triggered : bool = false

@onready var npc_deaths : int = 0
@onready var rewards_collected : int = 0

var end_text : String = ""


# Instruction strings for current tutorial stage

var instruction_0 : String = "Alright, let's see if you've still got this.\n\nMove with WASD. Climb onto your ship. Jump with SPACE to do so."
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
	
	if not triggers[0]:
		if Input.is_action_just_pressed("jump"):
			triggers[0] = true
			gui_cooldown.start()
		if triggers[0]:
			trigger_engaged = true
	elif not triggers[1]:
		if Input.is_action_just_pressed("jump") and gui_cooldown.is_stopped():
			triggers[1] = true
		if triggers[1]:
			trigger_engaged = true
	elif not triggers[2]:
		highlight_aim.show()
		highlight_2.show()
	elif not triggers[3]:
		highlight_aim.hide()
		highlight_2.hide()
		highlight_3.show()
		label_1.show()
	elif not triggers[4]:
		highlight_3.hide()
		label_1.hide()
		label_2.show()
		highlight_1_2.show()
	elif not triggers[5]:
		label_2.hide()
		highlight_1_2.hide()
		highlight_3.show()
	elif not triggers[6]:
		highlight_3.hide()
		highlight_4.show()
		highlight_1_1.show()
	elif not triggers[7]:
		highlight_4.hide()
		highlight_1_1.hide()
		highlight_5.show()
	elif not triggers[8]:
		highlight_5.hide()
		if Input.is_action_just_pressed("scan"):
			triggers[8] = true
		if triggers[8]:
			trigger_engaged = true
	elif not triggers[9]:
		highlight_5.hide()
			
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
	wall.ai = false
	enemy_mech_4.ai = false
	enemy_mech_8.ai = false
	enemy_mech_8.max_hp = 999
	enemy_mech_8.hp = 999
	player.hp = 100

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

func advance():
	if enemies_left > 0:
		player.camera.limit_right += SPAWN_OFFSET + 1500
		screen_border.position.x += SPAWN_OFFSET + 1500
		static_ui.display_advance_arrow()
		advance_trigger()

func end_stage():
	await get_tree().create_timer(0.1).timeout
	minigame_result.position.y -= 550
	end_text =  (
			"YOU WIN!\n\n\n" +
			"Rewards collected: " + str(rewards_collected) +
			"\n\nMech Status" +
			"\nDamage taken: " + str(int(mech.max_hp - mech.hp)) + 
			"\n- Repair costs: " + str(int((mech.max_hp - mech.hp) * 0.5)) + 
			"\n\nCrew Status" +
			"\nCrew Wages: " + str(mech.npcs.get_child_count() * 5) +
			"\nCrew Injured: " + str(npc_deaths) + 
			"\n- Medical fees: " + str(npc_deaths * 10) +
			"\n\nTotal cash: " + str("Can't recieve cash in tutorial.") +
			"\n\n\nGoing to next stage in 5 seconds..."
		)
	minigame_result.text = end_text
	minigame_result.add_theme_color_override("font_color", Color("green"))
	minigame_result.show()
	await get_tree().create_timer(5).timeout
	IndieBlueprintSceneTransitioner.transition_to(
		"res://Scenes/Tutorials/tutorial3.tscn",
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
		{ 
			"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("55648C")},
			"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
		}
	)


func _on_control_1_aim_set() -> void:
	if current_trigger == 2:
		advance_trigger()
		
func _on_control_2_connection_started() -> void:
	if current_trigger == 3:
		advance_trigger()

func _on_gun_is_connected() -> void:
	if current_trigger == 4:
		advance_trigger()

func _on_control_2_interacted_with() -> void:
	if current_trigger == 5:
		advance_trigger()

func _on_control_3_interacted_with() -> void:
	if current_trigger == 7:
		advance_trigger()
