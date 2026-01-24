extends Area2D

@onready var mech = $"../.."

@onready var hitbox = $Hitbox
@onready var sprite = $Sprite
@onready var interaction_label = $InteractionLabel

var player_in_range : bool = false
var direction : int

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	interaction_label.text = get_meta("labeltext")
	direction = get_meta("direction")

func _unhandled_input(event):
	if player_in_range:
		if event.is_action_pressed("interact"):
			mech.direction = direction
			

func _on_body_entered(body):
	if body.name == "Player":
		interaction_label.visible = true
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		interaction_label.visible = false
		player_in_range = false
