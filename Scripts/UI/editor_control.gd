extends Control

@onready var editor = $"../.."

@onready var tab_container = $TabContainer

@onready var left = $Left
@onready var right = $Right

# INSTANTIABLE OBJECTS
# WEAPONS
const MACHINEGUN1 = preload("uid://tgc6pvjmf1xi")
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

# *ADD MOVEMENT OBJECTS HERE*!!

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# Controls are statically connected
# =================================

func _on_left_pressed():
	if tab_container.current_tab == 0:
		return
	tab_container.current_tab -= 1

func _on_right_pressed():
	if tab_container.current_tab == 4:
		return
	tab_container.current_tab += 1

func _on_block_list_item_clicked(index, _at_position, _mouse_button_index):
	print(index)
	editor.edit_layer = 0
	match index:
		0:
			editor.chosen_block = Vector2i(0,6)
		1:
			editor.chosen_block = Vector2i(2,4)

func _on_wall_list_item_clicked(index, _at_position, _mouse_button_index):
	print(index)
	editor.edit_layer = 1
	match index:
		0:
			editor.chosen_block = Vector2i(8,3)
		1:
			editor.chosen_block = Vector2i(6,3)
		2:
			editor.chosen_block = Vector2i(6,5)

func _on_weapons_item_clicked(index, _at_position, _mouse_button_index):
	editor.edit_layer = 2
	match index:
		0:
			editor.chosen_object = MACHINEGUN1

func _on_controllers_item_clicked(index, _at_position, _mouse_button_index):
	editor.edit_layer = 2
	match index:
		0:
			editor.chosen_object = AIM_CONTROL
			editor.chosen_action = 0
		1:
			editor.chosen_object = MOV_CONTROL_X_AXIS
			editor.chosen_action = -1
		2:
			editor.chosen_object = MOV_CONTROL_X_AXIS
			editor.chosen_action = 1
		3:
			editor.chosen_object = MOV_CONTROL_X_AXIS
			editor.chosen_action = 0
		4:
			editor.chosen_object = JUMP_CONTROL
			editor.chosen_action = 0
		5:
			editor.chosen_object = WEAPON_CONTROL
			editor.chosen_action = 0

func _on_item_list_item_clicked(index, _at_position, _mouse_button_index):
	editor.edit_layer = 3
	match index:
		0:
			editor.chosen_movement_collider = WHEEL_COLLIDER_1
			editor.chosen_movement_sprite = WHEEL_1
