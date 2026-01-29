extends Control

@onready var editor = $"../.."

@onready var tab_container = $TabContainer

@onready var left = $Left
@onready var right = $Right

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
	if tab_container.current_tab == 3:
		return
	tab_container.current_tab += 1


func _on_block_list_item_clicked(index, at_position, mouse_button_index):
	print(index)
	match index:
		0:
			editor.chosen_block = Vector2i(0,6)
		1:
			editor.chosen_block = Vector2i(2,4)
