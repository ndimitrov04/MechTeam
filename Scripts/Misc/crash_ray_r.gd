extends RayCast2D

@onready var mech = get_parent().get_parent()

@onready var can_collide : bool = true

@onready var damage_multiplier : float = 0.01

@export var update_interval : int = 12
var offset : int = randi() % update_interval

func calculate_crash_damage(own_velocity, target_velocity):
	var total_velocity = abs(own_velocity) + abs(target_velocity)
	return total_velocity.x * damage_multiplier

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (Engine.get_process_frames() + offset) % update_interval != 0:
		return
	if not can_collide:
		return
	if not is_colliding():
		return
	if get_collider() == null:
		return
	if get_collider().get_parent() == null:
		return
	if not "IS_ENEMY" in get_collider().get_parent():
		return
	if get_collider().get_parent().IS_ENEMY:
		#print("FRIENDLY CRASH!")
		var own_velocity = mech.linear_velocity
		var target_velocity = get_collider().get_parent().linear_velocity
		var dmg = calculate_crash_damage(own_velocity, target_velocity)
		# Take knockback and stop mech movement, make sure mech doesn't jump a lot
		mech.direction = 0
		#mech.get_parent().player.camera.bonus_impact = 3
		#print("Player?: " + str(mech.get_parent().player.name))
		mech.get_parent().player.camera.trauma = 1.5
		mech.apply_central_impulse(Vector2(-10000, 0))
		for object in mech.wheels.get_children():
			if object.has_meta("is_movement"):
				object.physics_material_override.friction = 0.0
				object.apply_central_impulse(Vector2(-10000, 0))
				await get_tree().create_timer(0.1).timeout
				object.physics_material_override.friction = 0.15
		# Take damage
		mech.take_damage(dmg)
		# A bit of crash invincibility
		can_collide = false
		await get_tree().create_timer(1.5).timeout
		#mech.get_parent().player.camera.bonus_impact = 0
		can_collide = true
