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
@onready var jump_timer = $JumpTimer

@onready var energy_regen = $EnergyRegen

@onready var game_over

const SPEED = 50.0
const JUMP_linear_velocity = -600.0

@onready var in_editor : bool = false

@onready var mech_edit : bool = true
var current_terminal

var direction : int = 0
var jump : bool = false
var can_jump : bool = true

var max_hp : int = 200 # Default value
var hp : int = max_hp # Default value
var base_weight : float = 25 # Default value
var weight : float = base_weight + max_hp / 4.0 # Default value
var max_energy : int
var energy : int
var regen_rate : int = 1

func _ready():
	if get_parent().name == "Editor":
		in_editor = true
	if not in_editor:
		game_over = $"../GUI/Control/GameOver"
	energy_regen.timeout.connect(_regenerate_energy)
	jump_timer.timeout.connect(_jump_timeout)
	if not get_meta("prebuilt"):
		load_mech()
	@warning_ignore("integer_division")
	# Calculate and set true weight/hp for mech
	max_hp = frame.get_used_cells().size() / 4
	hp = max_hp
	weight = base_weight + max_hp / 4.0 + movement_sprites.get_child_count() * 0.2
	self.mass = weight
	if has_meta("constant_weight"):
		self.mass = get_meta("constant_weight")

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
	
	# Keep upright
	#rotation_degrees = clamp(rotation_degrees, -45, 45)
	
	# Add the gravity.
	if not is_on_floor():
		linear_velocity += get_gravity() * delta

	# Handle jump.
	if jump and can_jump and movement_sprites.get_child_count() > 0:
		linear_velocity.y = JUMP_linear_velocity
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
		for movement_object in movement_sprites.get_children():
			if movement_object.get_meta("is_active"):
				if movement_object.floor_detector.is_colliding():
					var push_point = movement_object.global_position - Vector2(0, 0)
					self.apply_force(Vector2(direction, 0) * SPEED * 450, push_point)
		#linear_velocity.x = move_toward(linear_velocity.x, direction * SPEED, 1) 
	else:
		physics_material_override.friction = 0.9
		#linear_velocity.x = move_toward(linear_velocity.x, 0, 0.2)

	# Max/Top speed (horizontal) - Determined by number of movement objects
	var max_speed = movement_sprites.get_child_count() * 45
	if linear_velocity.x > max_speed:
		linear_velocity.x = max_speed
	if linear_velocity.x < -max_speed:
		linear_velocity.x = -max_speed

	# Handle wheel/track animations
	if abs(linear_velocity.x) > 1:
		for spr in movement_sprites.get_children():
			if not spr.is_playing():
				spr.play("default")
			if not spr.dust.emitting and spr.floor_detector.is_colliding():
				spr.dust.emitting = true
				spr.start_dust.play("default")
				if direction < 0:
					spr.start_dust.flip_h = true
					spr.start_dust.offset.x = +35
				else:
					spr.start_dust.flip_h = false
					spr.start_dust.offset.x = -35
	else:
		for spr in movement_sprites.get_children():
			spr.stop()
			spr.dust.emitting = false
	
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

func take_damage(damage_value : int):
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

func die():
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
