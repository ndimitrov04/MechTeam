extends Node2D

const MECH = preload("uid://bg0x4kcl3emfw")

@onready var grid = $Grid
@onready var mech_prototype = $MechPrototype

# These two overlap the grid, so grid_positions = blocks positions, etc.
@onready var blocks = $MechPrototype/Blocks
@onready var walls = $MechPrototype/Walls

var global_mouse_pos : Vector2 = Vector2.ZERO
const MAX_X : int = 34
const MAX_Y : int = 17

# Top left atlas_coords
var chosen_block : Vector2i = Vector2i.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	# Test mech loading
	if Input.is_action_just_pressed("debug_mech_load"):
		print("Loading mech...")
		var mech_instance = MECH.instantiate()
		self.add_child(mech_instance)
		mech_instance.global_position = Vector2(0, 0)
		print("Hiding building UI...")
		grid.hide()
		mech_prototype.hide()
			
	if event is InputEventMouseButton:
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
		# Delete tile
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			global_mouse_pos = get_global_mouse_position()
			print("Global Mouse Position = " + str(global_mouse_pos))
			# Mouse pos relative to grid node
			var mouse_pos = mouse_to_tilemap()
			var grid_pos = expand_position(mouse_pos)
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

# Note -> Tilemap is 16x16, Scale = 2
# Keep in mind that each click will make 4 tiles
# So you need every 4th tile in both horizontal and vertical
func mouse_to_tilemap() -> Vector2i:
	var local_pos = to_local(global_mouse_pos)
	var tile_pos = grid.local_to_map(local_pos)
	print("Tile Mouse position = " + str(tile_pos))
	return tile_pos

func expand_position(mouse_pos : Vector2i) -> Vector2i:
	var chosen_x = floor(mouse_pos.x / 2) * 2
	var chosen_y = floor(mouse_pos.y / 2) * 2
	print("Grid Mouse position = " + str(Vector2i(chosen_x, chosen_y)))
	return Vector2i(chosen_x, chosen_y)

func load_mech():
	for y in range(0, MechData.grid_size.y, 4):
		for x in range(0, MechData.grid_size.y, 4):
			blocks.set_cell(Vector2i(x,y) + Vector2i.ZERO, 0, chosen_block + Vector2i.ZERO)
			blocks.set_cell(Vector2i(x,y) + Vector2i.RIGHT, 0, chosen_block + Vector2i.RIGHT)
			blocks.set_cell(Vector2i(x,y) + Vector2i.DOWN, 0, chosen_block + Vector2i.DOWN)
			blocks.set_cell(Vector2i(x,y) + Vector2i.ONE, 0, chosen_block + Vector2i.ONE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
