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
	
@onready var mod_label: Label = $ModLabel
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if has_meta("enemy_mod"):
		if Input.is_action_pressed("scan"):
			mod_label.show()
			sprite.material.set_shader_parameter("color", Color(1, 0, 0))
		else:
			mod_label.hide()
			sprite.material.set_shader_parameter("color", Color(1, 1, 1))
	else:
		if Input.is_action_pressed("scan"):
			interaction_label.show()
		elif not player_in_range:
			interaction_label.hide()

func _unhandled_input(event):
	if player_in_range:
		if event.is_action_pressed("interact"):
			# Main functionality
			var direction = get_meta("direction")
			mech.direction = direction
			engage.play()
			# Tutorial functionality
			interacted_with.emit()

func _on_body_entered(body):
	if body.name == "Player":
		var direction = get_meta("direction")
		match direction:
			0:
				interaction_label.text = "Brake"
				show_interaction_prompt(true, "Press F to Brake")
			-1:
				interaction_label.text = "Go Left"
				show_interaction_prompt(true, "Press F to Go Left")
			1:
				interaction_label.text = "Go Right"
				show_interaction_prompt(true, "Press F to Go Right")
		interaction_label.visible = true
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		interaction_label.visible = false
		player_in_range = false
		var direction = get_meta("direction")
		match direction:
			0:
				show_interaction_prompt(false, "Press F to Brake")
			-1:
				show_interaction_prompt(false, "Press F to Go Left")
			1:
				show_interaction_prompt(false, "Press F to Go Right")

func show_interaction_prompt(shown : bool, interaction_prompt : String):
	if shown:
		mech.get_parent().minigame_result.modulate = Color(1,1,1,1)
		mech.get_parent().minigame_result.add_theme_color_override("font_color", Color("6a7cb4ff"))
		mech.get_parent().minigame_result.text = interaction_prompt
		mech.get_parent().minigame_result.show()
	else:
		if mech.get_parent().minigame_result.text == interaction_prompt:
			mech.get_parent().minigame_result.hide()
