extends Area2D

@onready var mech = $"../../.."

@onready var hitbox = $Hitbox
@onready var interaction_label = $InteractionLabel

@onready var cooldown = $Cooldown
@onready var cooldown_bar = $Cooldown/CooldownBar
@onready var timer = $Cooldown/Timer

var controlled_module
var controlled_module_index
var cooldown_time : float
var on_cooldown : bool = false
var energy_cost : int 

var player_in_range : bool = false
var player = null
var last_zoom : Vector2 = Vector2(1, 1)

@onready var type : MechData.ObjectType = MechData.ObjectType.CONTROLLER
@onready var npc_controllable : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.timeout.connect(_on_cooldown_timeout)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	interaction_label.text = get_meta("labeltext")
	arm(get_parent())
	start_cooldown()

func _process(_delta):
	var time_elapsed = cooldown_time - timer.time_left
	var time_percentage_left = time_elapsed / cooldown_time * cooldown_bar.max_value
	cooldown_bar.value = cooldown_bar.max_value - time_percentage_left

func _unhandled_input(event):
	if player_in_range and not on_cooldown and controlled_module != null:
		if event.is_action_pressed("interact"):
			if mech.energy < energy_cost:
				print("INSUFFICIENT ENERGY")
				return
			if not player.minigame_mode:
				mech.drain_energy(energy_cost)
				#player.start_minigame("quicktime_arrow", controlled_module)
				controlled_module.engage()
				start_cooldown()
			else:
				player.end_minigame()

const OFFSET : Vector2 = Vector2(0, -15)
func arm(module):
	controlled_module = module
	controlled_module_index = module.index
	cooldown_time = module.cooldown_time
	energy_cost = module.energy_cost
	module.controller = self

func disarm():
	print("Module " + controlled_module.name + " has been destroyed!")
	controlled_module = null
	controlled_module_index = null

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
	start_cooldown()
	if mech.energy < energy_cost:
		print("INSUFFICIENT ENERGY TO AUTOENGAGE")
		return
	if mech.has_method("drain_energy"):
		mech.drain_energy(energy_cost)
	if controlled_module:
		controlled_module.engage()

func start_cooldown():
	on_cooldown = true
	cooldown_bar.show()
	timer.start(cooldown_time + (randf_range(-1, 3)))

func npc_engage():
	if mech.energy < energy_cost:
		print("INSUFFICIENT ENERGY")
		return
	mech.drain_energy(energy_cost)
	controlled_module.engage()
	start_cooldown()
