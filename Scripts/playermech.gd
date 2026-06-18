extends RigidBody2D

const MALFUNCTION = preload("uid://dmps7d80pkvbu")
const NPC = preload("uid://cmy4r8enqaty2")

@onready var player

@onready var crosshair = $Crosshair

@onready var background = $Background
@onready var frame : TileMapLayer = $Frame

@onready var wheels = $Wheels
@onready var controllers = $Controllers
@onready var modules = $Modules
@onready var npcs = $NPCs
@onready var malfunctions = $Malfunctions
@onready var jump_timer = $JumpTimer

@onready var energy_regen = $EnergyRegen

@onready var malfunction_timer

@onready var game_over

const SPEED = 50.0
const JUMP = -450.0

const IS_ENEMY : bool = false

@onready var in_editor : bool = false

@onready var mech_edit : bool = true
var current_terminal

var direction : int = 0
var jump : bool = false
var can_jump : bool = true

var max_hp : int = 200 # Default value
var hp : float = max_hp # Default value
var base_weight : float = 25 # Default value
var weight : float = base_weight + max_hp / 4.0 # Default value
var max_energy : int
var energy : int
var regen_rate : int = 1

@onready var malfunction_min : float = 20
@onready var malfunction_max : float = 30

var destroyed : bool = false

func _ready():
	if get_parent().name == "Editor":
		in_editor = true
	energy_regen.timeout.connect(_regenerate_energy)
	jump_timer.timeout.connect(_jump_timeout)
	if has_node("MalfunctionTimer"):
		malfunction_timer = $MalfunctionTimer
		malfunction_timer.timeout.connect(_malfunction)
	if not in_editor:
		game_over = $"../GUI/Control/GameOver"
		if has_node("MalfunctionTimer"):
			@warning_ignore("narrowing_conversion")
			malfunction_timer.start(randi_range(malfunction_min, malfunction_max))
	if not get_meta("prebuilt"):
		load_mech()
	@warning_ignore("integer_division")
	# Calculate and set true weight/hp for mech
	max_hp = frame.get_used_cells().size() / 2
	hp = max_hp
	@warning_ignore("integer_division")
	weight = base_weight + frame.get_used_cells().size() / 8 + wheels.get_child_count() * 0.2
	self.mass = weight
	if has_meta("constant_weight"):
		self.mass = get_meta("constant_weight")

# Helper needed for controller proximity penalty calculations
func get_closest_node_distance(target, nodes):
	var best_dist = INF
	var target_pos = target.global_position
	for node in nodes:
		if not node or node == target: 
			continue
		var node_pos = node.global_position
		var dist = target_pos.distance_to(node_pos)
		if dist < best_dist:
			best_dist = dist
	return best_dist

func load_mech():
	# Load mech frame and background
	for x in range(0, MechData.blocks.size()):
		for y in range(0, MechData.blocks[x].size()):
			frame.set_cell(Vector2i(x,y), 0, MechData.blocks[x][y])
			background.set_cell(Vector2i(x,y), 0, MechData.walls[x][y])
	# Load mech objects
	#var hitbox_instance
	for i in range(0, MechData.object_scenes.size()):
		var object_scene = MechData.object_scenes[i]
		var object_action = MechData.object_actions[i]
		var object_type = MechData.object_types[i]
		var object_coords = MechData.object_coordinates[i]
		
		var object_instance = object_scene.instantiate()
		object_instance.position = object_coords
		match object_type:
			MechData.ObjectType.MODULE:
				modules.add_child(object_instance)
			MechData.ObjectType.CONTROLLER:
				controllers.add_child(object_instance)
				if not object_instance.get_meta_list().is_empty():
					object_instance.set_meta(object_instance.get_meta_list().front(), object_action)
					print(object_instance.get_meta(object_instance.get_meta_list().front()))
			#MechData.ObjectType.COLLIDER:
				#add_child(object_instance)
				## Add and setup hitbox for collider
				#hitbox_instance = WHEEL_HITBOX_1.instantiate()
				#add_child(hitbox_instance)
				#hitbox_instance.position = object_coords + Vector2(0, 16)
				#hitbox_instance.wheel_collider = object_instance
				#hitbox_instance.set_collision_layer_value(9, 1)
				#hitbox_instance.set_collision_mask_value(9, 1)
				#hitbox_instance.set_collision_layer_value(10, 0)
				#hitbox_instance.set_collision_mask_value(10, 0)
			MechData.ObjectType.SPRITE:
				wheels.add_child(object_instance)
				#hitbox_instance.wheel_objite = object_instance
			MechData.ObjectType.NPC:
				npcs.add_child(object_instance)
			_:
				pass
	# Load mech object connections
	for i in range(0, MechData.control_pairs.size()):
		# Check if controller should be connected to anything
		if MechData.control_pairs[i] == null:
			continue
		# Connect controller to controlled module
		controllers.get_child(i).arm(modules.get_child(MechData.control_pairs[i]))
	
	# Set proximity penalties to applicable objects
	var controller_array = controllers.get_children()
	for controller in controllers.get_children():
		if controller.has_method("set_proximity_penalty"):
			controller.set_proximity_penalty(get_closest_node_distance(controller, controller_array))
	
	print("Mech loaded!")

func _physics_process(delta):
	# Do not process physics while in editor
	#if in_editor:
		#return
	
	# Keep upright
	#rotation_degrees = clamp(rotation_degrees, -45, 45)
	
	# Add the gravity.
	if not is_on_floor():
		linear_velocity += get_gravity() * delta

	# Handle jump.
	if jump and can_jump and wheels.get_child_count() > 0:
		linear_velocity.y = JUMP * wheels.get_child_count()
		jump = false
		can_jump = false
		jump_timer.start()

	# Handle physics movement
	if direction:
		if get_meta("prebuilt"):
			physics_material_override.friction = 0.0
		else:
			physics_material_override.friction = 0.1
		# Apply movement force at wheels/tracks if they are touching the floor
		for movement_object in wheels.get_children():
			if not movement_object.has_meta("is_movement"):
				continue
			if movement_object.get_meta("is_active"):
				if movement_object.floor_detector.is_colliding():
					movement_object.drive()
		#linear_velocity.x = move_toward(linear_velocity.x, direction * SPEED, 1) 
	else:
		physics_material_override.friction = 0.9
		#linear_velocity.x = move_toward(linear_velocity.x, 0, 0.2)

	# Max/Top speed (horizontal) - Determined by number of movement objects
	var max_speed = wheels.get_child_count() * 45
	if linear_velocity.x > max_speed:
		linear_velocity.x = max_speed
	if linear_velocity.x < -max_speed:
		linear_velocity.x = -max_speed

	# Handle wheel/track animations
	if abs(linear_velocity.x) > 1:
		for obj in wheels.get_children():
			if not obj.has_meta("is_movement"):
				continue
			if not obj.is_playing():
				obj.play("default")
			if not obj.dust.emitting and obj.floor_detector.is_colliding():
				obj.dust.emitting = true
				obj.start_dust.play("default")
				if direction < 0:
					obj.start_dust.flip_h = true
					obj.start_dust.offset.x = +35
				else:
					obj.start_dust.flip_h = false
					obj.start_dust.offset.x = -35
	else:
		for obj in wheels.get_children():
			if obj.has_method("stop") and obj.has_meta("is_movement"):
				obj.stop()
				obj.dust.emitting = false
	
	# Recalculate total mech energy
	total_energy()
	
func _unhandled_input(event):
	if event.is_action_pressed("debug_mech_edit"):
		if not mech_edit:
			mech_edit = true
			print("ENTERED DEBUG MECH EDIT MODE")
		else:
			mech_edit = false
			print("EXITED DEBUG MECH EDIT MODE")
	if event.is_action_pressed("debug_connection_view"):
		for child in controllers.get_children():
			if not ("connector" in child):
				continue
			if child.connector.visible:
				child.connector.hide()
				continue
			child.connector.show()
		

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

func take_damage(damage_value : float):
	hp -= damage_value
	# Godot 4.6 still has no fallthrough switches :/
	if hp <= max_hp:
		background.break_random_tile()
	@warning_ignore("integer_division")
	if hp <= max_hp/2:
		background.break_random_tile()
	@warning_ignore("integer_division")
	if hp <= max_hp/4:
		background.break_random_tile()
	if hp <= 0:
		die()

func _malfunction():
	var frame_cells = frame.get_used_cells()
	var background_cells = background.get_used_cells()
	var malfunction_location = null
	var from_frame = randi_range(0, 1)
	if background_cells.is_empty():
		from_frame = 1
	if from_frame:
		var cell = frame_cells.pick_random()
		malfunction_location = to_global(frame.map_to_local(cell))
	else:
		var cell = background_cells.pick_random()
		malfunction_location = to_global(background.map_to_local(cell))
	if malfunction_location != null:
		# Spawn malfunction
		print("Spawning malfunction at: " + str(malfunction_location))
		var malfunction_instance = MALFUNCTION.instantiate()
		malfunctions.add_child(malfunction_instance)
		malfunction_instance.global_position = malfunction_location
		
	@warning_ignore("narrowing_conversion")
	malfunction_timer.start(randi_range(malfunction_min, malfunction_max))

func die():
	if destroyed:
		return
	
	destroyed = true
	
	# Destroy wheels
	for child in self.get_children():
		if child.has_meta("whitbox"):
			child.destroy()
	# Hide controllers
	controllers.hide()
	# Kill NPCs
	for npc in npcs.get_children():
		npc.die()
	# Destroy modules
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

func _jump_timeout():
	can_jump = true

func summon_friendly_npc(at_position : Vector2):
	var npc_instance = NPC.instantiate()
	npcs.add_child(npc_instance)
	npc_instance.global_position = at_position
