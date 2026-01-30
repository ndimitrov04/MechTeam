extends Area2D

@onready var mech = $"../.."

@onready var hitbox = $Hitbox
@onready var connector = $Connector
@onready var connection_marker = $ConnectionMarker
@onready var sprite = $Sprite
@onready var interaction_label = $InteractionLabel

@onready var cooldown = $Cooldown
@onready var cooldown_bar = $Cooldown/CooldownBar
@onready var timer = $Cooldown/Timer

var controlled_weapon
var cooldown_time : float
var on_cooldown : bool = false
var energy_cost : int 

var player_in_range : bool = false
var player = null
var last_zoom : Vector2 = Vector2(1, 1)

@onready var type : MechData.ObjectType = MechData.ObjectType.CONTROLLER

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.timeout.connect(_on_cooldown_timeout)
	connection_marker.set_process(false)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	interaction_label.text = get_meta("labeltext")

func _process(_delta):
	var time_elapsed = cooldown_time - timer.time_left
	var time_percentage_left = time_elapsed / cooldown_time * cooldown_bar.max_value
	cooldown_bar.value = cooldown_bar.max_value - time_percentage_left

func _unhandled_input(event):
	if player_in_range and not on_cooldown and controlled_weapon != null:
		if event.is_action_pressed("interact"):
			if mech.energy < energy_cost:
				print("INSUFFICIENT ENERGY")
				return
			if not player.minigame_mode:
				mech.energy -= energy_cost
				player.start_minigame("quicktime_arrow", controlled_weapon)
				start_cooldown()
			else:
				player.end_minigame()

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and mech.mech_edit:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Activating terminal connection mode...")
			if controlled_weapon != null:
				print("Terminal disconnected from: " + controlled_weapon.name)
				controlled_weapon = null
			connector.clear_points()
			connector.add_point(Vector2(0,0))
			connection_marker.show()
			connection_marker.set_process(true)
			print("Terminal set as active for connection")
			mech.current_terminal = self

const OFFSET : Vector2 = Vector2(0, -15)
func arm(weapon):
	controlled_weapon = weapon
	cooldown_time = weapon.cooldown_time
	energy_cost = weapon.energy_cost
	connector.add_point(weapon.global_position - self.global_position + OFFSET)
	connection_marker.hide()
	connection_marker.set_process(false)

func _on_body_entered(body):
	if body.name == "Player":
		interaction_label.visible = true
		player_in_range = true
		player = body

func _on_body_exited(body):
	if body.name == "Player":
		interaction_label.visible = false
		if player.minigame_mode:
			player.end_minigame()
		player_in_range = false
		player = null

func _on_cooldown_timeout():
	on_cooldown = false
	cooldown_bar.hide()

func start_cooldown():
	on_cooldown = true
	cooldown_bar.show()
	timer.start(cooldown_time)
