extends RigidBody2D

@onready var main = $"../../.."

const DEBRIS = preload("uid://rg2m11gs0xex")

@onready var destroyed : bool = false
@onready var type : MechData.ObjectType = MechData.ObjectType.MODULE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func destroy():
	# Spawn debris
	var debris_instance = DEBRIS.instantiate()
	main.add_child(debris_instance)
	debris_instance.global_position = global_position
	
	set_collision_layer_value(2, 0)
	set_collision_layer_value(4, 0)
	set_collision_mask_value(2, 0)
	set_collision_mask_value(4, 0)
	
	set_collision_layer_value(7, 1)
	set_collision_mask_value(7, 1)
	
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	destroyed = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
	freeze = false

func _on_body_entered(_body):
	var debris_instance = DEBRIS.instantiate()
	main.call_deferred("add_child", debris_instance)
	debris_instance.global_position = global_position
	await get_tree().create_timer(1.0).timeout
	queue_free()
