extends CharacterBody2D

@onready var crosshair = $Crosshair

@onready var background = $Background
@onready var frame = $Frame

@onready var movement_sprites = $MovementSprites
@onready var controllers = $Controllers
@onready var weapons = $Weapons

@onready var energy_regen = $EnergyRegen

const SPEED = 50.0
const JUMP_VELOCITY = -600.0

@onready var in_editor : bool = false

@onready var mech_edit : bool = false
var current_terminal

var direction : int = 0
var jump : bool = false

var max_hp : int = 100
var hp : int = max_hp
var max_energy : int = 100
var energy : int = max_energy
var regen_rate : int = 1

func _ready():
	if get_parent().name == "Editor":
		in_editor = true
	energy_regen.timeout.connect(_regenerate_energy)
	if not get_meta("prebuilt"):
		load_mech()
	#generate_frame_collision(0)

func load_mech():
	for x in range(0, MechData.blocks.size()):
		for y in range(0, MechData.blocks[x].size()):
			frame.set_cell(Vector2i(x,y), 0, MechData.blocks[x][y])
			background.set_cell(Vector2i(x,y), 0, MechData.walls[x][y])
	for i in range(0, MechData.object_scenes.size()):
		var object_scene = MechData.object_scenes[i]
		var object_action = MechData.object_actions[i]
		var object_type = MechData.object_types[i]
		var object_coords = MechData.object_coordinates[i]
		
		var object_instance = object_scene.instantiate()
		match object_type:
			MechData.ObjectType.WEAPON:
				weapons.add_child(object_instance)
			MechData.ObjectType.CONTROLLER:
				controllers.add_child(object_instance)
				if not object_instance.get_meta_list().is_empty():
					object_instance.set_meta(object_instance.get_meta_list().front(), object_action)
					print(object_instance.get_meta(object_instance.get_meta_list().front()))
			MechData.ObjectType.COLLIDER:
				add_child(object_instance)
			MechData.ObjectType.SPRITE:
				movement_sprites.add_child(object_instance)
			_:
				pass
		object_instance.position = object_coords

func _physics_process(delta):
	# Do not process physics while in editor
	#if in_editor:
		#return
	
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if jump and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump = false

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if abs(velocity.x) > 0:
		for spr in movement_sprites.get_children():
			if not spr.is_playing():
				spr.play("default")
	else:
		for spr in movement_sprites.get_children():
			spr.stop()
	
	move_and_slide()
	
func _unhandled_input(event):
	if event.is_action_pressed("debug_mech_edit"):
		if not mech_edit:
			mech_edit = true
			print("ENTERED DEBUG MECH EDIT MODE")
		else:
			mech_edit = false
			print("EXITED DEBUG MECH EDIT MODE")

func _regenerate_energy():
	if energy + regen_rate < max_energy:
		energy += regen_rate
	else:
		energy = max_energy

func take_damage(damage_value : int):
	hp -= damage_value
	# Godot 4.5 still has no fallthrough switches :/
	if hp <= 75:
		background.break_random_tile()
	if hp <= 50:
		background.break_random_tile()
	if hp <= 25:
		background.break_random_tile()
	if hp <= 0:
		die()

func die():
	background.break_all_tiles()
	frame.collision_enabled = false
	frame.break_all_tiles()
	set_collision_layer_value(3, 0)
	await get_tree().create_timer(4).timeout
	print(name + " has died. (Not really, it's a robot, but what else could I call this function?)")
	queue_free()

#func is_on_floor():
	#return true

# func generate_frame_collision(layer : int):
	#var cells = frame.get_used_cells()
	#
	#for cell in cells:
		#var quadrant_size = frame.physics_quadrant_size
		#
		#var data: TileData = frame.get_cell_tile_data(cell) 
		#var points: PackedVector2Array = data.get_collision_polygon_points(0, layer) 
		#var collision_shape = CollisionPolygon2D.new()  
		#collision_shape.polygon = points 
		## Magic numbers, DO NOT TOUCH
		#var new_pos : Vector2i = Vector2i(
			#quadrant_size / 2, 
			#(quadrant_size / 2) - 1) + (cell * Vector2i(quadrant_size, quadrant_size)
		#)
		#
		#collision_shape.position = new_pos
		#add_child(collision_shape)
