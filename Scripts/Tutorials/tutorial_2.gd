extends Node2D

@onready var player = $Player
@onready var music = $Music
@onready var mech = $Mech

@onready var static_ui = $GUI/Control/StaticUI
@onready var minigame_result = $GUI/Control/StaticUI/MinigameResult
@onready var screen_border = $Foreground/Parallax1/ScreenBorder

const SPAWN_OFFSET = 1000
@onready var enemies_left : int = 1
@onready var triggered : bool = false

@onready var npc_deaths : int = 0
@onready var rewards_collected : int = 0

const MECH_1 = preload("uid://b8wn41m8pycq8")
const MECH_2 = preload("uid://c6itfhereaxo0")
const MECH_3 = preload("uid://j5p75yywprhn")
const MECH_4 = preload("uid://b6st1n1r2654j")

@onready var enemies = [MECH_1, MECH_2, MECH_3, MECH_4]

var end_text : String = ""


# Instruction strings for current tutorial stage

var instruction_0 : String = "Welcome to basic combat training. Your mech has been equipped with:\n
1x Battery
1x Machine Gun
1x Engage Terminal
1x Aim Terminal
\nPress space to continue."
var instruction_1 : String = "Weapons and other modules require battery energy to function.\n\nPress space to continue."
var instruction_2 : String = "To aim a weapon, you must walk over to the aim terminal and press F to interact with it.\nThen, you must move your crosshair with WASD and press F again to confirm the target."
var instruction_3 : String = "To fire a weapon, you must first connect it to an engage terminal.\n\nClick on the engage terminal."
var instruction_4 : String = "Now click on the machine gun."
var instruction_5 : String = "Now, go near the engage terminal and press F to interact with it. After pressing F, you must play a quick minigame in order to engage the connected machine gun."
var instruction_6 : String = "Good job!\n\nDestroy the wall to finish your combat training."

var instructions = [instruction_0, instruction_1, instruction_2, 
					instruction_3, instruction_4, instruction_5, 
					instruction_6]

# Tutorial objects
@onready var highlight_1_1: ColorRect = $Mech/Modules/Battery/Highlight
@onready var highlight_1_2: ColorRect = $Mech/Modules/Gun/Highlight
@onready var highlight_2: ColorRect = $Mech/Controllers/Control1/Highlight
@onready var highlight_3 : ColorRect = $Mech/Controllers/Control2/Highlight
@onready var highlight_4: ColorRect = $GUI/Control/StaticUI/StatusPanel/ENLabel/Highlight
@onready var highlight_aim: ColorRect = $GUI/Control/StaticUI/CameraPanel/Highlight

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

var triggers = [trigger_0, trigger_1, trigger_2,
				trigger_3, trigger_4, trigger_5]

@onready var current_instruction : int = 0
@onready var current_trigger : int = 0
# Internal trigger engagement mechanism
func tutorial_script():
	var trigger_engaged : bool = false
	
	if not triggers[0]:
		if Input.is_action_just_pressed("jump"):
			triggers[0] = true
		if triggers[0]:
			trigger_engaged = true
	elif not triggers[1]:
		highlight_1_1.show()
		highlight_4.show()
		if Input.is_action_just_pressed("jump"):
			triggers[1] = true
		if triggers[1]:
			trigger_engaged = true
	elif not triggers[2]:
		highlight_1_1.hide()
		highlight_4.hide()
		highlight_2.show()
		highlight_aim.show()
	elif not triggers[3]:
		highlight_aim.hide()
		highlight_2.hide()
		highlight_3.show()
		label_1.show()
	elif not triggers[4]:
		highlight_3.hide()
		label_1.hide()
		highlight_1_2.show()
		label_2.show()
	elif not triggers[5]:
		mech.mech_edit = false
		highlight_1_2.hide()
		label_2.hide()
		highlight_3.show()
	else:
		# Tutorial ends here
		# Remove highlight
		highlight_3.hide()
		pass
	
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
	
@onready var enemy_mech_4: RigidBody2D = $EnemyMech4
func _ready():
	tutorial_ui.load_instruction(instruction_0)
	enemy_mech_4.ai = false

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
	
	tutorial_script()

# Edited MAIN functions

func advance():
	if enemies_left > 0:
		player.camera.limit_right += SPAWN_OFFSET + 1500
		screen_border.position.x += SPAWN_OFFSET + 1500
		spawn_random_enemy()
		static_ui.display_advance_arrow()

func spawn_random_enemy():
	var enemy_instance = enemies.pick_random().instantiate()
	mech.add_sibling(enemy_instance)
	enemy_instance.global_position.x = screen_border.global_position.x - 250

func end_stage():
	await get_tree().create_timer(0.1).timeout
	minigame_result.position.y -= 550
	end_text =  (
			"YOU WIN!\n\n\n" +
			"Rewards collected: " + str(rewards_collected) +
			"\n\nMech Status" +
			"\nDamage taken: " + str(mech.max_hp - mech.hp) + 
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
		#"res://Scenes/Tutorials/tutorial3.tscn",
		"res://Scenes/menu.tscn",
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
