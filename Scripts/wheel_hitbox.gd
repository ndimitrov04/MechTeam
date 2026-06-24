extends Area2D

const DEBRIS = preload("uid://rg2m11gs0xex")

@onready var main = $"../../.."

@onready var prebuilt = get_meta("prebuilt")

@onready var wheel_collider
@onready var wheel_sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if "damage_value" in body:
		print("WHEEL HIT")
		# Spawn debris
		var debris_instance = DEBRIS.instantiate()
		main.call_deferred("add_child", debris_instance)
		#main.add_child(debris_instance)
		debris_instance.global_position = global_position
		get_parent().queue_free()

func destroy():
	# Spawn debris
	var debris_instance = DEBRIS.instantiate()
	main.call_deferred("add_child", debris_instance)
	#main.add_child(debris_instance)
	debris_instance.global_position = global_position
	get_parent().destroy()
