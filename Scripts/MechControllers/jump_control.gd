extends Node2D

@onready var mech = $"../.."

@onready var area = $Area
@onready var hitbox = $Area/Hitbox
@onready var sprite = $Sprite
@onready var interaction_label = $InteractionLabel

var player_in_range : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	interaction_label.text = get_meta("labeltext")

func _unhandled_input(event):
	if player_in_range:
		if event.is_action_pressed("interact"):
			mech.jump = true

func _on_body_entered(body):
	if body.name == "Player":
		interaction_label.visible = true
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		interaction_label.visible = false
		player_in_range = false
