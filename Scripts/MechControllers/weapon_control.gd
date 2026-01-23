extends Node2D

@onready var mech = $"../.."

@onready var area = $Area
@onready var hitbox = $Area/Hitbox
@onready var sprite = $Sprite
@onready var interaction_label = $InteractionLabel

@onready var cooldown = $Cooldown
@onready var cooldown_bar = $Cooldown/CooldownBar
@onready var timer = $Cooldown/Timer

@onready var gun = $"../../Weapons/Gun"

var controlled_weapon
var cooldown_time : float = 20
var on_cooldown : bool = false

var player_in_range : bool = false
var player = null
var last_zoom : Vector2 = Vector2(1, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup which gun node this will control here
	# *Control code here*
	controlled_weapon = gun # placeholder
	
	timer.timeout.connect(_on_cooldown_timeout)
	
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	interaction_label.text = get_meta("labeltext")

func _process(delta):
	var time_elapsed = cooldown_time - timer.time_left
	var time_percentage_left = time_elapsed / cooldown_time * cooldown_bar.max_value
	cooldown_bar.value = cooldown_bar.max_value - time_percentage_left

func _unhandled_input(event):
	if player_in_range and not on_cooldown:
		if event.is_action_pressed("interact"):
			if not player.minigame_mode:
				player.start_minigame("quicktime_arrow", controlled_weapon)
				start_cooldown()
			else:
				player.end_minigame()

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
