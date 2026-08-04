extends RayCast2D

@onready var mech = get_parent().get_parent()

@onready var can_collide : bool = true

@onready var damage_multiplier : float = 0.0025

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
	if not get_collider().get_parent().IS_ENEMY:
		#print("ENEMY CRASH!")
		var own_velocity = mech.linear_velocity
		var target_velocity = get_collider().get_parent().linear_velocity
		var dmg = calculate_crash_damage(own_velocity, target_velocity)
		mech.apply_impulse(Vector2(15000, 0), global_position)
		mech.take_damage(dmg)
		can_collide = false
		await get_tree().create_timer(0.5).timeout
		can_collide = true
