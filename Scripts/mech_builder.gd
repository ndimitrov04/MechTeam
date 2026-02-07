extends Node2D

const MECH = preload("uid://bg0x4kcl3emfw")
const MECH_PB = preload("uid://dimm11yjnr7ef")

@onready var grid = $Grid
@onready var mech_prototype = $MechPrototype

# These two overlap the grid, so grid_positions = blocks positions, etc.
@onready var blocks = $MechPrototype/Blocks
@onready var walls = $MechPrototype/Walls

@onready var in_editor : bool = false

@onready var build_ui_enabled : bool = true

@onready var player_spots = [Vector2i(24, 16), Vector2i(24, 18)]

var global_mouse_pos : Vector2 = Vector2.ZERO
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
var chosen_block : Vector2i = Vector2i.ZERO

# Object instance
var chosen_object = null
const OBJECT_OFFSET : Vector2i = Vector2i(16,16)
# Metadata modifier of object
var chosen_action : int = 0

var chosen_movement_collider = null
var chosen_movement_sprite = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().name == "Editor":
		in_editor = true
		
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
			
	if event is InputEventMouseButton and build_ui_enabled:
		# Set tile
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			global_mouse_pos = get_global_mouse_position()
			print("Global Mouse Position = " + str(global_mouse_pos))
			# Mouse pos relative to grid node
			var mouse_pos = mouse_to_tilemap()
			var grid_pos = expand_position(mouse_pos)
			if grid_pos.x / 2 - 1 < 0 or grid_pos.x / 2 - 1 >= 34:
				return
			if grid_pos.y / 2 - 1 < 0 or grid_pos.y / 2 - 1 >= 17:
				return
			if grid_pos.x / 2 == 12:
				if grid_pos.y / 2 == 8 or grid_pos.y / 2 == 9:
					return
			match edit_layer:
				EditLayer.BLOCKS:
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
				EditLayer.WALLS:
					# Set 4 16x16 tiles to make one 32x32 tile
					walls.set_cell(grid_pos + Vector2i.ZERO, 0 , chosen_block + Vector2i.ZERO)
					walls.set_cell(grid_pos + Vector2i.RIGHT, 0, chosen_block + Vector2i.RIGHT)
					walls.set_cell(grid_pos + Vector2i.DOWN, 0, chosen_block + Vector2i.DOWN)
					walls.set_cell(grid_pos + Vector2i.ONE, 0, chosen_block + Vector2i.ONE)
					# Add to mech data global
					MechData.walls[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 0)] = chosen_block
					MechData.walls[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 0)] = chosen_block + Vector2i.RIGHT
					MechData.walls[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 1)] = chosen_block + Vector2i.DOWN
					MechData.walls[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 1)] = chosen_block + Vector2i.ONE
				EditLayer.OBJECTS:
					# Set object in editor
					var object_instance = chosen_object.instantiate()
					mech_prototype.add_child(object_instance)
					object_instance.position = to_global(grid_pos*16+OBJECT_OFFSET)
					# Disable object processing
					object_instance.set_process(false)
					for child in object_instance.get_children():
						child.set_process(false)
					# Add to mech data global
					MechData.set_object(chosen_object, chosen_action, object_instance.type, to_global(grid_pos*16-OBJECT_OFFSET))
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

		# Delete tile
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			global_mouse_pos = get_global_mouse_position()
			print("Global Mouse Position = " + str(global_mouse_pos))
			# Mouse pos relative to grid node
			var mouse_pos = mouse_to_tilemap()
			var grid_pos = expand_position(mouse_pos)
			match edit_layer:
				EditLayer.BLOCKS:
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
				EditLayer.WALLS:
					# Set 4 16x16 tiles to make one 32x32 tile
					walls.set_cell(grid_pos + Vector2i.ZERO, 0 , chosen_block + Vector2i.ZERO)
					walls.set_cell(grid_pos + Vector2i.RIGHT, 0, chosen_block + Vector2i.RIGHT)
					walls.set_cell(grid_pos + Vector2i.DOWN, 0, chosen_block + Vector2i.DOWN)
					walls.set_cell(grid_pos + Vector2i.ONE, 0, chosen_block + Vector2i.ONE)
					# Add to mech data global
					MechData.walls[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 0)] = MechData.EMPTY_CELL
					MechData.walls[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 0)] = MechData.EMPTY_CELL
					MechData.walls[-2 + (grid_pos.x + 0)][-2 + (grid_pos.y + 1)] = MechData.EMPTY_CELL
					MechData.walls[-2 + (grid_pos.x + 1)][-2 + (grid_pos.y + 1)] = MechData.EMPTY_CELL
				EditLayer.OBJECTS:
					# Delete mech data by position
					MechData.delete_object(to_global(grid_pos*16-OBJECT_OFFSET))
					# Delete object from editor
					for child in mech_prototype.get_children():
						print(child.name + str(child.position))
						if child.position == Vector2(grid_pos*16+OBJECT_OFFSET):
							print("Deleting " + child.name)
							child.queue_free()
				EditLayer.MOVEMENT:
					# Repeat twice
					# Delete mech data by position
					MechData.delete_object(to_global(grid_pos*16-OBJECT_OFFSET))
					# Delete object from editor
					for child in mech_prototype.get_children():
						print(child.name + str(child.position))
						if child.position == Vector2(grid_pos*16+OBJECT_OFFSET):
							print("Deleting " + child.name)
							child.queue_free()
					# Delete mech data by position
					MechData.delete_object(to_global(grid_pos*16-OBJECT_OFFSET))
					# Delete object from editor
					for child in mech_prototype.get_children():
						print(child.name + str(child.position))
						if child.position == Vector2(grid_pos*16+OBJECT_OFFSET):
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
	for i in range(0, MechData.blocks.size()):
		for j in range(0, MechData.blocks[i].size()):
			blocks.set_cell(Vector2i(i+2, j+2), 0 , MechData.blocks[i][j])
			walls.set_cell(Vector2i(i+2, j+2), 0 , MechData.walls[i][j])
	for i in range(0, MechData.object_scenes.size()):
		# Set object in editor
		var object_instance = MechData.object_scenes[i].instantiate()
		mech_prototype.add_child(object_instance)
		object_instance.position = MechData.object_coordinates[i] + Vector2(OBJECT_OFFSET*2)
		# Disable object processing
		object_instance.set_process(false)
		for child in object_instance.get_children():
			child.set_process(false)

func clear_prototype():
	for i in range(0, MechData.blocks.size()):
		for j in range(0, MechData.blocks[i].size()):
			blocks.set_cell(Vector2i(i+2, j+2), 0 , Vector2i(-1,-1))
			walls.set_cell(Vector2i(i+2, j+2), 0 , Vector2i(-1,-1))
	MechData.reset_tiles()
	
	for i in range(2, mech_prototype.get_child_count()):
		mech_prototype.get_child(i).queue_free()
	MechData.object_scenes.clear()
	MechData.object_actions.clear()
	MechData.object_types.clear()
	MechData.object_coordinates.clear()
	
	MechData.control_pairs.clear()

func new_mech():
	MechData.new_mech()
	for i in range(0, MechData.blocks.size()):
		for j in range(0, MechData.blocks[i].size()):
			blocks.set_cell(Vector2i(i+2, j+2), 0 , Vector2i(-1,-1))
			walls.set_cell(Vector2i(i+2, j+2), 0 , Vector2i(-1,-1))
	for i in range(2, mech_prototype.get_child_count()):
		mech_prototype.get_child(i).queue_free()

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
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
