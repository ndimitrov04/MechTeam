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

const MECH_1 = preload("uid://b8wn41m8pycq8")
const MECH_2 = preload("uid://c6itfhereaxo0")
const MECH_3 = preload("uid://j5p75yywprhn")
const MECH_4 = preload("uid://b6st1n1r2654j")

@onready var enemies = [MECH_1, MECH_2, MECH_3, MECH_4]

var end_text : String = ""


# Instruction strings for current tutorial stage

var instruction_0 : String = "Welcome to advanced combat training.

You will be presented with two enemies in quick succession. 

Your tasks:
1. Destroy the first one.
2. Proceed forward.
3. Destroy the second one."


var instructions = [instruction_0]

# Specific tutorial instructions and triggers

@onready var tutorial_ui: CanvasLayer = $TutorialUI

var trigger_0 : bool = false

var triggers = [trigger_0]

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
	
@onready var enemy_mech_4: RigidBody2D = $EnemyMech4
func _ready():
	tutorial_ui.load_instruction(instruction_0)

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
		"res://Scenes/Tutorials/tutorial5.tscn", 
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
		{ 
			"in": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 0.5, "color": Color("55648C")},
			"out": {"texture": IndieBlueprintPremadeTransitions.Squares, "duration": 1.0, "color": Color("55648C")}
		}
	)
