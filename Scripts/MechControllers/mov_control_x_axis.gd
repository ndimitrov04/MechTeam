extends Area2D

@onready var mech = $"../.."

@onready var hitbox = $Hitbox
@onready var sprite = $Sprite
@onready var interaction_label = $InteractionLabel

@onready var engage = $SFX/Engage

var controlled_module_index

var player_in_range : bool = false

@onready var type : MechData.ObjectType = MechData.ObjectType.CONTROLLER

# Tutorial hooks
signal interacted_with()

var first_interaction : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event):
	if player_in_range:
		if event.is_action_pressed("interact"):
			# Main functionality
			var direction = get_meta("direction")
			mech.direction = direction
			engage.play()
			# Tutorial functionality
			if first_interaction:
				interacted_with.emit()
				first_interaction = false

func _on_body_entered(body):
	if body.name == "Player":
		var direction = get_meta("direction")
		match direction:
			0:
				interaction_label.text = "Brake"
			-1:
				interaction_label.text = "Go Left"
			1:
				interaction_label.text = "Go Right"
		interaction_label.visible = true
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		interaction_label.visible = false
		player_in_range = false
