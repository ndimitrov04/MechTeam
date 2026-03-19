extends Area2D

const DEBRIS = preload("uid://rg2m11gs0xex")

@onready var main = $"../.."

@onready var prebuilt = get_meta("prebuilt")

@onready var wheel_collider
@onready var wheel_sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	if prebuilt:
		wheel_collider = get_node(get_meta("whitbox"))
		wheel_sprite = get_node(get_meta("wsprite"))

func _on_body_entered(body):
	if "damage_value" in body:
		# Spawn debris
		var debris_instance = DEBRIS.instantiate()
		main.call_deferred("add_child", debris_instance)
		#main.add_child(debris_instance)
		debris_instance.global_position = global_position
		if wheel_collider != null:
			wheel_collider.call_deferred("queue_free")
		if wheel_sprite != null:
			wheel_sprite.call_deferred("queue_free")
		self.queue_free()
