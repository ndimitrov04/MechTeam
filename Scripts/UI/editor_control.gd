extends Control

@onready var editor = $"../.."

@onready var tab_container = $TabContainer
@onready var npc_shop = $NPCShop
@onready var npc_list = $NPCShop/NPCList
@onready var npc_label = $NPCShop/NPCLabel
@onready var capacity_label = $NPCShop/CapacityLabel
@onready var error = $Error
@onready var cash_label = $CashPanel/CashLabel

@onready var sfx = $"../SFX"

@onready var left = $Left
@onready var right = $Right

@onready var next_stage = $NextStage
@onready var previous_stage = $PreviousStage
@onready var current_stage = $CurrentStage

@onready var next_mech = $NextMech
@onready var previous_mech = $PreviousMech
@onready var save_mech = $SaveMech
@onready var new_mech = $NewMech
@onready var clear_field = $ClearField
@onready var debug_mech = $DebugMech

@onready var blocks = $TabContainer/Blocks
@onready var walls = $TabContainer/Walls
@onready var modules = $TabContainer/Modules
@onready var controllers = $TabContainer/Controllers
@onready var movement = $TabContainer/Movement

@onready var instruction = $Instruction

@onready var info_panel = $InfoPanel
@onready var icon = $InfoPanel/Icon
@onready var name_label = $InfoPanel/NameLabel
@onready var desc_label = $InfoPanel/DescLabel

# Tutorial hook
signal left_interacted_with()

# Staging phase control
# 0 = Mech Creation
# 1 = Node Connection
# 2 = Combat
@onready var build_stage = 0
@onready var build_instructions = [
	"Building Stage\n
	Select an object from the menu with left click.
	You can scroll between object menus by clicking on the left and right buttons near the object menu.

	Hover over objects in the menu for more information.

	Place objects with left click. Remove them with right click.
	You can only place objects next to blocks or walls.",

	"Connection Stage\n
	Select an ENGAGE controller (red) by left clicking it.
	Then, select a MODULE (gun or battery) by left clicking it.
	A connection will be drawn between the two objects.
	
	In the action stage, you will be able to trigger the connected module
	by pressing the interaction key while near the controller.",
	
	"PREPARE FOR COMBAT!"
]


@onready var mech_index = -1

# INSTANTIABLE OBJECTS
# MODULES
const MACHINEGUN1 = preload("uid://tgc6pvjmf1xi")
const BATTERY = preload("uid://l73g8614cmho")
const SUPPLIES = preload("uid://bqppfxqplbr13")
const AUX_GUN = preload("uid://de21e0lmsfjcd")
const SHIELD = preload("uid://cqoj1222gihhh")
const AUTO_GUN = preload("uid://bhwduvjbtg6l5")
const RAM = preload("uid://d2uuifeftj3yo")
const LASER = preload("uid://boso7sg4n7kia")
const PLASMA = preload("uid://c2estde02njs")
const BOOSTER = preload("uid://ch2aqahhlaycp")
# CONTROLLERS
const AIM_CONTROL = preload("uid://bjychxdy31gx5")
const JUMP_CONTROL = preload("uid://cqf1xuoccxt6k")
const MOV_CONTROL_X_AXIS = preload("uid://dkk6dac4fqg53")
const WEAPON_CONTROL = preload("uid://byb23wa6gburr")
# MOVEMENT
# Colliders
const WHEEL_COLLIDER_1 = preload("uid://cuhp74yuarb08")
# Sprites
const WHEEL_1 = preload("uid://uxt82jfkcjx8")
const WHEEL_1_PAS = preload("uid://cniaqjo3hwd8a")
# NPCs
const NPC = preload("uid://cmy4r8enqaty2")

# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerData.money += PlayerData.mech_cost
	await get_tree().process_frame
	PlayerData.mech_cost = 0
	if MechData.mechs.size() > 0:
		next_mech.disabled = false
	await get_tree().process_frame
	if MechData.mechs.size() == 0:
		mech_index = 0
		editor.new_mech()
		editor.clear_prototype()
	else:
		mech_index = 0
		MechData.load_mech(mech_index)
		editor.load_prototype()
	update_mech_scroll()
	update_instruction(build_stage)
	
	# Item tooltips
	# Blocks
	blocks.set_item_tooltip(0, "Cost: 1\nBasic destructible block.")
	blocks.set_item_tooltip(1, "Cost: 1\nDestructible platform that you can jump through.")
	# Walls
	walls.set_item_tooltip(0, "Basic decorative wall.")
	walls.set_item_tooltip(1, "Basic decorative wall.")
	walls.set_item_tooltip(2, "Basic decorative wall.")
	# Modules
	modules.set_item_tooltip(0, "Cost: 10
	Shoots 10 bullets per volley. 
	Needs 30 energy to shoot.
	Must be connected to an 
	ENGAGE control terminal to shoot.
	Mech must have an AIM control 
	terminal onboard for this weapon to be aimed.")
	modules.set_item_tooltip(1, "Cost: 25\nHolds energy. 
	Recharges passively (1 energy/sec).
	It can be manually recharged rapidly (50 energy) 
	if connected to an ENGAGE control temrinal.")
	modules.set_item_tooltip(2, "Cost: 20\nSupplies. 
	Add 1 point to crew capacity. 
	Required if you want crew operators.")
	modules.set_item_tooltip(3, "Cost: 20
	Shoots 5 bullets per volley. 
	Needs 10 energy to shoot.
	Controlled locally.
	Cannot be aimed.")
	modules.set_item_tooltip(4, "Cost: 35
	Drains 5 energy/sec.
	Regenerates 2 Shield HP/sec.
	Must be activated via an ENGAGE terminal.
	Summons a powerful force field.
	Can deflect up to 100 damage.")
	modules.set_item_tooltip(5, "Cost: 35
	Automatic machine gun.
	Shoots 5 bullets per volley. 
	Needs 10 energy to shoot.
	Controlled automatically.
	Cannot be aimed.")
	modules.set_item_tooltip(6, "Cost: 65
	Melee weapon.
	Ram into the enemy at high 
	speed to deal damage.
	Does not consume energy.
	Cannot be aimed.")
	modules.set_item_tooltip(7, "Cost: 75
	Does not destroy tiles. Piercing.
	Needs 30 energy to shoot.
	Must be connected to an 
	ENGAGE control terminal to shoot.
	Mech must have an AIM control 
	terminal onboard for this weapon to be aimed.")
	modules.set_item_tooltip(8, "Cost: 35
	Piercing. Goes through tiles.
	Needs 40 energy to shoot.
	Must be connected to an 
	ENGAGE control terminal to shoot.
	Mech must have an AIM control 
	terminal onboard for this weapon to be aimed.")
	modules.set_item_tooltip(9, "Cost: 25
	Boosts mech towards a point.
	Needs 25 energy to use.
	Must be connected to an 
	ENGAGE control terminal to use.
	Mech must have an AIM control 
	terminal onboard for this booster to be aimed.
	This module aims directly away from the crosshair.")
	# Controllers
	controllers.set_item_tooltip(0, "Cost: 10
	This controller lets the player aim a mech's weapons.")
	controllers.set_item_tooltip(1, "Cost: 5\nThis controller moves a mech to the left.")
	controllers.set_item_tooltip(2, "Cost: 5\nThis controller moves a mech to the right.")
	controllers.set_item_tooltip(3, "Cost: 5\nThis controller stops a mech from moving.")
	controllers.set_item_tooltip(4, "Cost: 15\nThis controller makes a mech jump.")
	controllers.set_item_tooltip(5, "Cost: 15\nThis controller must be 
	connected to a MODULE to work.
	When used, it makes the module 
	it is connected to work.")
	# Movement
	movement.set_item_tooltip(0, "Cost: 10
	Can be controlled by movement controllers.
	Can move to the left and right. 
	Can jump. Can brake.")
	movement.set_item_tooltip(1, "Cost: 10
	Passive tracks.
	Cannot be controlled.")
	# NPCs
	npc_list.set_item_tooltip(0, "Cost: 35 Wage: 5 Supply: 1\n 
	Will move left and right 
	and interact with ENGAGE 
	terminals it comes across. 
	Has 1 second of engage cooldown. 
	Medical fees if incapacitated: 10 coins.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# Controls are statically connected
# =================================

func _on_left_pressed():
	if tab_container.current_tab == 0:
		return
	tab_container.current_tab -= 1
	sfx.click_select.play()

func _on_right_pressed():
	if tab_container.current_tab == 4:
		return
	tab_container.current_tab += 1
	sfx.click_select.play()
	# Tutorial hook
	left_interacted_with.emit()

func _on_block_list_item_clicked(index, _at_position, _mouse_button_index):
	print(index)
	editor.edit_layer = 0
	editor.npc_mode = false
	update_info_panel(blocks.get_item_icon(index), blocks.get_item_text(index), blocks.get_item_tooltip(index))
	match index:
		0:
			editor.chosen_block = Vector2i(0,6)
			editor.current_cost = 1
		1:
			editor.chosen_block = Vector2i(2,4)
			editor.current_cost = 1

func _on_wall_list_item_clicked(index, _at_position, _mouse_button_index):
	print(index)
	editor.edit_layer = 1
	editor.npc_mode = false
	update_info_panel(walls.get_item_icon(index), walls.get_item_text(index), walls.get_item_tooltip(index))
	match index:
		0:
			editor.chosen_block = Vector2i(8,3)
			editor.current_cost = 0
		1:
			editor.chosen_block = Vector2i(6,3)
			editor.current_cost = 0
		2:
			editor.chosen_block = Vector2i(6,5)
			editor.current_cost = 0

func _on_weapons_item_clicked(index, _at_position, _mouse_button_index):
	editor.edit_layer = 2
	editor.npc_mode = false
	update_info_panel(modules.get_item_icon(index), modules.get_item_text(index), modules.get_item_tooltip(index))
	match index:
		0:
			editor.chosen_object = MACHINEGUN1
			editor.current_cost = 10
		1:
			editor.chosen_object = BATTERY
			editor.current_cost = 25
		2:
			editor.chosen_object = SUPPLIES
			editor.current_cost = 20
		3:
			editor.chosen_object = AUX_GUN
			editor.current_cost = 20
		4:
			editor.chosen_object = SHIELD
			editor.current_cost = 35
		5:
			editor.chosen_object = AUTO_GUN
			editor.current_cost = 35
		6:
			editor.chosen_object = RAM
			editor.current_cost = 65
		7:
			editor.chosen_object = LASER
			editor.current_cost = 75
		8:
			editor.chosen_object = PLASMA
			editor.current_cost = 35
		9:
			editor.chosen_object = BOOSTER
			editor.current_cost = 25

func _on_controllers_item_clicked(index, _at_position, _mouse_button_index):
	editor.edit_layer = 2
	editor.npc_mode = false
	update_info_panel(controllers.get_item_icon(index), controllers.get_item_text(index), controllers.get_item_tooltip(index))
	match index:
		0:
			editor.chosen_object = AIM_CONTROL
			editor.chosen_action = 0
			editor.current_cost = 10
		1:
			editor.chosen_object = MOV_CONTROL_X_AXIS
			editor.chosen_action = -1
			editor.current_cost = 5
		2:
			editor.chosen_object = MOV_CONTROL_X_AXIS
			editor.chosen_action = 1
			editor.current_cost = 5
		3:
			editor.chosen_object = MOV_CONTROL_X_AXIS
			editor.chosen_action = 0
			editor.current_cost = 5
		4:
			editor.chosen_object = JUMP_CONTROL
			editor.chosen_action = 0
			editor.current_cost = 15
		5:
			editor.chosen_object = WEAPON_CONTROL
			editor.chosen_action = 0
			editor.current_cost = 15

func _on_item_list_item_clicked(index, _at_position, _mouse_button_index):
	editor.edit_layer = 3
	editor.npc_mode = false
	update_info_panel(movement.get_item_icon(index), movement.get_item_text(index), movement.get_item_tooltip(index))
	match index:
		0:
			editor.chosen_movement_collider = WHEEL_COLLIDER_1
			editor.chosen_movement_sprite = WHEEL_1
			editor.current_cost = 10
		1:
			editor.chosen_movement_collider = WHEEL_COLLIDER_1
			editor.chosen_movement_sprite = WHEEL_1_PAS
			editor.current_cost = 10

func _on_npc_list_item_clicked(index, _at_position, _mouse_button_index):
	editor.edit_layer = 2
	editor.npc_mode = true
	update_info_panel(npc_list.get_item_icon(index), npc_list.get_item_text(index), npc_list.get_item_tooltip(index))
	match index:
		0:
			editor.chosen_object = NPC
			editor.current_cost = 35


func _on_next_stage_pressed():
	match build_stage:
		0:
			_on_save_mech_pressed()
			tab_container.hide()
			npc_shop.hide()
			info_panel.hide()
			editor.load_mech()
			previous_stage.text = "Building Stage"
			previous_stage.show()
			current_stage.text = "Wiring Stage"
			next_stage.text = "Combat Stage #" + str(PlayerData.current_stage)
			next_mech.disabled = true
			previous_mech.disabled = true
			clear_field.disabled = true
			new_mech.disabled = true
			debug_mech.disabled = true
			next_mech.hide()
			previous_mech.hide()
			clear_field.hide()
			new_mech.hide()
			debug_mech.hide()
			build_stage += 1
		1:
			if PlayerData.money >= 0:
				editor.finish_mech()
				build_stage += 1
			else:
				show_error("You can't start a stage while in debt!\nRemove mech parts until you have more than 0 cash!")
		2:
			pass
	update_instruction(build_stage)

func _on_previous_stage_pressed():
	match build_stage:
		0:
			pass
		1:
			_on_save_mech_pressed()
			tab_container.show()
			npc_shop.show()
			previous_stage.hide()
			current_stage.text = "Building Stage"
			next_stage.text = "Wiring Stage"
			editor.unload_mech()
			next_mech.disabled = false
			previous_mech.disabled = false
			clear_field.disabled = false
			new_mech.disabled = false
			debug_mech.disabled = false
			#next_mech.show()
			#previous_mech.show()
			clear_field.show()
			#new_mech.show()
			debug_mech.show()
		2:
			pass
	build_stage -= 1
	update_instruction(build_stage)

func _on_save_mech_pressed():
	print("Saving mech to mechs array...")
	editor.save_connections()
	MechData.save_mech(mech_index)
	if mech_index + 1 >= MechData.mechs.size():
		next_mech.disabled = true
	else:
		next_mech.disabled = false
	if mech_index <= 0:
		previous_mech.disabled = true
	else:
		previous_mech.disabled = false

func _on_next_mech_pressed():
	_on_save_mech_pressed()
	mech_index += 1
	update_mech_scroll()
	MechData.load_mech(mech_index)
	editor.load_prototype()

func _on_previous_mech_pressed():
	_on_save_mech_pressed()
	mech_index -= 1
	update_mech_scroll()
	MechData.load_mech(mech_index)
	editor.load_prototype()

func _on_clear_field_pressed():
	editor.clear_prototype()

func _on_new_mech_pressed():
	_on_save_mech_pressed()
	mech_index += 1
	update_mech_scroll()
	editor.new_mech()
	editor.clear_prototype()

func update_mech_scroll():
	if mech_index + 1 >= MechData.mechs.size():
		next_mech.disabled = true
	else:
		next_mech.disabled = false
	if mech_index <= 0:
		previous_mech.disabled = true
	else:
		previous_mech.disabled = false

func update_instruction(index : int):
	sfx.click_select.play()
	instruction.text = build_instructions[index]

func update_info_panel(icon_data, name_data, desc_data):
	sfx.click_select.play()
	info_panel.show()
	icon.texture = icon_data
	name_label.text = "Name:\n" + name_data
	desc_label.text = "Description:\n" + desc_data

func update_cash_panel():
	cash_label.text = "Cash: " + str(PlayerData.money)

func attention(ui_object, duration : int, fade_out : bool = false):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	ui_object.set_modulate(Color("red"))
	# Flash sequence
	for i in range(0, duration*2):
		tween.tween_property(ui_object, "modulate:a", 1.0, 0.05)
		tween.tween_property(ui_object, "modulate:a", 0.0, 0.1)
		tween.tween_property(ui_object, "modulate:a", 1.0, 0.3)
		tween.tween_property(ui_object, "modulate:a", 1.0, 0.1)
	if fade_out:
		tween.tween_property(ui_object, "modulate:a", 1.0, 0.1)
		tween.tween_property(ui_object, "modulate:a", 0.0, 0.1)
	else:
		ui_object.set_modulate(Color("white"))

func show_error(text : String):
	error.show()
	error.text = text
	attention(error, 1, true)
	sfx.click_fail.play()
