extends RigidBody2D

@onready var main = $".."

@onready var crosshair = $Crosshair
@onready var wheels = $MovementSprites

@onready var background = $Background
@onready var frame = $Frame
@onready var npcs = $NPCs
@onready var spawners = $Spawners
@onready var controllers = $Controllers
@onready var movement_sprites = $MovementSprites

@onready var hp_bar = $CanvasLayer/HPBar
@onready var hp_label = $CanvasLayer/HPBar/HPLabel

@onready var modules = $Modules

# Mech controller AI
@onready var action_decision = $ActionDecision

const SPEED = 55.0
const ACCEL = 450.0
const JUMP_linear_velocity = -400.0

const IS_ENEMY : bool = true

@onready var level_multiplier : float = 0.5 + (PlayerData.current_stage * 0.125)
@onready var base_hp = get_meta("hp")
var max_hp : int = 999 # Placeholder value (must be positive; non-null); Real value is set in _ready()
var hp : float = max_hp # Default value
var base_weight : float = 25 # Default value
var weight : float = base_weight + max_hp / 4.0 # Default value
var energy : int = 100
var reward : int = 25

var perma_brake : bool = false
var target_point : Vector2 = self.global_position
var moving : bool = true
var spawn_point = null

var asleep : bool = true
var destroyed : bool = false

var ai : bool = true
var choice_ranges : PackedByteArray = [65, 80, 90]
# Default values:
# Move = [0, choice_ranges[0]]
# Aim = [choice_ranges[0], choice_ranges[1]]
# Airstrike = [choice_ranges[1], choice_ranges[2]]
# Trigger Module = [choice_ranges[2], 100]

func _ready():
	# Load choice ranges of current mech
	if has_meta("choice_ranges"):
		choice_ranges = get_meta("choice_ranges")
	action_decision.timeout.connect(_on_action_decision_timeout)
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(0.1).timeout
	spawn_point = self.global_position
	max_hp = get_meta("hp")
	hp = max_hp
	weight = base_weight + frame.get_used_cells().size() / 16
	self.mass = weight
	if has_meta("constant_weight"):
		self.mass = get_meta("constant_weight")
	hp_bar.value = hp
	hp_label.text = "Boss HP: " + str(int(hp))
	await get_tree().create_timer(1).timeout
	update_decision_timer()
	

func _physics_process(delta):
	if main.enemies_left == 1:
		set_meta("shielded", false)
		frame.modulate = Color(1, 1, 1, 1)
		hp_label.modulate = Color(1, 1, 1, 1)
	
	if not destroyed:
		if hp <= 0:
			die()
		
	# Handle physics movement
	if moving:
		if global_position.distance_to(target_point) > 15.0:
			var direction = global_position.direction_to(target_point)
			var target_velocity = direction * SPEED
			linear_velocity = linear_velocity.move_toward(
				target_velocity,
				ACCEL * delta
			)
		else:
			linear_velocity.x = move_toward(linear_velocity.x, 0, 0.2)
			linear_velocity.y = move_toward(linear_velocity.y, 0, 0.2)

func take_damage(damage_value : float):
	hp -= damage_value
	hp_bar.value = hp
	hp_label.text = "Arm HP: " + str(int(hp))
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
	if destroyed:
		#print("Already dead.")
		return
	
	destroyed = true
	
	main.enemies_left -= 1
	#print(name + " has died. (Not really, it's a robot, but what else could I call this function?)")
	
	# Destroy wheels
	for child in movement_sprites.get_children():
		if child.has_method("destroy"):
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
	#print("Player has gained " + str(reward) + " coins!")
	main.rewards_collected += reward
	await get_tree().create_timer(1).timeout
	#print(name + " object freed.")
	queue_free()

func update_decision_timer():
	var crew_capacity = spawners.get_child_count()
	var crew_count = clamp(0, crew_capacity, npcs.get_child_count())
	#print((float(min(6, crew_capacity))/float(min(6,crew_count + 1))) * 1.5 - (PlayerData.current_stage * 0.05))
	#if (float(min(6, crew_capacity))/float(min(6,crew_count + 1))) * 1.5 - (PlayerData.current_stage * 0.05) <= 0:
		#breakpoint
	action_decision.wait_time = (float(min(6, crew_capacity))/float(min(6,crew_count + 1))) * 1.5 - (PlayerData.current_stage * 0.05)

func _on_action_decision_timeout():
	var action = randi_range(1, 100)

	if spawn_point:
		var target_x = randf_range(spawn_point.x - 300, spawn_point.x + 300)
		var target_y = randf_range(spawn_point.y - 150, spawn_point.y + 10)
		target_point = Vector2(target_x, target_y)

	# Punch
	if action < choice_ranges[0]:
		moving = false
		gravity_scale = 1
		await get_tree().create_timer(2.0).timeout
		linear_velocity.y -= 250
		target_point = spawn_point
		moving = true
		gravity_scale = 0
	# Aim
	elif action >= choice_ranges[0] and action < choice_ranges[1]:
		target_point = self.global_position
		crosshair.position += Vector2(randi_range(-35, 35), randi_range(-35, 35))
		# 25% chance to aim perfectly at mech
		if randi_range(0, 100) < 25:
			crosshair.global_position = main.mech.global_position + Vector2(300, 300)
	# Call in airstrike
	elif action >= choice_ranges[1] and action < choice_ranges[2]:
		airstrike()
	# Shoot
	elif action >= choice_ranges[2]:
		if modules.get_child_count() > 0:
			var module = null
			# Find a random gun that can be crew controlled; Make 5 attempts
			for i in range(0,5):
				module = modules.get_children().pick_random()
				if not ("auto" in module):
					break
			# If there aren't many guns on board, 50% chance to not shoot
			if modules.get_child_count() <= 2:
				if randf() < 0.5:
					return
			module.engage()

func is_on_floor():
	return true

# Call in airstrike
func airstrike():
	#if randi_range(0, 1) == 0:
		#return
	var can_airstrike : bool = false
	for module in modules.get_children():
		if module.has_meta("airstrike_object"):
			can_airstrike = true
			break
	if not can_airstrike:
		return
	const MORTAR_SHELL = preload("uid://di5dx65o5wvg3")
	var bomb_instance = MORTAR_SHELL.instantiate()
	var playermech_pos = main.mech.global_position
	const X_RANGE : int = 1024
	const HEIGHT : int = 1200
	bomb_instance.global_position.x = randi_range(playermech_pos.x, playermech_pos.x + X_RANGE)
	bomb_instance.global_position.y = playermech_pos.y - HEIGHT
	main.add_child(bomb_instance)

@onready var can_collide : bool = true
func _on_body_entered(body):
	if not can_collide:
		return
	#print("ENEMY CRASHED INTO: " + str(body.name))
	if body.name == "Mech":
		self.apply_central_impulse(Vector2(180000, 0))
		self.take_damage(5)
		# Take wheel knockback
		for object in self.wheels.get_children():
			if object.has_meta("is_movement"):
				object.physics_material_override.friction = 0.0
				object.apply_central_impulse(Vector2(70000, 0))
				await get_tree().create_timer(0.1).timeout
				object.physics_material_override.friction = 0.15
		can_collide = false
		await get_tree().create_timer(0.5).timeout
		can_collide = true
