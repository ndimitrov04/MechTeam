extends Resource
class_name MechObject

# All variables are public

@export var mech_name : StringName

# Tile Data
@export var blocks : Array
@export var walls : Array

# Object data (Modules, Controllers, Modlues, Movement)
@export var object_scenes = []
@export var object_actions = []
@export var object_types = []
@export var object_coordinates = []

# Controller -> Controlled Module pairs
# Object_scene #i controls contor_pair[i]
@export var control_pairs = []

func _init(
	_name := "",
	_blocks := [],
	_walls := [],
	_object_scenes := [],
	_object_actions := [],
	_object_types := [],
	_object_coordinates := [],
	_control_pairs := []
):
	mech_name = _name
	blocks = _blocks
	walls = _walls
	object_scenes = _object_scenes
	object_actions = _object_actions
	object_types = _object_types
	object_coordinates = _object_coordinates
	control_pairs = _control_pairs
