extends Node

const EMPTY_CELL = Vector2i(-1,-1)
@onready var grid_size : Vector2i = Vector2i(34*2, 17*2)

enum ObjectType {
	MODULE, CONTROLLER, COLLIDER, SPRITE
}

@onready var summon_debug_mech = false

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

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(0, grid_size.x):
		blocks.append([])
		walls.append([])
		for y in range(0, grid_size.y):
			blocks.back().append(EMPTY_CELL)
			walls.back().append(EMPTY_CELL)

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
