extends Node

const EMPTY_CELL = Vector2i(-1,-1)
@onready var grid_size : Vector2i = Vector2i(34*2, 17*2)

enum ObjectType {
	MODULE, CONTROLLER, COLLIDER, SPRITE
}

@onready var summon_debug_mech = false

# Array of mechs
@onready var mechs : Array[MechObject]

# Tile Data
@onready var blocks : Array
@onready var walls : Array

# Object data (Modules, Controllers, Modlues, Movement)
@onready var object_scenes = []
@onready var object_actions = []
@onready var object_types = []
@onready var object_coordinates = []

# Controller -> Controlled Module pairs
# Object_scene #i controls contor_pair[i]
@onready var control_pairs = []

func reset_tiles():
	blocks.clear()
	walls.clear()
	for x in range(0, grid_size.x):
		blocks.append([])
		walls.append([])
		for y in range(0, grid_size.y):
			blocks.back().append(EMPTY_CELL)
			walls.back().append(EMPTY_CELL)

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_tiles()
	# Load all saved mechs to mechs array
	load_from_file()

func set_object(scene : PackedScene, action : int, type : ObjectType, coords : Vector2):
	object_scenes.append(scene)
	object_actions.append(action)
	object_types.append(type)
	object_coordinates.append(coords)

func delete_object(coords : Vector2):
	var delete_index = null
	for i in range(0, object_coordinates.size()):
		if coords.is_equal_approx(object_coordinates[i]):
			delete_index = i
			break
	if delete_index:
		object_scenes.remove_at(delete_index)
		object_actions.remove_at(delete_index)
		object_types.remove_at(delete_index)
		object_coordinates.remove_at(delete_index)

func new_mech():
	# Create empty editor state
	reset_tiles()
	object_scenes.clear()
	object_actions.clear()
	object_types.clear()
	object_coordinates.clear()
	control_pairs.clear()
	
	# Create empty mech
	var mech := MechObject.new()
	mech.blocks = blocks.duplicate(true)
	mech.walls = walls.duplicate(true)
	mech.object_scenes = object_scenes.duplicate()
	mech.object_actions = object_actions.duplicate()
	mech.object_types = object_types.duplicate()
	mech.object_coordinates = object_coordinates.duplicate()
	mech.control_pairs = control_pairs.duplicate()
	mechs.append(mech)
	save_to_file()


func save_mech(active_mech_index):
	if active_mech_index < 0:
		return

	var mech := mechs[active_mech_index]
	mech.blocks = blocks.duplicate(true)
	mech.walls = walls.duplicate(true)
	mech.object_scenes = object_scenes.duplicate()
	mech.object_actions = object_actions.duplicate()
	mech.object_types = object_types.duplicate()
	mech.object_coordinates = object_coordinates.duplicate()
	mech.control_pairs = control_pairs.duplicate()

	save_to_file()

func load_mech(index: int):
	reset_tiles()

	blocks = mechs[index].blocks.duplicate(true)
	walls = mechs[index].walls.duplicate(true)
	object_scenes = mechs[index].object_scenes.duplicate()
	object_actions = mechs[index].object_actions.duplicate()
	object_types = mechs[index].object_types.duplicate()
	object_coordinates = mechs[index].object_coordinates.duplicate()
	control_pairs = mechs[index].control_pairs.duplicate()


func save_to_file():
	var container := MechsContainer.new()
	container.mechs = mechs
	ResourceSaver.save(container, "user://mechteam_save.tres")

func load_from_file():
	var container := ResourceLoader.load("user://mechteam_save.tres") as MechsContainer
	if container:
		mechs = container.mechs
