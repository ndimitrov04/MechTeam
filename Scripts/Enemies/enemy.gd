extends CharacterBody2D

@onready var crosshair = $Crosshair
@onready var movement_sprites = $MovementSprites

@onready var background = $Background
@onready var frame = $Frame

@onready var weapons = $Weapons

# Mech controller AI
@onready var action_decision = $ActionDecision

const SPEED = 25.0
const JUMP_VELOCITY = -400.0

var hp : int = 100
var energy : int = 100

var direction = 1

func _ready():
	action_decision.timeout.connect(_on_action_decision_timeout)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
		
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
	for module in weapons.get_children():
		module.destroy()
	background.break_all_tiles()
	frame.collision_enabled = false
	frame.break_all_tiles()
	set_collision_layer_value(3, 0)
	await get_tree().create_timer(4).timeout
	print(name + " has died. (Not really, it's a robot, but what else could I call this function?)")
	queue_free()

func _on_action_decision_timeout():
	var action = randi_range(1, 100)
	const directions = [-1, 1]
	var ai : bool = true
	
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
		weapons.get_children().pick_random().shoot()
