extends Node2D

const MECH = preload("uid://bg0x4kcl3emfw")
const MECH_PB = preload("uid://dimm11yjnr7ef")

@onready var grid = $Grid
@onready var mech_prototype = $MechPrototype
@onready var control = $GUI/Control
@onready var capacity_label = $GUI/Control/NPCShop/CapacityLabel

@onready var sfx = $GUI/SFX

# These two overlap the grid, so grid_positions = blocks positions, etc.
@onready var blocks = $MechPrototype/Blocks
@onready var walls = $MechPrototype/Walls

@onready var in_editor : bool = false

@onready var build_ui_enabled : bool = true

@onready var player_spots = [Vector2i(24, 16), Vector2i(24, 18)]

var global_mouse_pos : Vector2 = Vector2.ZERO
var first_click : bool = true
const MAX_X : int = 34
const MAX_Y : int = 17

enum EditLayer {
	BLOCKS, WALLS, OBJECTS, MOVEMENT
}

# 0 = Blocks
# 1 = Walls
# 2 = Objects
# 3 = Movement
var edit_layer : EditLayer = EditLayer.BLOCKS

# Top left atlas_coords
var chosen_block : Vector2i = Vector2i(-1, -1)
# Atlas coords of visual structure block placed behind chosen frame block
var structure_wall : Vector2i = Vector2i(10,3)

# Object instance
var chosen_object = null
const OBJECT_OFFSET : Vector2i = Vector2i(16,16)
# Metadata modifier of object
var chosen_action : int = 0

# Chosen Object/Block cost
var current_cost : int = 0

var chosen_movement_collider = null
var chosen_movement_sprite = null

var npc_mode : bool = false
var npc_capacity : int = 0
var npc_count : int = 0

# Instruction strings for current tutorial stage

var instruction_0 : String = "Welcome to mechbuilding training! 
Here, you will learn how to build mechs.

Begin by choosing the basic solid block and drawing a basic mech outline."
var instruction_1 : String = "Now create your mech's frame using the chosen block.

After you create your mech's frame, you have to add modules to it.

Press the right arrow on the menu twice."
var instruction_2 : String = "Now create your mech's frame using the chosen block.

After you create your mech's frame, you have to add modules to it.

Press the right arrow on the menu twice."
var instruction_3 : String = "When in the module menu, select and place one gun and one battery."
var instruction_4 : String = "Now, press right once more."
var instruction_5 : String = "Place control terminals:
- A left movement control.
- A right movement control.
- A brake control.
- An engage terminal.
- An aim terminal.

Make sure you place them in such a way that you can platform to them while under pressure.

Press right when you're ready."
var instruction_6 : String = "Place two tracks under your frame, so that your mech can actually move."
var instruction_7 : String = "Just like in the combat tutorial, click on the red engage terminal, then click on the gun you placed. This will connect the two and enable you to use the gun in combat via the engage terminal."
var instruction_8 : String = "When you're ready, you may press next stage to test out your new mech in combat!"

var instructions = [instruction_0, instruction_1, instruction_2, 
					instruction_3, instruction_4, instruction_5, 
					instruction_6, instruction_7, instruction_8, "FIGHT!"]

# Tutorial objects
@onready var highlight_item_1: ColorRect = $GUI/Control/HighlightItem1
@onready var highlight_item_2: ColorRect = $GUI/Control/HighlightItem2
@onready var highlight_right: ColorRect = $GUI/Control/HighlightRight
@onready var highlight_stage: ColorRect = $GUI/Control/HighlightStage

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
				trigger_9, trigger_10, trigger_11]

@onready var current_instruction : int = 0
@onready var current_trigger : int = 0
# Internal trigger engagement mechanism
func tutorial_script():
	var trigger_engaged : bool = false
	
	if not triggers[0]:
		pass
	elif not triggers[1]:
		highlight_item_1.hide()
		highlight_right.show()
		pass
	elif not triggers[2]:
		# Right is clicked once
		pass
	elif not triggers[3]:
		# Right is clicked twice -> Next instruction
		highlight_item_1.show()
		highlight_item_2.show()
		highlight_right.hide()
		# Select gun + battery
		pass
	elif not triggers[4]:
		# Handled in module list function
		pass
	elif not triggers[5]:
		# Handled in module list function
		pass
	elif not triggers[6]:
		highlight_right.hide()
	elif not triggers[7]:
		highlight_item_1.show()
	elif not triggers[8]:
		highlight_item_1.hide()
		control.next_stage.disabled = false
		highlight_stage.show()
	elif not triggers[9]:
		highlight_stage.hide()
		if Input.is_action_just_pressed("lmb"):
			triggers[9] = true
		if triggers[9]:
			trigger_engaged = true
	elif not triggers[10]:
		highlight_stage.show()
	else:
		# Tutorial ends here
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

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().name == "Editor":
		in_editor = true
	update_capacity_ui()
	control.update_cash_panel()
	await get_tree().create_timer(0.2).timeout
	clear_prototype()
	new_mech()
	clear_prototype()
	await get_tree().create_timer(0.2).timeout
	new_mech()
	clear_prototype()
	PlayerData.money = 800
	tutorial_ui.load_instruction(instruction_0)

func is_connected_to_frame(grid_coords : Vector2i) -> bool:
	for cell_coords in blocks.get_surrounding_cells(grid_coords):
		if blocks.get_cell_atlas_coords(cell_coords) != MechData.EMPTY_CELL:
			return true
		if blocks.get_cell_atlas_coords(cell_coords + Vector2i.RIGHT) != MechData.EMPTY_CELL:
			return true
		if blocks.get_cell_atlas_coords(cell_coords + Vector2i.DOWN) != MechData.EMPTY_CELL:
			return true
		if blocks.get_cell_atlas_coords(cell_coords + Vector2i.ONE) != MechData.EMPTY_CELL:
			return true
	for cell_coords in walls.get_surrounding_cells(grid_coords):
		if walls.get_cell_atlas_coords(cell_coords) != MechData.EMPTY_CELL:
			return true
		if walls.get_cell_atlas_coords(cell_coords + Vector2i.RIGHT) != MechData.EMPTY_CELL:
			return true
		if walls.get_cell_atlas_coords(cell_coords + Vector2i.DOWN) != MechData.EMPTY_CELL:
			return true
		if walls.get_cell_atlas_coords(cell_coords + Vector2i.ONE) != MechData.EMPTY_CELL:
			return true
	return false

var mech_instance
func _input(event):
	# Test mech loading
	if Input.is_action_just_pressed("debug_mech_load"):
		print("Loading mech...")
		mech_instance = MECH.instantiate()
		self.add_child(mech_instance)
		mech_instance.global_position = Vector2(0, 0)
		print("Disabling building UI...")
		grid.hide()
		mech_prototype.hide()
		build_ui_enabled = false
	
	# Test mech loading
	if Input.is_action_just_pressed("goto_main"):
		# Save controller:module pair connections
		for controller in mech_instance.controllers.get_children():
			# Match controller child #i to module child #i
			MechData.control_pairs.append(controller.controlled_module_index)
		#await get_tree().create_timer(10).timeout #debug timer
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
	
	if Input.is_action_just_pressed("debug_add_cash"):
		PlayerData.money += 100
		control.update_cash_panel()
	
	if event is InputEventMouseButton and build_ui_enabled:
		# Set tile
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			global_mouse_pos = get_global_mouse_position()
			print("Global Mouse Position = " + str(global_mouse_pos))
			# Mouse pos relative to grid node
			var mouse_pos = mouse_to_tilemap()
			var grid_pos = expand_position(mouse_pos)
			# Check if click is in bounds
			if grid_pos.x / 2 - 1 < 0 or grid_pos.x / 2 - 1 >= 34:
				return
			if grid_pos.y / 2 - 1 < 0 or grid_pos.y / 2 - 1 >= 17:
				return
			# Check if click is on top of spawn area
			if grid_pos.x / 2 == 12:
				if grid_pos.y / 2 == 8 or grid_pos.y / 2 == 9:
					return
			# Check if block would be connected to another block or wall
			var tile_connected : bool = true
			if not first_click:
				tile_connected = is_connected_to_frame(grid_pos)
			first_click = false
			if not tile_connected:
				const ERR : String = "Cannot place that there. Tile is not connected to mech!"
				print(ERR)
				control.show_error(ERR)
				return
			# Block spawning tiles on top
			# of eachother
			if edit_layer == EditLayer.BLOCKS:
				if blocks.get_cell_atlas_coords(grid_pos) != MechData.EMPTY_CELL:
					const ERR : String = "Can't create block on top of another one!"
					print(ERR)
					#control.show_error(ERR)
					return
			# Block spawning objects
			# on top of eachother
			else:
				if MechData.get_object_index(to_global(grid_pos*16-OBJECT_OFFSET)) != null:
					const ERR : String = "Can't create object on top of another one!"
					print(ERR)
					control.show_error(ERR)
					return
			# Attempt to buy
			if not buy(current_cost):
				return
			# Place block on given layer
			match edit_layer:
				EditLayer.BLOCKS:
					# Add a frame tile
					# Set 4 16x16 tiles to make one 32x32 tile
					blocks.set_cell(grid_pos + Vector2i.ZERO, 0 , chosen_block + Vector2i.ZERO)
					blocks.set_cell(grid_pos + Vector2i.RIGHT, 0, chosen_block + Vector2i.RIGHT)
					blocks.set_cell(grid_pos + Vector2i.DOWN, 0, chosen_block + Vector2i.DOWN)
					blocks.set_cell(grid_pos + Vector2i.ONE, 0, chosen_block + Vector2i.ONE)
					# Add to mech data global
					MechData.blocks[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 0)] = chosen_block
					MechData.blocks[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 0)] = chosen_block + Vector2i.RIGHT
					MechData.blocks[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 1)] = chosen_block + Vector2i.DOWN
					MechData.blocks[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 1)] = chosen_block + Vector2i.ONE
					# Add a background wall tile behind the frame tile for a visual strucutre effect
					# Set 4 16x16 tiles to make one 32x32 tile
					walls.set_cell(grid_pos + Vector2i.ZERO, 0 , structure_wall)
					walls.set_cell(grid_pos + Vector2i.RIGHT, 0, structure_wall)
					walls.set_cell(grid_pos + Vector2i.DOWN, 0, structure_wall)
					walls.set_cell(grid_pos + Vector2i.ONE, 0, structure_wall)
					# Add to mech data global
					MechData.walls[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 0)] = structure_wall
					MechData.walls[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 0)] = structure_wall
					MechData.walls[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 1)] = structure_wall
					MechData.walls[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 1)] = structure_wall
					# Play sound
					sfx.bulld_block.play()
				EditLayer.WALLS:
					# Set 4 16x16 tiles to make one 32x32 tile
					walls.set_cell(grid_pos + Vector2i.ZERO, 0, chosen_block + Vector2i.ZERO)
					walls.set_cell(grid_pos + Vector2i.RIGHT, 0, chosen_block + Vector2i.RIGHT)
					walls.set_cell(grid_pos + Vector2i.DOWN, 0, chosen_block + Vector2i.DOWN)
					walls.set_cell(grid_pos + Vector2i.ONE, 0, chosen_block + Vector2i.ONE)
					# Add to mech data global
					MechData.walls[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 0)] = chosen_block
					MechData.walls[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 0)] = chosen_block + Vector2i.RIGHT
					MechData.walls[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 1)] = chosen_block + Vector2i.DOWN
					MechData.walls[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 1)] = chosen_block + Vector2i.ONE
					# Play sound
					sfx.bulld_block.play()
				EditLayer.OBJECTS:
					if npc_mode:
						if npc_count < npc_capacity:
							npc_count += 1
							update_capacity_ui()
							sfx.hire_operator.play()
						else:
							control.attention(control.capacity_label, 2)
							const ERR : String = "Insufficient crew capacity! Build more supllies."
							print(ERR)
							control.show_error(ERR)
							# Refund
							unbuy(current_cost)
							return
					# Set object in editor
					var object_instance = chosen_object.instantiate()
					if object_instance.has_meta("npc_capacity"):
						npc_capacity += object_instance.get_meta("npc_capacity")
						update_capacity_ui()
					mech_prototype.add_child(object_instance)
					object_instance.position = to_global(grid_pos*16+OBJECT_OFFSET)
					# Disable object processing
					object_instance.set_process(false)
					for child in object_instance.get_children():
						child.set_process(false)
					# Add to mech data global
					MechData.set_object(chosen_object, chosen_action, object_instance.type, to_global(grid_pos*16-OBJECT_OFFSET))
					# Show object editor helper
					if object_instance.has_meta("big_object"):
						object_instance.get_child(1).show()
					# Play sound
					sfx.build_entity.play()
				EditLayer.MOVEMENT:
					# ADD COLLIDER
					# Set object in editor
					var object_instance = chosen_movement_collider.instantiate()
					mech_prototype.add_child(object_instance)
					object_instance.position = to_global(grid_pos*16+OBJECT_OFFSET)
					# Disable object processing
					object_instance.set_process(false)
					for child in object_instance.get_children():
						child.set_process(false)
					# Add to mech data global
					MechData.set_object(chosen_movement_collider, chosen_action, MechData.ObjectType.COLLIDER, to_global(grid_pos*16-OBJECT_OFFSET))
					# ADD SPRITE
					# Set object in editor
					object_instance = chosen_movement_sprite.instantiate()
					mech_prototype.add_child(object_instance)
					object_instance.position = to_global(grid_pos*16+OBJECT_OFFSET)
					# Disable object processing
					object_instance.set_process(false)
					for child in object_instance.get_children():
						child.set_process(false)
					# Add to mech data global
					MechData.set_object(chosen_movement_sprite, chosen_action, MechData.ObjectType.SPRITE, to_global(grid_pos*16-OBJECT_OFFSET))
					# Show object editor helper
					if object_instance.has_meta("big_object"):
						object_instance.get_child(1).show()
					# Play sound
					sfx.build_entity.play()
		# Delete tile/object
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			global_mouse_pos = get_global_mouse_position()
			print("Global Mouse Position = " + str(global_mouse_pos))
			# Mouse pos relative to grid node
			var mouse_pos = mouse_to_tilemap()
			var grid_pos = expand_position(mouse_pos)
			match edit_layer:
				EditLayer.BLOCKS:
					# Return cash
					if blocks.get_cell_atlas_coords(grid_pos) != MechData.EMPTY_CELL:
						# Play sound
						sfx.break_block.play()
						unbuy(1)
					# Remove frame tile
					# Delete 4 tiles
					blocks.set_cell(grid_pos + Vector2i.ZERO, 0)
					blocks.set_cell(grid_pos + Vector2i.RIGHT, 0)
					blocks.set_cell(grid_pos + Vector2i.DOWN, 0)
					blocks.set_cell(grid_pos + Vector2i.ONE, 0)
					# Remove from mech data global
					MechData.blocks[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 0)] = MechData.EMPTY_CELL
					MechData.blocks[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 0)] = MechData.EMPTY_CELL
					MechData.blocks[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 1)] = MechData.EMPTY_CELL
					MechData.blocks[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 1)] = MechData.EMPTY_CELL
					# Remove structure wall tile
					# Set 4 16x16 tiles to make one 32x32 tile
					walls.set_cell(grid_pos + Vector2i.ZERO, 0)
					walls.set_cell(grid_pos + Vector2i.RIGHT, 0)
					walls.set_cell(grid_pos + Vector2i.DOWN, 0)
					walls.set_cell(grid_pos + Vector2i.ONE, 0)
					# Add to mech data global
					MechData.walls[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 0)] = MechData.EMPTY_CELL
					MechData.walls[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 0)] = MechData.EMPTY_CELL
					MechData.walls[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 1)] = MechData.EMPTY_CELL
					MechData.walls[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 1)] = MechData.EMPTY_CELL
				EditLayer.WALLS:
					# Set 4 16x16 tiles to make one 32x32 tile
					walls.set_cell(grid_pos + Vector2i.ZERO, 0)
					walls.set_cell(grid_pos + Vector2i.RIGHT, 0)
					walls.set_cell(grid_pos + Vector2i.DOWN, 0)
					walls.set_cell(grid_pos + Vector2i.ONE, 0)
					# Add to mech data global
					MechData.walls[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 0)] = MechData.EMPTY_CELL
					MechData.walls[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 0)] = MechData.EMPTY_CELL
					MechData.walls[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 1)] = MechData.EMPTY_CELL
					MechData.walls[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 1)] = MechData.EMPTY_CELL
					# Play sound
					sfx.break_block.play()
				_:
					remove_generic_object(grid_pos)

func remove_generic_object(grid_pos):
	# Delete object from editor
	for child in mech_prototype.get_children():
		print(child.name + str(child.position))
		if child.position == Vector2(grid_pos*16+OBJECT_OFFSET):
			if child.has_meta("friendly_npc"):
				npc_count -= 1
				update_capacity_ui()
				sfx.fire_operator.play()
			elif child.has_meta("npc_capacity"):
				if npc_count >= npc_capacity:
					control.show_error("Cannot remove supply required by crew. Remove crew members first.")
					control.attention(control.capacity_label, 2)
					continue
				else:
					npc_capacity -= 1
					update_capacity_ui()
			elif child.has_meta("is_movement"):
				remove_movement_object(grid_pos)
				return
			# Return cash
			unbuy(child.get_meta("price"))
			# Play sound
			sfx.break_entity.play()
			# Delete mech data by position
			MechData.delete_object(to_global(grid_pos*16-OBJECT_OFFSET))
			print("Deleting " + child.name)
			child.queue_free()

func remove_movement_object(grid_pos):
	# Repeat twice
	# Delete mech data by position
	MechData.delete_object(to_global(grid_pos*16-OBJECT_OFFSET))
	# Delete object from editor
	for child in mech_prototype.get_children():
		print(child.name + str(child.position))
		if child.position.is_equal_approx(Vector2(grid_pos*16+OBJECT_OFFSET)):
			# Return cash
			# Note: I don't know why this works when commented out
			# Unbuy is called somewhere else ?! :/
			#if child.has_meta("price"):
				#unbuy(child.get_meta("price"))
			print("Deleting " + child.name)
			child.queue_free()
			# Play sound
			sfx.break_entity.play()
	# Delete mech data by position
	MechData.delete_object(to_global(grid_pos*16-OBJECT_OFFSET))
	# Delete object from editor
	for child in mech_prototype.get_children():
		print(child.name + str(child.position))
		if child.position.is_equal_approx(Vector2(grid_pos*16+OBJECT_OFFSET)):
			print("Deleting " + child.name)
			child.queue_free()

# Note -> Tilemap is 16x16, Scale = 2
# Keep in mind that each click will make 4 tiles
# So you need every 4th tile in both horizontal and vertical
func mouse_to_tilemap() -> Vector2i:
	var local_pos = to_local(global_mouse_pos)
	var tile_pos = grid.local_to_map(local_pos)
	print("Tile Mouse position = " + str(tile_pos))
	return tile_pos
	
func expand_position(mouse_pos : Vector2i) -> Vector2i:
	@warning_ignore_start("integer_division")
	var chosen_x = floor(mouse_pos.x / 2) * 2
	var chosen_y = floor(mouse_pos.y / 2) * 2
	@warning_ignore_restore("integer_division")
	print("Grid Mouse position = " + str(Vector2i(chosen_x, chosen_y)))
	return Vector2i(chosen_x, chosen_y)

func load_prototype():
	npc_count = 0
	npc_capacity = 0
	# Clear workspace
	for i in range(0, MechData.blocks.size()):
		for j in range(0, MechData.blocks[i].size()):
			if blocks.get_cell_atlas_coords(Vector2i(i+2, j+2)) != MechData.EMPTY_CELL:
				if i+2 % 2 == 0 and j+2 % 2 == 0:
					unbuy(1)
			blocks.set_cell(Vector2i(i+2, j+2), 0 , Vector2i(-1,-1))
			walls.set_cell(Vector2i(i+2, j+2), 0 , Vector2i(-1,-1))
	for i in range(2, mech_prototype.get_child_count()):
		if mech_prototype.get_child(i).has_meta("price"):
			unbuy(mech_prototype.get_child(i).get_meta("price"))
		mech_prototype.get_child(i).queue_free()
	# Load workspace data
	for i in range(0, MechData.blocks.size()):
		for j in range(0, MechData.blocks[i].size()):
			if blocks.get_cell_atlas_coords(Vector2i(i+2, j+2)) != MechData.EMPTY_CELL:
				if i+2 % 2 == 0 and j+2 % 2 == 0:
					PlayerData.money -= 1
					PlayerData.mech_cost += 1
			blocks.set_cell(Vector2i(i+2, j+2), 0 , MechData.blocks[i][j])
			walls.set_cell(Vector2i(i+2, j+2), 0 , MechData.walls[i][j])
	for i in range(0, MechData.object_scenes.size()):
		# Set object in editor
		var object_instance = MechData.object_scenes[i].instantiate()
		mech_prototype.add_child(object_instance)
		if object_instance.has_meta("price"):
			PlayerData.money -= object_instance.get_meta("price")
			PlayerData.mech_cost += object_instance.get_meta("price")
		if object_instance.has_meta("friendly_npc"):
			npc_count += 1
		if object_instance.has_meta("npc_capacity"):
			npc_capacity += object_instance.get_meta("npc_capacity")
		# Show object editor helper
		if object_instance.has_meta("big_object"):
			object_instance.get_child(1).show()
		object_instance.position = MechData.object_coordinates[i] + Vector2(OBJECT_OFFSET*2)
		# Disable object processing
		object_instance.set_process(false)
		for child in object_instance.get_children():
			child.set_process(false)
	
	update_capacity_ui()
	control.update_cash_panel()

func clear_prototype():
	npc_count = 0
	npc_capacity = 0
	
	for i in range(0, MechData.blocks.size()):
		for j in range(0, MechData.blocks[i].size()):
			if blocks.get_cell_atlas_coords(Vector2i(i+2, j+2)) != MechData.EMPTY_CELL:
				if i+2 % 2 == 0 and j+2 % 2 == 0:
					unbuy(1)
			blocks.set_cell(Vector2i(i+2, j+2), 0 , Vector2i(-1,-1))
			walls.set_cell(Vector2i(i+2, j+2), 0 , Vector2i(-1,-1))
	MechData.reset_tiles()
	set_initial_cells()
	control.update_cash_panel()
	
	for i in range(2, mech_prototype.get_child_count()):
		if mech_prototype.get_child(i).has_meta("price"):
			unbuy(mech_prototype.get_child(i).get_meta("price"))
		mech_prototype.get_child(i).queue_free()
	MechData.object_scenes.clear()
	MechData.object_actions.clear()
	MechData.object_types.clear()
	MechData.object_coordinates.clear()
	
	MechData.control_pairs.clear()
	first_click = true
	
	update_capacity_ui()
	control.update_cash_panel()

func new_mech():
	npc_capacity = 0
	npc_count = 0
	
	for i in range(0, MechData.blocks.size()):
		for j in range(0, MechData.blocks[i].size()):
			if blocks.get_cell_atlas_coords(Vector2i(i+2, j+2)) != MechData.EMPTY_CELL:
				if i+2 % 2 == 0 and j+2 % 2 == 0:
					unbuy(1)
			blocks.set_cell(Vector2i(i+2, j+2), 0 , Vector2i(-1,-1))
			walls.set_cell(Vector2i(i+2, j+2), 0 , Vector2i(-1,-1))
	for i in range(2, mech_prototype.get_child_count()):
		if mech_prototype.get_child(i).has_meta("price"):
			unbuy(mech_prototype.get_child(i).get_meta("price"))
		mech_prototype.get_child(i).queue_free()
	
	MechData.new_mech()
	
	first_click = true
	
	update_capacity_ui()
	control.update_cash_panel()

func unload_mech():
	print("Unloading mech...")
	mech_instance.queue_free()
	print("Enabling building UI...")
	grid.show()
	mech_prototype.show()
	build_ui_enabled = true

func load_mech():
	print("Loading mech...")
	if MechData.summon_debug_mech:
		mech_instance = MECH_PB.instantiate()
	else:
		mech_instance = MECH.instantiate()
	self.add_child(mech_instance)
	mech_instance.global_position = Vector2(0, 0)
	print("Disabling building UI...")
	grid.hide()
	mech_prototype.hide()
	build_ui_enabled = false
	print("Enabling mech wiring mode...")
	mech_instance.mech_edit = true

func save_connections():
	MechData.control_pairs.clear()
	# Save controller:module pair connections
	if mech_instance:
		if mech_instance.controllers.get_child_count() != 0:
			for controller in mech_instance.controllers.get_children():
				# Match controller child #i to module child #i
				MechData.control_pairs.append(controller.controlled_module_index)

func finish_mech():
	MechData.control_pairs.clear()
	# Save controller:module pair connections
	if mech_instance:
		if mech_instance.controllers.get_child_count() != 0:
			for controller in mech_instance.controllers.get_children():
				# Match controller child #i to module child #i
				MechData.control_pairs.append(controller.controlled_module_index)
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://Scenes/Tutorials/tutorial4_1.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	tutorial_script()

func update_capacity_ui():
	capacity_label.text = "Capacity: " + str(npc_count) + "\\" + str(npc_capacity)

func set_initial_cells():
	const door_wall = Vector2i(9,0)
	var grid_pos = Vector2i(24,16)
	walls.set_cell(grid_pos + Vector2i.ZERO, 0, door_wall + Vector2i.ZERO)
	walls.set_cell(grid_pos + Vector2i.RIGHT, 0, door_wall + Vector2i.RIGHT)
	walls.set_cell(grid_pos + Vector2i.DOWN, 0, door_wall + Vector2i.DOWN)
	walls.set_cell(grid_pos + Vector2i.ONE, 0, door_wall + Vector2i.ONE)
	MechData.walls[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 0)] = door_wall
	MechData.walls[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 0)] = door_wall + Vector2i.RIGHT
	MechData.walls[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 1)] = door_wall + Vector2i.DOWN
	MechData.walls[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 1)] = door_wall + Vector2i.ONE
	var grid_pos2 = Vector2i(24,18)
	walls.set_cell(grid_pos2 + Vector2i.ZERO, 0, door_wall + Vector2i.ZERO)
	walls.set_cell(grid_pos2 + Vector2i.RIGHT, 0, door_wall + Vector2i.RIGHT)
	walls.set_cell(grid_pos2 + Vector2i.DOWN, 0, door_wall + Vector2i.DOWN)
	walls.set_cell(grid_pos2 + Vector2i.ONE, 0, door_wall + Vector2i.ONE)
	MechData.walls[-2 + (grid_pos2.x + 0)][-2 + (grid_pos2.y + 0)] = door_wall
	MechData.walls[-2 + (grid_pos2.x + 1)][-2 + (grid_pos2.y + 0)] = door_wall + Vector2i.RIGHT
	MechData.walls[-2 + (grid_pos2.x + 0)][-2 + (grid_pos2.y + 1)] = door_wall + Vector2i.DOWN
	MechData.walls[-2 + (grid_pos2.x + 1)][-2 + (grid_pos2.y + 1)] = door_wall + Vector2i.ONE

func buy(price : int) -> bool:
	if PlayerData.money < price:
		print("Not enough cash!")
		control.show_error("Not enough cash!\nNeed " + str(price-PlayerData.money) + " more!")
		control.attention(control.cash_label, 2)
		return false
	PlayerData.money -= price
	PlayerData.mech_cost += price
	control.update_cash_panel()
	return true

func unbuy(price : int):
	PlayerData.money += price
	PlayerData.mech_cost -= price
	control.update_cash_panel()


func _on_blocks_item_clicked(_index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	if current_trigger == 0:
		advance_trigger()

func _on_right_pressed() -> void:
	match current_trigger:
		1:
			advance_trigger()
		2:
			advance_trigger()
		5:
			advance_trigger()
		6:
			advance_trigger()
		_:
			pass

func _on_modules_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	if index == 0 and highlight_item_1.visible:
		triggers[current_trigger] = true
		current_trigger += 1
		highlight_item_1.visible = false
	elif index == 1 and highlight_item_2.visible:
		triggers[current_trigger] = true
		current_trigger += 1
		highlight_item_2.visible = false
	if current_trigger == 5:
		highlight_right.show()
		current_instruction += 1
		tutorial_ui.load_instruction(instructions[current_instruction])

func _on_movement_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	if index == 0 and highlight_item_1.visible:
		triggers[current_trigger] = true
		current_trigger += 1
		highlight_item_1.visible = false
	if current_trigger == 6:
		highlight_item_1.hide()
		control.next_stage.disabled = false
		highlight_stage.show()

func _on_next_stage_pressed() -> void:
	advance_trigger()
