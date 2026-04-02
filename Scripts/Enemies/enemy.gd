extends RigidBody2D

@onready var main = $".."

@onready var crosshair = $Crosshair
@onready var movement_sprites = $MovementSprites

@onready var background = $Background
@onready var frame = $Frame
@onready var npcs = $NPCs
@onready var spawners = $Spawners
@onready var controllers = $Controllers

@onready var modules = $Modules

# Mech controller AI
@onready var action_decision = $ActionDecision

const SPEED = 45.0
const JUMP_linear_velocity = -400.0

@onready var level_multiplier : float = 0.5 + (PlayerData.current_stage * 0.25)
@onready var base_hp = get_meta("hp")
var max_hp : int = 999 # Placeholder value (must be positive; non-null); Real value is set in _ready()
var hp : int = max_hp # Default value
var base_weight : float = 25 # Default value
var weight : float = base_weight + max_hp / 4.0 # Default value
var energy : int = 100
var reward : int = 25

var direction : int = 1

var asleep : bool = true

var ai : bool = true

func _ready():
	action_decision.timeout.connect(_on_action_decision_timeout)
	await get_tree().create_timer(0.1).timeout
	max_hp = base_hp * level_multiplier
	hp = max_hp
	weight = base_weight + frame.get_used_cells().size() / 16
	self.mass = weight
	if has_meta("constant_weight"):
		self.mass = get_meta("constant_weight")
	await get_tree().create_timer(0.5).timeout
	update_decision_timer()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		linear_velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#linear_velocity.y = JUMP_linear_velocity
		
	# Handle physics movement
	if direction:
		# Apply movement force at wheels/tracks if they are touching the floor
		for movement_object in movement_sprites.get_children():
			if movement_object.floor_detector.is_colliding():
				var push_point = movement_object.global_position - Vector2(0, center_of_mass.y + 150)
				self.apply_force(Vector2(direction, 0) * SPEED * 450, push_point)
		#linear_velocity.x = move_toward(linear_velocity.x, direction * SPEED, 1) 
	else:
		linear_velocity.x = move_toward(linear_velocity.x, 0, 0.2)

	# Max/Top speed (horizontal) - Determined by number of movement objects
	var max_speed = movement_sprites.get_child_count() * 45
	if linear_velocity.x > max_speed:
		linear_velocity.x = max_speed
	if linear_velocity.x < -max_speed:
		linear_velocity.x = -max_speed

	if abs(linear_velocity.x) > 0:
		for spr in movement_sprites.get_children():
			if not spr.is_playing():
				spr.play("default")
	else:
		for spr in movement_sprites.get_children():
			spr.stop()

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
	main.enemies_left -= 1
	print("Player has gained " + str(reward) + " coins!")
	PlayerData.money += reward
	main.rewards_collected += reward
	await get_tree().create_timer(4).timeout
	print(name + " has died. (Not really, it's a robot, but what else could I call this function?)")
	main.advance()
	queue_free()

func update_decision_timer():
	var crew_capacity = spawners.get_child_count()
	var crew_count = clamp(0, crew_capacity, npcs.get_child_count())
	action_decision.wait_time = clampf((crew_capacity / 4.0) - ((crew_count - 1) / 4.0), 0.4, 5.0)

func _on_action_decision_timeout():
	var action = randi_range(1, 100)
	const directions = [-1, 1]
	
	if not ai:
		direction = 0
		return

	# Move 65%
	if action < 65:
		direction = directions.pick_random()
	# Aim 15%
	elif action >= 65 and action < 90:
		direction = 0
		crosshair.position += Vector2(randi_range(-35, 35), randi_range(-35, 35))
	# Shoot 10%
	elif action >= 90:
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
