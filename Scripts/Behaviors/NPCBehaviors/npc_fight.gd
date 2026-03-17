extends Node2D

@onready var detection_area = $DetectionArea
@onready var hitbox  = $DetectionArea/Hitbox

@onready var disabled : bool = false

@onready var sight_range : int = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	detection_area.body_entered.connect(_on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_body_entered(body):
	# On detection of enemy
	if "friendly_unit" in body:
		if body.friendly_unit != get_parent().friendly_unit:
			get_parent().fight(1.5)
			temp_disable(1.5)
			#detection_area.emit_signal("body_exited")

func temp_disable(time : float):
	detection_area.collision_mask = 0
	await get_tree().create_timer(time).timeout
	detection_area.set_collision_mask_value(1, 1)
	detection_area.set_collision_mask_value(2, 1)
	detection_area.set_collision_mask_value(3, 1)
	detection_area.set_collision_mask_value(4, 1)
	detection_area.set_collision_mask_value(12, 1)
	detection_area.set_collision_mask_value(13, 1)

func face_right(facing : bool):
	if facing:
		@warning_ignore("integer_division")
		hitbox.position.x = sight_range / 2
	else:
		@warning_ignore("integer_division")
		hitbox.position.x = -sight_range / 2
