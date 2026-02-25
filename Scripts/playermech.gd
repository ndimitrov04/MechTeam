extends RigidBody2D

const WHEEL_HITBOX_1 = preload("uid://gabbdsxamcdv")
const NPC = preload("uid://cmy4r8enqaty2")

@onready var crosshair = $Crosshair

@onready var background = $Background
@onready var frame : TileMapLayer = $Frame

@onready var movement_sprites = $MovementSprites
@onready var controllers = $Controllers
@onready var modules = $Modules
@onready var npcs = $NPCs

@onready var energy_regen = $EnergyRegen

@onready var game_over

const SPEED = 50.0
const JUMP_linear_velocity = -600.0

@onready var in_editor : bool = false

@onready var mech_edit : bool = false
var current_terminal

var direction : int = 0
var jump : bool = false

var max_hp : int = 200
var hp : int = max_hp
var max_energy : int
var energy : int
var regen_rate : int = 1

func _ready():
	if get_parent().name == "Editor":
		in_editor = true
	if not in_editor:
		game_over = $"../GUI/Control/GameOver"
	energy_regen.timeout.connect(_regenerate_energy)
	if not get_meta("prebuilt"):
		load_mech()
	max_hp = frame.get_used_cells().size() / 4
	hp = max_hp

func load_mech():
	# Load mech frame and background
	for x in range(0, MechData.blocks.size()):
		for y in range(0, MechData.blocks[x].size()):
			frame.set_cell(Vector2i(x,y), 0, MechData.blocks[x][y])
			background.set_cell(Vector2i(x,y), 0, MechData.walls[x][y])
	# Load mech objects
	var hitbox_instance
	for i in range(0, MechData.object_scenes.size()):
		var object_scene = MechData.object_scenes[i]
		var object_action = MechData.object_actions[i]
		var object_type = MechData.object_types[i]
		var object_coords = MechData.object_coordinates[i]
		
		var object_instance = object_scene.instantiate()
		match object_type:
			MechData.ObjectType.MODULE:
				modules.add_child(object_instance)
			MechData.ObjectType.CONTROLLER:
				controllers.add_child(object_instance)
				if not object_instance.get_meta_list().is_empty():
					object_instance.set_meta(object_instance.get_meta_list().front(), object_action)
					print(object_instance.get_meta(object_instance.get_meta_list().front()))
			MechData.ObjectType.COLLIDER:
				add_child(object_instance)
				# Add and setup hitbox for collider
				hitbox_instance = WHEEL_HITBOX_1.instantiate()
				add_child(hitbox_instance)
				hitbox_instance.position = object_coords + Vector2(0, 16)
				hitbox_instance.wheel_collider = object_instance
				hitbox_instance.set_collision_layer_value(9, 1)
				hitbox_instance.set_collision_mask_value(9, 1)
				hitbox_instance.set_collision_layer_value(10, 0)
				hitbox_instance.set_collision_mask_value(10, 0)
			MechData.ObjectType.SPRITE:
				movement_sprites.add_child(object_instance)
				hitbox_instance.wheel_sprite = object_instance
			MechData.ObjectType.NPC:
				npcs.add_child(object_instance)
			_:
				pass
		object_instance.position = object_coords
	# Load mech object connections
	for i in range(0, MechData.control_pairs.size()):
		# Check if controller should be connected to anything
		if MechData.control_pairs[i] == null:
			continue
		# Connect controller to controlled module
		controllers.get_child(i).arm(modules.get_child(MechData.control_pairs[i]))

func _physics_process(delta):
	# Do not process physics while in editor
	#if in_editor:
		#return
	
	# Add the gravity.
	if not is_on_floor():
		linear_velocity += get_gravity() * delta

	# Handle jump.
	if jump and is_on_floor():
		linear_velocity.y = JUMP_linear_velocity
		jump = false

	if direction:
		linear_velocity.x = move_toward(linear_velocity.x, direction * SPEED, 1) 
	else:
		linear_velocity.x = move_toward(linear_velocity.x, 0, 1)

	if abs(linear_velocity.x) > 0:
		for spr in movement_sprites.get_children():
			if not spr.is_playing():
				spr.play("default")
	else:
		for spr in movement_sprites.get_children():
			spr.stop()
	
	total_energy()
	
func _unhandled_input(event):
	if event.is_action_pressed("debug_mech_edit"):
		if not mech_edit:
			mech_edit = true
			print("ENTERED DEBUG MECH EDIT MODE")
		else:
			mech_edit = false
			print("EXITED DEBUG MECH EDIT MODE")

func total_energy():
	energy = 0
	for child in modules.get_children():
		if "current_energy" in child:
			energy += child.current_energy

func _regenerate_energy():
	return # dont regen passively for now (debug!!!)
	#if energy + regen_rate < max_energy:
		#energy += regen_rate
	#else:
		#energy = max_energy

func drain_energy(amount : int) -> bool:
	var leftover = null
	for child in modules.get_children():
		if "current_energy" in child:
			leftover = child.drain(amount)
		if leftover == null:
			continue
		if leftover <= 0:
			break
	if leftover <= 0:
		return true
	return false

func take_damage(damage_value : int):
	hp -= damage_value
	# Godot 4.5 still has no fallthrough switches :/
	if hp <= 150:
		background.break_random_tile()
	if hp <= 100:
		background.break_random_tile()
	if hp <= 50:
		background.break_random_tile()
	if hp <= 0:
		die()

func die():
	for module in modules.get_children():
		module.destroy()
	background.break_all_tiles()
	frame.collision_enabled = false
	frame.break_all_tiles()
	set_collision_layer_value(3, 0)
	await get_tree().create_timer(4).timeout
	print(name + " has died. (Not really, it's a robot, but what else could I call this function?)")
	# Game over sequence here
	game_over.show()

func is_on_floor():
	return true

func summon_friendly_npc(at_position : Vector2):
	var npc_instance = NPC.instantiate()
	npcs.add_child(npc_instance)
	npc_instance.global_position = at_position
